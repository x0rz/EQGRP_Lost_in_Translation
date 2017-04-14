
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('kisu_loadmodule' not in cmd_definitions):
    kisu_loadmod_data = OpsClass('loadmodule', {'handle': OpsField('handle', dsz.TYPE_INT), 'id': OpsField('id', dsz.TYPE_INT), 'instance': OpsField('instance', dsz.TYPE_INT)}, DszObject)
    kisu_loadmod_command = OpsClass('loadmodule', {'loadmodule': kisu_loadmod_data}, DszCommandObject)
    cmd_definitions['kisu_loadmodule'] = kisu_loadmod_command