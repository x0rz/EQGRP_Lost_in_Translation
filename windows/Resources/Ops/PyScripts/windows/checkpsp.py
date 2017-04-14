
import dsz.ui
import dsz.version.checks.windows
from ops.psp import CheckProcList, GetPreviousConfig, RunList, CreateList, WriteMetaData, CompareConfigs, printPSPSettings
import ops.survey
from optparse import OptionParser
import util.DSZPyLogger as logging
psplog = logging.getLogger('PSPlog')

def main(vendor=None, force=False):
    try:
        if (not force):
            isDone = (ops.survey.isDone('checkpsp') == ops.survey.DONE)
        else:
            isDone = False
    except TypeError:
        try:
            if (not force):
                isDone = (ops.survey.isDone('checkpsp', None) == ops.survey.DONE)
            else:
                isDone = False
        except:
            isDone = False
    if isDone:
        msg = "checkpsp already ran, skipping. Rerun with 'checkpsp' if you need it."
        ops.info(msg)
        return True
    if (vendor is not None):
        vendor = vendor.lower()
        dsz.ui.Echo('Checking for any PSP products by {0}...'.format(vendor))
        canRun = [vendor]
        shouldCreate = []
    else:
        dsz.ui.Echo("Checking for any running known PSP's...")
        (canRun, shouldCreate) = CheckProcList()
        if ((not ('microsoft' in canRun)) and dsz.version.checks.windows.IsVistaOrGreater()):
            canRun.append('microsoft')
        for inrun in canRun:
            dsz.ui.Echo('  {0}'.format(inrun), dsz.WARNING)
        dsz.ui.Echo('\n')
    dsz.ui.Echo('Checking for target PSP history...\n')
    history = GetPreviousConfig(vendor)
    if (len(history) > 0):
        for psptorun in history:
            dsz.ui.Echo('Found configuration history for {0}.\n'.format(psptorun.vendor), dsz.GOOD)
            if ((len(filter((lambda x: (psptorun.vendor.lower() in x.lower())), shouldCreate)) == 0) and (len(filter((lambda x: (psptorun.vendor.lower() in x.lower())), canRun)) == 0)):
                if dsz.ui.Prompt("  It appears that this PSP isn't running. Do you want to run the script anyway?"):
                    canRun.append(psptorun.vendor.lower())
    else:
        dsz.ui.Echo('No target history found.\n', dsz.WARNING)
    psps = []
    if ((len(canRun) == 0) and (len(shouldCreate) == 0)):
        dsz.ui.Echo("I don't see any known PSP's running.")
    elif (len(canRun) > 0):
        dsz.ui.Echo("Saw PSP's we can act on. Running scripts.")
        psps.extend(RunList(canRun))
    if (len(shouldCreate) > 0):
        psps.extend(CreateList(shouldCreate))
    psps = CompareConfigs(psps, history)
    WriteMetaData(psps)
    ops.survey.complete('checkpsp')
    return True
if (__name__ == '__main__'):
    usage = 'usage: %prog [options]\n\tLooks for PSPs, extracts configuration, and executes actions as needed.'
    parser = OptionParser(usage)
    parser.add_option('--vendor', dest='vendor', default=None, help='Look for this specific vendor on target.')
    parser.add_option('--printConfig', dest='printconf', action='store_true', default=False, help='Print the current PSP configuration data and exit.')
    (options, args) = parser.parse_args()
    vendor = options.vendor
    if options.printconf:
        printPSPSettings(vendor)
        exit((-1))
    elif (not main(vendor, True)):
        exit((-1))