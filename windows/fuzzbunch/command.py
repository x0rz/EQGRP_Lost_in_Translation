"""
Derived command line processing handler class from the Python standard
module 'cmd'.  Many methods overridden to support more FB like behavior.

"""
import string
import subprocess
import time

from context   import CmdCtx
import exception
import iohandler
import cmd

__all__ = ["FbCmd"]

PROMPT_PRE = 'fb'
PROMPT_POST = '> '
PROMPT_FMTSTR = " %s (%s) "

IDENTCHARS = string.ascii_letters + string.digits + '_'

INTERACTIVE    = 1
NONINTERACTIVE = 2

class FbCmd(cmd.Cmd):
    """Reimplementation of the Python Cmd class to fit more inline with Fuzzbunch
    needs and operation.  It effectively provides a base set of capabilities and
    commands.  The commands are:
    * changeprompt
    * help
    * history
    * sleep
    * echo
    * shell
    * quit
    * python
    * script

    """

    use_rawinput = 1
    identchars = IDENTCHARS

    # Create a CmdCtx for this class
    defaultcontext = CmdCtx("Fuzzbunch", "Fuzzbunch")
    shortcutKeys = {"?" : "help",
                    "!" : "shell"}

    helpKeys = {"?" : "help"}

    def __init__(self, stdin=None, stdout=None, stderr=None, enablecolor=True):
        # Set our I/O handlers
        self.init_io(stdin=stdin, stdout=stdout, stderr=stdout, enablecolor=enablecolor)
        self.runmode_interactive()      # default to interactive mode

        self.promptpre   = PROMPT_PRE
        self.completekey = 'tab'
        self.cmdqueue    = []       # Holds a list of commands yet to be executed 
        self.cmdhistory  = []       # Holds a list of commands already executed

        self.setcontext(None)       # Set us to the default context
        self.setprompt()
        
    """
    I/O Handling

    Changed so that we can handle raw I/O, which python cmd.py cannot.
    """
    def init_io(self, stdin=None, stdout=None, stderr=None, logfile=None, enablecolor=True):
        self.io = iohandler.IOhandler(stdin, stdout, logfile, enablecolor=enablecolor)

    def set_raw(self, mode=1):
        if mode in (1,0):
            self.io.raw_input = mode

    def set_ionoprompt(self, mode=False):
        if mode in (True,False):
            self.io.noprompt = mode

    """
    Run Mode Handling

    Added to enable scriptability
    """
    def runmode_interactive(self):
        self.runmode = INTERACTIVE
        self.set_raw()
        self.scripting(False)

    def runmode_noninteractive(self):
        self.runmode = NONINTERACTIVE
        self.set_raw(0)
        self.scripting(True)

    def scripting(self, mode=False):
        if mode in (False,True):
            self.scriptmode = mode
            self.set_ionoprompt(mode)

    def is_interactive(self):
        if self.runmode == INTERACTIVE:
            return True
        else:
            return False

    def is_scripted(self):
        return self.scriptmode

    """
    Context handling
    
    Added to enable us to change the prompt easily among different plug-in or 
    base contexts.
    """
    def setprompt(self, prompt=None):
        """Set the prompt for the current context.  Append the name of
        the current plugin to the prompt
        """
        if prompt is None:
            if self.getcontext().get_name() == self.defaultcontext.get_name():
                context = " "
            else:
                context = PROMPT_FMTSTR % (self.getcontext().get_type(), 
                                           self.getcontext().get_name())
            prompt = self.promptpre + context + PROMPT_POST
        self.prompt = prompt

    def setcontext(self, new_context):
        """Change contexts"""
        if new_context is None:
            new_context = self.defaultcontext
        self.ctx = new_context

    def getcontext(self):
        """Retrieve the current plugin context"""
        return self.ctx

    """
    Change prompt look

    """
    def help_changeprompt(self):
        usage = ["changeprompt [new prompt]",
                 "Change the command prompt string. Run with no",
                 "args for default prompt."]
        self.io.print_usage(usage)

    def do_changeprompt(self, input):
        """Change the command prompt"""
        newprompt = input.strip()
        if newprompt:
            self.promptpre = newprompt
        else:
            self.promptpre = PROMPT_PRE
        self.setprompt()

    """
    Command parsing and handling
    
    """
    def cmdloop(self):
        """Repeatedly issue a prompt, accept input, parse an initial prefix
        off the received input, and dispatch to action methods, passing them
        the remainder of the line as argument.
        """
        self.preloop()
        self.io.pre_input(self.complete)

        try:
            stop = None
            while not stop:
                if self.cmdqueue:
                    # First, clear out anything we have in the command queue
                    line = self.cmdqueue.pop(0)
                else:
                    # Then, accept input
                    line = self.io.get_input(self.prompt)
                stop = self.runcmd(line)
            self.postloop()
        finally:
            self.io.post_input()


    def runcmdlist(self, cmdlist):
        stop = None
        while cmdlist and not stop:
            stop = self.runcmd(cmdlist.pop(0))

    def runcmdlist_noex(self, cmdlist):
        stop = None
        while cmdlist and not stop:
            stop = self.runcmd_noex(cmdlist.pop(0))

    def runcmd_noex(self, line):
        line = self.precmd(line)
        stop = self.onecmd(line)
        return self.postcmd(stop, line)

    def runcmd(self, line):
        try:
            stop = self.runcmd_noex(line)
        except exception.CmdErr, err:
            self.io.print_error(err.getErr())
            stop = None
        return stop


    def register_shortcut(self, shortcutChar, expansion):
        """Register a new shortcut key expansion.  If a shortcut key is reused
        the old command will be deleted.
        
        """
        if shortcutChar in self.shortcutKeys:
            del self.shortcutKeys[shortcutChar]
        self.shortcutKeys[shortcutChar] = expansion 

    def precmd(self, line):
        """Executed before each command. Append the line to history and then log
        the line to the output.
        
        """
        if len(line.strip()):
            self.cmdhistory.append(line)
        self.io.log(self.prompt + line)
        return line

    #def postcmd(self, stop, line):
    #    """Executed after each command."""
    #    return stop

    #def preloop(self):
    #    pass

    #def postloop(self):
    #    pass

    def parseline(self, line):
        """Parse the line into a command name and a string containing the
        arguments.  Returns a tuple containing (command, args, line).
        'command' and 'args' may be None if line couldn't be parsed.  Check for
        registered special handlers.
        """
        line = line.strip()
        if not line:
            return None, None, line
        
        if line[-1:] in self.helpKeys:
            line = self.helpKeys[line[-1:]] + " " + line[:-1]

        if line[0] in self.shortcutKeys:
            line = self.shortcutKeys[line[0]] + " " + line[1:]

        i, n = 0, len(line)
        while i < n and line[i] in self.identchars:
            i = i+1
        cmd, arg = line[:i], line[i:].strip()
        return cmd, arg, line

    def onecmd(self, line):
        """Run a single command. Exceptions should be caught by the caller"""
        cmd, arg, line = self.parseline(line)
        if not line:
            return self.emptyline()
        if cmd is None:
            return self.default(line)
        self.lastcmd = line
        if cmd == '':
            return self.default(line)
        else:
            try:
                # retrieve the command execution function, which will be 
                # self.do_<command>
                func = getattr(self, 'do_' + cmd.lower())
            except AttributeError:
                return self.default(line)
            return func(arg)
            
    def emptyline(self):
        """Called when an empty line is encountered"""
        pass

    def default(self, line):
        """Called when command prefix is not recognized."""
        cmd, arg, line = self.parseline(line)

        # Check if the current context handles the cmd instead
        try:
            func = self.ctx.lookup_function(cmd)
        except AttributeError:
            self.io.print_error("Unknown syntax: %s" % line)
        else:
            func(arg)

    
    #def completedefault(self, *ignored):
    #    return []

    def completenames(self, text, *ignored):
        """Return a list of command names for command completion."""
        dotext = 'do_' + text
        return [ a[3:] for a in self.ctx.get_names() if a.startswith(dotext) ] +\
               [ a[3:] for a in self.get_names()     if a.startswith(dotext) ]

    def get_compstate(self, text, arglist):
        if text == "":
            return len(arglist)
        else:
            return max(len(arglist) - 1, 0)

    def complete(self, text, state):
        """Return the next possible completion for 'text'."""
        if state == 0:
            try:
                import readline
            except ImportError:
                import pyreadline as readline
            origline = readline.get_line_buffer()
            begidx = readline.get_begidx()
            endidx = readline.get_endidx()
            if begidx > 0:
                cmd, args, foo = self.parseline(origline)
                if cmd == '':
                    compfunc = self.completedefault
                else:
                    try:
                        compfunc = getattr(self, 'complete_' + cmd.lower())
                    except AttributeError:
                        try:
                            compfunc = self.ctx.lookup_compfunction(cmd)
                        except AttributeError:
                            compfunc = self.completedefault
            else:
                compfunc = self.completenames
            arglist = [item.strip() for item in origline.strip().split()]
            comp_state = self.get_compstate(text, arglist)
            self.completion_matches = compfunc(text, origline, arglist, comp_state, begidx, endidx)

        try:
            return self.completion_matches[state]
        except IndexError:
            return None

    #def get_names(self):
    #    names = []
    #    classes = [self.__class__]
    #    while classes:
    #        aclass = classes.pop(0)
    #        if aclass.__bases__:
    #            classes = classes + list(aclass.__bases__)
    #        names = names + dir(aclass)
    #    return names

    def complete_help(self, *args):
        return self.completenames(*args)


    """
    Cmd: help

    """
    def get_help_lists(self, names, ctx):
        do_cmds = list(set([name for name in names if name.startswith('do_')]))
        do_cmds.sort()
        return [(name[3:], str(getattr(ctx, name).__doc__)) for name in do_cmds]

    def get_shortcut_help(self):
        """Shortcut help"""
        return [(key, "Shortcut for %s" % val) for key,val in self.shortcutKeys.items()]

    def do_help(self, input):
        """Print out help"""
        args = input.strip().split()
        if len(args) > 0:
            arg = args[0]
            try:
                func = self.ctx.lookup_helpfunction(arg)
                func()
            except AttributeError:
                pass
            try:
                func = getattr(self, 'help_' + arg.lower())
                func()
            except AttributeError:
                pass
        else:
            cmds = self.get_shortcut_help() + self.get_help_lists(self.get_names(), self)
            cmdlist = {'title'    : "Core Commands",
                       'commands' : cmds}
            self.io.print_cmd_list(cmdlist)

            if self.ctx.get_name() != self.defaultcontext.get_name():
                cmds = self.get_help_lists(self.ctx.get_names(), self.ctx)
                cmdlist = {'title'    : "%s Commands" %self.ctx.get_type(),
                           'commands' : cmds}
                self.io.print_cmd_list(cmdlist)


    """
    Cmd: history

    """
    def help_history(self):
        usage = ["history [index]",
                "Rerun a previous command. Omit index to print history"]
        self.io.print_usage(usage)

    def do_history(self, arg):
        """Run a previous command."""
        # keep the history cmds out of the history to reduce noise
        self.cmdhistory.pop()
        if len(arg) == 0:
            history = {'items' : enumerate(self.cmdhistory)}
            self.io.print_history(history)
        else:
            try:
                index = int(arg)
            except ValueError:
                self.io.print_error("Bad history index")
                return

            try:
                self.cmdqueue.append(self.cmdhistory[index])
            except IndexError:
                maxIndex = len(self.cmdhistory) - 1
                self.io.print_error("History index out of range [0 : %d]" % maxIndex)


    """
    Cmd: sleep

    """
    def help_sleep(self):
        usage = ["sleep [N seconds]",
                 "Sleep for N seconds"]
        self.io.print_usage(usage)

    def do_sleep(self, count):
        """Sleep for n seconds"""
        try:
            count = int(count)
        except ValueError:
            self.io.print_error("Invalid delay")
            return 
        self.io.print_msg("Sleeping for %d seconds" % count)
        try:
            time.sleep(count)
        except KeyboardInterrupt:
            self.io.print_error("User Interrupt")

    """
    Cmd: echo

    """
    def help_echo(self):
        usage = ["echo [msg]",
                 "echo the given message"]
        self.io.print_usage(usage)

    def do_echo(self, msg):
        """Echo a message"""
        self.io.print_msg(msg.strip())

    """
    Cmd: shell

    """
    def help_shell(self):
        usage = ["shell [command [args]]",
                 "Runs command with args in OS shell"]
        self.io.print_usage(usage)

    def do_shell(self, arg):
        """Execute a shell command"""
        try:
            retcode = subprocess.call(arg, shell=True)
            del retcode
        except OSError, e:
            self.io.print_error("Execution failed: " + e.message)
        except KeyboardInterrupt:
            self.io.print_warning("Execution aborted by user: Ctrl-c")


    """
    Cmd: EOF, quit

    """
    def help_eof(self):
        usage = ["eof",
                 "Quits program (CTRL-D)"]
        self.io.print_usage(usage)

    def do_eof(self, arg):
        """Quit program (CTRL-D)"""
        return self.do_quit(arg)

    def help_quit(self):
        usage = ["quit",
                 "Quits program (CTRL-D)"]
        self.io.print_usage(usage)
    def do_quit(self, arg):
        """Quit program"""
        return True

    """
    Cmd: Python

    """
    def help_python(self):
        usage = ["python",
                 "Enters the interactive python interpreter. Exit the",
                 "interpreter to return back to Fuzzbunch."]
        self.io.print_usage(usage)

    def do_python(self, arg):
        """Drop to an interactive Python interpreter"""
        raise exception.Interpreter

    """
    Scripting Support

    """
    def help_script(self):
        usage = ["script [scriptfile]",
                 "Run the given scriptfile"]
        self.io.print_usage(usage)

    def do_script(self, input):
        """Run a script"""
        inputList = input.strip().split()

        if len(inputList) == 0:
            self.help_script()
        else:
            try:
                self.scripting(True)
                try:
                    script = [ line.strip() 
                               for line in open(inputList[0]).readlines()
                               if not line.startswith('#') ]
                except IOError:
                    raise exception.CmdErr, "Couldn't read script file"
                self.runcmdlist_noex(script)
            except exception.CmdErr, err:
                self.io.print_error(err.getErr())
                self.io.print_error("Aborting script")
            finally:
                self.scripting(False)


if __name__ == "__main__":
    fb = FbCmd()
    fb.cmdloop()


