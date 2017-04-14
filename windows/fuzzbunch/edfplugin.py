import hashlib
import os
import threading

import edfexecution
import exception
from plugin       import Plugin
from redirection  import LocalRedirection, RemoteRedirection
import util

import truantchild
from pytrch import TrchError

import edfmeta
import xml.parsers.expat as expat


__all__ = ["EDFPlugin"]

class EDFPlugin(Plugin):
    def __init__(self, files, io):
        try:
            Plugin.__init__(self, files, io)
            self.metaconfig = files[2]
            self.initTouches()
            self.initRedirection()
            self.initConsoleMode()
        except TrchError:
            # There was an error parsing the plug-in XML
            raise
        except IndexError:
            # We didn't get the right number of files
            raise
        self.procs = []
            
    def getMetaHash(self):
        return "%s %s %s" % (hashlib.sha1(open(self.metaconfig, 'rb').read()).hexdigest(),
                                      os.lstat(self.metaconfig).st_size,
                                      os.path.basename(self.metaconfig))
 

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
    
    """
    Plugin execution routine

    """
    def execute(self, session, consolemode, interactive, scripted, globalvars={}, runMode=''):
        self.lastsession = session
        baseDir, logDir = session.get_dirs()
        waitmode, newconsole = self.get_runflags(consolemode, interactive, scripted)

        # save history
        session.history = self.getParameters()

        timestamp = util.formattime()
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
            Plugin.initConsoleMode(self)

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
                Plugin.initTouches(self)
            except IndexError:
                Plugin.initTouches(self)
        else:
            Plugin.initTouches(self)
