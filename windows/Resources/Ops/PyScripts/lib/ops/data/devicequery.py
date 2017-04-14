
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('devicequery' not in cmd_definitions):
    dszdevicequery = OpsClass('deviceitem', {'servicepath': OpsField('servicepath', dsz.TYPE_STRING), 'physdevobjname': OpsField('physdevobjname', dsz.TYPE_STRING), 'friendlyname': OpsField('friendlyname', dsz.TYPE_STRING), 'devicedesc': OpsField('devicedesc', dsz.TYPE_STRING), 'locationinfo': OpsField('locationinfo', dsz.TYPE_STRING), 'driver': OpsField('driver', dsz.TYPE_STRING), 'mfg': OpsField('mfg', dsz.TYPE_STRING), 'hardwareid': OpsField('hardwareid', dsz.TYPE_STRING)}, DszObject, single=False)
    devicequerycommand = OpsClass('devicequery', {'deviceitem': dszdevicequery}, DszCommandObject)
    cmd_definitions['devicequery'] = devicequerycommand