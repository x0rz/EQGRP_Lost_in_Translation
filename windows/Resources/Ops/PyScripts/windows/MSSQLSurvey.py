
import dsz, os, shutil, subprocess, dsz.windows, dsz.lp, sys, random
instanceList = list()
defaultInstanceOnly = True
workingInstance = 0
instanceReg = ''
serverString = 'localhost'
workingDatabase = ''
instanceVersion = ''
instanceAuditLevel = ''
instanceLoginMode = ''
SQLdirectory = ''
SQLresults = list()
pre9 = False
useOSQL = False
useSQLCMD = False
foundOSQL = False
foundSQLCMD = False
pathOSQL = ''
pathSQLCMD = ''
useInputFile = False
inputFilePath = ''
outputToFile = False
outFile = ''
NPenabled = False
TCPenabled = False
currentCmdName = ''

def getInstances():
    try:
        instances = dsz.windows.registry.GetValue('L', 'SOFTWARE\\Microsoft\\Microsoft SQL Server', 'InstalledInstances')
    except RuntimeError as details:
        return
    for entry in instances:
        instanceList.append((entry, entry))

def chooseInstance():
    print 'There are multiple SQL Server instances on this server.'
    print 'Choose the instance you want to query:'
    for i in xrange(len(instanceList)):
        print ((('\t [' + str(i)) + ']') + instanceList[i][0])
    print '\n'
    instanceChoice = int(input())
    print instanceChoice
    if (instanceChoice >= len(instanceList)):
        print '\t !!! You chose an invalid instance, choose again !!!'
        chooseInstance()
    global workingInstance
    workingInstance = instanceChoice

def getCurrentVersion():
    try:
        currentVersion = dsz.windows.registry.GetValue('L', (('SOFTWARE\\Microsoft\\MSSQLServer\\' + instanceList[workingInstance][1]) + '\\CurrentVersion'), 'CurrentVersion')
    except RuntimeError as details:
        if (details[0].find('Registry query failed') != (-1)):
            try:
                currentVersion = dsz.windows.registry.GetValue('L', (('SOFTWARE\\Microsoft\\Microsoft SQL Server\\' + instanceList[workingInstance][1]) + '\\MSSQLServer\\CurrentVersion'), 'CurrentVersion')
            except RuntimeError as details:
                if (details[0].find('Registry query failed') != (-1)):
                    print ''
    if currentVersion[0].startswith('8.00', 0, 4):
        global pre9
        pre9 = True
    else:
        try:
            instanceID = dsz.windows.registry.GetValue('L', 'SOFTWARE\\Microsoft\\Microsoft SQL Server\\Instance Names\\SQL', instanceList[workingInstance][1])
        except RuntimeError as details:
            if (details[0].find('Registry query failed') != (-1)):
                print ''
    global instanceReg
    if (pre9 & (instanceList[workingInstance][1] == 'MSSQLSERVER')):
        instanceReg = 'SOFTWARE\\Microsoft\\MSSQLServer\\'
    elif pre9:
        instanceReg = ('SOFTWARE\\Microsoft\\Microsoft SQL Server\\' + instanceList[workingInstance][1])
    else:
        instanceReg = ('SOFTWARE\\Microsoft\\Microsoft SQL Server\\' + instanceID[0])
    if (pre9 == False):
        editionKey = (instanceReg + '\\Setup')
        edition = dsz.windows.registry.GetValue('L', editionKey, 'Edition')
    if currentVersion[0].startswith('10.0', 0, 4):
        return ((currentVersion[0] + ' - SQL Server 2008 ') + edition[0])
    elif currentVersion[0].startswith('9.00', 0, 4):
        return ((currentVersion[0] + ' - SQL Server 2005 ') + edition[0])
    elif currentVersion[0].startswith('8.00', 0, 4):
        return (currentVersion[0] + ' - SQL Server 2000 ')
    else:
        return 'unknown SQL Server version'

