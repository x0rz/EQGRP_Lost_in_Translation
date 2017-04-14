"""
Exception handling classes.
"""
import sys

__all__ = [
            "CmdErr", 
            "PromptErr", 
            "PromptHelp", 
            "Interpreter", 
            "PluginXmlErr", 
            "PluginMetaErr",
            "exceptionwrapped"]

class CmdErr(Exception):
    """CmdErr covers command error conditions."""
    def __init__(self, error):
        self.error = str(error)
        self.prefix = "Error:"

    def getErr(self):
        return "%s %s" % (self.prefix, self.error)

class PromptErr(CmdErr):
    """PromptErr covers prompt error conditions."""
    def __init__(self, error):
        CmdErr.__init__(self, error)
        self.prefix = "Prompt Error:"

class PromptHelp(CmdErr):
    """PromptHelp covers prompt help conditions."""
    def __init__(self, error):
        CmdErr.__init__(self, error)
        self.prefix = "Prompt Help:"

class Interpreter(Exception):
    """Interpreter covers dropping control to the
       python interactive prompt. 
    """
    def __init__(self):
        self.prefix = "Dropping to Interpreter"

    def getErr(self):
        return "%s" % self.prefix

class PluginXmlErr(CmdErr):
    """Pluginfinder error when trying to load
       EDF plugins
    """
    def __init__(self, error):
        CmdErr.__init__(self, error)
        self.prefix = "Loader Error:"

class PluginMetaErr(CmdErr):
    def __init__(self, error):
        CmdErr.__init__(self, error)
        self.prefix = "Touch XML Error:"

def exceptionwrapped(fn):
    """This is a decorator meant to be a catch-all wrapper for exceptions, 
    providing the user with instructions as to what to do in the event of an 
    unrecoverable failure.
    """
    def wrap(*args, **kwargs):
        try:
            ret = fn(*args, **kwargs)
            return ret
        except SystemExit:
            return None
        except:
            import traceback
            stacktrace = traceback.format_exc()
            print >>sys.stderr, "==============================================================="
            print >>sys.stderr, "="
            print >>sys.stderr, "= Encountered an unhandled error.  Please provide the following"
            print >>sys.stderr, "= information to the developer"
            print >>sys.stderr, "= "
            print >>sys.stderr, "==============================================================="
            print >>sys.stderr, "%s" % (stacktrace) 
            return None
    wrap.__doc__ = fn.__doc__
    return wrap
