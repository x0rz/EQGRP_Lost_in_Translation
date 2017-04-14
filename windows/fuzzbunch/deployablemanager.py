"""
    EDF Plugin Manager

"""
from command   import CmdCtx
from iohandler import truncate
import exception
import util
import traceback
from pluginmanager import PluginManager

MAX_PARAM_ECHO_LEN = 60

EDF_PLUGIN_INFO = """
    Name: %s
 Version: %s
    Type: %s
"""

__all__ = ["DeployableManager"]

class DeployableManager(PluginManager):
    def __init__(self, type, fb):
        PluginManager.__init__(self, type, fb)
    def exe_print_params(self, plugin, redirid):
        args = {'title'   : plugin.getName(),
                'session' : self.fb.redirection.get_session(redirid),
                'vars'    : plugin.getParameters(hidden=True)}
        self.io.print_exe_set_names(args)
        
    def do_execute(self, input):
        """Execute the current plugin"""
        session = None
        self.io.newline()
        inputList = input.strip().split()
        if len(inputList) > 0:
            consolemode = inputList[0].lower()
            consolemode = util.convert_consolemode(consolemode)
        else:
            consolemode = 0

        plugin = self.get_active_plugin()
        self.io.print_warning("Preparing to Execute %s" % plugin.name)
        if plugin.validate(self.session.get_dirs(), globalvars=self.fb.fbglobalvars) and plugin.isValid():
            # XXX - Get the description before redirection.
            # This really should be fixed to not care about order
            runMode = 'FB'
            plugin_desc = plugin.getSessionDescription()
            
            modes = [
                ("DANE", "Forward deployment via DARINGNEOPHYTE"),
                #("DAVE", "Forward deployment via DARINGVETERAN"),
                ("FB", "Traditional deployment from within FUZZBUNCH"),
            ]
            self.io.print_prompt_param({
                "name": "Mode",
                "description": "Delivery mechanism",
                "type": "Choice",
                "attribs": modes
            }, "0")
            runMode = self.io.prompt_user("Mode", params=modes, default="0", gvars=self.fb.fbglobalvars)
            self.io.print_success("Run Mode: %s" % (runMode))
            self.io.newline()

            listenPort = 0
            if runMode in ("DANE", "DAVE"):
                pairs = sorted((k, k) for k in plugin.package_arches.iterkeys())
                self.io.print_prompt_param({
                    "name": "ArchOs",
                    "description": "Architecture/OS of REDIRECTOR",
                    "required": "YES",
                    "valid": "YES",
                    "type": "Choice",
                    "attribs": pairs
                }, "0")
                archOs = self.io.prompt_user("ArchOS", "0", pairs, gvars=self.fb.fbglobalvars)
                # Prompt for proxy port
                listenPort = int(self.io.prompt_user("Linkup TCP port (0=none)?", default="0", gvars=self.fb.fbglobalvars))
                if listenPort:
                    plugin.set("DaveProxyPort", str(listenPort))
                    self.io.print_success("set DaveProxyPort ==> %d" % (listenPort))
                # TODO: prompt operator to verify remote callback tunnel exists for localhost comms
            else:
                archOs = 'x86-Windows'
            
            if runMode == "FB":
                if not self.io.prompt_yn("This will execute locally like traditional Fuzzbunch plugins. Are you sure? (y/n)"):
                    raise exception.CmdErr("User abort")
                redirid = self.fb.redirection.pre_exec(plugin)
            else:
                redirid = ''
            
            newwindow = False
            
            try:
                # Last chance to quit, print execution info and prompt
                if redirid:
                    self.fb.redirection.print_session(redirid)
                    #self.fb.do_redirect("")
                    self.io.print_warning("Verify Redirection Tunnels Exist")
                    self.io.prompt_confirm_redir()
                self.exe_print_params(plugin, redirid)
                self.io.prompt_continue()
                self.io.print_msg("Executing Plugin")
                if self.fb.log:
                    try:
                        self.fb.log[plugin.getName()] = self.fb.log.launch_from_command('execute', plugin.getName(), plugin.getConfigVersion()).start()
                    except:
                        pass
                # Generate a new session and execute
                session = self.session.add_item(plugin.getName(),
                                                plugin_desc)
                newwindow, logfile = plugin.execute(session, 
                                                    consolemode, 
                                                    self.fb.is_interactive(),
                                                    self.fb.is_scripted(),
                                                    globalvars=self.fb.fbglobalvars,
                                                    runMode=runMode,
                                                    archOs=archOs, 
                                                    listenPort=listenPort)
            except Exception as e:
                self.io.print_error("Error running plugin: {0}".format(e))
                newwindow = False
                session = None
            finally:
                self.fb.redirection.post_exec(plugin, redirid)
                if self.fb.log and plugin.name in self.fb.log:
                    try:
                        try: session
                        except: pass
                        else:
                            if 'Project' in self.fb.fbglobalvars: self.fb.log[plugin.name].set(project_name=self.fb.fbglobalvars['Project'])
                            self.fb.log[plugin.name].queue(**dict([(k,v) for k,v in session.history.params.values()]+[(v[0],v[1]) for v in session.contract.params.values()]))
                            if session.is_failed(): parent = self.fb.log[plugin.name].failed_exploit()
                            else: parent = self.fb.log[plugin.name].successful_exploit()
                            self.fb.log[plugin.name].file_from_path(logfile, parent)
                    except:
                        if self.fb.log: self.fb.log.notify_of_error('Recording use of ' + str(plugin.name))

            if runMode in ('DANE', 'DAVE'):
                return
                        
            if newwindow:
                self.io.print_warning("Plugin Spawned in New Console - Running Detached")
            else:
                if session and not session.is_failed():
                    self.io.print_success("%s Succeeded" % plugin.name)
                    if plugin.createsRendezvous():
                        self.io.newline()
                        self.io.print_warning("Connection to Target Established")
                        self.io.print_warning("Waiting For Next Stage")
                else:
                    raise exception.CmdErr, "%s Failed" % plugin.name
        else:
            #self.do_validate()
            raise exception.CmdErr, "Execution Aborted"
        self.io.newline()