def getAuditLevel():
    auditKey = (instanceReg + '\\MSSQLServer')
    auditLevel = dsz.windows.registry.GetValue('L', auditKey, 'AuditLevel')
    if (auditLevel[0] == '0'):
        return '0 - no auditing'
    elif (auditLevel[0] == '1'):
        return '1 - successful logons'
    elif (auditLevel[0] == '2'):
        return '2 - failed logons'
    elif (auditLevel[0] == '3'):
        return '3 - successful and failed logons'
    else:
        return "couldn't get audit setting"

def getLoginMode():
    loginModeKey = (instanceReg + '\\MSSQLServer')
    loginMode = dsz.windows.registry.GetValue('L', loginModeKey, 'LoginMode')
    if (loginMode[0] == '0'):
        return '0 - mixed mode'
    elif (loginMode[0] == '1'):
        return '1 - integrated mode'
    elif (loginMode[0] == '2'):
        return '2 - mixed mode'
    else:
        return "couldn't get login mode"

def getSQLProgramDir():
    progDirKey = (instanceReg + '\\Setup')
    if (pre9 == False):
        progDirKey = dsz.windows.registry.GetValue('L', progDirKey, 'SqlProgramDir')
    else:
        progDirKey = dsz.windows.registry.GetValue('L', progDirKey, 'SQLPath')
    rootSQLdir = progDirKey[0][0:progDirKey[0].rfind('\\')]
    return rootSQLdir

def getNamedPipe():
    namedPipeKey = (instanceReg + '\\MSSQLServer\\SuperSocketNetLib\\Np')
    namedPipe = dsz.windows.registry.GetValue('L', namedPipeKey, 'PipeName')
    return namedPipe[0]

def getTCPPort():
    if (pre9 == True):
        TCPKey = (instanceReg + '\\MSSQLServer\\SuperSocketNetLib\\Tcp')
        port = dsz.windows.registry.GetValue('L', TCPKey, 'TcpPort')
        return port[0]
    else:
        TCPKey = (instanceReg + '\\MSSQLServer\\SuperSocketNetLib\\Tcp\\IPALL')
        port = dsz.windows.registry.GetValue('L', TCPKey, 'TcpPort')
        return port[0]

def getProtocols():
    global TCPenabled
    global NPenabled
    if pre9:
        protoKey = (instanceReg + '\\MSSQLServer\\SuperSocketNetLib')
        protos = dsz.windows.registry.GetValue('L', protoKey, 'ProtocolList')
        for item in protos:
            if (item == 'tcp'):
                TCPenabled = True
            elif (item == 'np'):
                NPenabled = True
    else:
        namedPipeKey = (instanceReg + '\\MSSQLServer\\SuperSocketNetLib\\Np')
        NP = dsz.windows.registry.GetValue('L', namedPipeKey, 'Enabled')
        if (NP[0] == '1'):
            NPenabled = True
        tcpKey = (instanceReg + '\\MSSQLServer\\SuperSocketNetLib\\Tcp')
        TCP = dsz.windows.registry.GetValue('L', tcpKey, 'Enabled')
        if (TCP[0] == '1'):
            TCPenabled = True

def findOSQL():
    dsz.cmd.Run((('dir -mask osql.exe -path "' + SQLdirectory) + '" -recursive -max 0'), dsz.RUN_FLAG_RECORD)
    try:
        toolPath = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
        global pathOSQL
        pathOSQL = toolPath[0]
        return True
    except RuntimeError as details:
        if (details[0].find('Failed to find STRING diritem::path') != (-1)):
            return False

def findSQLCMD():
    dsz.cmd.Run((('dir -mask sqlcmd.exe -path "' + SQLdirectory) + '" -recursive -max 0'), dsz.RUN_FLAG_RECORD)
    try:
        toolPath = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
        global pathSQLCMD
        pathSQLCMD = toolPath[0]
        return True
    except RuntimeError as details:
        if (details[0].find('Failed to find STRING diritem::path') != (-1)):
            return False

