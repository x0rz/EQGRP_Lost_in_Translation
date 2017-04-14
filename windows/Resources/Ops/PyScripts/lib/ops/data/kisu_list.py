
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('kisu_list' not in cmd_definitions):
    kisu_list_data = OpsClass('enumeration', {'item': OpsClass('item', {'id': OpsField('id', dsz.TYPE_INT), 'versionminor': OpsField('versionminor', dsz.TYPE_INT), 'versionmajor': OpsField('versionmajor', dsz.TYPE_INT), 'versionfix': OpsField('versionfix', dsz.TYPE_INT), 'versionbuild': OpsField('versionbuild', dsz.TYPE_INT), 'name': OpsField('name', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject)
    kisu_list_command = OpsClass('enumeration', {'enumeration': kisu_list_data}, DszCommandObject)
    cmd_definitions['kisu_list'] = kisu_list_command