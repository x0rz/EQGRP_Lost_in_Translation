"""
Fuzzbunch plugin base class

Wraps the truantchild Config class to provide easy access to setting and
getting parameters.

"""
import truantchild
import exception
import util
import edfmeta


__all__ = ["Plugin"]


"""
Decorators

"""
def setwrapper(f):
    def wrap(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except AttributeError:
            raise exception.CmdErr, "Unknown parameter"
        except (ValueError, TypeError, OverflowError):
            raise exception.CmdErr, "Invalid value"
        except (IOError, RuntimeError, ZeroDivisionError,
                IndexError, SyntaxError, MemoryError) as err:
            raise exception.CmdErr("TRCH internal : " + str(err))
            
    return wrap

def resetwrapper(f):
    def wrap(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except AttributeError:
            raise exception.CmdErr, "Unknown parameter"
        except (IOError, RuntimeError, ZeroDivisionError,
                IndexError, SyntaxError, MemoryError) as err:
            raise exception.CmdErr("TRCH internal : " + str(err))
    return wrap

def getwrapper(f):
    def wrap(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except AttributeError:
            raise exception.CmdErr, "Unknown parameter"
    return wrap

def safesetparameter(f):
    """save and restore old value if new is invalid"""
    def wrap(self, name, value):
        old = self.get(name)
        f(self, name, value)
        if not self.hasValidValue(name):
            self._trch_set(name, old)
            raise exception.CmdErr, "Invalid value for '%s' (%s)" % (name, value)
    return wrap

def safesetchoice(f):
    """Set a choice (cannot be invalid setting) and update
    [non-hidden] parameters lower in the tree."""
    def wrap(self, name, value):
        paramcache = self.cache_choiceparams(name)
        old = self.get(name)
        f(self, name, value)
        if not self.hasValidValue(name):
            # Restore to the old
            self._trch_set(name, old)
            raise exception.CmdErr, "Invalid value for %s (%s)" % (name, value)
        # We want var matches, not var/val 
        for param in paramcache:
            if param.name in util.iDict(self.cache_choiceparams(name)):
                try:
                    if not self.getParameter(param.name).isHidden():
                        self.set(*param)
                except (exception.CmdErr, AttributeError):
                    # XXX Is ignoring errors here a good idea?
                    pass
    return wrap

"""
Plugin base class

"""
class Plugin(truantchild.Config):
    def __init__(self, files, io):
        import truantchild
        from pytrch import TrchError as TruantchildError
        try:
            truantchild.Config.__init__(self, files)
            self.param_order = edfmeta.parse_iparamorder(self.xmlInConfig)
            self._curParams   = self._inputParams
            self._defaults    = self.getParameters()

            self.io = io            
            self.touchlist = []     
            self.redirection = {}
            self.consolemode = util.CONSOLE_DEFAULT
            self.lastsession = None
        except AttributeError:
            #print >>sys.stderr, "Plugin.__init__ failed to find an attribute - %s" % (str(e))
            raise
        except TruantchildError:
            #print >>sys.stderr, "Plugin.__init__ failed to initialize Config - %s" % (str(e))
            raise
            
    """
    Parameter value set and get

    """
    def set(self, name, value, globalvars={}):
        if self.isParameter(name):
            self.set_parameter(name, util.variable_replace(value, globalvars))
        else:
            self.set_choice(name, util.variable_replace(value, globalvars))

    def get(self, name):
        """Get a specific parameter value"""
        return self._trch_get(name)

    @resetwrapper
    def reset(self, name):
        self._trch_reset(name)

    @safesetparameter
    def set_parameter(self, name, value):
        """Set a parameter to value"""
        self._trch_set(name, value)

    @safesetchoice
    def set_choice(self, name, value):
        """Set a choice to a value."""
        self._trch_set(name, value)

    def cache_choiceparams(self, name):
        """Cache values, Ignore hidden"""
        paramcache = []
        choice = self._trch_findparamchoice(name)
        if choice:
            for param in choice.getParameterList():
                if param.name == name:
                    continue
                paramcache.append(param) 
                paramcache += self.cache_choiceparams(param.name)
        return paramcache

    """
    Individual Parameter Interface

    """
    def getDescription(self, name):
        """Get the description of a parameter"""
        return self._trch_getdescription(name)

    def getType(self, name):
        """Get the type of a parameter"""
        return self._trch_gettype(name)

    def getFormat(self, name):
        """Get the format of a parameter"""
        return self._trch_getformat(name)

    def getAttributeList(self, name):
        """Get the attribute list of a parameter"""
        return self._trch_getattributelist(name)

    def getParameter(self, name):
        """Get the parameter struct"""
        return self._trch_findoption(name)

    def hasParameter(self, name):
        if self.getParameter(name):
            return True
        else:
            return False
    
    def isParamchoice(self, name):
        return self._trch_isparamchoice(name)

    def isParameter(self, name):
        return self._trch_isparameter(name)

    # Added to support fixing bug #2133
    def isHiddenParameter(self, name):
        """Given a parameter name, is that parameter hidden?"""
        param = self.getParameter(name)
        if self.isParameter(name):
            return param.isHidden()
        return False

    """
    Multiple parameters

    """
    def getParameters(self, hidden=True):
        """Get the current parameter list"""
        # Members of the plist array are dictionary items
        plist = self._trch_getparameterlist()
        if not hidden:
            plist = [x for x in plist if not self.isHiddenParameter(x.name)]

        if not self.param_order:
            return plist

        # Give them same order in which they appear in xml file
        pdict = util.iDict(plist)
        order = [ util.Param(pname, pdict.pop(pname) or "") 
                      for pname in self.param_order
                      if pname in pdict ]

        return order + list(pdict.items())

    def iterPromptParameters(self):
        
        # Take all the root level parameters first
        rootparams = self._trch_getrootparameterlist()
        for param in self.getParameters():
            if self._trch_isparameter(param.name) and \
               param in rootparams and \
               not self.isHiddenParameter(param.name):
                    yield param

        # Walk all choices.  Need to take into account that setting a choice
        # causes changes to everything below it.
        usedchoices = []
        done = False
        while not done:
            for param in self.getParameters():
                if self._trch_isparamchoice(param.name) and \
                   param.name not in usedchoices and \
                   not self.isHiddenParameter(param.name):
                    usedchoices.append(param.name)
                    yield param
                    break
            else:
                done = True
        usedchoices += util.iDict(rootparams).keys()

        # Now all the choices are stable, we can walk all params that are under
        # a choice which is anything that we haven't looked at yet
        for param in self.getParameters():
            if self._trch_isparameter(param.name) and \
               param.name not in usedchoices and \
               not self.isHiddenParameter(param.name):
                yield param

    def getOutputParameters(self):
        """Get the output parameter list"""
        return self._trch_getoutputparameters()

    def getDefaultParameters(self):
        """Return the defaults parameters"""
        return self._defaults

    def setParameters(self, params):
        for param in self.iterPromptParameters():
            if param in params.items():
                try:
                    self.set(param.name, params[param.name])
                except exception.CmdErr:
                    self.io.print_warning("Skipping %s - Bad value" % param.name)
                else:
                    self.io.print_success("Set %s => %s" % (param.name, params[param.name]))

        if self.redirection:
            targetip   = params.get('targetip', None)
            targetport = params.get('targetport', None)
            callbackip = params.get('callbackip', None)

            redir = self.getRedirection() 
            if callbackip:
                for r in redir['remote']:
                    self.set(r.listenaddr, callbackip)
            if targetip:
                for l in redir['local']:
                    # Only set this if we want the TargetIp
                    if l.listenaddr == 'TargetIp':
                        self.set(l.listenaddr, targetip)

    """
    Parameter validity

    """
    def hasValidValue(self, name):
        """Check if a parameter of the whole set has a valid value"""
        return self._trch_hasvalidvalue(name)

    def isValid(self, name=None):
        """Check if a parameter or the whole set is invalid"""
        return self._trch_isvalid(name)

    def getInvalid(self):
        """Get a list of all parameters with invalid values"""
        # XXX - Should be smarter about choices
        return [ (param.name, param.value, self.getDescription(param.name))
                 for param in self.getParameters()
                 if not self.isValid(param.name) ]

    """
    Plugin execution

    """
    def execute(self, session, mode):
        """Execute the plugin"""
        pass

    def validate(self):
        """Validate the plugin"""
        return True

    def getSessionDescription(self):
        """Extra information about a session"""
        return ""

    """
    Rendezvous

    """
    def doRendezvous(self, value):
        """Do required actions to complete EDF Rendezvous"""
        return False

    def createsRendezvous(self):
        for name,val in self._outputParams.getParameterList():
            if "Socket" == self._outputParams.findOption(name).getType():
                return True
        return False

    """
    Run Mode

    """
    def initConsoleMode(self):
        self.consolemode = util.CONSOLE_DEFAULT

    def getConsoleMode(self):
        return self.consolemode

    """
    Redirection

    """
    def initRedirection(self):
        self.redirection = {}

    def getRedirection(self):
        return self.redirection

    def canRedirect(self):
        if not self.redirection:
            return False
        if not self.redirection['remote'] and not self.redirection['local']:
            return False
        return True

    def canDeploy(self):
        return False
        
    """
    Touches

    """
    def initTouches(self):
        self.touchlist = []

    def getTouchList(self):
        return self.touchlist

    def get_touch(self, index):
        try:
            return self.getTouchList()[index]
        except IndexError:
            raise exception.CmdErr, "Bad touch"

    """
    Truantchild abstractions
    """
    @setwrapper
    def _trch_set(self, name, value):
        """Set a parameter to a value"""
        self._curParams.set(name, value)

    @getwrapper
    def _trch_get(self, name):
        """Return the value of a parameter"""
        return self._curParams.get(name)

    def _trch_reset(self, name):
        return self._curParams.reset(name)

    @getwrapper
    def _trch_getdescription(self, name):
        return self._curParams.getDescription(name)

    @getwrapper
    def _trch_gettype(self, name):
        return self._curParams.getType(name)

    @getwrapper
    def _trch_getformat(self, name):
        return self._curParams.getFormat(name)

    @getwrapper
    def _trch_getattributelist(self, name):
        return self._curParams.getAttributeList(name)

    def _trch_findoption(self, name):
        return self._curParams.findOption(name)

    def _trch_isparamchoice(self, name):
        return self._curParams.isParamchoice(name)

    def _trch_isparameter(self, name):
        return self._curParams.isParameter(name)

    def _trch_findparamchoice(self, name):
        return self._curParams.findParamchoice(name)

    def _trch_getparameterlist(self):
        return self._curParams.getParameterList()

    def _trch_getrootparameterlist(self):
        return self._curParams.getRootParameterList()

    @getwrapper
    def _trch_hasvalidvalue(self, name):
        return self._curParams.hasValidValue(name)

    @getwrapper
    def _trch_isvalid(self, name):
        return self._curParams.isValid(name)
    
    def _trch_addrendezvousparam(self, value):
        self._curParams.addRendezvousParam(value)

    def _trch_getoutputparameters(self):
        return self._outputParams.getParameterList()

    # Added to support fixing Bug #2133 
    @getwrapper
    def _trch_findparameter(self, name):
        return self._curParams.findParameter(name)