def findERRORLOG():
    dsz.cmd.Run((('dir -mask ERRORLOG -path "' + SQLdirectory) + '" -recursive -max 0'), dsz.RUN_FLAG_RECORD)
    try:
        errorlogPath = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
        size = dsz.cmd.data.Get('diritem::fileitem[0]::size', dsz.TYPE_INT)
        print (((('\t ERRORLOG path - ' + errorlogPath[0]) + ' - current size ') + str(size[0])) + ' bytes')
    except RuntimeError as details:
        if (details[0].find('Failed to find STRING diritem::path') != (-1)):
            print "\t couldn't find ERRORLOG"

def querySQL(qString):
    output = list()
    runCMD = 'log run -command "'
    if useSQLCMD:
        runCMD = (((((runCMD + '\\"') + pathSQLCMD) + '\\sqlcmd.exe\\" -S ') + serverString) + ' -E -s , -W')
    elif useOSQL:
        runCMD = (((((runCMD + '\\"') + pathOSQL) + '\\osql.exe\\" -S ') + serverString) + ' -E -s , -w 500')
    else:
        runCMD = (((runCMD + 'osql.exe -S ') + serverString) + ' -E -s , -w 500')
    if (workingDatabase != ''):
        runCMD = ((runCMD + ' -d ') + workingDatabase)
    if outputToFile:
        runCMD = (((runCMD + ' -o \\"') + outFile) + '\\"')
    if useInputFile:
        runCMD = (((runCMD + ' -i \\"') + qString) + '\\" " -redirect')
    else:
        runCMD = (((runCMD + ' -Q \\"') + qString) + '\\" " -redirect')
    print (runCMD + '\n')
    dsz.cmd.Run(runCMD, dsz.RUN_FLAG_RECORD)
    if (outputToFile == False):
        try:
            outString = dsz.cmd.data.Get('processoutput::output', dsz.TYPE_STRING)
        except RuntimeError as details:
            if (details[0].find('Failed to find STRING processoutput::output') != (-1)):
                print 'ERROR: Could not parse SQL output. Likely due to special characters.\n'
                return
        cmdID = dsz.cmd.LastId()
        for entry in outString:
            item = entry.split('\n')
            for it in item:
                output.append(it)
        moveLogToGetFiles(cmdID)
        return output
    else:
        return ''

def moveLogToGetFiles(cmdID):
    logPath = (dsz.lp.GetLogsDirectory() + '\\Logs')
    getFilesPath = (dsz.lp.GetLogsDirectory() + '\\GetFiles')
    if (not os.path.exists(getFilesPath)):
        os.mkdir(getFilesPath)
    logDir = os.listdir(logPath)
    for file in logDir:
        if (file.find((str(cmdID) + '-run')) != (-1)):
            logFile = file
            break
    tmpCmdName = checkCmdFileName()
    completeOutputFileName = (((((((getFilesPath + '\\MSSQLQuery_') + workingDatabase) + '_') + tmpCmdName) + '_') + str(random.randint(1, 100000))) + '.txt')
    shutil.copy2(((logPath + '\\') + logFile), completeOutputFileName)
    stripFile(completeOutputFileName)

def checkCmdFileName():
    tmpCmdName = currentCmdName
    tmpCmdName = tmpCmdName.replace('/', '-')
    tmpCmdName = tmpCmdName.replace('\\', '-')
    tmpCmdName = tmpCmdName.replace(':', '-')
    tmpCmdName = tmpCmdName.replace('*', '-')
    tmpCmdName = tmpCmdName.replace('?', '-')
    tmpCmdName = tmpCmdName.replace('"', '-')
    tmpCmdName = tmpCmdName.replace('>', '-')
    tmpCmdName = tmpCmdName.replace('<', '-')
    tmpCmdName = tmpCmdName.replace('|', '-')
    return tmpCmdName

def stripFile(completeOutputFileName):
    if (not pre9):
        return
    rawOutputFile = open(completeOutputFileName, 'r')
    rawLines = rawOutputFile.readlines()
    rawOutputFile.close()
    fixedOutputFile = open((completeOutputFileName + '_fixed.txt'), 'a')
    for line in rawLines:
        if (not line.startswith('\t')):
            fixedOutputFile.write('\n')
        lineList = line.split(',')
        newLine = ''
        for item in lineList:
            item = item.strip()
            newLine = ((newLine + ',') + item)
        newLine = newLine.strip()[1:]
        fixedOutputFile.write(newLine)
    print ('This is a pre-MSSQL v9 installation, so we cleaned the output up a little and dumped it in: %sfixed\n' % completeOutputFileName)

