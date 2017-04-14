
import dsz
import os
import re
from task import *

class RegQuery(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'RegistryQuery')

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
        return [('registryquery -hive %s -key %s' % (key, self.Subkey))]
TaskingOptions['_regQueryTasking'] = RegQuery