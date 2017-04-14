"""
IO Handling classes

The IO Handler works as a wrapper around all user input and output.

Theoretically, to change the way Fuzzbunch looks should only require changing
this file.  Specialized print functions provide a template-like facility.

"""
import sys
import exception
from util import variable_replace

MAX_OUTPUT_ROWS = 5
MAX_PROMPT_ECHO_LEN = 50

try:
    try:
        import readline
    except ImportError:
        import pyreadline as readline
    HAVE_READLINE = True
except:
    HAVE_READLINE = False

mswindows = (sys.platform == "win32")

__all__ = ["IOhandler"]

"""
Valid Attributes : none,      bold,
                   faint,     italic,
                   underline, blink,
                   fast,      reverse,
                   concealed

Valid Colors : grey     red 
               green    yellow 
               blue     magenta 
               cyan     white
"""
COLORIZEMAP = {"[-]" : {"fg" : "red",     "attr" : "bold"},
               "[+]" : {"fg" : "green",   "attr" : "bold"},
               "[!]" : {"fg" : "red",     "attr" : "bold"},
               "[*]" : {"fg" : "green",   "attr" : "bold"},
               "[?]" : {"fg" : "blue",    "attr" : "bold"}}

VMAP = {"[-]" : {"fg" : "magenta",   "attr" : "bold"},
        "[+]" : {"fg" : "magenta",   "attr" : "bold"},
        "[!]" : {"fg" : "magenta",   "attr" : "bold"},
        "[*]" : {"fg" : "magenta",   "attr" : "bold"},
        "[?]" : {"fg" : "magenta",   "attr" : "bold"}}

class DevNull:
    def write(self, *ignore):
        pass
    def close(self):
        pass
    def flush(self):
        pass

def truncate(string, length=MAX_PROMPT_ECHO_LEN):
    return string if (len(string) <= length) else ("%s... (plus %d characters)" % (string[:length], len(string) - length))

