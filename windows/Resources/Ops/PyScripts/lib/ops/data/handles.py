
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('handles' not in cmd_definitions):
    dszhandles = OpsClass('process', {'id': OpsField('id', dsz.TYPE_INT), 'handle': OpsClass('handle', {'id': OpsField('id', dsz.TYPE_INT), 'type': OpsField('type', dsz.TYPE_STRING), 'metadata': OpsField('metadata', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject, single=False)
    handlescommand = OpsClass('handles', {'process': dszhandles}, DszCommandObject)
    cmd_definitions['handles'] = handlescommand