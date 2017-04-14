
import dsz
import sys
import optparse

def parseCmdInput():
    parser = optparse.OptionParser()
    parser.add_option('-p', '--path', dest='path', action='store', type='string', help='Path to dir/delete in')
    parser.add_option('-m', '--mask', dest='mask', action='store', type='string', help='Mask you want to dir/delete for')
    (options, args) = parser.parse_args(sys.argv)
    if (options.path is None):
        print 'You must specify a path'
        parser.print_help()
        exit(0)
    if (options.mask is None):
        print 'You must specify a mask'
        parser.print_help()
        exit(0)
    global MASK
    MASK = options.mask
    global PATH
    PATH = options.path

def main():
    cmd = ('dir -mask "%s" -path "%s" -max 0' % (MASK, PATH))
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    file_list = dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)
    input = raw_input('Do you wish to continue? [WILL GET THEN DELETE ALL LISTED FILES] (Y/N)')
    if (input.lower() == 'n'):
        return 0
    for file in file_list:
        cmd = ('get -mask "%s" -path "%s"' % (file, PATH))
        dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
        try:
            success = dsz.cmd.data.Get('Conclusion::NumSuccess', dsz.TYPE_INT)[0]
        except:
            print 'Unable to get file get status information'
            return 0
        if (success <= 0):
            print 'Get failed'
            input = raw_input('Do you wish to continue? (Y/N)')
            if (input.lower() == 'n'):
                return 0
            else:
                continue
        cmd = ('delete -file "%s\\%s"' % (PATH, file))
        dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
        status = ''
        try:
            success = dsz.cmd.data.Get('deletionitem::StatusValue', dsz.TYPE_INT)[0]
            status = dsz.cmd.data.Get('deletionitem::StatusString', dsz.TYPE_STRING)[0]
        except:
            print 'Unable to get deletion status information'
            return 0
        if (not (success == 0)):
            print ('Deletion failed: %s, %s' % (success, status))
            input = raw_input('Do you wish to continue? (Y/N)')
            if (input.lower() == 'n'):
                return 0
            else:
                continue
    cmd = ('dir -mask "%s" -path "%s" -max 0' % (MASK, PATH))
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
if (__name__ == '__main__'):
    parseCmdInput()
    main()