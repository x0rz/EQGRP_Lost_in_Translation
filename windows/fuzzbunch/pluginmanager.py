"""
    EDF Plugin Manager

"""
from command   import CmdCtx
from iohandler import truncate
import exception
import util
import traceback

MAX_PARAM_ECHO_LEN = 60

EDF_PLUGIN_INFO = """
    Name: %s
 Version: %s
    Type: %s
"""

__all__ = ["PluginManager"]

class PluginManager(CmdCtx):
    """A PluginManager maintains a list of available plugins OF A GIVEN TYPE.  For
    instance, one PluginManager will exist for each of exploits, touches, payloads, etc.
    It also extends the commands available to interact with various plug-ins.  Extension
    commands are:
    * apply
    * execute
    * export
    * prompt
    * rendezvouz
    * reset
    * touch
    * validate

    """
    def __init__(self, type, fb):
        CmdCtx.__init__(self, type, type)
        self.pluginList = util.iDict()
        self.activePlugin = None
        self.session = fb.session
        self.io = fb.io
        self.fb = fb

    """
    Plugin Management

    """
    def add_plugin(self, files, Constructor):
        from pytrch import TrchError as TruantchildError
        try:
            item = Constructor(files, self.io)
            try:
                self.pluginList[item.getName()] = item 
            except AttributeError:
                # We're in MinSizeRel
                name = files[0].split('-')[0]
                self.pluginList[name] = item
        except TruantchildError, e:
            # If we fail to process something, don't load this plugin, but also don't fail
            # to load the other plugins
            raise exception.PluginXmlErr(str(e))

    def get_plugin(self, name):
        try:
            return self.pluginList[name]
        except KeyError:
            raise exception.CmdErr, "'%s' not a valid %s" % (name, self.get_type())

    def get_plugins(self):
        for plugin in self.pluginList.values():
            yield plugin
        return 

    def get_plugin_names(self):
        return self.pluginList.keys()

    def get_active_name(self):
        if self.activePlugin:
            return self.get_name()
        else:
            return "None"

    def set_active_plugin(self, name):
        self.activePlugin = self.get_plugin(name)
        self.name = self.activePlugin.getName()

    def unset_active_plugin(self):
        self.activePlugin = None
        self.name = self.type

    def get_active_plugin(self):
        return self.activePlugin

    
    """
    Current context info 

    """
    def print_info(self, pname=None):
        """Get the currently active plugin and print various 
        informational items about it: 
        * Name, Version, Type
        * Redirection information
        * Parameters established for that context
        """
        if pname == None:
            plugin = self.get_active_plugin()
        else:
            plugin = self.get_plugin(pname)

        # XXX - Output Fix
        self.io.write(EDF_PLUGIN_INFO % (plugin.getName(), 
                                         plugin.getVersion(),
                                         self.get_type()))
        #self.io.write(plugin.getBinaryHash() + "\n")
        #self.io.write(plugin.getConfigHash() + "\n")
        #self.io.write(plugin.getMetaHash() + "\n")
                                         

        self.io.write("Redirection:")
        self.io.print_redir_info(plugin.getRedirection(), 
                                 plugin.getParameters())

        # Bug #2133: Fix this so that hidden parameters are cached but not
        # displayed
        self.io.write("Parameters:")
        params = [ (param[0], param[1], plugin.getDescription(param[0]))
                   for param in plugin.getParameters(hidden=False) ]
        self.io.print_param_list(params)

    """
    Main plugin routines

    """
    def complete_execute(self, text, line, arglist, state, begidx, endidx):
        cmap = dict([(val,key) for key,val in util.consolemode_map.items()])
        clist = [cmap[util.CONSOLE_REUSE], cmap[util.CONSOLE_NEW]]

        if state == 1:
            return [item 
                    for item in sorted(clist)
                    if item.lower().startswith(text.lower())]
        return [""]

    def help_execute(self):
        usage = ["execute [mode]",
                 "Executes the current plugin. Mode specifies to",
                 "open a new window or reuse the current console.",
                 "Plugin default will be used if mode is not specified",
                 "Modes:",
                 "  new      Run plugin in a new window",
                 "  reuse    Reuse the current window",
                 "  default  Use the plugin default"]
        self.io.print_usage(usage)

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
            plugin_desc = plugin.getSessionDescription()
            redirid = self.fb.redirection.pre_exec(plugin)
            
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
                    self.fb.log[plugin.name] = self.fb.log.launch_from_command('execute', plugin.getName(), plugin.getConfigVersion()).start()
                # Generate a new session and execute
                session = self.session.add_item(plugin.getName(),
                                                plugin_desc)
                newwindow, logfile = plugin.execute(session, 
                                                    consolemode, 
                                                    self.fb.is_interactive(),
                                                    self.fb.is_scripted(),
                                                    globalvars=self.fb.fbglobalvars,
                                                    runMode="FB")
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


    def help_validate(self):
        usage = ["validate",
                 "Validates the current plugin parameters"]
        self.io.print_usage(usage)

    def do_validate(self, *ignore):
        """Validate the current parameter settings"""
        plugin = self.get_active_plugin()

        self.io.print_msg("Checking %s parameters" % plugin.getName())
        self.io.newline()
        if plugin.validate(self.session.get_dirs(), globalvars=self.fb.fbglobalvars) and self.activePlugin.isValid():
            self.io.print_success("Parameters are valid")
        else:
            self.io.print_error("Parameter check failed")
            #self.io.print_param_list(plugin.getInvalid())    
    
    """
    Session parameter inheritance

    """
    def complete_apply(self, text, line, arglist, state, begidx, endidx):
        """Command completion for apply command."""
        # XXX - one might not be good to have completion for
        itemList = [str(i) 
                    for i,item in enumerate(sorted(self.session.get_itemlist()))]
        if state == 1:
            return [i for i in itemList if i.startswith(text)]
        return [""]

    def help_apply(self):
        usage = ["apply [index]",
                 "Inherits the output parameters from plugins that",
                 "are marked READY and input parameters from all",
                 "plugins in the session history. Specify an index",
                 "to inherit parameters from a specific session",
                 "regardless of state"]
        self.io.print_usage(usage)

    def apply_prompt(self, var, vals, plugin, singlemode=False):
        if var.lower() == "rendezvous":
            default = None
        else:
            default = plugin.get(var)

        if not default:
            default = ""

        # vals is a list of oParams
        if len(vals) == 1 or singlemode:
            (param, contract) = vals[0]
        else:
            params = {'default'  : default,
                      'variable' : var,
                      'vals'     : vals}
            self.io.print_apply_prompt(params)

            line = self.io.prompt_user(var, "0")
            if line == "":
                line = "0"
            try:
                index = int(line)
            except ValueError:
                raise exception.CmdErr, "Invalid Input"

            if index == len(vals):
                # picked current
                self.io.print_success("Using current val for %s" % var)
                return True
            else:
                try:
                    (param, contract) = vals[int(line)]
                except (IndexError, ValueError):
                    raise exception.CmdErr, "Invalid Input"

        if var.lower() == "rendezvous":
            sval = param.value.value
            plugin.doRendezvous(sval)
        else:
            if param.value.format.lower() == plugin.getFormat(var).lower():
                # scalar => scalar or
                # list => list
                sval = param.value.value
            elif param.value.format.lower() == 'scalar':
                # scalar => list
                sval = util.scalar_to_list(param.value)
            else:
                # list => scalar
                vals = util.parse_param_list(param.value.value, param.value.type)
                if not vals:
                    raise exception.CmdErr, "Invalid Input"

                params = {'default'  : "",
                          'contract' : contract.get_item_info(),
                          'variable' : var,
                          'vals'     : vals}
                self.io.print_apply_prompt_list(params)
                line = self.io.prompt_user(var, "0")
                if line == "":
                    line = "0"

                try:
                    index = int(line)
                except IndexError:
                    raise exception.CmdErr, "Invalid Input"

                if index == len(vals):
                    #picked current
                    self.io.print_success("Using current val for %s" % var)
                    return True
                else:
                    try:
                        sval = vals[index]
                    except (IndexError, ValueError):
                        raise exception.CmdErr, "Invalid Input"

            plugin.set(var, sval, globalvars=self.fb.fbglobalvars)

        if contract:
            contract.mark_used()
        self.io.print_success("Set %s => %s" % (var, sval))

        return True

    def apply_singleloop(self, var, params, plugin, singlemode=False):
        done = None
        while not done:
            try:
                if var not in params:
                    raise exception.CmdErr, "Unknown var"
                done = self.apply_prompt(var, params[var], plugin, singlemode)
            except exception.PromptErr, err:
                raise 
            except exception.CmdErr, err:
                self.io.print_error(err.getErr())
                # With errors, continue on, skipping param
                self.io.print_error("Skipping '%s'" % var)
                done = True

    def apply_process(self, params, plugin, singlemode=False):
        self.io.print_msg("Applying Session Parameters")
        # Iterate over the plugin's parameters
        for var,val in plugin.iterPromptParameters():
            if var.lower() == "rendezvous":
                continue
            if var in params:
                self.apply_singleloop(var, params, plugin, singlemode)

        for k in params.keys():
            if k.lower() == "rendezvous" and plugin.hasParameter("ConnectedTcp"):
                self.apply_singleloop("Rendezvous", params, plugin, singlemode)

    def do_apply(self, input):
        """Apply parameters values from session items"""
        plugin = self.get_active_plugin()
        params = util.iDict()

        inputList = input.strip().split()
        if not inputList:
            # Case where we just type 'apply'
            for contract in self.session.get_contractlist():
                for param in contract.get_paramlist():
                    params.setdefault(param.name, []).append((param, contract))
            self.apply_process(params, plugin)
        else:
            # Case where we type 'apply X'
            try:
                index = int(inputList[0])
            except ValueError:
                raise exception.CmdErr, "apply [index]"

            contract = self.fb.session.get_contract(index)
            for param in contract.get_paramlist():
                params[param.name] = [(param, contract)]
            self.apply_process(params, plugin, singlemode=True)
            

    """
    Interactive prompt mode

    """
    def help_prompt(self):
        usage = ["prompt",
                 "Walks through plugin parameters prompting the user to set",
                 "a value for each one"]
        self.io.print_usage(usage)

    def prompt_param(self, name, value, plugin):
        """Prompt for a parameter, and set the value in the session on response"""
        valid_convert = {1 : "YES", 0 : "NO"}
        param      = plugin.getParameter(name)
        attribs    = util.iDict(param.getAttributeList())
        attribvals = param.getAttributeValueList()

        args = {'name'        : name,
                'value'       : value,
                'description' : attribs['Description'],
                'required'    : attribs['Required'],
                'valid'       : valid_convert[plugin.isValid(name)],
                'type'        : attribs.get('Type', "Choice"),
                'attribs'     : attribvals,}

        if plugin.isParamchoice(name):
            default_value = ""
            for i,p in enumerate(attribvals):
                if p.name.lower() == value.lower():
                    default_value = str(i)
        else:
            default_value = value

        self.io.print_prompt_param(args, default_value)
        line = self.io.prompt_user(name, default_value, attribvals, gvars=self.fb.fbglobalvars)
        if line != value:
            self.do_set(name + " " + line)

        if plugin.hasValidValue(name):
            return True
        else:
            return False

    def prompt_param_help(self, name, value, plugin):
        valid_convert = {1 : "YES", 0 : "NO"}
        param      = plugin.getParameter(name)
        attribs    = util.iDict(param.getAttributeList())
        attribvals = param.getAttributeValueList()

        args = {'name'        : name,
                'value'       : value,
                'description' : attribs['Description'],
                'required'    : attribs['Required'],
                'valid'       : valid_convert[plugin.isValid(name)],
                'type'        : attribs.get('Type', "Choice"),
                'attribs'     : attribvals,}
        self.io.print_prompt_param_help(args)

    def do_prompt(self, input):
        """Walk through all parameters prompting for a value for each one"""
        plugin = self.get_active_plugin()
        self.io.newline()
        self.io.print_warning("Enter Prompt Mode :: %s" % plugin.name)

        inputList = input.strip().split()
        if len(inputList) == 1 and inputList[0].lower() == "confirm":
            self.do_set("")
            if plugin.isValid():
                self.io.print_warning("plugin variables are valid")
            else:
                self.io.print_warning("Plugin Variables are NOT Valid")
            if not self.io.prompt_runsubmode("Prompt For Variable Settings?"):
                self.io.print_warning("Skipping Prompt")
                if self.fb.log: self.fb.log.command('prompt', '%s %s configured with default parameters'%(plugin.getName(),plugin.getConfigVersion()))
                return

        for name, value in plugin.iterPromptParameters():
            done = None
            while not done:
                try:
                    done = self.prompt_param(name, value, plugin)
                except exception.PromptHelp, err:
                    self.prompt_param_help(name, value, plugin)
                except exception.PromptErr, err:
                    raise
                except exception.CmdErr, err:
                    self.io.print_error(err.getErr())
        self.io.newline()
        if self.fb.log: self.fb.log.command('prompt', '%s %s configured with manually entered parameters'%(plugin.getName(),plugin.getConfigVersion()))

    """
    Parameter handling user commands

    """
    def complete_set(self, text, line, arglist, state, begidx, endidx):
        paramlist = self.get_active_plugin().getParameters(hidden=False)

        if state == 1:
            return [item[0] 
                    for item in sorted(paramlist) 
                    if item[0].upper().startswith(text.upper())]
        elif state == 2:
            if arglist[1] not in dict(paramlist):
                return [""]
            else:
                try:
                    plugin = self.get_active_plugin()
                    param  = plugin.getParameter(arglist[1])
                    if plugin.isParamchoice(arglist[1]):
                        attribVal = param.getAttributeValueList()
                        return [attr.name
                                for attr in attribVal
                                if attr.name.upper().startswith(text.upper())]
                except exception.CmdErr:
                    return [""]
        else:
            return [""]

    def help_set(self):
        usage = ["set [parameter] [value]",
                 "Set a configuration parameter.  This command is context",
                 "sensitive and will set options for the active plugin context",
                 "only.  Set with no arguments will show all parameters and",
                 "values.",
                 "  L:value  - Input ascii string to widechar",
                 "  H:value  - Input hex string"]
        self.io.print_usage(usage)

    @util.charconvert
    def do_set(self, input):
        """Set a configuration parameter"""
        plugin    = self.get_active_plugin()
        inputList = input.strip().split()
        if not inputList:
            # Print the list of parameters

            args = {'title' : plugin.getName(),
                    'vars'  : plugin.getParameters(hidden=False)}
            self.io.print_set_names(args)
        elif len(inputList) == 1:
            param = plugin.getParameter(inputList[0])
            try:
                # XXX - Output Fix
                attribList = param.getAttributeList()
                self.io.print_set_attributes(plugin.getName(),
                                             inputList[0],
                                             attribList)
                if plugin.isParamchoice(inputList[0]):
                    attribVal = param.getAttributeValueList()
                    self.io.print_set_choices(attribVal)
            except AttributeError:
                raise exception.CmdErr, "set [param] [value]"
        elif len(input) >= 2:
            set_value = " ".join(inputList[1:])
            plugin.set(inputList[0], set_value, globalvars=self.fb.fbglobalvars)
            self.io.print_success("Set %s => %s" % (inputList[0], truncate(set_value)))

    """
    Parameter reset 

    """
    def complete_reset(self, text, line, arglist, state, begidx, endidx):
        paramlist = self.get_active_plugin().getParameters()
        if state == 1:
            return [item[0] 
                    for item in sorted(paramlist) 
                    if item[0].upper().startswith(text.upper())]
        return [""]

    def help_reset(self):
        usage = ["reset [parameter]",
                 "Reset a configuration parameter to default"]
        self.io.print_usage(usage)

    def do_reset(self, input):
        """Reset a configuration parameter"""
        plugin    = self.get_active_plugin()
        inputList = input.strip().split()
        if not inputList:
            args = {'title' : plugin.getName(),
                    'vars'  : plugin.getParameters()}
            self.io.print_set_names(args)
        elif len(inputList) == 1:
            plugin.reset(inputList[0])
            self.io.print_success("Reset %s" % inputList[0])
        else:
            raise exception.CmdErr, "Invalid input"

    """
    Parameter exporting to globals

    """
    def complete_export(self, text, line, arglist, state, begidx, endidx):
        paramlist = self.get_active_plugin().getParameters()
        if state == 1:
            return [item[0] 
                    for item in sorted(paramlist) 
                    if item[0].upper().startswith(text.upper())]
        return [""]

    def help_export(self):
        usage = ["export [parameter] [globalname]",
                 "Export a configuration parameter to the global namespace."]
        self.io.print_usage(usage)

    def do_export(self, input):
        """Export a local parameter as a global"""
        plugin    = self.get_active_plugin()
        inputList = input.strip().split()
        if not inputList:
            args = {'title' : plugin.getName(),
                    'vars'  : plugin.getParameters()}
            self.io.print_set_names(args)
        elif len(inputList) == 1:
            param = plugin.getParameter(inputList[0])
            try:
                # XXX - Output Fix
                attribList = param.getAttributeList()
                self.io.print_set_attributes(plugin.getName(),
                                             inputList[0],
                                             attribList)
                if plugin.isParamchoice(inputList[0]):
                    attribVal = param.getAttributeValueList()
                    self.io.print_set_choices(attribVal)
            except AttributeError:
                raise exception.CmdErr, "export [param] [globalname]"
        elif len(input) >= 2:
            value = plugin.get(inputList[0])
            self.fb.do_setg("%s %s" % (inputList[1], value))
        
    """
    Touch support

    """
    def complete_touch(self, text, line, arglist, state, begidx, endidx):
        plugin = self.get_active_plugin()
        if state == 1:
            return [str(i) for i in range(0, len(plugin.getTouchList()))]
        return [""]

    def help_touch(self):
        usage = ["touch [index | all]",
                 "Run a touch associated with the current plugin.",
                 "Specify an index to run a single touch. Specify",
                 "all to run all touches."]
        self.io.print_usage(usage)

    def touch_mapinput(self, plugin, touch):
        self.io.print_msg("Inheriting Input Variables")
        for param in touch["iparams"].items():
            self.fb.runcmd_noex("set %s %s" % param)
        for param in touch["ivparams"].items():
            try:
                val = plugin.get(param.value)
                if val:
                    self.fb.runcmd_noex("set %s %s" % (param.name, val))
            except exception.CmdErr:
                pass

    def touch_mapoutput(self, plugin, touch, contract):
        self.io.print_msg("Exporting Contract To Exploit")
        params = util.iDict()
        for param in contract.get_paramlist():
            params[param.name] = [(param, contract)]
            if param.name in touch['oparams']:
                params[ touch['oparams'][param.name] ] = [(param, contract)]

        for var,val in plugin.iterPromptParameters():
            if var in touch['oparams'].values():
                self.apply_singleloop(var, params, plugin, True)
    
    def touch_single(self, plugin, index):
        touch  = plugin.get_touch(index)

        self.fb.runcmd_noex("use %s" % touch["name"])
        touchplugin = self.fb.get_manager("Touch").get_active_plugin()
        touchplugin.lastsession = None

        self.touch_mapinput(plugin, touch)
        self.fb.runcmd_noex("prompt")
        self.fb.runcmd_noex("execute")
        # This looks like a bug, but lastsession is actually modified in edfplugin.execute
        self.touch_mapoutput(plugin, touch, touchplugin.lastsession.contract)
        if touch["postmsg"]:
            self.io.print_warning(touch["postmsg"])


    def do_touch(self, input):
        """Run a touch plugin"""
        argc, argv = util.parseinput(input, 1)
        if argc == 0:
            args = {'touchlist': [ (t["displayname"], t["description"], t["name"])
                                   for t in self.get_active_plugin().getTouchList() ]}
            self.io.print_touch_info(args)
        elif argc == 1:
            if argv[0].lower() == 'all':
                index = None
            else:
                try:
                    index = int(argv[0])
                except (IndexError, ValueError):
                    raise exception.CmdErr, "Bad touch"

            plugin = self.get_active_plugin()
            try:
                if index is None:
                    for i in range(0, len(plugin.getTouchList())):
                        self.touch_single(plugin, i)
                else:
                    self.touch_single(plugin, index)
            finally:
                self.fb.runcmd_noex("enter %s" % self.type)
        self.io.newline()

    """
    Rendezvous

    """
    def help_rendezvous(self):
        usage = ["rendezvous",
                 "Adds a rendezvous input parameter.  This is part of",
                 "the oh-shit button."]
        self.io.print_usage(usage)

    def do_rendezvous(self, input):
        """Create a rendezvous input parameter"""
        self.get_active_plugin().doRendezvous("0")