class IOhandler:
    """Handle I/O for fuzzbunch commands"""

    def __init__(self, stdin=None, 
                       stdout=None, 
                       use_raw=1,
                       noprompt=False,
                       completekey='tab',
                       enablecolor=True,
                       history=4096):

        """

        @param  stdin
        @param  stdout
        @param  use_raw         
        @param  noprompt        Do we want to prompt for values upon plugin execution?
        @param  completekey     Command completion
        """

        import sys
        if stdin is not None:
            self.stdin = stdin
        else:
            self.stdin = sys.stdin

        if stdout is not None:
            self.stdout = stdout
        else:
            self.stdout = sys.stdout

        self.stderr = self.stdout

        self.logout = DevNull()
        self.noprompt  = noprompt
        self.raw_input = use_raw
        self.completekey = completekey
        self.havecolor = False          # Are we in color mode?
        self.enablecolor = enablecolor  # Do we want to permanently enable color.  Change to False to disable
        self.colormode = "ansi"
        self.colormap  = COLORIZEMAP
        self.historysize = history

    def setlogfile(self, logfile):
        self.logout.close()
        try:
            self.logout = open(logfile, "w")
        except:
            self.logout = DevNull()

    def setcolormode(self, isEnabled):
        """Switch to enable or disable color output"""
        self.enablecolor=isEnabled

    def switch(self):
        if self.colormap == COLORIZEMAP:
            self.colormap = VMAP
        else:
            self.colormap = COLORIZEMAP

    def pre_input(self, completefn):
        if self.raw_input:
            if HAVE_READLINE:
                import atexit
                self.old_completer = readline.get_completer()
                # Fix Bug #3129: Limit the history size to consume less memory
                readline.set_history_length(self.historysize)   
                readline.set_completer(completefn)
                readline.parse_and_bind(self.completekey+": complete")
                try:
                    readline.read_history_file()
                except IOError:
                    pass
                atexit.register(readline.write_history_file)
                self.havecolor = True
                if mswindows and self.enablecolor:
                    self.cwrite = readline.GetOutputFile().write_color
                else:
                    self.cwrite = self.stdout.write

    def post_input(self):
        if self.raw_input:
            if HAVE_READLINE:
                readline.set_completer(self.old_completer)
                self.havecolor = False
        self.cwrite = None

    """
    User input handling

    """
    def get_input_lines(self, prompt):
        done = False
        lines = []
        while not done:
            line = self.get_input(prompt)
            if line == 'EOF':
                done = True
            else:
                lines.append(line)
        return ''.join(lines)

    def get_input_line(self, prompt):
        line = self.get_input(prompt)
        if line == 'EOF':
            return ''
        else:
            return line.strip()

    def get_input(self, prompt):
        if self.raw_input:
            try:
                line = raw_input(prompt)
            except (EOFError, KeyboardInterrupt):
                line = 'EOF'
        else:
            self.write(prompt)
            self.flush()
            line = self.stdin.readline()
            if not len(line):
                line = 'EOF'
            else:
                line = line[:-1]
        return line
       
    def prompt_user(self, msg, default=None, params=None, gvars=None):
        if self.noprompt:
            return variable_replace(default, gvars)     # Fix a small bug in 3.2.0

        if default is not None:
            # If we pass a default, interepret any variables (marked with '$')
            interpreted_default = variable_replace(default, gvars)
            p = "[?] %s [%s] : " % (msg, truncate(interpreted_default))
        else:
            # No default, so empty string
            p = "[?] %s : " % msg
            interpreted_default = ""

        if self.havecolor and self.enablecolor:
            p = self.colorize(p)
        line = self.get_input(p)

        # Check the user input
        if line.upper() in ("EOF",):
            self.newline()

        if line.upper() in ("EOF", "Q", "QUIT"):
            raise exception.PromptErr, "Aborted by user"

        if line.upper() in ("?", "HELP"):
            raise exception.PromptHelp, "No help available"

        # Retrieve the line, and replace any '$' vars with their values
        line = variable_replace(line, gvars)
        if not len(line.strip()):
            # If line is empty, just use the default
            line = interpreted_default

        # If it's a choice, figure out which value they chose
        if params:
            try:
                index = int(line)
                line = params[index][0]
            except (IndexError, ValueError):
                raise exception.CmdErr, "Invalid input"

        return line

    def prompt_yn(self, msg, default="Yes", params=None, gvars=None):
        if default.lower() not in ["yes", 'y', 'no', 'n']:
            default = 'No'
        yn = self.prompt_user(msg, default, params=params, gvars=gvars).lower()
        if yn == 'yes' or yn == 'y':
            return True
        return False

    def prompt_continue(self):
        line = self.prompt_user("Execute Plugin?", "Yes")
        if line.lower() not in ("yes", "y"):
            raise exception.CmdErr, "Execution Aborted"
        return

    def prompt_confirm_redir(self):
        line = self.prompt_user("Press Any Key To Continue")
        del line
        return

    def prompt_runsubmode(self, text):
        line = self.prompt_user(text, "Yes")
        if line.lower() not in ("yes", "y"):
            return False
        else:
            return True

    """
    Basic user output handling

    """
    def flush(self):
        self.logout.flush()
        self.stdout.flush()

    def log(self, line):
        line += "\n"
        self.logout.write(line)

    def write(self, line):
        self.log(line)
        line += "\n"

        # Fix bug #2910
        if self.havecolor and self.enablecolor:
            try:
                self.cwrite(self.colorize(line))
            except LookupError:
                # We failed to print in color.  This is a problem looking up the encoding
                # Permanently disable color and continue
                self.havecolor = False
                self.enablecolor = False
                self.stdout.write(line)
        else:
            self.stdout.write(line)
        self.flush()

    def newline(self):
        self.write("")

    def print_error(self, line):
        self.write("[-] " + line)

    def print_success(self, line):
        self.write("[+] " + line)

    def print_warning(self, line):
        self.write("[!] " + line)

    def print_msg(self, line):
        self.write("[*] " + line)


    """
    Output formatting help

    """
    def get_single_col_max_width(self, data, colnum):
        # Min len = 6
        maxlen = 6
        for row in data:
            for i,col in enumerate(row):
                if i == colnum:
                    maxlen = max(maxlen, len(col))
        return maxlen

    def get_column_max_width(self, data):
        maxlens = list(0 for i in range(0, len(data[0])))
        for row in data:
            for i,col in enumerate(row):
                maxlens[i] = max(maxlens[i], len(col), 1)
        return maxlens

    def print_headingline(self, msg):
        self.newline()
        self.write(msg)
        self.write("=" * len(msg))
        self.newline()

    def print_vheading(self, vector):
        self.newline()
        for v in vector:
            self.write(v)
        self.newline()

    def vprint(self, fmt, vector, max_str_len=None):
        for v in vector:
            if max_str_len:
                if isinstance(v, tuple):
                    v = tuple(truncate(field, max_str_len) for field in v)
                else:
                    v = truncate(field, max_str_len)
            self.write(fmt % v)
        self.newline()

    def makeplural(self, name, count):
        if count < 2:
            return name

        if name.endswith("h"):
            return name + "es"
        elif name.endswith("s"):
            return name
        else:
            return name + "s"

    """
    Color support

    """
    def colorize(self, line):
        for pattern, attrs in self.colormap.items():
            plen = len(pattern)
            index = line.find(pattern)
            if self.colormap == VMAP:
                pattern = "[TF]"
            if index != -1:
                r = index + plen
                line = (line[:index] +
                        self.color(**attrs) +
                        pattern +
                        self.color() +
                        line[r:])
                return line
        return line

    def color(self, fg=None, bg=None, attr=None):
        if self.colormode != "ansi":
            return ""

        attrs  = 'none bold faint italic underline blink fast reverse concealed'
        colors = 'grey red green yellow blue magenta cyan white'
        attrs  = dict((s,i) for i,s in enumerate(attrs.split()))
        colors = dict((s,i) for i,s in enumerate(colors.split()))
        fgoffset, bgoffset = 30,40

        cmd = ["0"]

        if fg in colors:
            cmd.append("%s" % (colors[fg] + fgoffset))
        if bg in colors:
            cmd.append("%s" % (colors[bg] + bgoffset))
        if attr:
            for a in attr.split():
                if a in attrs:
                    cmd.append("%s" % attrs[a])

        return "\033[" + ";".join(cmd) + "m"

                
    """
    Specialized output routines

    """
    # OK because it's readline
    def print_history(self, args):
        self.newline()
        for index,item in args['items']:
            self.write("%4d  %s" % (index, item))
        self.newline()
    def print_cmd_list(self, args):
        self.print_headingline(args['title'])
        cmds = args['commands']

        cmds.insert(0, ("Command", "Description"))
        cmds.insert(1, ("-------", "-----------"))
        self.vprint("  %-15s %s", cmds)

    def print_banner(self, args):
        self.write(args['banner'])
        self.write("--[ Version %s" % args['version'])
        for count, type in args['stats']:
            self.write("  * %d %s" % (count, self.makeplural(type, count)))
        self.newline()

    def print_opensessions(self, args):
        self.newline()
        for session in enumerate(args['sessions']):
            self.print_warning("Session item %d (%s) has open contract" % session)
        self.newline()

    def print_usage(self, arg):
        self.write("Usage: %s\n" % arg[0])
        self.write("\n".join(arg[1:]))

    def print_module_lists(self, args):
        category = args['module']
        modules  = args['plugins']
        self.print_headingline("Plugin Category: %s" % category)
        modules.sort()
        modules.insert(0, ("Name", "Version"))
        modules.insert(1, ("----", "-------"))
        widths = self.get_column_max_width(modules)
        self.vprint("  %%-%ds %%s" % (widths[0] + 4), modules)

    def print_module_types(self, args):
        self.print_headingline("Plugin Categories")
        modules = args['modules']
        modules.sort()
        modules.insert(0, ("Category", "Active Plugin"))
        modules.insert(1, ("--------", "-------------"))
        widths = self.get_column_max_width(modules)
        self.vprint("  %%-%ds %%s" % (widths[0] + 4), modules)

    def print_session_item(self, args):
        self.print_vheading(("Name: %s" % args['name'],
                            "Status: %s" % args['status']))

        for type,info in args['info']:
            self.write("%s:\n" % type)
            if info:
                params = [x[:2] for x in dict(info.get_paramlist()).values()]
                params.insert(0, ("Name", "Value"))
                params.insert(1, ("----", "-----"))
                widths = self.get_column_max_width(params)
                self.vprint("  %%-%ds %%s" % (widths[0] + 4), params, MAX_PROMPT_ECHO_LEN)


    def print_session_items(self, args):
        items = args['items']
        self.print_headingline("Session History")
        if not items:
            self.write("  *Empty*\n")
            self.newline()
        else:
            _list = [("Index", "Name", "Status"),
                     ("-----", "----", "------")]
            for index,item in enumerate(items):
                _list.append((str(index), item[0], item[1]))

            widths = self.get_column_max_width(_list)
            fmt    = "%%7s %%-%ds %%s" % (widths[1] + 4)
            self.vprint(fmt, _list, MAX_PROMPT_ECHO_LEN)

    # Move to table
    def is_table_row_empty(self, v):
        ncols = len(v)
        for i in range(0, ncols):
            if len(v[i]) > 0 and len(v[i][0]) > 0:
                return False
        return True

    # Move to table
    def get_table_row(self, vector):
        ncols = len(vector)

        while not self.is_table_row_empty(vector):
            line = []
            for i in range(0, ncols):
                try:
                    val = vector[i].pop(0)
                except IndexError:
                    val = ""
                line.append(val)
            yield line

    # Move to Table
    def print_row(self, widths, data):
        fmt = "%%-%ds    " * len(widths) % tuple(widths)
        vectors = []
        for i,width in enumerate(widths):
            vector = []
            col = data[i]
            printed_rows = 0
            while col:
                if printed_rows > MAX_OUTPUT_ROWS:
                    vector.append("... (plus %d more lines)" % (len(col) / widths[i]))
                    break
                vector.append(col[:widths[i]])
                col = col[widths[i]:]
                printed_rows += 1
            vectors.append(vector)

        for line in self.get_table_row(vectors):
            self.write(fmt % tuple(line))

    # Move to Table
    def print_table(self, widths, heading, params):
        sep = tuple(['-' * len(word) for word in heading[0]])
        heading.append(sep)
        heading.extend(params)

        for d in heading:
            self.print_row(widths, d)
        self.newline()

    def print_set_names(self, args):
        self.print_headingline("Module: %s" % args['title'])
        params = args['vars']
        if not params:
            self.write(" *Empty")
            self.newline()
        else:
            widths = [self.get_single_col_max_width(params, 0), 50]
            self.print_table(widths, [("Name", "Value")], params)

    def print_exe_set_names(self, args):
        if not args['session']:
            return self.print_set_names(args)
        self.print_headingline("Module: %s" % args['title'])
        params = args['vars']
        session = args['session']['params']

        print_params = []
        for param in params:
            if session.get(param.name):
                realval = truncate(session.get(param.name))
                redirval = truncate(param.value)
            else:
                realval = truncate(param.value)
                redirval = ""
            print_params.append((param.name, realval, redirval))
        widths = self.get_column_max_width(print_params)
        widths[1] = max(widths[1], len("Set Value"))
        widths[2] = max(widths[2], len("Redirected Value"))
        self.print_table(widths, [("Name", "Set Value", "Redirected Value")], print_params)

    def print_set_attributes(self, title, param, attribs):
        self.print_vheading(("Module: %s" % title,
                            "Parameter: %s" % param))

        attribs.insert(0, ("Parameter Attribute", "Value"))
        attribs.insert(1, ("-------------------", "-----"))
        widths = self.get_column_max_width(attribs)
        fmt = "  %%-%ds %%s" % (widths[0] + 4)
        self.vprint(fmt, attribs)


    def print_set_choices(self, choices):
        choices.insert(0, ("Parameter Options", "Description"))
        choices.insert(1, ("-----------------", "-----------"))
        widths = self.get_column_max_width(choices)
        fmt = "    %%-%ds %%s" % (widths[0] + 4)
        self.vprint(fmt, choices)
        

    def print_sorted_vals(self, sorted_vals, vals):
        i = 0
        for cat in ("Contract", "History", "Other"):
            self.write("\n---[ %s\n" % cat)
            for index in sorted_vals[cat]:
                (val, name, label, info) = vals[index]
                self.write("   %d) %s (%s)" % (i, val, name))
                i += 1

        if len(sorted_vals["Contract"]):
            default = 0
        else:
            default = i - 1

        return i,default

    def print_param_list(self, param_list):
        self.write("")
        widths = self.get_column_max_width(param_list)
        widths[0] = max(widths[0], len('Name'))
        widths[1] = max(widths[1], len('Value'))
        widths[2] = 50
        self.print_table(widths, [('Name', 'Value', 'Description')], param_list)

    def print_touch_info(self, args):
        touchlist = args['touchlist']
        self.print_headingline("Touch List")

        if not touchlist:
            self.write("  *Empty*\n")
            self.newline()
        else:
            hdrlist = []
            hdrlist.append(("Index", "Name", "Description"))
            hdrlist.append(("-----", "----", "-----------"))

            widths = self.get_column_max_width(touchlist)
        
            fmt = "%%7s  %%-%ds %%s" % (widths[0] + 4)
            self.vprint(fmt, hdrlist)

            fmt = "%%7d  %%-%ds %%s (%%s)" % (widths[0] + 4)
            for i,touch in enumerate(touchlist):
                self.write(fmt % ((i,) + touch))
            self.newline()

    """
    Apply command
    
    """
    def print_apply_prompt_list(self, args):
        if args['default']:
            default = args['default']
        else:
            default = '[NOT SET]'
        vals = args['vals']
        vals = [(str(i), args['contract'], v) for i,v in enumerate(args['vals'])]
        vals.append((str(i+1), "Current Value", default))

        widths = self.get_column_max_width(vals)
        widths[0] = len("Index")
        widths[2] = 50

        self.newline()
        self.print_msg("%s :: Deconflict" % args['variable'])
        self.newline()
        self.print_table(widths, [("Index", "Session ID", "Value")], vals)

    def print_apply_prompt(self, args):
        if args['default']:
            default = args['default']
        else:
            default = '[NOT SET]'
        vals = [(str(i), contract.get_item_info(), param.value.value)
                for i,(param,contract) in enumerate(args['vals'])]
        vals.append((str(i+1), "Current Value", default))

        widths = self.get_column_max_width(vals)
        widths[0] = len("Index")
        widths[2] = 50

        self.newline()
        self.print_msg("%s :: Deconflict" % args['variable'])
        self.newline()
        self.print_table(widths, [("Index", "Session ID", "Value")], vals)


    """
    Prompt Command

    """
    def print_prompt_param(self, args, default):
        self.newline()
        self.print_msg(" %s :: %s" % (args['name'], args['description']))

        fmt = []
        if args['attribs']:
            fmt.append("")
            widths = self.get_column_max_width(args['attribs'])
            choice_fmt = "   %%s%%d) %%-%ds %%s" % (widths[0] + 4)
            for i,(attr,val) in enumerate(args['attribs']):
                if default and i == int(default): 
                    markdef = "*"
                else:
                    markdef = " "
                fmt.append(choice_fmt % (markdef,i,attr,val))
        self.vprint("%s", fmt)

    def print_prompt_param_help(self, args):
        self.newline()
        fmt = [ "     Name : %s" % args['name'],
                "     Desc : %s" % args['description'],
                "     Type : %s" % args['type'],
                " Required : %s" % args['required'],
                " Is Valid : %s" % args['valid']]
        if args['type'] != "Choice":
            fmt.append("    Value : %s" % args['value'])

        self.vprint("%s", fmt)

    """
    Redirection

    """
    def print_localiplist(self, iplist):
        self.print_headingline("Local IP Addresses")
        for ip in iplist:
            self.write(" * %s " % ip)
        self.newline()

    def print_redir_info(self, redir, paramList):
        #params = iDict(paramList)

        try:
            self.print_headingline("Local")
            if not redir or not redir['local']:
                self.write(" *Empty* ")
            else:
                for l in redir['local']:
                    self.write("Name: %s" % l.name)
                    self.write("Protocol: %s" % l.protocol)
                    self.write("Listen Address: %s" % l.listenaddr)
                    self.write("Listen Port: %s" % l.listenport)
                    self.write("Destination Address: %s" % l.destaddr)
                    self.write("Destination Port: %s" % l.destport)
                    self.write("Source Port : %s" % l.srcport)
                    self.write("")
            self.print_headingline("Remote")
            if not redir or not redir['remote']:
                self.write(" *Empty* ")
            else:
                for r in redir['remote']:
                    self.write("Name: %s" % r.name)
                    self.write("Protocol: %s" % r.protocol)
                    self.write("Listen Address: %s" % r.listenaddr)
                    self.write("Listen Port: %s" % r.listenport)
                    self.write("Destination Address: %s" % r.destaddr)
                    self.write("Destination Port: %s" % r.destport)
        except:
            # XXX - ESKE. Due to group visibility some of the redir params
            # being looked up might not be in the params list
            pass
        self.write("")




    def print_local_tunnels(self, tunnels):
        data = [("Proto", "Listen IP", "Source IP", "Destination IP")]

        for tunnel in tunnels:
            if tunnel.srcport is None:
                srcport = 'ANY'
            else:
                srcport = '0'
            data.append((tunnel.protocol,
                        tunnel.listenaddr + ":" + tunnel.listenport,
                        "Redirector" + ":" + srcport,
                        tunnel.destaddr + ":" + tunnel.destport))

        maxlens = self.get_column_max_width(data)
        data.insert(1, tuple(["-" * length for length in maxlens]))

        fmt = "%%-%ds   %%-%ds   %%-%ds   %%-%ds" % tuple(maxlens)
        for line in data:
            self.write(fmt % line)


    def print_remote_tunnels(self, tunnels):
        data = [("Proto", "Destination IP", "Listen IP", "Target")]

        for tunnel in tunnels:
            data.append((tunnel.protocol,
                         tunnel.destaddr + ":" + tunnel.destport, 
                         tunnel.listenaddr + ":" + tunnel.listenport,
                         "TARGET"))

        maxlens = self.get_column_max_width(data)
        data.insert(1, tuple(["-" * length for length in maxlens]))

        fmt = "%%-%ds   %%-%ds   %%-%ds   %%-%ds" % tuple(maxlens)
        for line in data:
            self.write(fmt % line)


    def print_global_redir(self, tunnels):
        self.print_headingline("Local")
        if not tunnels['local']:
            self.write(" *empty* ")
        else:
            self.print_local_tunnels(tunnels['local'])

        self.print_headingline("Remote")
        if not tunnels['remote']:
            self.write(" *empty* ")
        else:
            self.print_remote_tunnels(tunnels['remote'])
        self.write("")

    """
    Autorun

    """

    def print_autoruncmds(self, status, auto):
        if status:
            self.print_msg("Autorun ON")
            for cat, cmds in auto.items():
                self.print_headingline(cat + " Autorun List")
                for i,cmd in enumerate(cmds):
                    self.write("  %d) %s" % (i,cmd[0]))
                self.newline()
        else:
            self.print_msg("Autorun OFF")
        self.newline()


    """
    General Help

    """
    def print_standardop(self):
        standardop = """
    Fuzzbunch2 Standard OP Usage Help
    ---------------------------------

    === Summary ===

    Run the following commands.  Answer questions along the way.
    Abort on any failures.

    use PcConfig
    use Explodingcan
    use Pclauncher

    === Detail ===

    use PcConfig will run the Peddlecheap configuration plugin and will
    generate a configured Peddlecheap DLL.

    use Explodingcan will run the Explodingcan exploit.  It will first run
    through the Explodingcan touch plugin then try to run the exploit.  This
    plugin will generate an open socket connection that MUST be consumed by the
    Pclauncher plugin before exiting.

    use Pclauncher will upload the configured Peddlecheap DLL to target over
    the open connection from Explodingcan and run it from memory.  A new window
    will be opened for the LP to communicate with target.

    """
        self.write(standardop)


