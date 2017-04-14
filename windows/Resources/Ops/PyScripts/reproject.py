
import dsz, dsz.ui
import os.path, sys
import ops

def main(args):
    if (len(args) != 1):
        dsz.ui.Echo('Usage: reproject <project>', dsz.ERROR)
        return 0
    f = open(os.path.join(ops.LOGDIR, 'project.txt'), 'w')
    f.write(args[0].upper())
    f.close()
    dsz.ui.Echo(("Target %s's project has been changed to %s" % (ops.TARGET_ADDR, args[0].upper())))
    return 1
if (__name__ == '__main__'):
    if (main(sys.argv[1:]) != True):
        sys.exit((-1))