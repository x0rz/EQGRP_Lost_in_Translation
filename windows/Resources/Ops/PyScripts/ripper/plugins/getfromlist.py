
from plugin import plugin

def description():
    return 'gets files listed in a file'

class getfromlist(plugin, ):

    def __init__(self, os, maxsize):
        plugin.__init__(self, os, maxsize, __name__)
        print ('loaded %s' % __name__)

    def preGet(self):
        lFiles = self.listFiles()
        size = 0
        for f in lFiles:
            size += f.size
        print ('About to get %d files totalling %d bytes. Will prompt for individual files > %d bytes' % (len(lFiles), size, self.getMaxSize()))

    def postGet(self):
        pass

    def check(self, path):
        import ops.env
        import os, os.path
        findThese = []
        __in = os.path.join(ops.env.get('_LOGPATH'), 'tmp', 'filestoget.txt')
        try:
            filesToCheck = open(__in)
        except:
            print ("Couldn't open file %s for input" % __in)
            return
        for file in filesToCheck.readlines():
            findThese.append(file.strip())
        filesToCheck.close()
        self.findPathAndMask(findThese, False)