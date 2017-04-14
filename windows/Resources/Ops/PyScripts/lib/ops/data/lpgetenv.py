
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('lpgetenv' not in cmd_definitions):
    dszenvitem = OpsClass('envitem', {'system': OpsField('system', dsz.TYPE_BOOL), 'option': OpsField('option', dsz.TYPE_STRING), 'value': OpsField('value', dsz.TYPE_STRING)}, DszObject, single=False)
    lpgetenvcommand = OpsClass('lpgetenv', {'envitem': dszenvitem}, DszCommandObject)
    cmd_definitions['lpgetenv'] = lpgetenvcommand