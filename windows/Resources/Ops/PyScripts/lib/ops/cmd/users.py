
import ops.cmd
import ops
import ops.env
import ops.cmd.safetychecks
import ops.security.auditing
from ops.cmd import getBoolOption, setBoolOption, getValueOption, setListOption
OpsCommandException = ops.cmd.OpsCommandException
VALID_OPTIONS = ['group', 'network', 'local', 'target']

class UsersCommand(ops.cmd.DszCommand, ):
    optgroups = {}
    reqgroups = []
    reqopts = []
    defopts = {}

    def __init__(self, plugin='users', netmap_type=None, **optdict):
        ops.cmd.DszCommand.__init__(self, plugin, **optdict)

    def validateInput(self):
        for opt in self.optdict:
            if (opt not in VALID_OPTIONS):
                return False
        return True
    local = property((lambda x: getBoolOption(x, 'local')), (lambda x, y: setBoolOption(x, y, 'local')))
    remote = property((lambda x: getBoolOption(x, 'remote')), (lambda x, y: setBoolOption(x, y, 'remote')))
    target = property((lambda x: getValueOption(x, 'target')), (lambda x, y: setStringOption(x, y, 'target')))
    group = property((lambda x: getValueOption(x, 'group')), (lambda x, y: setStringOption(x, y, 'group')))
ops.cmd.command_classes['users'] = UsersCommand
ops.cmd.aliasoptions['users'] = VALID_OPTIONS