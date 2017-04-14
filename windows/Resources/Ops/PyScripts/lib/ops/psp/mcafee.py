
import dsz.ui, dsz.cmd, dsz.menu, dsz.lp, dsz.version
import sys
import ops.cmd, ops.data
from ops.pprint import pprint
import optparse
from mcafeeLib import *
import mcafee85To88
import util.ip
from util.DSZPyLogger import getLogger
mcafeelog = getLogger('mcafee')

def __main__():
    parser = optparse.OptionParser()
    parser.disable_interspersed_args()
    parser.add_option('-s', '--survey', action='store_true', help='Perform a survey of the system')
    parser.add_option('-t', '--target', help='Target for the command (defaults to local box)', dest='target', type='string')
    (options, args) = parser.parse_args()
    if (options.survey != None):
        if ((options.target != None) and (not _isIP(options.target))):
            dsz.ui.Echo('Invalid IP', dsz.ERROR)
            return
        _survey(target=options.target)
    else:
        parser.print_help()

def _survey(pspobj=None, target=None):
    dsz.ui.Echo('Pulling HKLM\\Software\\Network Associates key...')
    if (target == None):
        if dsz.version.checks.windows.IsXpOrGreater():
            q = ops.cmd.DszCommand('registryquery', hive='L', key='"software\\network associates"', recursive=True, dszquiet=True, wow32=True)
        else:
            q = ops.cmd.DszCommand('registryquery', hive='L', key='"software\\network associates"', recursive=True, dszquiet=True)
    else:
        q = ops.cmd.DszCommand('registryquery', hive='L', key='"software\\network associates"', recursive=True, dszquiet=True, target=target, wow32=True)
    netassoc = q.execute()
    dsz.ui.Echo('Pulling HKLM\\Software\\McAfee key...')
    if (target == None):
        if dsz.version.checks.windows.IsXpOrGreater():
            q = ops.cmd.DszCommand('registryquery', hive='L', key='"software\\mcafee"', recursive=True, dszquiet=True, wow32=True)
        else:
            q = ops.cmd.DszCommand('registryquery', hive='L', key='"software\\mcafee"', recursive=True, dszquiet=True)
    else:
        q = ops.cmd.DszCommand('registryquery', hive='L', key='"software\\mcafee"', recursive=True, dszquiet=True, target=target, wow32=True)
    mcafee = q.execute()
    dsz.ui.Echo('Parsing registry information for installed products\n')
    products = checkInstalled(mcafee, netassoc)
    if (products == False):
        return
    pprint(products)
    dsz.ui.Echo('Parsing settings\n')
    checkInstalledSettings(mcafee, products)
    return

def _isIP(str):
    return util.ip.validate(str)
if (__name__ == '__main__'):
    try:
        __main__()
    except:
        mcafeelog.error('Mcafee.py: Caught and Logged Exception %s', sys.exc_info()[0], exc_info=1)