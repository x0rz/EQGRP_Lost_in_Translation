
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('whoami' not in cmd_definitions):
    dszwhoami = OpsClass('user', {'name': OpsField('name', dsz.TYPE_STRING)}, DszObject)
    whoamicommand = OpsClass('whoami', {'user': dszwhoami}, DszCommandObject)
    cmd_definitions['whoami'] = whoamicommand