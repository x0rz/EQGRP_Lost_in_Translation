
import ops
import ops.cmd
import ops.env
import ops.cmd.safetychecks
OpsCommandException = ops.cmd.OpsCommandException
VALID_OPTIONS = ['status', 'on', 'off', 'disable', 'force']

class AuditCommand(ops.cmd.DszCommand, ):
    optgroups = {'main': ['status', 'on', 'off', 'disable']}
    reqgroups = ['main']
    reqopts = []
    defopts = {}

    def __init__(self, plugin='audit', **optdict):
        ops.cmd.DszCommand.__init__(self, plugin, **optdict)

    def validateInput(self):
        for opt in self.optdict:
            if (opt not in VALID_OPTIONS):
                return False
        optcounts = {}
        for req in self.reqgroups:
            optcounts[req] = 0
            for opt in self.optgroups[req]:
                if (opt in self.optdict):
                    optcounts[req] += 1
        if (optcounts['main'] != 1):
            return False
        return True

    def __getDisable(self):
        if ('disable' in self.optdict):
            return self.optdict['disable']
        else:
            return None

    def __setDisable(self, val):
        if ((val is None) and ('disable' in self.optdict)):
            del self.optdict['disable']
        elif (val in ['all', 'security']):
            self.optdict['disable'] = val
        else:
            raise OpsCommandException(('Invalid value for -disable: %s' % val))
    disable = property(__getDisable, __setDisable)

    def __getForce(self):
        return (('force' in self.optdict) and self.optdict['force'])

    def __setForce(self, val):
        if (((val is None) or (val is False)) and ('force' in self.optdict)):
            del self.optdict['force']
        elif val:
            self.optdict['force'] = True
    force = property(__getForce, __setForce)

    def __getStatus(self):
        return (('status' in self.optdict) and self.optdict['status'])

    def __setStatus(self, val):
        if (((val is None) or (val is False)) and ('status' in self.optdict)):
            del self.optdict['status']
        elif val:
            self.optdict['status'] = True
    audit_status = property(__getStatus, __setStatus)

    def __getOn(self):
        return (('on' in self.optdict) and self.optdict['on'])

    def __setOn(self, val):
        if (((val is None) or (val is False)) and ('on' in self.optdict)):
            del self.optdict['on']
        elif val:
            self.optdict['on'] = True
            self.optdict['off'] = False
    audit_on = property(__getOn, __setOn)

    def __getOff(self):
        return (('off' in self.optdict) and self.optdict['off'])

    def __setOff(self, val):
        if (((val is None) or (val is False)) and ('off' in self.optdict)):
            del self.optdict['off']
        elif val:
            self.optdict['off'] = True
            self.optdict['on'] = False
    audit_off = property(__getOff, __setOff)

def mySafetyCheck(self):
    good = True
    msgparts = []
    if ((ops.env.get('OPS_NOINJECT').upper() == 'TRUE') and (self.disable is not None)):
        good = False
        msgparts.append('OPS_NOINJECT is set to TRUE, you should probably not disable auditing')
    if (self.force or self.audit_off or self.audit_on):
        good = False
        msgparts.append('Altering audit policy in a script is not safe, verify you really want to do that')
    msg = ''
    if (len(msgparts) > 0):
        msg = msgparts[0]
        for msgpart in msgparts[1:]:
            msg += ('\n\t' + msgpart)
    return (good, msg)
ops.cmd.command_classes['audit'] = AuditCommand
ops.cmd.aliasoptions['audit'] = VALID_OPTIONS
ops.cmd.safetychecks.addSafetyHandler('audit', 'ops.cmd.audit.mySafetyCheck')