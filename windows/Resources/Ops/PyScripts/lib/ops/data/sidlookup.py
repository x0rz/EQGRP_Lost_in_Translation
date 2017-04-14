
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('sidlookup' not in cmd_definitions):
    dszsidlookup = OpsClass('sid', {'name': OpsField('name', dsz.TYPE_STRING), 'id': OpsField('id', dsz.TYPE_STRING)}, DszObject, single=True)
    sidlookupcommand = OpsClass('sidlookup', {'sid': dszsidlookup}, DszCommandObject)
    cmd_definitions['sidlookup'] = sidlookupcommand