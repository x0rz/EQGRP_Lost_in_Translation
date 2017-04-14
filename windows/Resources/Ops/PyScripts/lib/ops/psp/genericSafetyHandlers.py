
import ops
import dsz.ui

def requiresPSPAvoidance(cmd):
    psp_avoid_on = (ops.env.get('_PSP_AVOIDANCE_ENABLE') == 'true')
    if (not psp_avoid_on):
        dsz.ui.Echo("Because of PSP concerns, the command '{0}' requires that psp_avoidance be enabled.".format(cmd.plugin), dsz.WARNING)
        enable = dsz.ui.Prompt('Would you like to enable PSP Avoidance?', True)
        if enable:
            psp_avoid_on = dsz.cmd.Run('psp_avoidance -enable')
        else:
            psp_avoid_on = False
    return (psp_avoid_on, 'PSP Avoidance must be on to run this command!')

def notRecommended(cmd):
    return (False, 'Because of PSP concerns, this command is not recommended.')