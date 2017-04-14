
import ops.cmd
import ops
import ops.env
import ops.cmd.safetychecks
from ops.cmd import getBoolOption, setBoolOption, getValueOption, setListOption, setStringOption
OpsCommandException = ops.cmd.OpsCommandException
VALID_OPTIONS = ['num', 'id', 'log', 'sid', 'string', 'startrecord', 'xpath', 'max', 'target', 'classic']

class EventlogfilterCommand(ops.cmd.DszCommand, ):
    optgroups = {}
    reqgroups = []
    reqopts = []
    defopts = {}

    def __init__(self, plugin='eventlogfilter', **optdict):
        ops.cmd.DszCommand.__init__(self, plugin, **optdict)

    def validateInput(self):
        for opt in self.optdict:
            if (opt not in VALID_OPTIONS):
                return False
        return True
    num = property((lambda x: getValueOption(x, 'num')), (lambda x, y: setStringOption(x, y, 'num')))
    id = property((lambda x: getValueOption(x, 'id')), (lambda x, y: setStringOption(x, y, 'id')))
    log = property((lambda x: getValueOption(x, 'log')), (lambda x, y: setStringOption(x, y, 'log')))
    sid = property((lambda x: getValueOption(x, 'sid')), (lambda x, y: setStringOption(x, y, 'sid')))
    string = property((lambda x: getValueOption(x, 'string')), (lambda x, y: setStringOption(x, y, 'string')))
    startrecord = property((lambda x: getValueOption(x, 'startrecord')), (lambda x, y: setStringOption(x, y, 'startrecord')))
    xpath = property((lambda x: getValueOption(x, 'xpath')), (lambda x, y: setStringOption(x, y, 'xpath')))
    max = property((lambda x: getValueOption(x, 'max')), (lambda x, y: setStringOption(x, y, 'max')))
    target = property((lambda x: getValueOption(x, 'target')), (lambda x, y: setStringOption(x, y, 'target')))
    classic = property((lambda x: getBoolOption(x, 'classic')), (lambda x, y: setBoolOption(x, y, 'classic')))
ops.cmd.command_classes['eventlogfilter'] = EventlogfilterCommand
ops.cmd.aliasoptions['eventlogfilter'] = VALID_OPTIONS