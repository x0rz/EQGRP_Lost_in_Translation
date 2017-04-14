
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('environment' not in cmd_definitions):
    dszenvironment = OpsClass('environment', {'action': OpsField('action', dsz.TYPE_STRING), 'value': OpsClass('value', {'name': OpsField('name', dsz.TYPE_STRING), 'value': OpsField('value', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject)
    environmentcommand = OpsClass('environment', {'environment': dszenvironment}, DszCommandObject)
    cmd_definitions['environment'] = environmentcommand