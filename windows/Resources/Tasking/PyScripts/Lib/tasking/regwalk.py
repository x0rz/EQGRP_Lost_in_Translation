
import dsz
import os
import re
from task import *

class RegWalk(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'RegistryWalk')

    def CreateCommandLine(self):
        key = ''
        self.RootKey = self.RootKey.strip('"')
        if (self.RootKey == 'HKEY_LOCAL_MACHINE'):
            key = 'L'
        elif (self.RootKey == 'HKEY_USERS'):
            key = 'U'
        elif (self.RootKey == 'HKEY_CURRENT_USER'):
            key = 'C'
        elif (self.RootKey == 'HKEY_CURRENT_CONFIG'):
            key = 'G'
        elif (self.RootKey == 'HKEY_CLASSES_ROOT'):
            key = 'R'
        else:
            dsz.ui.Echo(('Unknown key: %s' % self.RootKey), dsz.ERROR)
        depth = ''
        if ('Depth' in self.__dict__):
            if (int(self.Depth) == 1):
                depth = '-recursive'
        return [('registryquery -hive %s -key %s %s' % (key, self.Subkey, depth))]
TaskingOptions['_regWalkTasking'] = RegWalk