def printAndClearResults():
    for entry in SQLresults:
        print entry
    del SQLresults[:]

def clearResults():
    del SQLresults[:]

def listDBs():
    qString = 'select name, crdate, filename from sysdatabases'
    global currentCmdName
    currentCmdName = 'ListDBs'
    p = querySQL(qString)
    parseSQLresults(p)
    printAndClearResults()

def tblListRowCnt():
    qString = "select o.name, i.rows from sysobjects o, sysindexes i where o.type = 'U' and o.id = i.id and i.indid in (0,1) order by o.name"
    global currentCmdName
    currentCmdName = 'TableListingAndRowCount'
    p = querySQL(qString)
    parseSQLresults(p)
    clearResults()

def tblANDcol():
    if (pre9 == False):
        qString = 'select TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_DEFAULT, IS_NULLABLE, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH from information_schema.columns'
    else:
        qString = "select o.name as 'table', c.name as 'column', t.name as 'type', c.length, c.isnullable from sysobjects o, syscolumns c, systypes t where o.type = 'U' and o.id = c.id and t.xtype = c.xtype and t.name != 'sysname' order by o.name"
    global currentCmdName
    currentCmdName = 'TablesAndColumns'
    p = querySQL(qString)
    parseSQLresults(p)
    clearResults()

def userInfo():
    if (pre9 == False):
        qString = 'SELECT TOP 1000 loginname, language, isntname, isntgroup, isntuser, sysadmin, dbname FROM sys.syslogins where hasaccess = 1'
    else:
        qString = 'SELECT TOP 1000 loginname, language, isntname, isntgroup, isntuser, sysadmin, dbname FROM master.dbo.syslogins where hasaccess = 1'
    global currentCmdName
    currentCmdName = 'UserInfo'
    p = querySQL(qString)
    parseSQLresults(p)
    clearResults()

def dbConfiguration():
    if (pre9 == False):
        qString = 'SELECT TOP 1000 name, value, minimum, maximum, value_in_use, description, is_dynamic, is_advanced FROM sys.configurations'
    else:
        qString = 'SELECT TOP 1000 value, config, comment, status FROM master.dbo.sysconfigures'
    global currentCmdName
    currentCmdName = 'DBConfig'
    p = querySQL(qString)
    parseSQLresults(p)
    clearResults()

def listViews():
    if (pre9 == False):
        qString = 'SELECT * FROM INFORMATION_SCHEMA.VIEWS'
    else:
        qString = "select o.name, c.text from sysobjects o, syscomments c where o.id = c.id and o.xtype = 'V'"
    global currentCmdName
    currentCmdName = 'Views'
    p = querySQL(qString)
    parseSQLresults(p)
    clearResults()

def top10Rows():
    qString = "select o.name from sysobjects o, sysindexes i where o.type = 'U' and o.id = i.id and i.indid in (0,1) and i.rowcnt > 0 order by o.name"
    global currentCmdName
    currentCmdName = 'preQueryForTop10_'
    p = querySQL(qString)
    parseSQLresults(p)
    for entry in SQLresults[2:len(SQLresults)]:
        if (pre9 == False):
            qString = (("select distinct(column_name) from information_schema.columns where table_name = '" + entry) + "' and character_maximum_length != -1 and character_maximum_length < 50000")
        else:
            qString = (("select distinct(c.name) from sysobjects o, syscolumns c, systypes t where o.name = '" + entry) + "' and o.id = c.id and t.xtype = c.xtype and t.name != 'sysname' and c.length != -1 and c.length < 50000")
        currentCmdName = ('preQueryForTop10_' + entry)
        p = querySQL(qString)
        colList = ''
        for col in p:
            col = col.strip()
            if (col == ''):
                break
            elif ((col != 'column_name') & (col.find('---') == (-1))):
                colList = ((colList + ', ') + col)
        if list(entry).count(' '):
            print 'We have a space in the table name, must get the schema for that table to prepend to it'
            qString = ("select TABLE_SCHEMA from information_schema.columns where TABLE_NAME = '%s'" % entry)
            print qString
            p = querySQL(qString)
            schema = p[2]
            entry = ('%s.[%s]' % (schema, entry))
        if (pre9 == False):
            qString = ((('select top 10 ' + colList[2:len(colList)]) + ' from ') + entry)
        else:
            qString = ((('select top 10 ' + colList[8:len(colList)]) + ' from ') + entry)
        currentCmdName = ('Top10_' + entry)
        print qString
        p = querySQL(qString)
        for entry in p:
            entry = entry.strip()
            if (entry == ''):
                break
        print '\n'

