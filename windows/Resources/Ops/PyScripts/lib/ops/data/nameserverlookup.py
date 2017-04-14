
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('nameserverlookup' not in cmd_definitions):
    dsznameserverlookupitem = OpsClass('hostinfo', {'info': OpsField('info', dsz.TYPE_STRING)}, DszObject, single=False)
    nameserverlookupcommand = OpsClass('nameserverlookup', {'hostinfo': dsznameserverlookupitem}, DszCommandObject)
    cmd_definitions['nameserverlookup'] = nameserverlookupcommand