
from plugin import plugin

class skype(plugin, ):

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
            topDir = ('%s\\AppData\\Roaming\\Skype' % path)
        else:
            topDir = ('%s\\Application Data\\Skype' % path)
        findThese = ['call*.ddb', 'chat*.ddb', 'sms*.ddb', 'transfer*.ddb', 'voicemail*.ddb', 'main.db']
        self.find(topDir, findThese)