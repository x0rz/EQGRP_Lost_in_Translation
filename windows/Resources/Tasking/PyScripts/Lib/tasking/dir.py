
import dsz
import os
import re
from task import *
import tasking

class Dir(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'Dir')

    def IsVerify(self):
        if (('Path' in self.__dict__) and ('Depth' in self.__dict__) and ('Mask' in self.__dict__)):
            if ((self.Path == '*') and (Mask == '*') and (self.Depth == '0')):
                self.Concerns = 'This is full recursive dirwalk'
                return True
        return False

    def CreateCommandLine(self):
        str = 'dir'
        if ('Path' in self.__dict__):
            str = ('%s -path %s' % (str, self.Path))
        if ('Mask' in self.__dict__):
            str = ('%s -mask %s' % (str, self.Mask))
        if ('Depth' in self.__dict__):
            if (self.Depth == '0'):
                str = ('%s -recursive' % str)
        if ('Maximum' in self.__dict__):
            str = ('%s -max %s' % (str, self.Maximum))
        if ('Listall' in self.__dict__):
            if (not bool(self.Listall)):
                str = ('%s -dirsonly' % str)
        if (('Direction' in self.__dict__) and ('Time' in self.__dict__)):
            str = ('%s -%s %s' % (str, self.Direction, self.Time))
        if ('timeType' in self.__dict__):
            str = ('%s -time %s' % (str, self.timeType))
        return [str]

    def Display(self):
        dsz.ui.Echo('Directory listing')
        cmds = CreateCommandLine
        for cmd in cmds:
            dsz.ui.Echo(('  `%s`' % cmd))
        dsz.ui.Echo(('%s' % self.Concerns), dsz.WARNING)
TaskingOptions['_dirTasking'] = Dir