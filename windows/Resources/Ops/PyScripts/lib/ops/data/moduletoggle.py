
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('eventlogquery' not in cmd_definitions):
    moduletoggledsz = OpsClass('moduletoggle', {'system': OpsClass('system', {'selected': OpsField('selected', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject, single=True)
    moduletogglecommand = OpsClass('moduletoggle', {'moduletoggle': moduletoggledsz}, DszCommandObject)
    cmd_definitions['moduletoggle'] = moduletogglecommand