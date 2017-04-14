
import dsz
import os
import re
from task import *
MaximumAutomaticSize = ((1024 * 1024) * 2)

class Get(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'Get')
        self.Concerns = list()
        self.Count = 'Unknown'
        self.Verify = True

    def Preprocessing(self):
        bRecursive = False
        if ('Depth' in self.__dict__):
            if (self.Depth == '0'):
                bRecursive = True
        if (bRecursive and ((not ('Maximum' in self.__dict__)) or (int(self.Maximum) == 0))):
            self.Concerns.append('Recursive GET with no maximum')
        if ('Maximum' in self.__dict__):
            if (int(self.Maximum) > 100):
                self.Concerns.append('Maximum of over 100 files')
        if (len(self.Concerns) > 0):
            return
        str = 'dir'
        if ('Path' in self.__dict__):
            str = ('%s -path %s' % (str, self.Path))
        if ('Mask' in self.__dict__):
            str = ('%s -mask "%s"' % (str, self.Mask))
        if ('Depth' in self.__dict__):
            if (self.Depth == '0'):
                str = ('%s -recursive' % str)
        if ('Maximum' in self.__dict__):
            str = ('%s -max %s' % (str, self.Maximum))
        start = 0
        end = 0
        if (('Direction' in self.__dict__) and ('Time' in self.__dict__)):
            str = ('%s -%s %s' % (str, self.Direction, self.Time))
        if ('timeType' in self.__dict__):
            str = ('%s -time %s' % (str, self.timeType))
        if dsz.cmd.Run(str, dsz.RUN_FLAG_RECORD):
            try:
                size = sum(dsz.cmd.data.Get('DirItem::FileItem::size', dsz.TYPE_INT))
                self.Count = ('%d files' % dsz.cmd.data.Get('DirItem::FileItem::size', dsz.TYPE_INT)[0])
                if (size > MaximumAutomaticSize):
                    self.Concerns.append(('Retrievable size is %d bytes' % size))
                else:
                    self.Verify = False
            except:
                self.Concerns.append('Unable to enumerate files for size')
        else:
            self.Concerns.append('Directory listing to gather file size failed')
        return str

    def IsVerify(self):
        return self.Verify

    def CreateCommandLine(self):
        str = 'get'
        if ('Path' in self.__dict__):
            str = ('%s -path %s' % (str, self.Path))
        if ('Mask' in self.__dict__):
            str = ('%s -mask "%s"' % (str, self.Mask))
        if ('Depth' in self.__dict__):
            if (self.Depth == '0'):
                str = ('%s -recursive' % str)
        if ('Maximum' in self.__dict__):
            str = ('%s -max %s' % (str, self.Maximum))
        start = 0
        end = 0
        if ('Start' in self.__dict__):
            start = int(self.Start)
        if ('Length' in self.__dict__):
            length = int(self.Length)
            end = (start + length)
            if (end > 0):
                end = (end - 1)
        if (('Direction' in self.__dict__) and ('Time' in self.__dict__)):
            str = ('%s -%s %s' % (str, self.Direction, self.Time))
        if ('timeType' in self.__dict__):
            str = ('%s -time %s' % (str, self.timeType))
        if (start < 0):
            str = ('%s -tail %d' % (str, (- start)))
        elif (end > start):
            str = ('%s -range %d %d' % (str, start, end))
        else:
            str = ('%s -range %d' % (str, start))
        return [str]

    def Display(self):
        dsz.ui.Echo('Retrieve Files')
        try:
            path = self.Path
        except:
            path = 'None'
        try:
            mask = self.Mask
        except:
            mask = 'None'
        dsz.ui.Echo((' Path : %s' % path))
        dsz.ui.Echo((' Mask : %s' % mask))
        dsz.ui.Echo(('Count : %s' % self.Count))
        if (len(self.Concerns) > 0):
            dsz.ui.Echo('Concerns:')
            for concern in self.Concerns:
                dsz.ui.Echo(('    %s' % concern), dsz.WARNING)
        pass
TaskingOptions['_getTasking'] = Get