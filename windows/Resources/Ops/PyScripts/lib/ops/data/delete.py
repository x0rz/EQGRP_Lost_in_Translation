
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('delete' not in cmd_definitions):
    dszdelete = OpsClass('deletionitem', {'file': OpsField('file', dsz.TYPE_STRING), 'delay': OpsField('delay', dsz.TYPE_BOOL), 'statusvalue': OpsField('statusvalue', dsz.TYPE_INT), 'statusstring': OpsField('statusstring', dsz.TYPE_STRING)}, DszObject, single=False)
    deletecommand = OpsClass('delete', {'deletionitem': dszdelete}, DszCommandObject)
    cmd_definitions['delete'] = deletecommand