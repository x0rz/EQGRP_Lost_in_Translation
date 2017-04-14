
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('authentication' not in cmd_definitions):
    dszauthentication = OpsClass('authentication', {'username': OpsField('username', dsz.TYPE_STRING), 'password': OpsField('password', dsz.TYPE_STRING)}, DszObject)
    authenticationcommand = OpsClass('authentication', {'authentication': dszauthentication}, DszCommandObject)
    cmd_definitions['authentication'] = authenticationcommand