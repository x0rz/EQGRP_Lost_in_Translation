
import ops.cmd
import ops
import ops.env
import ops.cmd.safetychecks
from ops.cmd import getBoolOption, setBoolOption, getValueOption, setListOption, setStringOption
OpsCommandException = ops.cmd.OpsCommandException
VALID_OPTIONS = ['minimal', 'load', 'unload', 'list', 'minimal', 'nosignature', 'noversion']

class DriversCommand(ops.cmd.DszCommand, ):
    optgroups = {'operation': ['load', 'unload', 'list']}
    reqgroups = ['operation']
    rejects = {'load': ['minimal', 'nosignature', 'version'], 'unload': ['minimal', 'nosignature', 'version']}
    reqopts = []
    defopts = {}

    def __init__(self, plugin='drivers', autominimal=False, **optdict):
        self.autominimal = autominimal
        ops.cmd.DszCommand.__init__(self, plugin, **optdict)

    def validateInput(self):
        for opt in self.optdict:
            if (opt not in VALID_OPTIONS):
                return False
        if ((not self.driver_list) and (self.load is None) and (self.unload is None)):
            return False
        if (((self.load is not None) or (self.unload is not None)) and (self.minimal or self.nosignature or self.noversion)):
            return False
        return True

    def __getAutoMinimal(self):
        return self.__autoMinimal

    def __setAutoMinimal(self, val):
        self.__autoMinimal = val
    autominimal = property(__getAutoMinimal, __setAutoMinimal)
    minimal = property((lambda x: getBoolOption(x, 'minimal')), (lambda x, y: setBoolOption(x, y, 'minimal')))
    nosignature = property((lambda x: getBoolOption(x, 'nosignature')), (lambda x, y: setBoolOption(x, y, 'nosignature')))
    noversion = property((lambda x: getBoolOption(x, 'noversion')), (lambda x, y: setBoolOption(x, y, 'noversion')))
    driver_list = property((lambda x: getBoolOption(x, 'list')), (lambda x, y: setBoolOption(x, y, 'list')))
    load = property((lambda x: getValueOption(x, 'load')), (lambda x, y: setStringOption(x, y, 'load')))
    unload = property((lambda x: getValueOption(x, 'unload')), (lambda x, y: setStringOption(x, y, 'unload')))
ops.cmd.command_classes['drivers'] = DriversCommand
ops.cmd.aliasoptions['drivers'] = VALID_OPTIONS

def mySafetyCheck(self):
    good = True
    msgparts = []
    if ((ops.env.get('OPS_NODRIVER').upper() == 'TRUE') and ((self.load is not None) or (self.unload is not None))):
        good = False
        msgparts.append('OPS_NODRIVER is set to TRUE, you should probably not load or unload drivers')
    if ((ops.env.get('OPS_DRIVERLIST_MINIMAL').upper() == 'TRUE') and (not self.minimal) and self.driver_list):
        if self.autominimal:
            self.minimal = True
        else:
            good = False
            msgparts.append('OPS_DRIVERLIST_MINIMAL is set to TRUE, you should not run a drivers -list without -minimal')
    if ((ops.env.get('OPS_NODRIVERLIST').upper() == 'TRUE') and self.driver_list):
        good = False
        msgparts.append('OPS_NODRIVERLIST is set to true, you probably should not run a drivers -list')
    if (not self.validateInput()):
        good = False
        msgparts.append('Your command did not pass input validation')
    msg = ''
    if (len(msgparts) > 0):
        msg = msgparts[0]
        for msgpart in msgparts[1:]:
            msg += ('\n\t' + msgpart)
    return (good, msg)
ops.cmd.safetychecks.addSafetyHandler('drivers', 'ops.cmd.drivers.mySafetyCheck')