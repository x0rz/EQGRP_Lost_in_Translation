
import ops.cmd
import dsz
import ops.survey
import sys
import os.path
import dsz.lp

def main():
    ops.survey.print_header('Driver list')
    dsz.cmd.Run(('python %s -project Ops -args "%s"' % (os.path.join(dsz.lp.GetResourcesDirectory(), 'Ops', 'PyScripts', 'driverlist.py'), ' '.join(sys.argv[1:]))))
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()