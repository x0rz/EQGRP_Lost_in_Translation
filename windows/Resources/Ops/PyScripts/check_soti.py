
import operator, os, os.path, shutil, struct, sys
from ops.parseargs import ArgumentParser
import dsz.ui, ops.cmd, ops.env, ops.files.dirs, ops.system.environment
GETFILES = os.path.join(ops.env.get('_LOGPATH'), 'GetFiles')
NOSEND = os.path.join(GETFILES, 'NOSEND')
SOTIContainers = ['consolad.ttf', 'davidbi.ttf', 'georgiad.ttf', 'palabd.ttf', 'tahomabi.ttf', 'timesbc.ttf', 'trebucbc.ttf', 'verdanad.ttf']
remoteFontsDir = ''
remoteSystemDrive = ''
remoteEnv = ops.system.environment.get_environment()
for sysVar in remoteEnv.environment.value:
    if (sysVar.name.lower() == 'systemdrive'):
        remoteSystemDrive = sysVar.value
    if (sysVar.name.lower() == 'systemroot'):
        remoteFontsDir = os.path.join(sysVar.value, 'Fonts')
_logmsgs = []

def log(lmsg, smsg):
    global _logmsgs
    _logmsgs.append([lmsg, smsg])

def printlog(quietprint=True):
    global _logmsgs
    if (quietprint is True):
        smsg = 'soti_check: '
        for msg in _logmsgs:
            if (msg[1] != ''):
                smsg += (msg[1] + ' ')
        dsz.ui.Echo(smsg, dsz.GOOD)
    else:
        dsz.ui.Echo('soti_check:', dsz.GOOD)
        for msg in _logmsgs:
            if (msg[0] != ''):
                dsz.ui.Echo(msg[0], dsz.GOOD)

def containers(quiet=False):
    global remoteFontsDirs, SOTIContainers
    fontsdir = ops.files.dirs.get_dirlisting(path=remoteFontsDir, mask='*.ttf', maxage=0)
    foundContainers = []
    for diritem in fontsdir.diritem:
        for font in diritem.fileitem:
            if (font.name in SOTIContainers):
                foundContainers.append(font)
    if (int(len(foundContainers)) > 0):
        log(('  Found %d SOTI container(s);' % int(len(foundContainers))), ('Found %d SOTI container(s);' % int(len(foundContainers))))
        for container in foundContainers:
            log(('    %s (%d)' % (container.fullpath, container.size)), '')
    else:
        log('No SOTI containers', 'No SOTI containers')

def get8k():
    global remoteSystemDrive
    cmd = ops.cmd.getDszCommand('get')
    cmd.arglist = [('"\\\\?\\%s"' % remoteSystemDrive)]
    cmd.optdict = {'range': '0 8191', 'name': 'BootSector'}
    obj = cmd.execute()
    if cmd.success:
        gfBootSector = os.path.join(GETFILES, obj.filelocalname[0].localname)
        nsBootSector = os.path.join(NOSEND, obj.filelocalname[0].localname)
        if (not os.path.exists(NOSEND)):
            os.makedirs(NOSEND)
        shutil.move(gfBootSector, nsBootSector)
        localhash(nsBootSector)
    else:
        log(('get MBR failed. cmd %d' % obj._cmdid), ('get %d failed' % obj._cmdid))

def localhash(localFile=None):
    dataOffset = 656
    dataLen = 7024
    BootSectorDict = {}
    BootSectorDict[3045655125L] = 'Pre-Vista - SOTI 1.3.2'
    BootSectorDict[4057611551L] = 'VISTA+ - SOTI 1.3.2'
    BootSectorDict[2135347019] = 'Pre-Vista - SOTI 1.3.3 / 1.3.4'
    BootSectorDict[1284376162] = 'VISTA+ - SOTI 1.3.3 / 1.3.4'
    BootSectorDict[1125905602] = 'Windows 7 32/64 bit default'
    BootSectorDict[4194054995L] = 'W2k3 32 bit default'
    BootSectorDict[2744352803L] = 'XPSP3 32 bit default'
    BootSectorDict[2949997747L] = 'w7ldr / WindowsLoader'

    def CRCData(data):
        crc = 0
        length = len(data)
        for i in range(length):
            crc = (((crc >> 9) & 8388607) | ((crc << 23) & 4286578688L))
            crc += ((i + 1) * struct.unpack('b', data[i])[0])
        return crc

    def CRCBootSectorFile(path):
        if os.path.exists(path):
            with open(path, 'rb') as f:
                s = f.read()
            if (len(s) != 8192):
                log('  MBR getfile is not exactly 8192 bytes', '')
                return None
            return CRCData(s[dataOffset:(dataOffset + dataLen)])
        else:
            log("  couldn't open getfile", '')
            return None
    if (localFile is None):
        localFile = dsz.ui.GetString('Enter local path to collected boot sector')
    crc = CRCBootSectorFile(localFile)
    if (crc is not None):
        strCrc = ('0x%08X' % crc)
        if ((strCrc == '0x431BF4C2') or (strCrc == '0xF9FC3353') or (strCrc == '0xA3938023') or (strCrc == '0xAFD564B3')):
            log('  known MS/other boot hash', 'MS/other')
        if ((strCrc == '0x7F46CF4B') or (strCrc == '0x4C8E0662')):
            log('  SOTI 1.3.3 or 1.3.4. doublefeature will confirm', 'MBR 1.3.3 or 1.3.4')
        if ((strCrc == '0xB5890255') or (strCrc == '0xF1DA3D1F')):
            log('  SOTI 1.3.2, UPGRADE!', '1.3.2, UPGRADE!')

def parse_program_arguments(arguments):
    parser = ArgumentParser(prog='check_soti', description='performs some checks for SOTI')
    parser.add_argument('-c', '--containers', dest='containers', help='look for SOTI containers', action='store_true')
    parser.add_argument('-g', '--get8k', dest='get8k', help='gets the first 8k bytes from target boot drive', action='store_true')
    parser.add_argument('-l', '--localhash', dest='localhash', help='locally hashes first 8k bytes from target', action='store_true')
    parser.add_argument('-q', '--quiet', dest='quiet', help='one line output, intended for survey', action='store_true')
    options = parser.parse_args()
    if (options.localhash and (options.get8k is not True)):
        if options.containers:
            containers()
        localhash(None)
        printlog(options.quiet)
        return
    if operator.xor(options.containers, options.get8k):
        if options.containers:
            containers()
        if options.get8k:
            get8k()
            if options.localhash:
                log('  not running -l since -g ran', '-g ran -> no -l')
    else:
        containers()
        get8k()
        if options.localhash:
            log('  not running -l since -g ran', '-g ran -> no -l')
    printlog(options.quiet)
if (__name__ == '__main__'):
    parse_program_arguments(sys.argv)