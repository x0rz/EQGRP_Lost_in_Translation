
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('netmap' not in cmd_definitions):
    dsznetmap = OpsClass('netmapentryitem', {'level': OpsField('level', dsz.TYPE_INT), 'localname': OpsField('localname', dsz.TYPE_STRING), 'remotename': OpsField('remotename', dsz.TYPE_STRING), 'parentname': OpsField('parentname', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING), 'provider': OpsField('provider', dsz.TYPE_STRING), 'comment': OpsField('comment', dsz.TYPE_STRING), 'ip': OpsField('ip', dsz.TYPE_STRING, single=False), 'time': OpsField('time', dsz.TYPE_STRING), 'timezoneoffset': OpsField('timezoneoffset', dsz.TYPE_STRING), 'osplatform': OpsField('osplatform', dsz.TYPE_STRING), 'osversionmajor': OpsField('osversionmajor', dsz.TYPE_INT), 'osversionminor': OpsField('osversionminor', dsz.TYPE_INT), 'software': OpsClass('software', {'name': OpsField('name', dsz.TYPE_STRING), 'description': OpsField('description', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject, single=False)
    netmapquerycommand = OpsClass('netmap', {'netmapentryitem': dsznetmap}, DszCommandObject)
    cmd_definitions['netmap'] = netmapquerycommand