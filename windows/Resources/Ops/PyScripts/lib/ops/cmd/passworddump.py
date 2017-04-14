
import ops
import ops.cmd
import ops.env
import ops.cmd.safetychecks
VALID_OPTIONS = ['all', 'permanent', 'cached']

class PasswordDumpCommand(ops.cmd.DszCommand, ):

    def __init__(self, plugin='passworddump', **optdict):
        ops.cmd.DszCommand.__init__(self, plugin, **optdict)

    def validateInput(self):
        truecount = 0
        for optkey in self.optdict:
            optval = self.optdict[optkey]
            if (type(optval) is not bool):
                try:
                    optval = bool(optval)
                    self.optdict[optkey] = optval
                except:
                    return False
            if optval:
                truecount += 1
        if (truecount > 1):
            return False
        return True

def mySafetyCheck(self):
    if (self.validateInput() and (ops.env.get('OPS_NOINJECT').upper() != 'TRUE')):
        return (True, '')
    else:
        return (False, 'OPS_NOINJECT is set to TRUE, you should probably not run passworddump')
ops.cmd.command_classes['passworddump'] = PasswordDumpCommand
ops.cmd.aliasoptions['passworddump'] = VALID_OPTIONS
ops.cmd.safetychecks.addSafetyHandler('passworddump', 'ops.cmd.passworddump.mySafetyCheck')