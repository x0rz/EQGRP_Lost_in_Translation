
import ops.cmd
import ops
import ops.env
import ops.cmd.safetychecks
from ops.cmd import getBoolOption, setBoolOption, getValueOption, setListOption
OpsCommandException = ops.cmd.OpsCommandException
VALID_OPTIONS = ['minimal', 'type']

class NetmapCommand(ops.cmd.DszCommand, ):
    optgroups = {}
    reqgroups = []
    reqopts = []
    defopts = {}

    def __init__(self, plugin='netmap', netmap_type=None, **optdict):
        ops.cmd.DszCommand.__init__(self, plugin, **optdict)
        self.netmap_type = netmap_type

    def validateInput(self):
        for opt in self.optdict:
            if (opt not in VALID_OPTIONS):
                return False
        return True
    minimal = property((lambda x: getBoolOption(x, 'minimal')), (lambda x, y: setBoolOption(x, y, 'minimal')))
    netmap_type = property((lambda x: getValueOption(x, 'type')), (lambda x, y: setListOption(x, y, 'type', ['all', 'connected', 'remembered'])))

def mySafetyCheck(self):
    good = True
    msgparts = []
    if (ops.env.get('OPS_NONETMAP').upper() == 'TRUE'):
        good = False
        msgparts.append('OPS_NONETMAP is set to TRUE, you should probably not run a netmap')
    if (not self.validateInput()):
        good = False
        msgparts.append('Your command did not pass input validation')
    msg = ''
    if (len(msgparts) > 0):
        msg = msgparts[0]
        for msgpart in msgparts[1:]:
            msg += ('\n\t' + msgpart)
    return (good, msg)
ops.cmd.command_classes['netmap'] = NetmapCommand
ops.cmd.aliasoptions['netmap'] = VALID_OPTIONS
ops.cmd.safetychecks.addSafetyHandler('netmap', 'ops.cmd.netmap.mySafetyCheck')