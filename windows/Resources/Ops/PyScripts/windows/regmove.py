
import dsz
import sys, os
import dsz.file
import dsz.windows
from optparse import OptionParser

class pfro:

    def __init__(self, target=''):
        self.target = target
        self.key = []

    def getRenameKey(self):
        inputvals = []
        if (not self.target):
            try:
                cmd = 'registryquery -hive l -key "SYSTEM\\CurrentControlSet\\control\\session manager" -value "PendingFileRenameOperations"'
                dsz.cmd.Run(cmd.encode('utf-8'), dsz.RUN_FLAG_RECORD)
                inputvals = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)[0]
            except:
                print '[-] Failed to read PFRO key'
                return None
        else:
            try:
                cmd = ('registryquery -hive l -key "SYSTEM\\CurrentControlSet\\control\\session manager" -value "PendingFileRenameOperations" -target %s' % self.target)
                dsz.cmd.Run(cmd.encode('utf-8'), dsz.RUN_FLAG_RECORD)
                inputvals = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING)[0]
            except:
                print '[-] Failed to read PFRO key'
                return None
        self.key = inputvals.decode('hex').decode('utf-16le').split('\x00')
        self.key.pop()
        self.key.pop()

    def addKey(self, key):
        if self.checkPath(filename):
            if (filename.find(u'\\??\\') == (-1)):
                self.key.append((u'\\??\\%s' % filename))
            else:
                self.key.append(filename)
            self.key.append(u'|')
            return True
        else:
            return False

    def remKey(self, filename):
        indexes = []
        tempkey = self.key
        for i in range(0, len(tempkey), 2):
            if ((not tempkey[(i + 1)]) and self.checkFile(tempkey[i], filename)):
                indexes.insert(0, i)
                indexes.insert(0, (i + 1))
        for index in indexes:
            self.key.pop(index)
        if indexes:
            return True
        return False

    def writeKey(self):
        reg_key = u'|'.join(self.key)
        if (reg_key[(-1):] == '|'):
            reg_key = (u'%s|' % reg_key.rstrip('|'))
        if (self.target == ''):
            if reg_key:
                cmd = (u'registryadd -hive L -key "SYSTEM\\CurrentControlSet\\control\\session manager" -type REG_MULTI_SZ -value PendingFileRenameOperations -data "%s"' % reg_key)
                if (not dsz.cmd.Run(cmd.encode('utf-8'))):
                    print '[!] Writing PFRO Failed'
                    return False
                else:
                    print '[+] Write PFRO Win'
                    return True
            elif (not dsz.cmd.Run(u'registrydelete -hive L -key "SYSTEM\\CurrentControlSet\\control\\session manager" -value PendingFileRenameOperations')):
                print '[!] Writing PFRO Failed'
                return False
            else:
                print '[+] Write PFRO Win'
                return True
        elif reg_key:
            cmd = (u'registryadd -hive L -key "SYSTEM\\CurrentControlSet\\control\\session manager" -type REG_MULTI_SZ -value PendingFileRenameOperations -data "%s" -target %s' % (reg_key, self.target)).encode('utf-8')
            if (not dsz.cmd.Run(cmd)):
                print '[!] Writing PFRO Failed'
                return False
            else:
                print '[+] Write PFRO Win'
                return True
        elif (not dsz.cmd.Run((u'registrydelete -hive L -key "SYSTEM\\CurrentControlSet\\control\\session manager" -value PendingFileRenameOperations -target %s' % self.target))):
            print '[!] Writing PFRO Failed'
            return False
        else:
            print '[+] Write PFRO Win'
            return True

    def optimizeKey(self):
        DeletedKeys = []
        MoveKeys = []
        inputvals = self.key
        for i in range(0, len(inputvals), 2):
            if inputvals[(i + 1)]:
                MoveKeys.append(inputvals[i])
                MoveKeys.append(inputvals[(i + 1)])
            else:
                DeletedKeys.append(inputvals[i])
        DeletedKeys.sort()
        fixedRegVal = []
        counter = 1
        for line in DeletedKeys:
            if ((len(fixedRegVal) == 0) or (not (line.lower() == fixedRegVal[(len(fixedRegVal) - 1)][0].lower()))):
                counter = 1
                fixedRegVal.append([unicode(line), counter])
            else:
                counter += 1
                if (counter > 1):
                    fixedRegVal[(len(fixedRegVal) - 1)][1] = counter
        counts = []
        deletes = []
        for line in fixedRegVal:
            counts.append(line[1])
            deletes.append(line[0])
        return (deletes, counts, MoveKeys)

    def printKey(self):
        (deletes, counts, move) = self.optimizeKey()
        print '\n----------\nDelete\n----------'
        if deletes:
            for i in range(len(deletes)):
                print ('%s  x  %s' % (deletes[i], counts[i]))
        print '\n----------\nMove\nSRC---->DST\n----------'
        if move:
            for i in range(0, len(move), 2):
                print ('%s\t%s' % (move[i], move[(i + 1)]))

    def checkFile(self, key, checkFile):
        if (len(checkFile.split('\\')) > 1):
            if (checkFile.lower().lstrip('\\?') == key.lower().lstrip('\\?')):
                return True
        elif (checkFile.lower() == key.split('\\')[(-1)].lower()):
            return True
        return False

    def checkPath(self, filename):
        path = os.path.dirname(filename)
        return dsz.file.Exists(path.rstrip('\\'))

    def removePFRO(self, filename):
        print '[+] Checking if key needs to be changed'
        if self.remKey(filename):
            print ('[+] Removing %s' % filename)
            return self.writeKey()
        else:
            print ('[-] %s: not in PFRO key' % filename)
            return False

    def addPFRO(self, filename):
        print ('[+] Checking path of %s' % filename)
        if (self.target or self.checkPath(filename)):
            if (filename.find(u'\\??\\') == (-1)):
                self.key.append((u'\\??\\%s' % filename))
            else:
                self.key.append(filename)
            self.key.append(u'|')
            print ('[+] Adding %s to PendingFileRenameOperations key' % filename)
            return self.writeKey()
        else:
            print 'Path does not exist not changing key.'
            return False

    def queryPFRO(self):
        self.printKey()
if (__name__ == '__main__'):
    filename = u''
    command_string = u''
    usage = 'usage: regmove.py [options]'
    parser = OptionParser(usage)
    parser.add_option('-a', '--add', dest='add', action='store_true', help='Add FILENAME to PFRO key')
    parser.add_option('-r', '--remove', dest='remove', action='store_true', help='Remove FILENAME from PFRO key')
    parser.add_option('-q', '--query', help='Print values of PFRO key', action='store_true', dest='query')
    parser.add_option('-t', '--target', help='IP of remote target', default='', dest='target')
    (options, args) = parser.parse_args()
    if args:
        command_string = ' '.join(args)
    filename = command_string.replace("'", '').decode('utf-8')
    target = options.target
    dsz.control.echo.Off()
    if ((not options.add) and (not options.remove) and (not options.query)):
        parser.print_help()
        sys.exit((-1))
    if (options.add and options.remove):
        print '[!] Only one option at a time'
        sys.exit((-1))
    myPFRO = pfro(target)
    myPFRO.getRenameKey()
    if options.query:
        myPFRO.queryPFRO()
    elif options.remove:
        myPFRO.removePFRO(filename)
    elif options.add:
        myPFRO.addPFRO(filename)