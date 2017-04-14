
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('pwd' not in cmd_definitions):
    dszpwd = OpsClass('currentdirectory', {'virtual': OpsField('virtual', dsz.TYPE_BOOL), 'path': OpsField('path', dsz.TYPE_STRING)}, DszObject, single=True)
    pwdcommand = OpsClass('pwd', {'currentdirectory': dszpwd}, DszCommandObject)
    cmd_definitions['pwd'] = pwdcommand