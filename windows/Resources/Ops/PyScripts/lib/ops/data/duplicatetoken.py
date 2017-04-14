
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('duplicatetoken' not in cmd_definitions):
    dszduplicatetokenprocess = OpsClass('process', {'id': OpsField('id', dsz.TYPE_INT), 'name': OpsField('name', dsz.TYPE_STRING), 'user': OpsField('user', dsz.TYPE_STRING)}, DszObject, single=False)
    dszduplicatetokentoken = OpsClass('token', {'alias': OpsField('alias', dsz.TYPE_STRING), 'value': OpsField('value', dsz.TYPE_STRING)}, DszObject)
    duplicatetokencommand = OpsClass('duplicatetoken', {'process': dszduplicatetokenprocess, 'token': dszduplicatetokentoken}, DszCommandObject)
    cmd_definitions['duplicatetoken'] = duplicatetokencommand