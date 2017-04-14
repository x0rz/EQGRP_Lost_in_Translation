
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('kisu_readmodule' not in cmd_definitions):
    kisu_module = OpsClass('readmodule', {'id': OpsField('id', dsz.TYPE_INT), 'instance': OpsField('instance', dsz.TYPE_INT), 'size': OpsField('size', dsz.TYPE_INT), 'module': OpsField('module', dsz.TYPE_STRING)}, DszObject)
    kisu_readmodule_command = OpsClass('module', {'module': kisu_module}, DszCommandObject)
    cmd_definitions['kisu_readmodule'] = kisu_readmodule_command