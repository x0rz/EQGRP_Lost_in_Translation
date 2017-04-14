
import ops.cmd
import ops
import ops.env
import ops.cmd.safetychecks
OpsCommandException = ops.cmd.OpsCommandException

def mySafetyCheck(self):
    good = True
    msgparts = []
    if (ops.env.get('OPS_NOMEMORY').upper() == 'TRUE'):
        good = False
        msgparts.append('OPS_NOMEMORY is set to TRUE, you should probably not run this')
    if (not self.validateInput()):
        good = False
        msgparts.append('Your command did not pass input validation')
    msg = '\n\t'.join(msgparts)
    return (good, msg)
ops.cmd.safetychecks.addSafetyHandler('memory', 'ops.cmd.memory.mySafetyCheck')