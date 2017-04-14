
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('strings' not in cmd_definitions):
    dszstrings = OpsClass('strings', {'string': OpsClass('string', {'offset': OpsField('offset', dsz.TYPE_INT), 'string': OpsField('string', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject, single=True)
    stringscommand = OpsClass('strings', {'strings': dszstrings}, DszCommandObject)
    cmd_definitions['strings'] = stringscommand