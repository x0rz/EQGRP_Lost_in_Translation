
import xml.etree
import os.path
import ops
from util.DSZPyLogger import getLogger, WARNING
from ops.psp.actions import PSPManager, RegQueryAction, DirListAction, DoNotAction, ScriptAction, SafetyCheckAction
from ops.ActionFramework import XMLConditionalActionDataSource, ActionManager, XMLAttributeActionDataSource
import dsz.ui
psplog = getLogger('genericPSP')
psplog.setFileLogLevel(WARNING)
xmltoattributemap = {'regkey': RegQueryAction, 'directory': DirListAction}
xmltoactionmap = {'donot': DoNotAction, 'script': ScriptAction, 'safetycheck': SafetyCheckAction}

def findConfig(vendor):
    return os.path.join(ops.DATA, 'pspFPs', '{0}-fp.xml'.format(vendor))

def findActions(vendor):
    return os.path.join(ops.DATA, 'pspFPs', '{0}-actions.xml'.format(vendor))

def main(vendor):
    psps = []
    fpfile = findConfig(vendor)
    if (not os.path.exists(fpfile)):
        return None
    with open(fpfile, 'r') as fd:
        xmldata = xml.etree.ElementTree.parse(fd).getroot()
    atpkgs = XMLAttributeActionDataSource(xmldata, xmltoattributemap).GetRootActions()
    pspmgr = PSPManager()
    for atpkg in atpkgs:
        pspmgr.addVendor(atpkg)
    if pspmgr.valid:
        pspmgr.Execute()
        psps = pspmgr.GetAllPSPs()
        for psp in psps:
            if (psp.vendor is None):
                psp.vendor = vendor
    else:
        psplog.critical("This vendor's config file is not valid: {0}".format(vendor))
        return None
    psplog.debug('I found {0} PSPs for Vendor {1}'.format(len(psps), vendor))
    psplog.debug('PSP objects: {0}'.format(psps))
    actfile = findActions(vendor)
    if os.path.exists(actfile):
        with open(actfile, 'r') as fd:
            xmldata = xml.etree.ElementTree.parse(fd).getroot()
        actmgr = ActionManager(XMLConditionalActionDataSource(xmldata, xmltoactionmap, psps).GetRootActions())
        fails = actmgr.Validate()
        if (len(fails) == 0):
            psplog.info('Executing actions for: {0}'.format(vendor))
            psplog.debug('actmgr: {0}'.format(actmgr))
            actmgr.Execute()
        else:
            psplog.critical("This vendor's action file is not valid: {0}\n{1}".format(vendor, fails))
            return None
    if (len(psps) == 0):
        dsz.ui.Echo('I found 0 Products for {0}'.format(vendor), dsz.GOOD)
        return None
    return psps