
import ops.cmd
from ops.cmd import OpsCommandException
import os.path
VALID_OPTIONS = ['recursive', 'mask', 'path', 'max', 'time', 'age', 'after', 'before', 'hash', 'dirsonly', 'chunksize']

class DirCommand(ops.cmd.DszCommand, ):

    def __init__(self, plugin='dir', **optdict):
        ops.cmd.DszCommand.__init__(self, plugin=plugin, **optdict)
        if (len(self.arglist) > 0):
            (head, tail) = os.path.split(self.arglist[0])
            self.arglist = []
            if ((tail.find('"') > (-1)) or (tail.find("'") > (-1))):
                tail = tail[:(-1)]
            if ((head[0] == '"') or (head[0] == "'")):
                head = head[1:]
            if (head.find(' ') > (-1)):
                head = ('"%s"' % head)
            if (tail.find(' ') > (-1)):
                tail = ('"%s"' % tail)
            self.mask = tail
            self.path = head
        if ('path' in optdict):
            self.path = optdict['path']

    def validateInput(self):
        for optkey in self.optdict:
            optval = self.optdict[optkey]
            if (type(optval) is str):
                optval = optval.strip()
                if (optval[0] == '"'):
                    if (optval[(-1)] != '"'):
                        optval += '"'
                elif ((optkey in ['mask', 'path']) and (optval.find(' ') > (-1))):
                    optval = ('"%s"' % optval)
                self.optdict[optkey] = optval
        return True

    def _getMask(self):
        if ('mask' in self.optdict):
            return self.optdict['mask']
        else:
            return '*'

    def _setMask(self, val):
        val = val.strip()
        if ((val is not None) and (val != '')):
            self.optdict['mask'] = val
        else:
            del self.optdict['mask']
    mask = property(_getMask, _setMask)

    def _getPath(self):
        if ('path' in self.optdict):
            return self.optdict['path']
        else:
            return None

    def _setPath(self, val):
        val = val.strip()
        if ((val.find(' ') > (-1)) and (val[0] != '"')):
            val = ('"%s"' % val)
        if (val.find('""') > (-1)):
            val = val.replace('""', '"')
        if ((val is not None) and (val != '')):
            self.optdict['path'] = val
        else:
            del self.optdict['path']
    path = property(_getPath, _setPath)

    def _getRecursive(self):
        if ('recursive' in self.optdict):
            return True
        else:
            return False

    def _setRecursive(self, val):
        if val:
            self.optdict['recursive'] = True
        else:
            del self.optdict['recursive']
    recursive = property(_getRecursive, _setRecursive)

    def _getDirsonly(self):
        if ('dirsonly' in self.optdict):
            return True
        else:
            return False

    def _setDirsonly(self, val):
        if val:
            self.optdict['dirsonly'] = True
        else:
            del self.optdict['dirsonly']
    dirsonly = property(_getDirsonly, _setDirsonly)

    def _getTime(self):
        if ('time' in self.optdict):
            return self.optdict['time']
        else:
            return 'modified'

    def _setTime(self, val):
        if (val in ['modified', 'created', 'accessed']):
            self.optdict['time'] = val
        elif (val is None):
            del self.optdict['time']
        else:
            raise OpsCommandException('-time must be one of accessed|created|modified')
    time = property(_getTime, _setTime)

    def _getAge(self):
        if ('age' in self.optdict):
            return self.optdict['age']
        else:
            return None

    def _setAge(self, val):
        if ((val is not None) and (val != '')):
            val = val.strip()
            self.optdict['age'] = val
            self.after = None
            self.before = None
        elif ('age' in self.optdict):
            del self.optdict['age']
    age = property(_getAge, _setAge)

    def _getAfter(self):
        if ('after' in self.optdict):
            return self.optdict['after']
        else:
            return None

    def _setAfter(self, val):
        if ((val is not None) and (val != '')):
            val = val.strip()
            self.optdict['after'] = val
            if ((' ' in self.optdict['after']) and (self.optdict['after'][0] != '"')):
                self.optdict['after'] = (('"' + self.optdict['after']) + '"')
            self.age = None
        elif ('after' in self.optdict):
            del self.optdict['after']
    after = property(_getAfter, _setAfter)

    def _getBefore(self):
        if ('before' in self.optdict):
            return self.optdict['before']
        else:
            return None

    def _setBefore(self, val):
        if ((val is not None) and (val != '')):
            val = val.strip()
            self.optdict['before'] = val
            if ((' ' in self.optdict['before']) and (self.optdict['before'][0] != '"')):
                self.optdict['before'] = (('"' + self.optdict['before']) + '"')
            self.age = None
        elif ('before' in self.optdict):
            del self.optdict['before']
    before = property(_getBefore, _setBefore)

    def _getMax(self):
        if ('max' in self.optdict):
            return self.optdict['max']
        else:
            return None

    def _setMax(self, val):
        if (val is not None):
            try:
                val = int(val)
            except:
                raise OpsCommandException('-max for a dir command must be an integer')
            self.optdict['max'] = val
        else:
            del self.optdict['max']
    max = property(_getMax, _setMax)

    def _getHash(self):
        if ('hash' in self.optdict):
            return self.optdict['hash']
        else:
            return None

    def _setHash(self, val):
        if (val is not None):
            self.optdict['hash'] = val
        else:
            del self.optdict['hash']
    hash = property(_getHash, _setHash)

    def _getChunksize(self):
        if ('chunksize' in self.optdict):
            return self.optdict['chunksize']
        else:
            return None

    def _setChunksize(self, val):
        if (val is not None):
            try:
                val = int(val)
            except:
                raise OpsCommandException('-chunksize for a dir command must be an integer')
            self.optdict['chunksize'] = val
        else:
            del self.optdict['chunksize']
    chunksize = property(_getChunksize, _setChunksize)
ops.cmd.command_classes['dir'] = DirCommand
ops.cmd.aliasoptions['dir'] = VALID_OPTIONS