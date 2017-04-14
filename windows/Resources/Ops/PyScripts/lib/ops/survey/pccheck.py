
import ops.project
import ops.env
import dsz.cmd
from ops.system.registry import get_registrykey
from util.DSZPyLogger import DSZPyLogger
from datetime import timedelta
import dsz.script
PCFIX_VAR = 'OPS_PCFIX'

def main():
    if (ops.env.get(PCFIX_VAR) is not None):
        return
    pcid = ops.env.get('_PC_ID')
    reg_cmd = ops
    winsock = ''
    helper = ''
    try:
        winsock = get_registrykey('L', 'system\\currentcontrolset\\Services\\tcpip\\Parameters\\Winsock', cache_tag='OPS_PERSIST_WINSOCKHELPER', maxage=timedelta(seconds=18000))
        helper = winsock.key[0]['HelperDllName']
    except:
        return
    if (helper.value.find('wship.dll') > 0):
        if (ops.env.get(PCFIX_VAR) is None):
            ops.env.set(PCFIX_VAR, 0)
            prob_cmd = ops.cmd.getDszCommand('problem PCFIX 0')
            prob_cmd.execute()
            dsz.cmd.Run(('warn "WinsockHelper PC on %s. Log the state before Q&D" -warning ' % dsz.script.Env['target_address']))
            return
    elif ((pcid is not None) and (int(pcid, 16) != 0)):
        ops.info('Logging non-WinsockHelper PC')
        ops.env.set(PCFIX_VAR, 1)
        try:
            prob_cmd = ops.cmd.getDszCommand('problem PCFIX 1')
            prob_cmd.execute()
        except:
            return
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()