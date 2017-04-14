
from plugin import plugin

class unknowns(plugin, ):

    def __init__(self, os, maxsize):
        plugin.__init__(self, os, maxsize, __name__)
        print ('loaded %s' % __name__)

    def preGet(self):
        pass

    def postGet(self):
        pass

    def check(self, path):
        import ops.env
        import os, os.path
        __in = os.path.join(ops.env.get('_LOGPATH'), 'tmp', 'unknowns.txt')
        __out = os.path.join(ops.env.get('_LOGPATH'), 'GetFiles', 'NOSEND', 'unknowns.txt')
        if (not os.path.exists(os.path.split(__out)[0])):
            os.makedirs(os.path.split(__out)[0])
        try:
            filesToCheck = open(__in)
        except:
            print ("Couldn't open file %s for input" % __in)
            return
        try:
            saveFile = open(__out, 'a+b')
        except:
            print ("Couldn't open file %s for output" % __out)
            return
        for file in filesToCheck.readlines():
            rPath = os.path.split(file.strip())[0]
            rMask = os.path.split(file.strip())[1]
            rDir = ops.files.dirs.get_dirlisting(path=rPath, mask=rMask, hash=True)
            for diritem in rDir.diritem:
                for fileitem in diritem.fileitem:
                    saveFile.write((fileitem.fullpath + '\n'))
                    for filehash in fileitem.filehash:
                        remoteHash = filehash.value
                        saveFile.write((((filehash.type + ': ') + filehash.value) + '\n'))
                    saveFile.write('\n\n')
        saveFile.close()
        print ('Hashes saved to ' + __out)
        filesToCheck.close()