def customQuery():
    global outputToFile
    print 'bypass saftey checks? ([n]/y)'
    bypass = raw_input()
    bypass = str(bypass)
    print bypass
    print 'enter your query'
    qString = raw_input()
    qString = str(qString)
    qString = qString.lower()
    print qString
    if (bypass != 'y'):
        if (qString.find('drop') != (-1)):
            print 'illegal word found: drop'
        elif (qString.find('update') != (-1)):
            print 'illegal word found: update'
        elif (qString.find('insert') != (-1)):
            print 'illegal word found: insert'
        elif (qString.find('truncate') != (-1)):
            print 'illegal word found: truncate'
        elif (qString.find('create') != (-1)):
            print 'illegal word found: create'
        elif (qString.find('merge') != (-1)):
            print 'illegal word found: merge'
        elif (qString.find('grant') != (-1)):
            print 'illegal word found: grant'
        elif (qString.find('revoke') != (-1)):
            print 'illegal word found: revoke'
        elif (qString.find('alter') != (-1)):
            print 'illegal word found: alter'
        else:
            outputToFile = True
            setupOutputFile()
            p = querySQL(qString)
            outputToFile = False
            getOutputFile('_customQuery_')
    else:
        outputToFile = True
        setupOutputFile()
        p = querySQL(qString)
        outputToFile = False
        getOutputFile('_customQuery_')

def inputFileQuery():
    global useInputFile
    useInputFile = True
    tgtTEMPpath = ''
    print 'Enter the path for the input file: \n'
    global inputFilePath
    inputFilePath = str(raw_input())
    print inputFilePath
    inFile = open(inputFilePath, 'r')
    for line in inFile:
        if (line.find('drop') != (-1)):
            print 'illegal word found: drop'
            inFile.close()
            return
        elif (line.find('update') != (-1)):
            print 'illegal word found: update'
            inFile.close()
            return
        elif (line.find('insert') != (-1)):
            print 'illegal word found: insert'
            inFile.close()
            return
        elif (line.find('truncate') != (-1)):
            print 'illegal word found: truncate'
            inFile.close()
            return
        elif (line.find('create') != (-1)):
            print 'illegal word found: create'
            inFile.close()
            return
        elif (line.find('merge') != (-1)):
            print 'illegal word found: merge'
            inFile.close()
            return
        elif (line.find('grant') != (-1)):
            print 'illegal word found: grant'
            inFile.close()
            return
        elif (line.find('revoke') != (-1)):
            print 'illegal word found: revoke'
            inFile.close()
            return
        elif (line.find('alter') != (-1)):
            print 'illegal word found: alter'
            inFile.close()
            return
        else:
            continue
    inFile.close()
    dsz.cmd.Run('environment -get', dsz.RUN_FLAG_RECORD)
    nameList = dsz.cmd.data.Get('environment::value::name', dsz.TYPE_STRING)
    valueList = dsz.cmd.data.Get('environment::value::value', dsz.TYPE_STRING)
    i = 0
    for name in nameList:
        if (name == 'TEMP'):
            tgtTEMPpath = valueList[i]
            break
        i = (i + 1)
    if (tgtTEMPpath == ''):
        print "couldn't find the target's %TEMP%\n"
        print 'enter the path to use\n'
        tgtTEMPpath = str(raw_input())
        print tgtTEMPpath
    dsz.cmd.Run((((('put ' + inputFilePath) + ' -name ') + tgtTEMPpath) + '\\TRF3AD8.tmp'), dsz.RUN_FLAG_RECORD)
    dir = dsz.cmd.Run((('dir -mask TRF3AD8.tmp -path "' + tgtTEMPpath) + '"'), dsz.RUN_FLAG_RECORD)
    try:
        dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
    except RuntimeError as details:
        if (details[0].find('Failed to find STRING diritem::path') != (-1)):
            print "couldn't find input file in tgt\n"
            return False
    global currentCmdName
    currentCmdName = 'InputFile'
    p = querySQL((tgtTEMPpath + '\\TRF3AD8.tmp'))
    parseSQLresults(p)
    clearResults()
    useInputFile = False
    dsz.cmd.Run((('delete -file ' + tgtTEMPpath) + '\\TRF3AD8.tmp'), dsz.RUN_FLAG_RECORD)

