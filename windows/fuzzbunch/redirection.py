
import string
import uuid
import random
from util import iDict
import exception


# Nothing is validating the Redir section in the xml.  I may get nonexistent
# params.
#

__all__ = ['RedirectionManager', 'LocalRedirection', 'RemoteRedirection']


def str2bool(x):
    if x is None:
        return False
    if x.lower() in ('true', 't', '1'):
        return True
    else:
        return False

def strip_xpath(x):
    if not x:
        return x
    if x.startswith('/'):
        return ""
    else:
        return x

def is_identifier(x):
    if not x:
        return False
    else:
        if x[0] in string.digits:
            return False
        else:
            return True

def rand_port():
    RAND_PORT_MIN = 1025
    RAND_PORT_MAX = 65535
    return str(random.randint(RAND_PORT_MIN, RAND_PORT_MAX))

class LocalRedirection(object):
    """
    listenaddr: Name of parameter to give the IP addr of listening tunnel on local LP
    listenport: Name of parameter to give the port of the listening tunnel on local LP
    destaddr:   Name of parameter that contains the IP of the target computer
    destport:   Name of parameter that contains the port on the target computer
    """
    def __init__(self, protocol, listenaddr, listenport, destaddr, destport,
                    closeoncompletion="false", name="", srcport=None, srcportlist=None,
                    srcportrange=None, *trashargs, **trashkargs):
        self.protocol   = protocol
        # XXX - The redirection section really shouldn't have XPath in it.
        self.listenaddr = strip_xpath(listenaddr)
        self.listenport = strip_xpath(listenport)
        self.destaddr   = strip_xpath(destaddr)
        self.destport   = strip_xpath(destport)
        self.closeoncompletion = str2bool(closeoncompletion)
        self.name = name

        self.srcport = strip_xpath(srcport)
        self.srcportlist = srcportlist
        self.srcportrange = srcportrange

    def __repr__(self):
        return str(self.__dict__)


class RemoteRedirection(object):
    def __init__(self, protocol, listenaddr, destport, closeoncompletion="false",
                    name="", listenport=None, listenportlist=None,
                    listenportrange=None, listenportcount=None, destaddr="0.0.0.0",
                    *trashargs, **trashkargs):
        self.protocol   = protocol
        self.listenaddr = strip_xpath(listenaddr)
        self.listenport = strip_xpath(listenport)
        self.destaddr   = strip_xpath(destaddr)
        self.destport   = strip_xpath(destport)
        self.closeoncompletion = str2bool(closeoncompletion)
        self.name = name

        # Need conversion?
        self.listenportlist = listenportlist
        self.listenportrange = listenportrange
        self.listenportcount = listenportcount

    def __repr__(self):
        return str(self.__dict__)


