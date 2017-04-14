
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('throttle' not in cmd_definitions):
    dszthrottle = OpsClass('throttleitem', {'enabled': OpsField('enabled', dsz.TYPE_BOOL), 'bytespersecond': OpsField('bytespersecond', dsz.TYPE_INT), 'address': OpsField('address', dsz.TYPE_STRING)}, DszObject, single=False)
    throttlecommand = OpsClass('throttle', {'throttleitem': dszthrottle}, DszCommandObject)
    cmd_definitions['throttle'] = throttlecommand