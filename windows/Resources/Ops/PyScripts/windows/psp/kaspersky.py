
import sqlite3, dsz, dsz.lp, dsz.env, dsz.file, os, shutil, subprocess, re, StringIO, datetime, random, binascii, shared, ver_six, ver_nine, ver_eleven

def main():
    scriptVer = '1.0.0.6'
    logDir = dsz.lp.GetLogsDirectory()
    sysPid = 0
    usrPid = 0
    kasName = 'UNKNOWN'
    kasDescription = 'UNKNOWN'
    kasVersion = 'UNKNOWN'
    kasName = 'UNKNOWN'
    kasDescription = 'UNKNOWN'
    kasVersion = 'UNKNOWN'
    kasType = 'UNKNOWN'
    kasVerSplit = 'UNKNOWN'
    kasSubVersion = 'UNKNOWN'
    kasRoot = 'UNKNOWN'
    kasSubVersion = 'UNKNOWN'
    getFile = ''
    isWorkstation = False
    isInternetSec = False
    dbFile = (logDir + '\\target.db')
    con = sqlite3.connect(dbFile)
    con.row_factory = sqlite3.Row
    cur = con.cursor()
    cur.execute("SELECT NAME, DESCRIPTION, VERSION from applications where DESCRIPTION LIKE '%kaspersky%'")
    kasAppQuery = cur.fetchall()
    cur.execute("SELECT NAME, USER, PID, PATH from processlist where NAME like '%avp.exe'")
    kasProcQuery = cur.fetchall()
    cur.close
    con.close
    logDir = dsz.lp.GetLogsDirectory()
    kasXmlFilePtr = open((logDir + '\\kasperskyfile.xml'), 'w')
    myProc = shared.myProc()
    shared.safePrint('+---------------------------------------------------------------------------------')
    shared.safePrint('|   YOUR TARGET APPEARS TO BE RUNNING A KASPERSKYISH PSP!')
    shared.safePrint('|   FOLLOW WIKI GUIDELINES BASED ON VERSION AND TYPE LISTED BELOW!')
    shared.safePrint(('|   PLEASE REMEMBER YOUR PROCESS IS: ' + myProc))
    shared.safePrint(('|   SCRIPT VERSION: ' + scriptVer))
    shared.safePrint('+---------------------------------------------------------------------------------')
    if (2 != len(kasProcQuery)):
        shared.safePrint('|   I APPEAR TO HAVE ENCOUNTERED A PROBLEM WITH THE PROC TABLE QUERY RESULTS...')
        shared.safePrint(('|    THERE SHOULD BE 2 PROCESSES RUNNING; I SEE %d!!!' % len(kasProcQuery)))
        for a in range(len(kasProcQuery)):
            shared.safePrint(('|         %s\t\t%s\t\t%s' % (kasProcQuery[a][1], kasProcQuery[a][0], kasProcQuery[a][2])))
        if (0 == len(kasProcQuery)):
            shared.safePrint('|    NONE- WHY IS THIS SCRIPT RUNNING?!?!?!!?!?!')
            shared.safePrint('|    I AM EXITING BECAUSE I DO NOT THINK YOU HAVE KASPERSKY!')
            shared.safePrint('+---------------------------------------------------------------------------------')
            return False
        elif (1 == len(kasProcQuery)):
            shared.safePrint('|    I ONLY SEE ONE PROCESS RUNNING- THIS MAY BE BECAUSE NO USER IS LOGGED IN')
            shared.safePrint('|    REGARDLESSS, THIS IS NOT NORMAL, AND IF THIS IS KAS 2010 OR 2011 STOP NOW!')
        else:
            shared.safePrint('|    ADDITIONAL PROCESSES MAY BE DUE TO THE PRESENCE OF')
            shared.safePrint('|    AN UPDATE SERVER ON THIS BOX...')
            shared.safePrint('+---------------------------------------------------------------------------------')
        if (not dsz.ui.Prompt('ARE YOU SURE YOU WANT TO CONTINUE?', False)):
            return False
    if (1 != len(kasAppQuery)):
        shared.safePrint('+---------------------------------------------------------------------------------')
        shared.safePrint('|   I APPEAR TO HAVE ENCOUNTERED A PROBLEM WITH THE APP TABLE QUERY RESULTS...')
        shared.safePrint(('|   THERE SHOULD BE 1 APPLICATION INSTALLED; I SEE %d:' % len(kasAppQuery)))
        for a in range(len(kasAppQuery)):
            shared.safePrint(('|         %s' % kasAppQuery[a][0]))
        if (0 == len(kasAppQuery)):
            shared.safePrint('|        THERE ARE NO MATCHES...')
            shared.safePrint('|        CHANCES ARE GOOD THAT YOU ARE HERE BECAUSE YOUR BOX IS IN RUSSIAN...')
        else:
            shared.safePrint('|        YOU HAVE MULTIPLE KASPERSKY APPLICATIONS...')
            shared.safePrint('|        CHANCES ARE GOOD THAT YOU ARE HERE BECAUSE YOUR BOX IS AN UPDATE SERVER...')
        shared.safePrint('|   I HAVE FAILED TO FINGERPRINT WITH THE PRIMARY TECHNIQUE...')
        if dsz.ui.Prompt('WOULD YOU LIKE ME TO TRY AND FINGERPRINT USING REG KEYS (SECONDARY TECHNIQUE)?', True):
            shared.safePrint('|   QUERYING REGISTRY...')
            dsz.control.echo.Off()
            regCmd = 'registryquery -hive L -key software\\KasperskyLab\\protected'
            if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                regCmd = 'registryquery -hive L -key software\\KasperskyLab'
                shared.safePrint('FAILED FIRST REGQUERY')
                if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                    shared.errorBail(('FAILED TO RUN: ' + regCmd))
                    return True
            regName = dsz.cmd.data.Get('key::subkey::name', dsz.TYPE_STRING)
            numInstalls = 0
            for i in range(len(regName)):
                if (re.match('.*AVP.*', regName[i].upper()) and re.match('.*6.*', regName[i])):
                    numInstalls += 1
                    shared.safePrint('|   LOOKS LIKE KASPERSKY v6')
                    regCmd = 'registryquery -hive L -key software\\KasperskyLab\\AVP6\\settings\\ -value Ins_ProductVersion'
                    if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                        shared.errorBail(('FAILED TO RUN: ' + regCmd))
                        return True
                    tempVal = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
                    kasVersion = tempVal[0]
                    shared.safePrint(('|   VERSION: %s' % kasVersion))
                    regCmd = 'registryquery -hive L -key software\\KasperskyLab\\AVP6\\settings\\ -value Ins_ProductType'
                    if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                        shared.errorBail(('FAILED TO RUN: ' + regCmd))
                        return True
                    tempVal = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
                    kasType = tempVal[0]
                    shared.safePrint(('|   TYPE: %s' % kasType))
                if (re.match('.*AVP.*', regName[i].upper()) and re.match('.*80.*', regName[i])):
                    numInstalls += 1
                    shared.safePrint('|   LOOKS LIKE KASPERSKY v6 MP4')
                    regCmd = 'registryquery -hive L -key software\\KasperskyLab\\protected\\AVP80\\settings -value Ins_ProductVersion'
                    if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                        shared.errorBail(('FAILED TO RUN: ' + regCmd))
                        return True
                    tempVal = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
                    kasVersion = tempVal[0]
                    shared.safePrint(('|   VERSION: %s' % kasVersion))
                    regCmd = 'registryquery -hive L -key software\\KasperskyLab\\protected\\AVP80\\settings -value Ins_ProductType'
                    if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                        shared.errorBail(('FAILED TO RUN: ' + regCmd))
                        return True
                    tempVal = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
                    kasType = tempVal[0]
                    shared.safePrint(('|   TYPE: %s' % kasType))
                if (re.match('.*AVP.*', regName[i].upper()) and re.match('.*9.*', regName[i])):
                    numInstalls += 1
                    shared.safePrint('|   LOOKS LIKE KASPERSKY v9 (AKA KASPERSKY 2010)')
                    regCmd = 'registryquery -hive L -key software\\KasperskyLab\\protected\\avp9\\environment -value ProductVersion'
                    if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                        shared.errorBail(('FAILED TO RUN: ' + regCmd))
                        return True
                    tempVal = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
                    kasVersion = tempVal[0]
                    shared.safePrint(('|   VERSION: %s' % kasVersion))
                    regCmd = 'registryquery -hive L -key software\\KasperskyLab\\protected\\avp9\\environment -value ProductType'
                    if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                        shared.errorBail(('FAILED TO RUN: ' + regCmd))
                        return True
                    tempVal = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
                    kasType = tempVal[0]
                    shared.safePrint(('|   TYPE: %s' % kasType))
                    regCmd = 'registryquery -hive L -key software\\KasperskyLab\\protected\\avp9\\environment -value productroot'
                    if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                        shared.errorBail(('FAILED TO RUN: ' + regCmd))
                        return True
                    tempVal = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
                    kasRoot = tempVal[0]
                if (re.match('.*AVP.*', regName[i].upper()) and re.match('.*11.*', regName[i])):
                    numInstalls += 1
                    shared.safePrint('|   LOOKS LIKE KASPERSKY v11 (AKA KASPERSKY 2011)')
                    regCmd = 'registryquery -hive L -key software\\KasperskyLab\\protected\\avp11\\environment -value Ins_ProductVersion'
                    if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                        shared.errorBail(('FAILED TO RUN: ' + regCmd))
                        return True
                    tempVal = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
                    kasVersion = tempVal[0]
                    shared.safePrint(('|   VERSION: %s' % kasVersion))
                    regCmd = 'registryquery -hive L -key software\\KasperskyLab\\protected\\avp11\\environment -value Ins_ProductType'
                    if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                        shared.errorBail(('FAILED TO RUN: ' + regCmd))
                        return True
                    tempVal = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
                    kasType = tempVal[0]
                    regCmd = 'registryquery -hive L -key software\\KasperskyLab\\protected\\avp11\\environment -value productroot'
                    if (not dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD)):
                        shared.errorBail(('FAILED TO RUN: ' + regCmd))
                        return True
                    tempVal = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
                    kasRoot = tempVal[0]
                    shared.safePrint(('|   ROOT DIR: %s' % kasRoot))
            if (numInstalls > 1):
                shared.errorBail('THERE ARE MULTIPLE KASPERSKY PSPS ON THE BOX!!!')
                return True
            dsz.control.echo.On()
    else:
        kasName = kasAppQuery[0][0]
        kasDescription = kasAppQuery[0][1]
        kasVersion = kasAppQuery[0][2]
        kasType = kasProcQuery[0][0]
        kasRoot = kasProcQuery[0][3]
    if (re.match('.*WORKSTATION.*', kasName.upper()) or ('WKS' == kasType.upper())):
        shared.safePrint('|   IT APPEARS TO BE FOR WORKSTATIONS....')
        isWorkstation = True
    if (re.match('.*SECURITY.*', kasName.upper()) or ('KIS' == kasType.upper())):
        shared.safePrint('|   IT APPEARS TO BE INTERNET SECURITY....')
        isInternetSec = True
    for i in range(len(kasProcQuery)):
        if re.match('.*SYSTEM.*', kasProcQuery[i][1]):
            sysPid = kasProcQuery[i][2]
        if re.match('.*user.*', kasProcQuery[i][1]):
            usrPid = kasProcQuery[i][2]
    shared.safePrint(('|       PRODUCT NAME:             %s' % kasName))
    shared.safePrint(('|       VERSION:                  %s' % kasVersion))
    shared.safePrint(('|       SYSTEM PID:               %d' % usrPid))
    shared.safePrint(('|       USER PID:                 %d' % sysPid))
    shared.safePrint('+---------------------------------------------------------------------------------')
    if (kasVersion != ''):
        kasVerSplit = kasVersion.split('.')
        if (('6' == kasVerSplit[0]) and isWorkstation):
            if ('4' == kasVerSplit[2]):
                if dsz.ui.Prompt('MAY I CALL THE FUNCTION THAT HANDLES KASPERSKY 6 FOR WINDOWS WORKSTATIONS MP4?', True):
                    shared.safePrint('+---------------------------------------------------------------------------------')
                    shared.safePrint('|   CALLING FUNCTION TO HANDLE VERSION 6 MP4 FOR WINDOWS WORKSTATIONS....')
                    ver_six.kasVerSixMp4(kasName, kasDescription, kasVersion, kasRoot)
                else:
                    return False
            elif dsz.ui.Prompt('MAY I CALL THE FUNCTION THAT HANDLES KASPERSKY 6 FOR WINDOWS WORKSTATIONS (NOT MP4)?', True):
                shared.safePrint('+---------------------------------------------------------------------------------')
                shared.safePrint('|   CALLING FUNCTION TO HANDLE VERSION 6 FOR WINDOWS WORKSTATIONS (NOT MP4)....')
                ver_six.kasVerSix(kasName, kasDescription, kasVersion, kasRoot)
            else:
                return False
        elif (('9' == kasVerSplit[0]) and isInternetSec):
            if dsz.ui.Prompt('MAY I CALL THE FUNCTION THAT HANDLES KASPERSKY 9 (AKA 2010)?', True):
                shared.safePrint('+---------------------------------------------------------------------------------')
                shared.safePrint('|   CALLING FUNCTION TO HANDLE VERSION 9 (AKA 2010)....')
                ver_nine.kasVerNine(kasName, kasDescription, kasVersion, kasRoot)
            else:
                return False
        elif (('11' == kasVerSplit[0]) and isInternetSec):
            if dsz.ui.Prompt('MAY I CALL THE FUNCTION THAT HANDLES KASPERSKY 11 (AKA 2011)?', True):
                shared.safePrint('+---------------------------------------------------------------------------------')
                shared.safePrint('|   CALLING FUNCTION TO HANDLE VERSION 11 (AKA 2011)....')
                ver_eleven.kasVerEleven(kasName, kasDescription, kasVersion, kasRoot)
            else:
                return False
        else:
            shared.safePrint('|   -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-')
            shared.safePrint('|   THIS VERSION APPEARS TO BE UNSUPPORTED.  PLEASE HARASS THOSE RESPONSIBLE.')
            shared.safePrint('|   -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-')
            shared.safePrint('+---------------------------------------------------------------------------------')
            kasXmlFilePtr = open((logDir + '\\kasperskyfile.xml'), 'w')
            try:
                kasXmlFilePtr.write('<kaspersky_settings>\n')
                kasXmlFilePtr.write('<vendor>KASPERSKY</vendor>\n')
                kasXmlFilePtr.write((('<version>' + shared.xmlScrub(kasVersion)) + '</version>\n'))
                kasXmlFilePtr.write((('<description>' + shared.xmlScrub(kasName)) + '</vendor>\n'))
                kasXmlFilePtr.write((('<root>' + shared.xmlScrub(kasRoot)) + '</root>\n'))
                kasXmlFilePtr.write('</kaspersky_settings>\n')
            finally:
                kasXmlFilePtr.close()
    else:
        shared.safePrint(('ERRORED PARISNG %s FOR VERSION!' % kasVersion))
    return True
if (__name__ == '__main__'):
    main()