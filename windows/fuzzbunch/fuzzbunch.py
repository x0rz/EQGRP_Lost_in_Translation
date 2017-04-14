"""
Fuzzbunch command shell.  

- Implements (or inherits from FbCmd class) all core fuzzbunch commands.
- Support for Modules (plugin managers)

Modules add additional commands and operate in their own context

"""
import os
from command     import FbCmd
import exception
import redirection
import session
import util
import figlet
import edfmeta
from log import log
__all__ = ['Fuzzbunch']

GVAR_CHAR = '$'
class Fuzzbunch(FbCmd):
    """
    Fuzzbunch, in and of itself, is an execution environment.  It provides a set of
    commands and contexts to interact with.

    The Fuzzbunch class is really an extension of the FbCmd class, which allows it to add
    additional, context-specific commands to the general command line handling.  The base
    set of commands it adds to the FbCmd class are:
    * autorun
    * banner
    * back
    * enter
    * exit
    * mark
    * redirect
    * retarget
    * session
    * setg
    * show
    * standardop
    * toolpaste
    * unsetg
    * use

    For information regarding these commands, please run Fuzzbunch and type 'help <cmd>' at
    the command prompt.

    """
    def __init__(self, 
                 configfile,
                 base_dir, 
                 log_dir, 
                 stdin=None,
                 stdout=None,
                 stderr=None):
        """@brief   Initialize the Fuzzbunch object

        @param      configfile      The main Fuzzbunch configuration file (an XML file)
        @param      base_dir        
        @param      log_dir         Location for Fuzzbunch log files
        @param      stdin           
        @param      stdout          
        @param      stderr          
        """

        # Initialize the command interpreter, which creates a CmdCtx
        self.configvars = {}                    # Stores global config info (not setg globals)
        self.readconfig(configfile)             # Read in variables set for Fuzzbunch

        # Fix bug #2910 - Color breaks in some terminals that don't support ansi encoding.  Added
        # option to disable color
        enablecolor = eval(self.configvars['globals']['Color'])
        FbCmd.__init__(self, stdin=stdin, stdout=stdout, stderr=stderr, enablecolor=enablecolor )

        # Set the info function to Fuzzbunch's print_info function
        self.defaultcontext.print_info = self.print_info
        self.preconfig()

        self.fbglobalvars   = util.iDict()      # Our Fuzzbunch global variables
        self.pluginmanagers = util.iDict()      # A list of PluginManagers, each
                                                # of which contains a list of Plugins.

        # Create our Session manager, which has a list of the plugins we've run
        self.session  = session.Session(self.name)
        self.session.set_dirs(base_dir, log_dir)

        # Set the logdir from the Fuzzbunch.xml file, which will be overridden
        # later when retarget is executed
        self.default_logdir = os.path.normpath(log_dir)
        self.set_logdir(log_dir)

        # Create a Redirection object to keep track of the status of redirection, and to
        # perform transforms on the parameters prior to and after executing plugins
        self.redirection = redirection.RedirectionManager(self.io)

        self.fontdir = os.path.join(base_dir, "fonts")
        self.storage = os.path.join(base_dir, "storage")
        self.setbanner()
        self.postconfig()
        self.pwnies = False

        self.conv_tools = util.iDict([('MultiLine', self.toolpaste_ep),
                                 ('MD5',       self.toolpaste_md5),
                                 ('SHA1',      self.toolpaste_sha1),
                                 ('Base64',    self.toolpaste_base64),
                               ])

        self.log = log(self.name, self.version, dict(debugging=True, enabled=True, verbose=False))

    def precmd(self, line):
        """Intercept user cmd line to global replacement"""
        newline = util.variable_replace(line, self.fbglobalvars)
        return FbCmd.precmd(self, newline)

    def print_info(self, *ignore):
        self.do_banner("")

    """
    Log directory handling

    """
    def get_logdir(self):
        """Retrieve the current log directory"""
        (base_dir, log_dir) = self.session.get_dirs()
        return log_dir

    def get_basedir(self):
        """Retrieve the current base directory"""
        (base_dir, log_dir) = self.session.get_dirs()
        return base_dir

    def set_logdir(self, log_dir=None):
        """Set the current log directory and create a new log file"""
        if not log_dir:
            log_dir = os.path.normpath(self.default_logdir)

        base_dir = self.get_basedir()
        self.session.set_dirs(base_dir, log_dir)

        logname = "fuzzbunch-%s.log" % util.formattime()
        self.io.setlogfile(os.path.join(log_dir, logname))


    """
    Banners

    """
    def getstats(self):
        """ Return stats in the form of tuple(count, type)"""
        return [ (len(list(m.get_plugins())), m.get_type())
                 for m in self.get_manager_list() ]

    def setbanner(self):
        """Set the Fuzzbunch banner (seen when starting fuzzbunch)"""
        self.banner, font = figlet.newbanner(self.fontdir, self.bannerstr)
        #self.io.write("FONT: %s" % font)

    def printbanner(self):
        """Print the currently configured banner"""
        banner = {'banner'  : self.banner,
                  'version' : self.version,
                  'stats'   : self.getstats()}
        self.io.print_banner(banner)

    """
    CMD: Banner
    
    """
    def help_banner(self):
        usage = ["banner",
                 "Print the startup banner"]
        self.io.print_usage(usage)

    def do_banner(self, line):
        """Print the startup banner"""
        line = line.strip().split()
        if line:
            savedbanner = self.bannerstr
            self.bannerstr = " ".join(line)
        self.setbanner()
        self.printbanner()
        if line:
            self.bannerstr = savedbanner

    """
    Console Handlers
    """
    def do_resizeconsole(self, line):
        try:
            import readline
            readline.GetOutputFile().size(width=90,height=65)
        except:
            pass


    """
    Config File

    """

    def readconfig(self, file):
        """Parse the Fuzzbunch.xml file to setup the Fuzzbunch initial environment"""
        try:
            import xml.dom.minidom
            xmlDoc = xml.dom.minidom.parse(file)

            config  = edfmeta.get_elements(xmlDoc, "config")[0]
            redir   = edfmeta.get_elements(config, "redirection")[0]
            runmode = edfmeta.get_elements(config, "runmode")[0]
            banner  = edfmeta.get_elements(config, "banner")[0]
            scripts = edfmeta.get_elements(config, "autorun")[0]
            
            automode = str(scripts.getAttribute("value"))
            if automode.lower() == "on":
                automode = True
            else:
                automode = False
            autorun = {} 
            # 'scripts' contains auto-run scripts.  Get them and set up autorun commands
            for cat in edfmeta.get_elements(scripts, "category"):
                autorun[str(cat.getAttribute("name"))] = []
                for command in edfmeta.get_elements(cat, "command"):
                    autorun[str(cat.getAttribute("name"))].append((command.getAttribute("value"),
                                                                   command.getAttribute("msg")))

            params = {"name"    : str(config.getAttribute("name")),
                      "version" : str(config.getAttribute("version")),
                      "banner"  : str(banner.getAttribute("value")),
                      "globals" : {},
                      "redirection" : {"value" : str(redir.getAttribute("value"))},
                      "runmode" : str(runmode.getAttribute("value")),
                      "automode" : automode,
                      "autorun"  : autorun
                     }
            for param in edfmeta.get_elements(config, "parameter"):
                key = str(param.getAttribute("name"))
                params['globals'][key] = str(param.getAttribute("default"))
        except:
            self.configfile = None
            params = {}
        self.configfile = file
        self.configvars = params

    def preconfig(self):
        try:
            self.name      = self.configvars['name']
            self.bannerstr = self.configvars['banner']
            self.version   = self.configvars['version']
        except:
            self.name = "Fuzzbunch"
            self.bannerstr = "FUZZBUNCH"
            self.version   = "2.0"
        # Override the default context's name and type
        self.defaultcontext.set_name(self.name)
        self.defaultcontext.set_type(self.name)

    def postconfig(self):
        try:
            if self.configvars['redirection']['value'].lower() == "off":
                self.redirection.off()
            else:
                self.redirection.on()
        except:
            pass

        fntab = {"interactive"    : self.runmode_interactive,
                 "noninteractive" : self.runmode_noninteractive,
                 "scripted"       : lambda: (self.runmode_interactive(),
                                             self.scripting(True))}
        try:
            fntab[self.configvars['runmode'].lower()]()
        except:
            pass

        try:
            self.cmdqueue.append("echo Initializing %s v%s" % (self.name,self.version))
            self.cmdqueue.append("echo Adding Global Variables")
            for item in self.configvars['globals'].items():
                self.cmdqueue.append("setg %s %s" % item)
        except:
            pass
         
        try:
            self.autorunvars = self.configvars['autorun']
            self.autorun     = self.configvars['automode']
            self.cmdqueue.append("autorun")
        except:
            pass
        if "LogDir" not in self.configvars['globals']:
            self.cmdqueue.append("setg LogDir %s" % self.default_logdir)
        self.cmdqueue.append("setg FbStorage %s" % self.storage)

    """
    Plugin manager handling

    """

    def register_manager(self, type, typeConstructor):
        """Register a manager with Fuzzbunch.  Initially these are PluginManager objects"""
        if type in self.pluginmanagers:
            raise exception.CmdErr, "'%s' already registered" % type
        self.pluginmanagers[type] = typeConstructor(type, self)
        return self.pluginmanagers[type]

    def unregister_manager(self, type):
        try:
            del self.pluginmanagers[type]
        except KeyError:
            raise exception.CmdErr, "'%s' not a registered manager type" % type

    def get_manager_types(self):
        return self.pluginmanagers.keys()

    def get_manager_counts(self):
        return [ len(list(x.get_plugins())) for x in self.get_manager_list() ]

    def get_active_plugin_names(self):
        return [ (x.get_type(), x.get_active_name()) for x in self.get_manager_list() ]

    def get_manager(self, type):
        try:
            return self.pluginmanagers[type]
        except KeyError:
            raise exception.CmdErr, "'%s' not a registered manager type" % type

    def get_manager_list(self):
        for manager in self.pluginmanagers.values():
            yield manager
        return 


    """
    CMD: Quit

    """
    def do_quit(self, arg):
        """Quit fuzzbunch"""
        try:
            opencontracts = [ item.name
                              for item in self.session.get_itemlist()
                              if item.value.has_opencontract() ]
            if opencontracts:
                self.io.print_opensessions({'sessions' : opencontracts})

                line = self.io.get_input("Really quit [n] ? ")
                if line.lower() not in ("yes", "y", "q", "quit"):
                    return 
            if self.log: self.log.close()
            return True
        except:
            pass

        return True

    """
    Context handling user commands

    """
        

    """
    CMD: Info
    
    """
    def help_info(self):
        usage = ["info",
                 "Print information about the current context"]
        self.io.print_usage(usage)

    def do_info(self, *ignore):
        """Print information about the current context"""
        self.getcontext().print_info()

    """
    CMD: Back
    
    """
    def help_back(self):
        usage = ["back",
                 "Leave the context current plugin back to the default"]
        self.io.print_usage(usage)

    def do_back(self, *ignore):
        """Leave the current context back to the default"""
        self.setcontext(None)
        self.setprompt()

    """
    CMD: Exit
    
    """
    def help_exit(self):
        usage = ["exit",
                 "Leave the context current plugin back to the default"]
        self.io.print_usage(usage)

    def do_exit(self, arg):
        """Alias for back"""
        return self.do_back(arg)

    """
    CMD: Autorun

    """
    def complete_autorun(self, text, line, arglist, state, begidx, endidx):
        """Command completion routine for autorun"""
        if state == 1:
            return [item for item in ("on","off") if item.lower().startswith(text.lower())]
        return [""]

    def help_autorun(self):
        usage = ["autorun [mode]",
                 "Enable (on) or disable (off) autorun features"]
        self.io.print_usage(usage)
    
    def do_autorun(self, input):
        """Set autorun mode"""
        argc, argv = util.parseinput(input, 1)

        if argc == 0:
            self.io.print_autoruncmds(self.autorun, self.autorunvars)
        else:
            if argv[0].lower() in ("on", "enabled", "yes"):
                self.autorun = True
                self.io.print_msg("Autorun is ON")
            elif argv[0].lower() in ("off", "disabled", "no"):
                self.autorun = False
                self.io.print_msg("Autorun is OFF")

    """
    CMD: Enter
    
    """
    def complete_enter(self, text, line, arglist, state, begidx, endidx):
        """Command completion routine for enter."""
        if state == 1:
            return [item 
                    for item in self.get_manager_types()
                    if item.upper().startswith(text.upper())]
        return [""]

    def help_enter(self):
        usage = ["enter [type]",
                 "Enter the context of the given plugin type"]
        self.io.print_usage(usage)
                 
    def do_enter(self, input):
        """Enter the context of a plugin"""
        argc, argv = util.parseinput(input, 1)

        if argc == 0:
            self.io.print_module_types({'modules' : self.get_active_plugin_names()})
        else:
            manager = self.get_manager(argv[0])
            if manager is None:
                raise exception.CmdErr, "No plugin type for %s" % argv[0]

            if manager.get_active_name() is "None":
                raise exception.CmdErr, "No active plugin for %s" % argv[0]
            
            self.setcontext(manager)
            self.setprompt()

    """
    CMD: Use
    
    """
    def complete_use(self, text, line, arglist, state, begidx, endidx):
        """Command completion routine for use."""
        typeList = self.get_manager_types()

        if state == 1:
            pluginlist = []
            for manager in self.get_manager_list():
                pluginlist += manager.get_plugin_names()
            return [item 
                    for item in sorted(pluginlist) 
                    if item.upper().startswith(text.upper())]
        else:
            return []

    def help_use(self):
        usage = ["use [name]",
                 "Set the active plugin and enter the context of"
                 "the plugin"]
        self.io.print_usage(usage)

    def do_use(self, input):
        """Activate a plugin for use and enter context"""
        argc, argv = util.parseinput(input, 2)
        if argc == 0:
            for manager in self.get_manager_list():
                plugins = [ (plugin.getName(), plugin.getVersion())
                            for plugin in manager.get_plugins() ]
                args = {'module'  : manager.get_name(),
                        'plugins' : plugins}
                self.io.print_module_lists(args)
        elif argc == 1:
            for manager in self.get_manager_list():
                if argv[0].lower() in [x.lower() for x in manager.get_plugin_names()]:
                    manager.set_active_plugin(argv[0])
                    plugin = manager.get_active_plugin()
                    self.io.newline()
                    self.io.print_warning("Entering Plugin Context :: %s" % plugin.getName())
                    self.io.print_msg("Applying Global Variables")
                    try:
                        plugin.setParameters(self.fbglobalvars)
                    except:
                        pass
                    self.io.newline()
                    self.do_enter(manager.get_type())
                    # At this point, grab anything that is setup to execute 
                    # automatically according to the Fuzzbunch.xml file and
                    # execute it.  This is where 'apply' will get run when you
                    # enter a context
                    if self.autorun: 
                        for auto,msg in self.autorunvars.get(manager.get_type(), []):
                            if msg:
                                self.runcmd_noex("echo %s" % msg)
                            self.runcmd_noex(auto)
                    break
            else:
                raise exception.CmdErr, "Plugin %s not found!" % argv[0]

    """
    CMD: Show
    
    """
    def complete_show(self, text, line, arglist, state, begidx, endidx):
        """Command completion routine for show."""
        typeList = self.get_manager_types()
        if state == 1:
            return [item
                    for item in sorted(typeList)
                    if item.upper().startswith(text.upper())]
        elif state == 2:
            if arglist[1] not in typeList:
                return [""]
            else:
                pluginList = self.get_manager(arglist[1]).get_plugin_names()
                return [item
                        for item in pluginList
                        if item.upper().startswith(text.upper())]
        else:
            return []

    def help_show(self):
        usage = ["show [type] [name]",
                 "Show information about the types and specific plugins"]
        self.io.print_usage(usage)
   
    def do_show(self, input):
        """Show plugin info"""
        argc, argv = util.parseinput(input, 2)

        if argc == 0:
            self.io.print_module_types({'modules' : self.get_active_plugin_names()})
        elif argc == 1:
            plugins = [ (plugin.getName(), plugin.getVersion()) 
                  for plugin in self.get_manager(argv[0]).get_plugins() ]
            args = {'module'  : argv[0],
                    'plugins' : plugins}
            self.io.print_module_lists(args)
        elif argc == 2:
            self.get_manager(argv[0]).print_info(argv[1])


    """
    Contract handling user commands

    """

    """
    CMD: Session
    
    """
    def complete_session(self, text, line, arglist, state, begidx, endidx):
        """Command completion for session command."""
        itemList = [str(i) 
                    for i,item in enumerate(sorted(self.session.get_itemlist()))]
        if state == 1:
            return [i for i in itemList if i.startswith(text)]
        return [""]

    def help_session(self):
        usage = ["session [index]",
                 "Show inheritable plugin settings from session"]
        self.io.print_usage(usage)

    def do_session(self, input):
        """Show session items"""
        argc, argv = util.parseinput(input, 1)

        if argc == 0:
            items = [ (item.value.get_longname(), item.value.get_status())
                      for item in self.session.get_itemlist() ]
            self.io.print_session_items({'items' : items})
        else:
            try:
                index = int(argv[0])
            except ValueError: 
                raise exception.CmdErr, "Invalid index"

            item = self.session.get_item(index)
            args = {'name'   : item.get_name(),
                    'status' : item.get_status(),
                    'info'   : item.get_info()}
            self.io.print_session_item(args)

    """
    CMD: Mark
    
    """
    def complete_mark(self, text, line, arglist, state, begidx, endidx):
        """Command completion for mark command."""
        itemList = [str(i) 
                    for i,item in enumerate(sorted(self.session.get_itemlist()))]
        if state == 1:
            return [i for i in itemList if i.startswith(text)]
        elif state == 2:
            if arglist[1] not in itemList:
                return [""]
            else:
                markingList = ["READY", "RUNNING", "FAIL", "USED"]
                return [item for item in markingList if item.startswith(text.upper())]
        return [""]

    def help_mark(self):
        usage = ["mark [index] [value]",
                 "Mark a session item with a new status",
                 "Valid markings:",
                 "  READY    Plugin settings are ready to be used",
                 "  RUNNING  Plugin is not finished executing",
                 "  FAIL     Plugin failed to complete successfully",
                 "  USED     Plugin settings have been used"]
        self.io.print_usage(usage)

    def do_mark(self, input):
        """Mark a session item"""
        argc, argv = util.parseinput(input, 2)

        if argc == 0:
            return self.do_session(input)
        elif argc == 1:
            return self.help_mark()
        elif argc == 2:
            try:
                index = int(argv[0])
                value = argv[1]
            except (IndexError, ValueError): 
                raise exception.CmdErr, "Invalid index"

            item = self.session.get_item(index)
            item.set_status(value)
            self.io.print_success("Item marked as %s" % value)

    """
    Redirection support
    
    """

    """
    CMD: Redirect
    
    """
    def complete_redirect(self, text, line, arglist, state, begidx, endidx):
        """Command completion routine for redirect"""
        if state == 1:
            return [item for item in ("on","off")
                         if item.lower().startswith(text.lower())]
        return [""]

    def help_redirect(self):
        usage = ["redirect [on|off]",
                 "Turn redirection on or off.  If no arguments, then",
                 "displays the known redirection state."]
        self.io.print_usage(usage)

    def do_redirect(self, input):
        """Configure redirection"""
        argc, argv = util.parseinput(input, 2)
        self.io.newline()
        if argc == 0:
            # No arguments on command line.  Print the status of redirection
            if self.redirection.is_active():
                self.io.print_success("Redirection ON")
            else:
                self.io.print_warning("Redirection OFF")
        elif argc == 1:
            # Set redirection to on or off
            if argv[0].lower() in ("off", "no"):
                self.redirection.off()
                self.io.print_warning("Redirection OFF")
            elif argv[0].lower() in ("on", "yes"):
                self.redirection.on()
                self.io.print_success("Redirection ON")
            else:
                raise exception.CmdErr, "Invalid input"
            

    """
    Global variable support

    """

    """
    CMD: Setg
    
    """
    def complete_setg(self, text, line, arglist, state, begidx, endidx):
        if state == 1:
            return [item[0] 
                    for item in sorted(self.fbglobalvars.items()) 
                    if item[0].upper().startswith(text.upper())]
        return [""]

    def help_setg(self):
        usage = ["setg [variable name] [value]",
                 "Set a global variable to value.  If the variable",
                 "does not already exist then it will be created.",
                 "  L:value  - Input ascii string to widechar",
                 "  H:value  - Input hex string"]
        self.io.print_usage(usage)

    @util.charconvert
    def do_setg(self, input):
        """Set a global variable"""
        readonly_globals = ["logdir", "tmpdir"]
        argc, argv = util.parseinput(input, 2)
        if argc in (0,1):
            args = {'title' : "Global Variables",
                    'vars'  : self.fbglobalvars.items()}
            self.io.print_set_names(args)
        elif argc > 1:
            inputList = input.strip().split()
            value = " ".join(inputList[1:])
            self.fbglobalvars[inputList[0]] = value
            self.io.print_success("Set %s => %s" % (inputList[0], value))
            if inputList[0].lower() == "logdir":
                self.set_logdir(value)
                self.fbglobalvars["TmpDir"] = value
            elif inputList[0].lower() == "tmpdir":
                raise exception.CmdErr, "TmpDir is readonly and set with LogDir"
            elif inputList[0].lower() == "color":
                # Supports fix for bug #2910
                self.io.setcolormode( value.lower() == "true" )

    """
    CMD: unsetg
    """
    def complete_unsetg(self, text, line, begidx, endidx):
        paramlist = self.fbglobalvars.items()
        if begidx == 7:
            return [item[0] 
                    for item in sorted(paramlist) 
                    if item[0].upper().startswith(text.upper())]
        return [""]

    def help_unsetg(self):
        usage = ["unsetg [variable name]",
                 "Unset a global variable."]
        self.io.print_usage(usage)

    def do_unsetg(self, input):
        """Unset a global variable"""
        argc, argv = util.parseinput(input, 2)
        if argc == 0:
            args = {'title' : "Global Variables",
                    'vars'  : self.fbglobalvars.items()}
            self.io.print_set_names(args)
        else:
            try:
                del self.fbglobalvars[argv[0]]
            except KeyError:
                raise exception.CmdErr, "Invalid input"
            self.io.print_success("Unset %s" % argv[0])

    """
    CMD: Toolpaste
    """
    def complete_toolpaste(self, text, line, arglist, state, begidx, endidx):
        if state == 1:
            return [item 
                    for item in sorted(self.conv_tools.keys()) 
                    if item.upper().startswith(text.upper())]
        return [""]

    def toolpaste_base64(self, paramname):
        import base64
        input = self.io.get_input_line('Base64 > ')
        if input:
            input = base64.b64encode(input)
            self.do_setg("%s %s" %(paramname, input))
        else:
            raise exception.CmdErr, "Invalid input"

    def toolpaste_sha1(self, paramname):
        import hashlib
        input = self.io.get_input_line('SHA1 > ')
        if input:
            input = hashlib.sha1(input).hexdigest()
            self.do_setg("%s h:%s" %(paramname, input))
        else:
            raise exception.CmdErr, "Invalid input"

    def toolpaste_md5(self, paramname):
        import hashlib
        input = self.io.get_input_line('MD5 > ')
        if input:
            input = hashlib.md5(input).hexdigest()
            self.do_setg("%s h:%s" %(paramname, input))
        else:
            raise exception.CmdErr, "Invalid input"

    def toolpaste_ep(self, paramname):
        input = self.io.get_input_lines('MultiLine > ')
        self.do_setg("%s h:%s" %(paramname, input))

    def help_toolpaste(self):
        usage = ["toolpaste [operation type] [variable name]",
                "Transforms pasted input and exports as global variable",
                "Types:",
                "  MultiLine  Multiline hex input from EP",
                "  MD5        MD5Sum of input",
                "  SHA1       SHA1 of input",
                "  Base64     Base64 of input"]
        self.io.print_usage(usage)

    def do_toolpaste(self, input):
        """Paste and convert data from external tool output"""
        argc, argv = util.parseinput(input, 2)
        if argc in (0,1):
            self.help_toolpaste()
        elif argc == 2:
            try:
                self.conv_tools[argv[0]](argv[1])
            except KeyError:
                raise exception.CmdErr, "Invalid input"


    """
    Targetting support

    """
    """
    CMD: Retarget
    
    """
    def help_retarget(self):
        usage = ["retarget",
                 "Retarget the current session"]
        self.io.print_usage(usage)

    def getip_prompt(self, prompt, default):
        done = False
        while not done:
            try:
                targetvar = self.io.prompt_user("Default " + prompt, default, gvars=self.fbglobalvars)
                targetvar = util.validateip(targetvar)
                if not targetvar:
                    raise exception.CmdErr, "Invalid " + prompt
            except exception.PromptErr, err:
                raise exception.PromptErr, err.error
            except exception.PromptHelp, err:
                pass
            except exception.CmdErr, err:
                self.io.print_error(err.getErr())
            else:
                done = True
        return targetvar

    def _get_projectlist(self, d):
        """Gets a list of directories, which should be coverterms"""
        dirlist = []
        try:
            os.makedirs(d)
        except:
            if not os.path.exists(d):
                raise
        map(lambda x: os.path.isdir(os.path.join(d, x)) and dirlist.append(x), os.listdir(d))
        return dirlist
        
    def _prompt_for_project(self, projects):
        try:
            vals = [(str(i), v) for i,v in enumerate(projects)]
            vals.append( tuple([str(len(vals)), "Create a New Project"]) )
            widths = self.io.get_column_max_width(vals)
            widths[0] = max(6, widths[0])
            widths[1] = max(len("Project"), widths[1])
            self.io.print_table(widths, [("Index", "Project")], vals)
            c = self.io.prompt_user("Project", "0", gvars=self.fbglobalvars)
            if int(c)+1 < len(vals):
                try:
                    return projects[int(c)].lower()
                except IndexError:
                    self.io.print_error("Invalid choice")
                    return None
            elif int(c)+1 == len(vals):
                return self.io.prompt_user("New Project Name", None, gvars=self.fbglobalvars).lower()
            else: 
                self.io.print_error("Invalid choice")
                return None
        except KeyboardInterrupt:
            raise
        except:
            return None
        
    def _prompt_for_logging(self, target, oldproject):
        try:
            if oldproject is None:
                oldproject = ''
            base_logdir = self.get_logdir()
            base_logdir = ''.join(base_logdir[:base_logdir.find(oldproject)])
            if len(base_logdir) == 0:
                base_logdir = self.get_logdir()
            
            # Request #1699: Change to include compatible logging structure
            self.io.newline()
            log_dir = self.io.prompt_user("Base Log directory", base_logdir, gvars=self.fbglobalvars)
            log_dir = os.path.abspath(log_dir)

            # Get the list of projects
            self.io.print_msg("Checking %s for projects" % (log_dir))
            projects = self._get_projectlist(log_dir)
            
            # Give the user the choice to use an existing project or create a new one            
            project = None
            while project is None:
                project = self._prompt_for_project(projects)
            
            log_dir = os.path.join(log_dir, project, 'z'+target.replace(":", "_"))  # To support IPv6 address in log files
            if not self.io.prompt_yn("Set target log directory to '%s'?" % (log_dir)):
                log_dir = self.io.prompt_user("Target log directory?", log_dir, gvars=self.fbglobalvars)
            try:
                os.makedirs(log_dir)            # Fix from 3.2.0 - Don't reinvent the wheel
            except:
                if not os.path.exists(log_dir):
                    raise
            self.set_logdir(log_dir)
            return (project, log_dir)
        except OSError:
            self.io.print_warning("Access Denied to '%s'! Choose a different log directory." %(log_dir))
            return (None, None)
       

    def do_retarget(self, *ignore):
        """Set basic target info"""
        self.do_back(self)

        self.io.newline()
        self.io.print_msg("Retargetting Session")
        self.io.newline()
        try:
            target = self.getip_prompt("Target IP Address",
                                       self.fbglobalvars.get('targetip', ''))
            callback = self.getip_prompt("Callback IP Address", '')
            redirection = self.io.prompt_user("Use Redirection", "yes")
            if redirection.lower() in ("no", "n", "off"):
                redirection = "off"
            else:
                redirection = "on"
            # Setup logging
            log_dir = None
            project = self.fbglobalvars.get('project', '')
            while log_dir is None:
                (project, log_dir) = self._prompt_for_logging(target, project)

        except (exception.PromptErr, exception.CmdErr), err:
            self.io.print_error(err.getErr())
            return

        self.io.newline()
        self.io.print_msg("Initializing Global State")
        self.do_setg("TargetIp   %s" % target)
        self.do_setg("CallbackIp %s" % callback)
        self.do_redirect(redirection)
        self.do_setg("LogDir %s" % log_dir)
        self.do_setg("Project %s" % (project))
        self.io.newline()
        if self.log:
            if 'Project' in self.fbglobalvars: self.log.set(project_name=self.fbglobalvars['Project'])
            self.log.open()
    """
    CMD: Standard OP

    """
    def help_standardop(self):
        self.io.print_standardop()

    def do_standardop(self, *ignore):
        """Print standard OP usage message"""
        self.help_standardop()