def setupOutputFile():
    global outFile
    dsz.cmd.Run('environment -get', dsz.RUN_FLAG_RECORD)
    nameList = dsz.cmd.data.Get('environment::value::name', dsz.TYPE_STRING)
    valueList = dsz.cmd.data.Get('environment::value::value', dsz.TYPE_STRING)
    i = 0
    for name in nameList:
        if (name == 'TEMP'):
            tgtTEMPpath = valueList[i]
            break
        i = (i + 1)
    if (tgtTEMPpath == ''):
        print "couldn't find the target's %TEMP%\n"
        print 'enter the path to use\n'
        tgtTEMPpath = str(raw_input())
        print tgtTEMPpath
    dir = dsz.cmd.Run((('dir -mask TRF3AD8.tmp -path "' + tgtTEMPpath) + '"'), dsz.RUN_FLAG_RECORD)
    try:
        dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
        print '\n output file already exists\n'
        print 'would you like to delete it? ([y]/n)\n'
        ans = str(raw_input())
        if (((ans.lower() == 'y') | (ans.lower() == 'yes')) | (ans.lower() == '')):
            dsz.cmd.Run((('delete -file ' + tgtTEMPpath) + '\\TRF3AD8.tmp'), dsz.RUN_FLAG_RECORD)
            outFile = (tgtTEMPpath + '\\TRF3AD8.tmp')
    except RuntimeError as details:
        if (details[0].find('Failed to find STRING diritem::path') != (-1)):
            outFile = (tgtTEMPpath + '\\TRF3AD8.tmp')

def getOutputFile(outputName):
    dsz.cmd.Run((('dir "' + outFile) + '"'), dsz.RUN_FLAG_RECORD)
    size = dsz.cmd.data.Get('diritem::fileitem[0]::size', dsz.TYPE_INT)
    print (('the file is ' + str(size[0])) + ' bytes, would you like to download it? ([y]/n)')
    ans = str(raw_input())
    if (((ans.lower() == 'y') | (ans.lower() == 'yes')) | (ans.lower() == '')):
        dsz.cmd.Run((('get "' + outFile) + '"'), dsz.RUN_FLAG_RECORD)
        status = dsz.cmd.data.Get('filestop::successful', dsz.TYPE_BOOL)
        if status:
            print 'file downloaded\n'
            getFileName = dsz.cmd.data.Get('filelocalname::localname', dsz.TYPE_STRING)
            getFilePath = (dsz.lp.GetLogsDirectory() + '\\GetFiles')
            completeOutputFileName = (((((getFilePath + '\\MSSQLQuery_') + workingDatabase) + outputName) + str(random.randint(1, 100000))) + '.txt')
            shutil.move(((getFilePath + '\\') + getFileName[0]), completeOutputFileName)
            stripFile(completeOutputFileName)
        else:
            print 'the file was not downloaded\n'
    dsz.cmd.Run((('delete -file "' + outFile) + '"'), dsz.RUN_FLAG_RECORD)

def setConnString():
    global serverString
    print 'enter the connection string:\n'
    serverString = str(raw_input())
    print serverString