class RedirectionManager:
    """This is something of a misnomer.  This is really a redirection manager rather than
    a redirection object.  This is responsible for taking the defined tunnels in the 
    plug-in's XML and 'swapping out' the parameters as they pertain to redirection.

    A sample redirection section appears as follows:
    <redirection>
        <!-- (1) The "throwing" tunnel -->
        <local name="Launch"
               protocol="TCP"
               listenaddr="TargetIp"        # IP of redirector
               listenport="TargetPort"      # Port of redirector 
               destaddr="TargetIp"          # IP of target computer
               destport="TargetPort"        # Port of target computer
               closeoncompletion="true"/>
        <!-- (2) The "Callin" tunnel -->
        <local name="Callin"
               protocol="TCP"
               listenaddr="TargetIp"        # IP on redirector
               listenport="CallinPort"      # Port on redirector
               destaddr="TargetIp"          # IP of target callin
               destport="ListenPort"        # Port of target callin
               closeoncompletion="false"/>
        <!-- (3) The "callback" tunnel -->
        <remote name="Callback"
                protocol="TCP"
                listenaddr="CallbackIp"         # IP opened by egg (last redirector)
                listenport="CallbackPort"       # Port opened by egg (last redirector)
                destport="CallbackLocalPort"    # Port for throwing side to listen
                closeoncompletion="false"/>
    </redirection>

    For the "throwing" (launch) tunnel, we:
        1: Ask for/retrieve the "Destination IP" and "Destination Port", which default to
           the "TargetIp" and "TargetPort" parameters
        2: Ask for the "Listen IP" (listenaddr) and "Listen Port" (listenport) 
           and then swap them in "TargetIp" and "TargetPort"
        3: After execution, restore the proper session parameters
        * (listenaddr, listenport) = l(destaddr, destport)

    For the "callin" tunnel, we:
        1: Ask for/retrieve the "Destination IP" and Destination Port", which default to
           the "TargetIp" and the "ListenPort" parameters
        2: Ask for the "Listen IP" (listenaddr) and "Listen Port" (listenport) and
           then swap them into "TargetIp" and "CallinPort" parameters
        3: After execution, restore the proper session parameters
        * (listenaddr, listenport) = l(destaddr, destport)

    For the "callback" tunnel, we:
        1: Ask for the Listen IP and Listen Port for which the payload will callback.
           This is most likely the last hop redirector IP and a port on it
        2: Ask for the Destination IP and Destination Port, which will likely be the
           operator workstation.  Store the Destination port as "CallbackLocalPort", 
           basically ignoring the DestinationIp
        3: After execution, restore the proper session parameters
        * (destaddr, destport) = l(listenaddr, listenport)

    """
    def __init__(self, io):
        self.io = io
        self.active = False
        # A place to store parameters for the session.  We push the info, run the plug-in
        # (with redirection), and then pop the info to restore it
        self.session_cache = {}       

    def on(self):
        self.active = True

    def off(self):
        self.active = False

    def is_active(self):
        return self.active

    def get_status(self):
        if self.active:
            return "ON"
        else:
            return "OFF"

    def get_session(self, id):
        return self.session_cache.get(id)
        
    def pre_exec(self, plugin):
        if not plugin.canRedirect():
            return 0
        
        if self.is_active():
            self.io.print_msg("Redirection ON")
            return self.config_redirect(plugin, True)
        else:
            self.io.print_msg("Redirection OFF")
            return self.config_redirect(plugin, False)

    def post_exec(self, plugin, id):
        if id == 0:
            return
        # if plugin doesn't do redir, return

        try:
            stored_session_data = self.session_cache.pop(id)
        except KeyError:
            return

        # Restore the old information to the session
        for key,val in stored_session_data['params'].items():
            plugin.set(key, val)

    def print_session(self, id):
        try:
            session = self.session_cache[id]
        except KeyError:
            return
        self.io.print_global_redir(session)

    """
    Pre plugin execution

    """
    def conv_param(self, val, params, session_data={}):
        """Resolve a value from one of session, params, or the hard value"""
        try:
            # First try to find the session parameter
            if val in session_data:
                return session_data[val]
            # Then try to find the context-specific parameter
            if is_identifier(val):
                return params[val]
        except:
            return None
        # If it is neither a session or context parameter, return the value as is
        return val

    def prompt_redir_fake(self, msg, default):
        done = None
        while not done:
            try:
                line = self.io.prompt_user(msg, default)
            except exception.PromptHelp, err:
                self.io.print_warning('No help available')
            except exception.PromptErr, err:
                raise
            except exception.CmdErr, err:
                self.io.print_error(err.getErr())
            if line:
                return line

    def prompt_redir(self, plugin, var, msg, default):
        """Prompt for a redirect value and set it in Truantchild"""
        done = None
        while not done:
            try:
                line = self.io.prompt_user(msg, default)
                plugin.set(var, line)
                done = plugin.hasValidValue(var)
            except exception.PromptHelp, err:
                self.io.print_warning('No help available')
            except exception.PromptErr, err:
                raise
            except exception.CmdErr, err:
                self.io.print_error(err.getErr())
        return plugin.get(var)

    def straight_remote(self, r, plugin):
        params = iDict(plugin.getParameters())
        lport = self.conv_param(r.listenport, params)
        dport = self.conv_param(r.destport, params)
        laddr = self.conv_param(r.listenaddr, params)
        if None in (lport, dport, laddr):
            return

        # Do we need to choose a random local port? 
        # XXX - This won't happen unless lport is 0
        if not lport or lport == "0":
            lport = rand_port()

        # Store off the old values so that we can restore them after the
        # plug-in executes
        cache = {r.listenaddr : plugin.get(r.listenaddr),
                 r.listenport : plugin.get(r.listenport),
                 r.destport   : plugin.get(r.destport)}
        self.io.print_success("Remote Tunnel - %s" % r.name)
        try:
            # Modify the plugin and report success
            callbackip = self.prompt_redir(plugin, r.listenaddr, 'Listen IP', laddr)
            callbackport = self.prompt_redir(plugin, r.listenport, 'Listen Port', lport)
            plugin.set(r.destport, callbackport)
            self.io.print_success("(%s) Remote %s:%s" % (r.protocol, callbackip, callbackport))
        except exception.PromptErr:
            self.io.print_error("Aborted by user")
            for (var,val) in cache.items():
                try:
                    plugin.set(var, val)
                except:
                    self.io.print_error("Error setting '%s' - May be in an inconsistent state" % var)
            raise

    def straight_local(self, l, plugin):
        """Effectively just print the straight path to the target"""
        params = iDict(plugin.getParameters())
        laddr = self.conv_param(l.listenaddr, params)
        lport = self.conv_param(l.listenport, params)
        if not laddr or not lport:
            return 
        
        # HACK HACK 
        # The logic here was previously wrong, which meant that people didn't have to be careful
        # about their redirection sections.  Until we get them fixed, we need a hack that will
        # allow these invalid redirection sections if we try it the valid way and fail
        enable_hack = False
        try:
            cache = {l.destaddr : plugin.get(l.destaddr),
                     l.destport : plugin.get(l.destport)}
            laddr = self.conv_param(l.destaddr, params)
            lport = self.conv_param(l.destport, params)
        except exception.CmdErr:
            enable_hack = True
            cache = {l.destaddr : plugin.get(l.listenaddr),
                     l.destport : plugin.get(l.listenport)}
        self.io.print_success("Local Tunnel - %s" % l.name)
        try:
            if not enable_hack:
                targetip = self.prompt_redir(plugin, l.destaddr, 'Destination IP', laddr)
                targetport = self.prompt_redir(plugin, l.destport, 'Destination Port', lport)
                self.io.print_success("(%s) Local %s:%s" % (l.protocol, targetip, targetport))
            else:
                targetip = self.prompt_redir(plugin, l.listenaddr, 'Destination IP', laddr)
                targetport = self.prompt_redir(plugin, l.listenport, 'Destination Port', lport)
                self.io.print_success("(%s) Local %s:%s" % (l.protocol, targetip, targetport))
        except exception.PromptErr:
            self.io.print_error("Aborted by user")
            for (var,val) in cache.items():
                try:
                    plugin.set(var, val)
                except:
                    self.io.print_error("Error setting '%s' - May be in an inconsistent state" % var)
            raise
        except Exception as e:
            self.io.print_error("Error: {0}".format(str(type(e))))
            

    def redirect_remote(self, r, plugin, session_data):
        """(destaddr, destport) = r-xform(listenaddr, listenport)
        
        * Each of the identifiers above specifies a variable for the plug-in

        (1) Prompt for Listen IP            - Likely the ultimate redirector's IP
        (2) Prompt for Listen Port          - Likely the ultimate redirector's port
        (3) Prompt for Destination          - Likely 0.0.0.0
        (4) Prompt for Destination Port     - Likely a local port

        Lookup the variables specified by listenaddr and listenport, transform them with
        a given transform function, and substitute the resulting values into the 
        variables specified by destaddr and destport.

        The plug-in will then have to open a port to listen on using the variables
        specified by the destnation IP and destination port
        """
        params = iDict(plugin.getParameters())
        lport = self.conv_param(r.listenport, params, session_data['params'])
        dport = self.conv_param(r.destport, params, session_data['params'])
        laddr = self.conv_param(r.listenaddr, params, session_data['params'])
        daddr = self.conv_param(r.destaddr, params, session_data['params'])
        if None in (lport, dport, laddr, daddr):
            for p,n in (laddr, r.listenaddr), (lport, r.listenport), (daddr, r.destaddr), (dport, r.destport):
                if p == None:
                    self.io.print_warning("Parameter %s referenced by tunnel %s not found. This tunnel will "
                                          "be ignored" % (n, r.name))
            return

        if not lport or lport == "0":
            lport = rand_port()

        self.io.print_success("Remote Tunnel - %s" % r.name)

        #
        # Prompt the user for the listenaddr and listenport
        #
        callbackip = self.prompt_redir(plugin, r.listenaddr, 'Listen IP', laddr)
        callbackport = self.prompt_redir(plugin, r.listenport, 'Listen Port', lport)

        #
        # Do the substitution
        #
        session_data['params'][r.listenaddr] = callbackip
        session_data['params'][r.listenport] = callbackport

        # Get the other end of the tunnel, where the connection will eventually be made.
        # This will likely be, but does not have to be, the local workstation
        callbacklocalip = self.prompt_redir_fake('Destination IP', daddr)
        if not dport:
            dport = callbackport 
        callbacklocalport = self.prompt_redir(plugin, r.destport, 'Destination Port', dport)
        session_data['params'][r.destport] = callbacklocalport

        session_data['remote'].append(RemoteRedirection(r.protocol, 
                                                   callbackip, 
                                                   callbacklocalport, 
                                                   listenport=callbackport, 
                                                   destaddr=callbacklocalip,
                                                   name=r.name))

        self.io.print_success("(%s) Remote %s:%s -> %s:%s" % 
                (r.protocol, callbackip, callbackport, 
                 callbacklocalip, callbacklocalport))

    def redirect_local(self, l, plugin, session_data):
        """
        targetip    = Destination IP (on the target)
        targetport  = Destination Port (on the target)
        redirip     = IP of the LP
        redirport   = Port on the LP

        """

        # listenaddr - name of variable containing the LP IP
        # listenport - name of variable containing the LP Port
        # destaddr   - name of variable containing the Target IP
        # destport   - name of variable containing the Target Port

        # targetip   - IP of the target
        # targetport - Port of the target 
        # redirip    - IP of the LP
        # redirport  - Port of the LP

        params = iDict(plugin.getParameters())

        # Get the defaults for the user prompt
        laddr = self.conv_param(l.listenaddr, params, session_data['params'])
        lport = self.conv_param(l.listenport, params, session_data['params'])
        daddr = self.conv_param(l.destaddr, params, session_data['params'])
        dport = self.conv_param(l.destport, params, session_data['params'])
        if None in (laddr, lport, daddr, dport):
            for p,n in (laddr, l.listenaddr), (lport, l.listenport), (daddr, l.destaddr), (dport, l.destport):
                if p == None:
                    self.io.print_warning("Parameter %s referenced by tunnel %s not found. This tunnel will "
                                          "be ignored" % (n, l.name))
            return

        self.io.print_success("Local Tunnel - %s" % l.name)

        #
        # Get the destination IP and port for the target
        #
        targetip = self.prompt_redir_fake('Destination IP', daddr)
        targetport = self.prompt_redir_fake('Destination Port', dport)

        #
        # Get the redirection addresses
        # 
        redirip = self.prompt_redir(plugin, l.listenaddr, 'Listen IP', '127.0.0.1')
        if not dport:
            dport = targetport
        redirport  = self.prompt_redir(plugin, l.listenport, 'Listen Port', lport)

        #
        # 
        #
        session_data['params'][l.listenaddr] = targetip
        session_data['params'][l.listenport] = targetport

        # 
        # Record the redirection tunnel
        # 
        session_data['local'].append(LocalRedirection(l.protocol, redirip, 
                                                 redirport, targetip, 
                                                 targetport, name=l.name))

        self.io.print_success("(%s) Local %s:%s -> %s:%s" % 
                (l.protocol, redirip, redirport, targetip, targetport))

    def config_redirect(self, plugin, do_redir):
        """Configure whether the plug-in should perform redirection
        plugin - An instance of a plugin
        do_redir - Should we do redirection? (True or False)"""
        redir  = plugin.getRedirection()

        # Make a new session dictionary here
        session_data = {
                'params' : {},      # 
                'remote' : [],      # 
                'local'  : []       # 
                }
        if do_redir:
            id = uuid.uuid4()
        else:
            id = 0

        try:
            self.io.newline()
            self.io.print_success("Configure Plugin Local Tunnels")
            for l in redir['local']:
                if do_redir:
                    self.redirect_local(l, plugin, session_data)
                else:
                    self.straight_local(l, plugin)

            self.io.newline()
            self.io.print_success("Configure Plugin Remote Tunnels")
            for r in redir['remote']:
                if do_redir:
                    self.redirect_remote(r, plugin, session_data)
                else:
                    self.straight_remote(r, plugin)
        except exception.PromptErr:
            for key,val in session_data['params'].items():
                plugin.set(key, val)
            raise

        self.io.newline()
        # Store info into the cache so that we can restore it in post_exec
        if id:
            self.session_cache[id] = session_data
        return id 


