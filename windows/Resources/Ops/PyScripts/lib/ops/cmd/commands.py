
import ops.cmd
from ops.cmd import getBoolOption, setBoolOption
OpsCommandException = ops.cmd.OpsCommandException

def getRunningCommands():
    return ops.cmd.quickrun('commands')
VALID_OPTIONS = ['all', 'any', 'local', 'remote', 'astyped', 'verbose']

class CommandsCommand(ops.cmd.DszCommand, ):

    def __init__(self, plugin='commands', **optdict):
        ops.cmd.DszCommand.__init__(self, plugin, **optdict)

    def validateInput(self):
        for opt in self.optdict:
            if (opt not in VALID_OPTIONS):
                return False
        return True
    all = property((lambda x: getBoolOption(x, 'all')), (lambda x, y: setBoolOption(x, y, 'all')))
    any = property((lambda x: getBoolOption(x, 'any')), (lambda x, y: setBoolOption(x, y, 'any')))
    local = property((lambda x: getBoolOption(x, 'local')), (lambda x, y: setBoolOption(x, y, 'local')))
    remote = property((lambda x: getBoolOption(x, 'remote')), (lambda x, y: setBoolOption(x, y, 'remote')))
    astyped = property((lambda x: getBoolOption(x, 'astyped')), (lambda x, y: setBoolOption(x, y, 'astyped')))
    verbose = property((lambda x: getBoolOption(x, 'verbose')), (lambda x, y: setBoolOption(x, y, 'verbose')))
ops.cmd.command_classes['commands'] = CommandsCommand
ops.cmd.aliasoptions['commands'] = VALID_OPTIONS