def setDB():
    qString = 'select name from master.dbo.sysdatabases'
    dbList = list()
    global workingDatabase
    workingDatabase = ''
    p = querySQL(qString)
    parseSQLresults(p)
    i = 0
    del SQLresults[0:2]
    print 'select the database:'
    for entry in SQLresults:
        if (entry != ''):
            display = ((('[' + str(i)) + ']') + entry)
            if (entry.find('master') != (-1)):
                display = (display + ' (default)')
            elif (entry.find('tempdb') != (-1)):
                display = (display + ' (default)')
            elif (entry.find('model') != (-1)):
                display = (display + ' (default)')
            elif (entry.find('msdb') != (-1)):
                display = (display + ' (default)')
            print display
            dbList.append(entry)
            i = (i + 1)
        else:
            continue
    del SQLresults[:]
    print '\n'
    dbChoice = int(input())
    print (('option ' + str(dbChoice)) + ' chosen\n')
    workingDatabase = dbList[dbChoice]

def parseSQLresults(results):
    for line in results:
        line = line.strip()
        line = line.replace('  ', '')
        if (line.find('rows affected)') != (-1)):
            break
        SQLresults.append(line)

def printMenu():
    print '\n'
    print ('workingDatabase: ' + workingDatabase)
    print 'choose a task'
    print '[1] list databases'
    print '[2] set working database'
    print 'set the working DB before choosing any of the options below'
    print '[3] table listing & row counts'
    print '[4] all table & column data (schema)'
    print '[5] get top 10 rows from all tables'
    print '[6] get user info'
    print '[7] get DB configuration'
    print '[8] get views'
    print "[9] enter a custom query (writes results to target's disk, use for large queries)"
    print '[10] enter an input file'
    print '[11] set custom connection string'
    print '[12] Default Query Plans'
    print ''
    print '[0] exit'
    print '\n'
    try:
        menuChoice = int(input())
    except:
        print 'Invalid option, exiting'
        exit(0)
    print (('option ' + str(menuChoice)) + ' chosen\n')
    return menuChoice

def evalMenuChoice(choice):
    if (choice == 1):
        listDBs()
        evalMenuChoice(printMenu())
    elif (choice == 2):
        setDB()
        evalMenuChoice(printMenu())
    elif (choice == 3):
        tblListRowCnt()
        evalMenuChoice(printMenu())
    elif (choice == 4):
        tblANDcol()
        evalMenuChoice(printMenu())
    elif (choice == 5):
        top10Rows()
        evalMenuChoice(printMenu())
    elif (choice == 6):
        userInfo()
        evalMenuChoice(printMenu())
    elif (choice == 7):
        dbConfiguration()
        evalMenuChoice(printMenu())
    elif (choice == 8):
        listViews()
        evalMenuChoice(printMenu())
    elif (choice == 9):
        customQuery()
        evalMenuChoice(printMenu())
    elif (choice == 10):
        inputFileQuery()
        evalMenuChoice(printMenu())
    elif (choice == 11):
        setConnString()
        evalMenuChoice(printMenu())
    elif (choice == 12):
        defaultQueryPlans()
        evalMenuChoice(printMenu())
    else:
        print 'Done'
        exit(0)

def kav6():
    queries = [['select * from v_hosts', '_KAV6_v_hosts_'], ['select * from hst_mac', '_KAV6_hst_mac_'], ['select * from nf_host', '_KAV6_nf_hosts_'], ['select * from NtDomains', '_KAV6_NtDomains_'], ['select * from DnsDomains', '_KAV6_DnsDomains_']]
    for query in queries:
        global outputToFile
        outputToFile = True
        setupOutputFile()
        p = querySQL(query[0])
        outputToFile = False
        getOutputFile(query[1])

