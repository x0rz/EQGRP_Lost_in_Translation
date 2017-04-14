import hashlib, os, threading
import xml.parsers.expat as expat

import exception, util, truantchild
import edfmeta, edfexecution
#from plugin import Plugin
from edfplugin import EDFPlugin
from pytrch import TrchError

from redirection  import LocalRedirection, RemoteRedirection

__all__ = ["DAVEPlugin"]

class DAVEPlugin(EDFPlugin):
    def __init__(self, files, io):
        # DAVE plugins are *currently* supported only on Win32 (that's a
        # restriction based on delivery mechanisms, not the DAVE spec itself)
        import sys
        if sys.platform != "win32":
            raise EnvironmentError("DAVEPlugins are supported only on Windows for this version of Fuzzbunch!")
        
        try:
            EDFPlugin.__init__(self, files, io)
            self.metaconfig = files[2]
            self.initTouches()
            self.initConsoleMode()
            self.initRedirection()
        except TrchError:
            # There was an error parsing the plug-in XML
            raise
        except IndexError:
            # We didn't get the right number of files
            raise
        self.procs = []
        self.package_arches = edfmeta.parse_forward(self.metaconfig)
        if not self.package_arches:
            raise EnvironmentError("A DAVEPlugin is missing required 'package' information in its .fb file!")
            
    def getMetaHash(self):
        return "%s %s %s" % (hashlib.sha1(open(self.metaconfig, 'rb').read()).hexdigest(),
                                      os.lstat(self.metaconfig).st_size,
                                      os.path.basename(self.metaconfig))
 

    def canDeploy(self):
        return True
 
    def killPlugin(self):
        """Helper function for forceful termination of the plugin executable,
        primarily used for testing
        """
        for p in self.procs:
            p.kill()
        self.procs = []


    def write_interpreted_xml_file(self, inConfFile, globalvars={}):
        """Rewrite the inconfig, substituting variables"""
        tmpFile = open(inConfFile, "w");

        # Note: Truantchild has been used to this point to store parameters, so 
        # the inconfig here represents all of the prompted data
        configdata = self.getMarshalledInConfig()
        configlines = configdata.split("\n")
        newlines = []
        for line in configlines:
            newlines.append(util.variable_replace(line, globalvars))
        newconfig = "\n".join(newlines)
        tmpFile.write(newconfig)
        tmpFile.close()
        return inConfFile

    """
    Plugin validation routine

    """
    def validate(self, dirs, globalvars={}):
        baseDir, logDir = dirs
        timestamp = util.formattime()
        exeBaseName = os.path.basename(self.executable)

        logName = "%s-%s.log" % (exeBaseName, timestamp)
        logFile = os.path.join(logDir, logName)
        try:
            os.remove(logFile)
        except:
            pass

        inConfName = "%s-%s-InConfig.validate.xml" % (exeBaseName, timestamp)
        inConfFile = os.path.join(logDir, inConfName)
        self.write_interpreted_xml_file(inConfFile, globalvars=globalvars)

        if edfexecution.validate_plugin(self.executable, inConfFile, self.io) == 0:
            return True
        else:
            return False
    
    def marshal_params(self, logDir, archOs, output_filename=None, globalvars={}):
        import sys, subprocess, platform
        
        # Find/compute various paths and filename components we'll need later
        storageDir = globalvars['FbStorage']
        timestamp = util.formattime()
        exeBaseName = os.path.basename(self.executable)
        
        # Get our own packaging options (for reference)
        arch_map = self.package_arches
        
        # Figure out which piece to use for marshaling
        host_archOs = "%s-%s" % (platform.machine(), platform.system())
        proxy = arch_map[host_archOs][0]
        core = arch_map[archOs][1]
        
        # Non supported!
        if proxy is None:
            return (None, None)
        
        # Get files/paths set up for marshaling
        if output_filename is None:
            output_filename = os.path.join(logDir, "%s-%s-Marshal.bin" % (exeBaseName, timestamp))
        output_path = os.path.dirname(output_filename)
        try:
            os.makedirs(output_path)
        except os.error:
            assert os.path.isdir(output_path), "Output path '%s' could not be found/created!" % output_path
        xml_config_name = os.path.join(logDir, "%s-%s-InConfig.marshal.xml" % (exeBaseName, timestamp))
        self.write_interpreted_xml_file(xml_config_name, globalvars=globalvars)
        
        # Fire off the DANE config utility to actually create the package.  Note that this is strictly
        # Win32[/64] for now...
        # (This stuff should be abtracted away form cross-platformness and to avoid hard-coded paths.)
        proxy_dll = os.path.join(os.path.dirname(self.executable), proxy)
        assert os.path.isfile(proxy_dll), "Required file '%s' doesn't exist!" % proxy_dll
        self.io.print_msg("\tUsing '%s' to handle parameter marshaling" % proxy_dll)
        self.io.print_msg("\tMarshaling the contents of '%s'" % xml_config_name)

        config_exe = os.path.join(storageDir, 'dvmarshal.exe')
        assert os.path.isfile(config_exe), "Required program '%s' doesn't exist!" % config_exe
        subprocess.check_call([config_exe, proxy_dll, xml_config_name, output_filename])
        
        core_dll = os.path.join(os.path.dirname(self.executable), core)
        return (core_dll, output_filename)
    
    def build_package(self, logDir, archOs, listenPort=None, output_filename=None, globalvars={}):
        import sys, subprocess, platform
        
        # Find/compute various paths and filename components we'll need later
        storageDir = globalvars['FbStorage']
        timestamp = util.formattime()
        exeBaseName = os.path.basename(self.executable)
        
        # Get our own packaging options (for reference)
        arch_map = self.package_arches
        
        # Figure out which architecture/OS to use for each piece
        host_archOs = "%s-%s" % (platform.machine(), platform.system())
        proxy = arch_map[host_archOs][0]
        core = arch_map[archOs][1]
        
        if (proxy is None) or (core is None):
            # Not supported!
            return None
        
        if output_filename is None:
            output_filename = os.path.join(logDir, "%s-%s-Package.dll" % (exeBaseName, timestamp))
        
        output_path = os.path.dirname(output_filename)
        try:
            os.makedirs(output_path)
        except os.error:
            assert os.path.isdir(output_path), "Output path '%s' could not be found/created!" % output_path
        
        xml_config_name = os.path.join(logDir, "%s-%s-InConfig.package.xml" % (exeBaseName, timestamp))
        self.write_interpreted_xml_file(xml_config_name, globalvars=globalvars)
        
        # Fire off the DANE config utility to actually create the package.  Note that this is strictly
        # Win32[/64] for now...
        # (This stuff should be abtracted away for cross-platformness and to avoid hard-coded paths.)
        baseArch = archOs.split('-')[0]

        dane_dll = os.path.join(storageDir, 'dane_%s.dll' % baseArch)
        assert os.path.isfile(dane_dll), "Required file '%s' doesn't exist!" % dane_dll
        self.io.print_msg("\tUsing '%s' as the output template" % dane_dll)
        
        proxy_dll = os.path.join(os.path.dirname(self.executable), proxy)
        assert os.path.isfile(proxy_dll), "Required file '%s' doesn't exist!" % proxy_dll
        self.io.print_msg("\tUsing '%s' to handle parameter marshaling" % proxy_dll)
        
        core_dll = os.path.join(os.path.dirname(self.executable), core)
        assert os.path.isfile(core_dll), "Required file '%s' doesn't exist!" % core_dll
        self.io.print_msg("\tUsing '%s' as the input payload" % core_dll)

        config_exe = os.path.join(storageDir, 'danecfg.exe')
        assert os.path.isfile(config_exe), "Required program '%s' doesn't exist!" % config_exe
        subprocess.check_call([config_exe, dane_dll, proxy_dll, core_dll, xml_config_name, output_filename])
        
        if listenPort:
            # Pack in the listen-port as a particular binary resource
            import ctypes, struct
            RT_RCDATA = 10
            ID_PORTNUM = 101
            LANG_ID = 0x0000
            
            BeginUpdateResource = ctypes.windll.kernel32.BeginUpdateResourceA
            UpdateResource      = ctypes.windll.kernel32.UpdateResourceA
            EndUpdateResource   = ctypes.windll.kernel32.EndUpdateResourceA
            
            rblob = struct.pack("<H", listenPort)
            handle = BeginUpdateResource(output_filename, False)
            if handle is None:
                raise ctypes.WinError()
            if not UpdateResource(handle, RT_RCDATA, ID_PORTNUM, LANG_ID, rblob, len(rblob)):
                raise ctypes.WinError()
            if not EndUpdateResource(handle, False):
                raise ctypes.WinError()
        
        return output_filename
    
    """
    Plugin execution routine

    """
    def execute(self, session, consolemode, interactive, scripted, globalvars={}, runMode='', archOs='x86-Windows', listenPort=0):
        self.lastsession = session
        baseDir, logDir = session.get_dirs()
        waitmode, newconsole = self.get_runflags(consolemode, interactive, scripted)
        timestamp = util.formattime()

        # Save history
        session.history = self.getParameters()

        # Prompt for run mode
        if runMode in ("DANE", "DAVE"):
           
            # TODO: prompt operator to verify remote callback tunnel exists for localhost comms
            
            if runMode == "DANE":
                # Build package
                packagePath = self.build_package(logDir, archOs, listenPort, globalvars=globalvars)
                
                # Print package info
                self.io.print_success("DANE Package: %s" % packagePath)
            # elif runMode == "DAVE":
                # # Marshal params (and get core module name)
                # modulePath, inputPath = self.marshal_params(logDir, archOs, globalvars=globalvars)
                
                # # Build up DAVE commandline
                # dvcmds = 'daringveteran -module "%s" -input "%s" -run %s' % (
                    # modulePath,
                    # inputPath,
                    # 'interactive' if (listenPort) else 'batch')
                # if listenPort:
                    # dvcmds += " -homeport %d" % listenPort
                
                # # Print core module and marshaled data info
                # self.io.print_success('DAVE Pastable:\n\t' + dvcmds)
            else:
                raise NotImplementedError("No such option '%s'; what happened??" % (runMode))
            
            # Set "DaveProxyPort" hidden parameter in current config
            if listenPort:
                #self.set("DaveProxyPort", str(listenPort))
                self.io.print_msg("Proxy listening on localhost:%d" % listenPort)
            else:
                # Bail right now--gracefully...
                return newconsole, None
        elif runMode == 'FB':
            # Make sure the proxy port is zeroed
            self.set("DaveProxyPort", "0")
        else:
            raise NotImplementedError("No such option '%s'; what happened??" % (runMode))
        
        exeBaseName = os.path.basename(self.executable)

        logName = "%s-%s.log" % (exeBaseName, timestamp)
        logFile = os.path.join(logDir, logName)
        try:
            os.remove(logFile)
        except:
            pass

        # Touch the logfile
        tmpFile = open(logFile, "w")
        tmpFile.close()

        # Create InConfig and write to the logdir
        inConfName = "%s-%s-InConfig.xml" % (exeBaseName, timestamp)
        inConfFile = os.path.join(logDir, inConfName)
        self.write_interpreted_xml_file(inConfFile, globalvars=globalvars)

        # Create the pipe that we will use for the --OutConfig parameter
        pipeName = edfexecution.generate_pipename()
        pipe = edfexecution.create_pipe(pipeName)

        cwd = os.getcwd() 
        os.chdir(logDir)
        try:
            #
            # This is the sneaky bit for the output.  We call launch_plugin, 
            # which does two things.  First, it passes stdin,stdout, and stderr
            # to the call to subprocess.Popen so that output is duplicated to
            # the console.  Second, it passes --OutConfig a pipe so that, when we
            # later call write_outconfig, this contains only the data we want
            #
            proc = edfexecution.launch_plugin(self.executable, inConfFile, 
                                      pipeName, logFile, self.io, newconsole)
            self.procs.append(proc)
        except KeyboardInterrupt:
            self.io.print_error("Stopping plugin")
            try:
                self.procs.remove(proc)
                proc.kill()
            except:
                pass
            # Create the output param for the contract
            session.contract = [util.oParam("Status", "Failed", "String", "Scalar"), 
                                util.oParam("ReturnCode", "User Abort", "String", "Scalar")]
            session.mark_fail()
            raise exception.CmdErr, "Canceled by User"
            
        os.chdir(cwd)

        try:
            # Wait for the spawned process to connect to our named pipe
            pipe = edfexecution.connect_pipe(pipe, pipeName)
        except edfexecution.PipeError, err:
            self.io.print_error(str(err))
            pipe = None

        if pipe == None:
            try:
                # Try to kill the process
                self.procs.remove(proc)
                proc.kill()
            except:
                pass
            try:
                # See if the process has terminated
                proc.poll()
            except:
                pass
            # Create the output param for the contract
            session.contract = [util.oParam("Status", "Failed", "String", "Scalar"),
                                util.oParam("ReturnCode", str(proc.returncode), "String", "Scalar")]
            session.mark_fail()
            raise exception.CmdErr, "Error Connecting Pipe to Plugin"

        # Create OutConfig file name
        outConfName = "%s-%s-OutConfig.xml" % (exeBaseName, timestamp)
        outConfFile = os.path.join(logDir, outConfName)

        if waitmode:
            # Wait for the plugin to finish.  So, we don't have overlapping 
            # output or problems waiting for the outconfig
            self.get_outconfig(pipe, session, outConfFile, proc)
        else:
            # Creates a new thread to read output config from the executed plugin.  
            pluginThread = threading.Thread(None, 
                                  self.get_outconfig,
                                  None,
                                  (pipe, session, outConfFile, proc))
            pluginThread.start()
        return newconsole, logFile 

    """
    Output XML handling

    """
    def get_outconfig(self, pipe, session, outConfName, proc):
        try:
            # Read from the named pipe we passed to launch_plugin and 
            # write to file
            edfexecution.write_outconfig(outConfName, pipe)
        except KeyboardInterrupt:
            self.io.print_error("Canceled by User")
            self.io.print_error("Stopping plugin")
            try:
                proc.kill()
            except:
                pass
        finally:
            # XXX - Remove_pipe too?
            edfexecution.close_pipe(pipe)
        try:
            #name   = self.getName()
            params = self.read_outxml(outConfName)
            params.append(util.oParam("Status", "Success", "String", "Scalar"))
            if len(params) > 1:
                session.mark_ready()
            else:
                session.mark_used()
        except (ValueError, TrchError, AttributeError) as e:
            # We get here if the following conditions happen:
            #  Argument errors to any calls
            #  Plug-in failed and didn't actually write an outconfig
            #  Output created an invalid XML configuration
            #self.io.print_warning("Output XML error: It's either empty or does not parse: %s" % (e))
            self.io.print_warning("Plugin failed")
            proc.wait()
            params = [util.oParam("Status", "Failed", "String", "Scalar"),
                      util.oParam("ReturnCode", str(proc.returncode), "String", "Scalar")]
            session.mark_fail()
        session.contract = params

    def read_outxml(self, filename):
        try:
            return truantchild.Config((filename, self.executable))._outputParams.getParameterListExt()
        except:
            pass

    """
    Session info description generation

    """
    def getSessionDescription(self):
        descr = [""]
        if self.redirection:
            redir = self.getRedirection()
            descr = []
            for l in redir['local']:
                try:
                    descr.append( self.get(l.listenaddr) )
                except exception.CmdErr:
                    # The tunnel is invalid because the parameter is not in scope.  Ignore the tunnel
                    pass
        return " ".join(descr)

    """
    Rendezvous

    """
    def doRendezvous(self, value):
        self._trch_addrendezvousparam(value)

    """
    Run Mode

    """
    def initConsoleMode(self):
        if self.metaconfig:
            try:
                mode = edfmeta.parse_consolemode(self.metaconfig)
                self.consolemode = util.convert_consolemode(mode)
            except expat.ExpatError:
                # Pass here because we printed something while parsing the
                # invalid file, but we want execution to continue
               pass
        else:
            EDFPlugin.initConsoleMode(self)

    def get_runflags(self, mode, interactive, scripted):
        """
        
        Return the following boolean flags:

            newconsole - the plugin should execute in a new console
            waitmode   - Execution should wait for the plugin to finish
                         executing
        """
        if interactive:
            if not mode:
                # Use the plugin's settings
                mode = self.getConsoleMode()
        else:
            # Non-interactive mode must reuse the console
            mode = util.CONSOLE_REUSE

        if mode == util.CONSOLE_REUSE:
            # Reusing implies no new console
            newconsole = False
        else:
            newconsole = True

        waitmode = True
        # If non-scripted, interactive sessions that launch new consoles don't
        # need to wait for plugins to finish.  All other permutations do.
        if interactive and not scripted and newconsole:
            waitmode = False
        return (waitmode,newconsole)

    """
    Redirection

    """
    def initRedirection(self):
        redir = None
        try:
            redir = edfmeta.parse_redirection(self.xmlInConfig)
        except expat.ExpatError:
            self.io.print_error("Error parsing redirection information")

        # XXX - What should we do if we fail to parse redirection?
        counter = 1
        for r in redir['remote']:
            if 'name' not in r:
                r['name'] = 'remote-tunnel-%d' % counter
                counter += 1
        counter = 1
        for r in redir['local']:
            if 'name' not in r:
                r['name'] = 'local-tunnel-%d' % counter
                counter += 1

        self.redirection = {
                'remote' : [RemoteRedirection(**r) for r in redir['remote']],
                'local'  : [LocalRedirection(**l)  for l in redir['local']]
                }

    """
    Touches

    """
    def initTouches(self):
        if self.metaconfig:
            try:
                self.touchlist = edfmeta.parse_touchlist(self.metaconfig)
            except exception.PluginMetaErr:
                import os.path
                (p,f) = os.path.split(self.metaconfig)
                n = f.split('-')[0]
                self.io.pre_input(None)
                self.io.print_warning("Error in %s meta (.fb) file - touches not loaded " % (str(n)))
                self.io.post_input()
                EDFPlugin.initTouches(self)
            except IndexError:
                EDFPlugin.initTouches(self)
        else:
            EDFPlugin.initTouches(self)
