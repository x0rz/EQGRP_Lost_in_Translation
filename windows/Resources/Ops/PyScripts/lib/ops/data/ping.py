
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('ping' not in cmd_definitions):
    dszping = OpsClass('response', {'elapsed': OpsField('elapsed', dsz.TYPE_INT), 'length': OpsField('length', dsz.TYPE_INT), 'ttl': OpsField('ttl', dsz.TYPE_INT), 'type': OpsField('type', dsz.TYPE_STRING), 'data': OpsClass('data', {'data': OpsField('data', dsz.TYPE_STRING)}, DszObject), 'fromaddr': OpsClass('fromaddr', {'addr': OpsField('addr', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING)}, DszObject)}, DszObject, single=False)
    pingcommand = OpsClass('ping', {'response': dszping}, DszCommandObject)
    cmd_definitions['ping'] = pingcommand