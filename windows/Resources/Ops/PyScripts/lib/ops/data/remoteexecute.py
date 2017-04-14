
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('remoteexecute' not in cmd_definitions):
    dszremoteexecute = OpsClass('remoteexecution', {'processid': OpsField('processid', dsz.TYPE_INT), 'returnvalue': OpsField('returnvalue', dsz.TYPE_INT)}, DszObject, single=True)
    dszretarget = OpsClass('target', {'local': OpsField('local', dsz.TYPE_BOOL), 'location': OpsField('location', dsz.TYPE_STRING)}, DszObject, single=True)
    remoteexecutecommand = OpsClass('remoteexecute', {'remoteexecution': dszremoteexecute, 'target': dszretarget}, DszCommandObject)
    cmd_definitions['remoteexecute'] = remoteexecutecommand