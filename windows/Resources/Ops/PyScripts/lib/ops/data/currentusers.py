
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('currentusers' not in cmd_definitions):
    dszuser = OpsClass('user', {'sessionid': OpsField('sessionid', dsz.TYPE_INT), 'loginpid': OpsField('loginpid', dsz.TYPE_INT), 'host': OpsField('host', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING), 'device': OpsField('device', dsz.TYPE_STRING), 'logintime': OpsField('logintime', dsz.TYPE_STRING), 'logindate': OpsField('logindate', dsz.TYPE_STRING)}, DszObject, single=False)
    currentuserscommand = OpsClass('currentusers', {'user': dszuser}, DszCommandObject)
    cmd_definitions['currentusers'] = currentuserscommand