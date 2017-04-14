import sys
import truantchild
import exma
from optparse import OptionParser
import logging
import ctypes

EDF_CLEANUP_WAIT = 0

#
# @todo coli needs a logger that will duplicate output to stdout and the file
#

# ID - sha1 of Name-Maj.Min.Rev of the version number.  See EDF/noarch/EDF-CMake/generatePluginID.py
class ExploitConfigError(ValueError):
    pass

def get_logger(logfile):
    # configure the root logger
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    
    if logfile is not None:
        fh = logging.FileHandler(logfile, mode="w")
        fh.setLevel(logging.DEBUG)
        fhFormatter = logging.Formatter('[%(levelname)-8s] %(filename)-18s (line %(lineno)-4s) -- %(message)s')
        fh.setFormatter(fhFormatter)
        logger.addHandler(fh) 
    
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    chFormatter = logging.Formatter("%(message)s")
    ch.setFormatter(chFormatter)
    logger.addHandler(ch)
    return logger
    
    
class CommandlineWrapper(object):
    def __init__(self):
        # This takes care of addWrapperInputs
        self.__coli_parser = OptionParser()
        self.__coli_parser.add_option("--InConfig",        dest="InConfig", help="The Input XML file" )
        self.__coli_parser.add_option("--OutConfig",       dest="OutConfig", default=sys.stdout, 
                                      help="Output XML file")
        self.__coli_parser.add_option("--LogFile",         dest="LogFile",   default=None,       
                                      help="Truantchild log file")
        self.__coli_parser.add_option("--ValidateOnly",    dest="ValidateOnly", default=False, action="store_true", 
                                      help="Valid params")
        
    def __hack_params_parseCommandLine(self, params, args, doHelp):
        params = ctypes.pointer(params)
        cArgs = len(args)
        args = ctypes.pointer(args)
        doHelp = ctypes.c_uint()
        pass

    def __call__(self, argv):
        """Effectively "main" from Commandlinewrapper"""
        logConfig = None
        context = {}
        rendezvous = None
        try:
            (opts, args) = self.__coli_parser.parse_args(argv)
            if opts.InConfig is None:
                raise ExploitConfigError("You must pass a valid --InConfig option")

            # Read the input config and create a truanchild Config object
            self.config = truantchild.Config([opts.InConfig])

            # make sure the id from the binary matches the config
            if self.getID() != self.config.id:
                print "Mismatching configurations!!"
                return 1

            # XXX Add the bit about help, line 215

            inputs = self.config._inputParams
            outputs= self.config._outputParams
            constants = None                # Fuzzbunch doesn't support these yet

            #pytrch.Params_parseCommandLine( inputs.parameters, len(sys.argv), sys.argv, doHelp)

            # Convert the options from Truanchild to easy-to-handle input for the plugin
            iOptions = self.tc2List( inputs )
            oOptions = self.tc2Dict( outputs )

            # add the params from the wrapper
            valid = self.validateParams(iOptions)
            # XXX Print the invalid options
            if opts.ValidateOnly is True:
                return 0

            (fhNo, logConfig) = self.processWrapperParams( opts )

            # Setup all of the existing sockets
            self.doRendezvousClient(inputs)        
            retval = self.processParams(iOptions, constants, oOptions, context, logConfig)

            try:
                self.options2Tc( oOptions, outputs )
            except Exception as e:
                # If this fails, the plugin was not successful
                print str(oOptions)
                print "Failed: {0}".format(e)
                return 1

            # Add the output parameter for the rendezvous
            (rendezvous, sock) = self.addWrapperOutputParams( outputs, self.config.namespaceUri, self.config.schemaVersion )
            exma.writeParamsToEM( fhNo, self.config.getMarshalledInConfig() )
        
            # This sends us into a send/recv loop
            self.doRendezvousServer( rendezvous, sock )
            self.cleanup( EDF_CLEANUP_WAIT, context, logConfig )

        except Exception as e:
            print "Failed: {0}".format(e)
            raise
    
    def __putConfig(self, config, outfile):
        self.config.putMarshalledConfig( opts.OutConfig )
    
    def processWrapperParams(self, options):
        """Setup so that we can do logging"""
        fh = None
        if options.LogFile is not None:
            print "logging to file"
            fh = exma.openEMForWriting( options.OutConfig )
            logger = get_logger(options.LogFile)
            #logging.basicConfig(filename=options.LogFile, filemode="w", format="%(message)s", level=logging.INFO)
        else:
            print "logging to stdout"
            fh = exma.openEMForWriting( None )        # Will cause stdout to be used
            logger = get_logger( None )
            #logging.basicConfig(level=logging.INFO, stream=sys.stdout)
        return (fh, logger)
        
    def tc2Dict(self, params):
        """Convert Truantchild parameters into a dictionary for easy processing"""
        d = {}
        for k,v in params.getParameterList():
            d[k] = v
        return d 

    def tc2List(self, inputs):
        """Convert inputs to optparse style options for ease of processing in Python"""
        args = []
        for k,v in inputs.getParameterList():
            args += ["--{0}".format(k), str(v)]
        return args

    def iterParams(self, params):
        """A parameter iterator"""
        for k,v in params.getParameterList():
            yield k

    def options2Tc( self, options, outputs ):
        """Convert from optparse options back to Truantchild parameters after execution"""
        # Need to match between the names of the outputs and the types in the config
        for name, val in outputs.getParameterList():
            if name in options.keys():
                # set the value
                outputs.set(name, options[name])

    def __needRendezvous(self, params, checkForContract):
        """Basically stolen from plugin::createsRendezvous"""
        if checkForContract:
            for name,val in params.getParameterList():
                if "Socket" == params.findOption(name).getType():
                    return True
        return False

    def __exma_bindRendezvous(self, outputs, namespaceUri, schemaVersion):
        """bindRendezvous taken from exma.dll"""
        rendezvous = ctypes.c_ushort()
        sock = ctypes.c_uint()
        ret = exma.bindRendezvous(ctypes.pointer(rendezvous), ctypes.pointer(sock))
        return (rendezvous.value, sock.value)

    def addWrapperOutputParams(self, outputs, namespaceUri, schemaVersion):
        """Add output parameters after the script runs to do rendezvous"""
        rendezvous = None
        sock = None
        if self.__needRendezvous(outputs, True):
            (rendezvous, sock) = self.__exma_bindRendezvous( outputs, namespaceUri, schemaVersion)
            outputs.addRendezvousParam( str(rendezvous) )  # addRendezvous needs a string
        return (rendezvous, sock)

    def __transformSocket(self, rendezvous, remoteSocket, localSocket, cache):
        """Perform the rendezvous socket transfer between plugins"""
        ls = ctypes.c_uint()
        if remoteSocket is None:
            localSocket = None
            return
        
        # Look in the cache
        for (l,r) in cache:
            if remoteSocket == r:
                localSocket = l
                return

        # Didn't find it in the cache, so add it
        exma.recvSocket( ctypes.c_uint(rendezvous), ctypes.c_uint(remoteSocket), ctypes.pointer(ls) )
        localSocket = ls.value
        entry = (ls.value, remoteSocket )
        cache.append(entry)

    def doRendezvousClient(self, inputs):
        """Connect all sockets to rendezvous server sockets"""
        cache = []
        rendezvousLocation = None
        sock = ctypes.c_uint()
        local = None
        sockparams = []
        for name,val in inputs.getParameterList():
            if name == "Rendezvous" and inputs.hasValidValue("Rendezvous"): 
                rendezvousLocation = inputs.get("Rendezvous")
            elif "Socket" == inputs.findOption(name).getType():
                sockets.append(inputs.findOption(name))
                
        if rendezvousLocation is not None and sockparam is not None:
            exma.connectRendezvous( rendezvousLocation, ctypes.pointer(sock) )

        for param in sockparams:
            if param.getFormat() == "Scalar":
                remote = param.getValue()
                self.__transformSocket( sock.value, remote, local, cache)
                param.setValue(local)
            else:
                socks = params.getvalue() # this is a list
                for i in xrange(remotes):
                    self.__transformSocket( sock, socks[i], local, cache )
                    socks[i] = local
                param.setValue(socks)
        exma.disconnectRendezvous( sock )
        # Now get rid of the rendezvous parameter
                
    def doRendezvousServer(self, rendezvous, sock):
        """Setup the rendezvous server so the next plugin can talk 'through' us"""
        if sock is not None:
            r = ctypes.c_uint(sock)
            if -1 == exma.sendSockets(r):
                return -1
            exma.closeRendezvous( ctypes.c_ushort(rendezvous), r)
            sock = None
        return 0

    #
    # These need to be implemented by the exploit
    # 
    def processParams(self, inputs, constants, outputs, context, logConfig):
        """Process the input parameters and achieve the intended purpose"""
        raise NotImplementedError("processParams must be implemented")

    def getID(self):
        """Return the plugin ID"""
        raise NotImplementedError("getID must be implemented")

    def cleanup(self, flags, context, logConfig):
        """Cleanup any errant connections or data after the rendezvous is done"""
        raise NotImplementedError("cleanup must be implemented")

    def validateParams(self, inputs):
        """Validate parameters to verify sane values"""
        raise NotImplementedError("validateParams must be implemented")
