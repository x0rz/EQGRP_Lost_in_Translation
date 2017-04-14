
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('dll_u' not in cmd_definitions):
    dszdllload = OpsClass('dllload', {'loadaddress': OpsField('loadaddress', dsz.TYPE_INT)}, DszObject)
    dszdllunload = OpsClass('dllunload', {'unloaded': OpsField('unloaded', dsz.TYPE_BOOL)}, DszObject)
    dll_ucommand = OpsClass('dll_u', {'dllload': dszdllload, 'dllunload': dszdllunload}, DszCommandObject)
    cmd_definitions['dll_u'] = dll_ucommand