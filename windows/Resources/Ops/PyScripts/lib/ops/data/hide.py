
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('hide' not in cmd_definitions):
    dszhideobj = OpsClass('hideobject', {'value': OpsField('value', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING), 'data': OpsField('data', dsz.TYPE_STRING)}, DszObject)
    hidecommand = OpsClass('hide', {'hideobject': dszhideobj, 'unhideobject': dszhideobj}, DszCommandObject)
    cmd_definitions['hide'] = hidecommand