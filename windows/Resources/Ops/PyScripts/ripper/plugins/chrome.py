
from plugin import plugin

class chrome(plugin, ):

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
        topDir = ''
        if (self.getOS() == 6):
            topDir = ('%s\\AppData\\Local\\Google\\Chrome\\User Data' % path)
        else:
            topDir = ('%s\\Application Data\\Google\\Chrome\\User Data' % path)
        findThese = ['Bookmarks', 'Cookies', 'History', 'Login Data', 'Preferences', 'Web Data']
        self.find(topDir, findThese)