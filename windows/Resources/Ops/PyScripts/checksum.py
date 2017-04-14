
import os.path
import dsz
import sys
import dsz.lp
import hashlib
from optparse import OptionParser

def hashFile(path, mask, hashtype):
    try:
        dsz.cmd.Run(('dir -mask %s -path "%s" -hash %s' % (mask, path, hashtype)), dsz.RUN_FLAG_RECORD)
        hashes = dsz.cmd.data.Get('diritem::fileitem::hash::value', dsz.TYPE_STRING)
        files = dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)
    except:
        print '[-] Error no such localfile file'
        return []
    return [hashes, files]

def localhashFile(path, mask, hashtype):
    try:
        dsz.cmd.Run(('local dir -mask %s -path "%s" -hash %s' % (mask, path, hashtype)), dsz.RUN_FLAG_RECORD)
        hashes = dsz.cmd.data.Get('diritem::fileitem::hash::value', dsz.TYPE_STRING)
        files = dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)
    except:
        print '[-] Error no such localfile file'
        return []
    return [hashes, files]

def prepArgs(args):
    if (len(args) == 5):
        return (args[1], args[2], args[3], args[4])
    elif (len(args) == 3):
        temp = ['', '', '', '']
        (temp[0], temp[1]) = os.path.split(args[1])
        (temp[2], temp[3]) = os.path.split(args[2])
        if ((len(temp[2]) == 0) or (len(temp[1]) == 0)):
            return (args[1], args[2])
        return temp
    elif (len(args) == 2):
        return os.path.split(args[1])
    elif (len(args) == 1):
        return os.path.split(args[0])

def compareLocalRemote(args, hashtype):
    remoteHashes = hashFile(args[0], args[1], hashtype)
    localHashes = localhashFile(args[2], args[3], hashtype)
    total = len(remoteHashes[0])
    matches = 0
    if ((len(remoteHashes) > 0) and (len(localHashes) > 0)):
        for i in range(len(remoteHashes[0])):
            flag = False
            duplicate = False
            for j in range(len(localHashes[0])):
                if ((remoteHashes[0][i] == localHashes[0][j]) and (not duplicate)):
                    print ('Remote:%s ++++ Local:%s' % (remoteHashes[1][i], localHashes[1][j]))
                    flag = True
                    matches += 1
                    duplicate = True
                elif ((remoteHashes[0][i] == localHashes[0][j]) and duplicate):
                    print ('Remote:%s ++++ Local:%s' % (remoteHashes[1][i], localHashes[1][j]))
                    print '!!!REMOTE FILE MATCHES MORE THAN ONE FILE!!!'
                    flag = True
                    matches += 1
                    duplicate = True
            if (not flag):
                print ('Remote:%s ---- NO MATCH' % remoteHashes[1][i])
                print ('%s: %s\n' % (hashtype.upper(), remoteHashes[0][i]))
        print '---------------------------------------'
        print ('%d of %d Files Matched' % (matches, total))
        if (matches > total):
            print 'Extra Matches: Check for duplicate files in list above'

def compareRemoteFile(args, filename, hashtype):
    remoteHashes = hashFile(args[0], args[1], hashtype)
    if os.path.exists(filename):
        try:
            masterList = open(filename, 'rb')
        except:
            print ('[-] Error opening %s for reading' % filename)
    else:
        print ('[-] ERROR file %s does not exist' % filename)
        sys.exit((-1))
    total = len(remoteHashes[0])
    matches = 0
    multiflag = False
    for i in range(len(remoteHashes[0])):
        flag = False
        masterList.seek(0)
        multimatch = 0
        for line in masterList:
            if (line.split('\t')[0] == remoteHashes[0][i]):
                print ('Remote: %s ++++ File: %s' % (remoteHashes[1][i], line.split('\t')[1].rstrip()))
                flag = True
                matches += 1
                multimatch += 1
        if (multimatch > 1):
            (multiflag == True)
        if (not flag):
            print ('Remote: %s --- NO MATCH' % remoteHashes[1][i])
            print ('%s: %s\n' % (hashtype.upper(), remoteHashes[0][i]))
    print ('%d/%d Files Matched' % (matches, total))
    if multiflag:
        print 'Files have matched multiple entries in Masterlist'