def kav8():
    queries = [['select * from v_hosts', '_KAV8_v_hosts_'], ['select * from ak_users', '_KAV8_ak_users_'], ['select * from hst_loggedin_users', '_KAV8_hst_loggedin_users_'], ['select * from hst_mac', '_KAV8_hst_mac_'], ['select * from nf_host', '_KAV8_nf_host_'], ['select * from NtDomains', '_KAV8_NtDomains_'], ['select * from DnsDomains', '_KAV8_DnsDomains_'], ['select * from hst_inventory_patches', '_KAV8_hst_inventory_patches_'], ['select * from hst_inventory_hstpatches', '_KAV8_hst_inventory_hstpatches_'], ['select * from hst_inventory_products', '_KAV8_hst_inventory_products_'], ['select * from hst_inventory_hstprds', '_KAV8_hst_inventory_hstprds_']]
    for query in queries:
        global outputToFile
        outputToFile = True
        setupOutputFile()
        p = querySQL(query[0])
        outputToFile = False
        getOutputFile(query[1])

def defaultQueryPlans():
    choice = printDefaultQueryPlansMenu()
    if (choice == 1):
        kav6()
    elif (choice == 2):
        kav8()
    else:
        pass

def printDefaultQueryPlansMenu():
    print '\n'
    print 'choose a task'
    print '[1] Kaspersky Administration Server v6 survey'
    print '[2] Kaspersky Administration Server v8 survey'
    print ''
    print '[0] return'
    print '\n'
    try:
        menuChoice = int(input())
    except:
        print 'Invalid option, exiting'
        exit(0)
    print (('option ' + str(menuChoice)) + ' chosen\n')
    return menuChoice
dsz.control.echo.Off()
getInstances()
if (len(instanceList) > 1):
    defaultInstanceOnly = False
if (defaultInstanceOnly == False):
    chooseInstance()
if (instanceList[workingInstance][0] != 'MSSQLSERVER'):
    serverString = ('localhost\\' + instanceList[workingInstance][0])
instanceVersion = getCurrentVersion()
instanceAuditLevel = getAuditLevel()
instanceLoginMode = getLoginMode()
SQLdirectory = getSQLProgramDir()
foundOSQL = findOSQL()
foundSQLCMD = findSQLCMD()
getProtocols()
if (pre9 == True):
    useOSQL = True
print 'current script parameters:'
print ('\t active SQL Server instance: ' + instanceList[workingInstance][0])
print ('\t instance version: ' + instanceVersion)
print ('\t instance audit level: ' + instanceAuditLevel)
print ('\t instance login mode: ' + instanceLoginMode)
print ('\t SQL Server base directory: ' + SQLdirectory)
if TCPenabled:
    print ('\t TCP/IP is enabled - port:  ' + getTCPPort())
else:
    print '\t TCP/IP port was not found via the Registry. Try a netstat.'
if NPenabled:
    print ('\t NamedPipe is enabled - namedpipe:  ' + getNamedPipe())
else:
    print '\t NamedPipe was not found via the Registry. Try a netstat.'
if ((foundOSQL & foundSQLCMD) & (pre9 == False)):
    useSQLCMD = True
    useOSQL = False
    print (('\t using ' + pathSQLCMD) + '\\sqlcmd.exe')
elif (foundSQLCMD & (pre9 == False)):
    useSQLCMD = True
    print (('\t using ' + pathSQLCMD) + '\\sqlcmd.exe')
elif foundOSQL:
    useOSQL = True
    print (('\t using ' + pathOSQL) + '\\osql.exe')
else:
    print ('\t neither sqlcmd.exe or osql.exe was found under ' + SQLdirectory)
    print '\t \t try to find osql.exe elsewhere and cd to that dir'
findERRORLOG()
try:
    osAuditing = dsz.env.Get('OPS_AUDITOFF')
    if (osAuditing == 'TRUE'):
        print "\t OS auditing is off (not sure if it's just Security Log or all auditing though)"
    else:
        print '\t OS auditing is on'
except EnvironmentError as details:
    if (details[0].find('Failed to get env value') != (-1)):
        print "\t couldn't determint OS auditing status"
print 'given the information above, would you like to continue? ([y]/n)'
ans = str(raw_input())
print ans
if (((ans.lower() == 'y') | (ans.lower() == 'yes')) | (ans.lower() == '')):
    evalMenuChoice(printMenu())