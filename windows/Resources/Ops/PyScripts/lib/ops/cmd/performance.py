
import ops.cmd
import util.ip
DATA_TYPES = ['all', 'browser', 'cache', 'expensive', 'icmp', 'ip', 'jobobject', 'jobobjectdetails', 'logicaldisk', 'memory', 'networkinterface', 'objects', 'pagingfile', 'physicaldisk', 'process', 'processor', 'system', 'tcp', 'telephony', 'terminalservices', 'thread', 'udp']

class PerformanceCommand(ops.cmd.DszCommand, ):

    def __init__(self, plugin='performance', data=None, objectNumber=None, initialBufferSize=None, bare=False, target=None, **optdict):
        self.data = data
        self.objectNumber = objectNumber
        self.initialBufferSize = initialBufferSize
        self.bare = bare
        self.target = target
        ops.cmd.DszCommand.__init__(self, plugin, **optdict)

    def _getInitialBufferSize(self):
        return self._opt_initial

    def _setInitialBufferSize(self, bufferSize):
        assert ((bufferSize is None) or ((type(bufferSize) is int) and (bufferSize > 0))), 'bufferSize must be an integer greater than zero; or None to clear this option.'
        self._opt_initial = bufferSize
    initialBufferSize = property(_getInitialBufferSize, _setInitialBufferSize)

    def _getObjectNumber(self):
        return self._opt_objectNumber

    def _setObjectNumber(self, objectNumber):
        assert ((objectNumber is None) or ((type(objectNumber) is int) and (objectNumber >= 0))), 'Object number must be a positive integer or zero; or None to clear this option.'
        self._opt_objectNumber = objectNumber
    objectNumber = property(_getObjectNumber, _setObjectNumber)

    def _getData(self):
        return self._opt_data

    def _setData(self, data):
        assert ((type(data) is str) or (type(data) is unicode) or (data is None)), 'Data must be a string value or None to clear this option.'
        assert ((data is None) or (data.lower() in DATA_TYPES)), 'Data must be one of the valid data type queries.'
        self._opt_data = data
    data = property(_getData, _setData)

    def _getBare(self):
        return self._opt_bare

    def _setBare(self, bare):
        assert (type(bare) is bool), 'Bare must be Boolean.'
        self._opt_bare = bare
    bare = property(_getBare, _setBare)

    def _getTarget(self):
        return self._opt_target

    def _setTarget(self, target):
        assert ((type(target) is str) or (type(target) is unicode) or (target is None)), 'Target must be a string representation or None to clear.'
        assert ((target is None) or util.ip.validate(target)), 'Target address must be a valid IPv4 or IPv6 address.'
        self._opt_target = target
    target = property(_getTarget, _setTarget)

    def validateInput(self):
        if ((self.data is not None) and (self.objectNumber is not None)):
            return False
        if ((self.data is None) and (self.objectNumber is None)):
            return False
        return True

    def __str__(self):
        cmdstr = u''
        for prefix in self.prefixes:
            cmdstr += ('%s ' % prefix)
        cmdstr += (self.plugin + ' ')
        if self.initialBufferSize:
            cmdstr += ('-initial %s ' % self.initalBufferSize)
        if self.objectNumber:
            cmdstr += ('-objectnum %s ' % self.objectNumber)
        if self.data:
            cmdstr += ('-data %s ' % self.data)
        if self.bare:
            cmdstr += '-bare '
        if self.target:
            cmdstr += ('-target %s ' % self.target)
        return ops.utf8(cmdstr)
ops.cmd.command_classes['performance'] = PerformanceCommand