def printHashes(args, hashtype):
    remoteHashes = hashFile(args[0], args[1], hashtype)
    if (len(remoteHashes) > 0):
        for i in range(len(remoteHashes[0])):
            print ('Remote:%s' % remoteHashes[1][i])
            print ('%s: %s\n' % (hashtype.upper(), remoteHashes[0][i]))

def genMasterList(args, filename, hashtype):
    try:
        dsz.cmd.Run(('dir -mask %s -path "%s" -hash %s' % (args[1], args[0], hashtype)), dsz.RUN_FLAG_RECORD)
        hashes = dsz.cmd.data.Get('diritem::fileitem::hash::value', dsz.TYPE_STRING)
        files = dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)
    except:
        print '[-] Error no such localfile file'
        return []
    try:
        masterList = open(filename, 'ab')
    except:
        print ('[-] Error Opening %s to write' % filename)
        sys.exit((-1))
    masterList.write(('#PATH: %s\n#MASK: %s\n#HashType%s\n' % (args[0], args[1], hashtype)))
    if (len(hashes) > 0):
        for i in range(len(hashes)):
            masterList.write(('%s\t%s\n' % (hashes[i], files[i])))
    masterList.close()

def printUserHash(arg, hashtype):
    if (hashtype == 'md5'):
        m = hashlib.md5()
    elif (hashtype == 'sha1'):
        m = hashlib.sha1()
    else:
        return False
    m.update(arg)
    print ('Entered: %s\n%s: %s\n' % (arg, hashtype.upper(), m.hexdigest()))

def parseArgs():
    usage = 'checksum [options] filename\n            '
    example = '\n    Checksum a file:\n        checksum c:\\windows\\system32\\ipconfig.exe\n    Checksum a file and compare to a local file: \n        checksum c:\\windows\\system32\\ipconfig.exe -l d:\\knowngood\\ipconfig.exe\n    Checksum a file and search a file of hashes for matches:\n        checksum c:\\windows\\system32\\ipconfig.exe -f d:\\fileOhashes.txt\n    Checksum a string:\n        checksum -u "String to Hash"\n    '
    parser = OptionParser(usage=usage)
    parser.add_option('-f', dest='filecompare', type='string', action='store', default=None, help='[File Compare] file of hashes to compare against')
    parser.add_option('-l', dest='localcompare', type='string', action='store', default=None, help='[Local File Compare] actual file to compare against')
    parser.add_option('-u', dest='userentry', type='string', action='store', default=None, help='[User Entry] Hash entered string')
    parser.add_option('-t', dest='hashtype', type='string', action='store', default='sha1', help='[hash type] sha1 or md5 default: sha1')
    parser.add_option('-g', dest='genfile', type='string', action='store', default=None, help='[Gen List] filename to store generated hash list of remote files')
    (options, args) = parser.parse_args(sys.argv)
    if (len(sys.argv) == 1):
        parser.print_help()
        print example
        sys.exit((-1))
    return [options, args]
if (__name__ == '__main__'):
    dsz.control.echo.Off()
    (options, args) = parseArgs()
    if (not (options.userentry == None)):
        printUserHash(options.userentry, options.hashtype)
    if (not (options.localcompare == None)):
        newargs = (prepArgs(args) + prepArgs([options.localcompare]))
        compareLocalRemote(newargs, options.hashtype)
    if (not (options.filecompare == None)):
        args = prepArgs(args)
        compareRemoteFile(args, options.filecompare, options.hashtype)
    if (not (options.genfile == None)):
        args = prepArgs(args)
        genMasterList(args, options.genfile, options.hashtype)
    if ((options.genfile == None) and (options.userentry == None) and (options.localcompare == None) and (options.filecompare == None)):
        args = prepArgs(args)
        printHashes(args, options.hashtype)
    print '--Checksum Complete--'