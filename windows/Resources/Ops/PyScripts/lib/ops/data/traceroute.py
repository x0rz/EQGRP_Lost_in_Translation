
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('traceroute' not in cmd_definitions):
    dszhopinfo = OpsClass('hopinfo', {'hop': OpsField('hop', dsz.TYPE_INT), 'time': OpsField('time', dsz.TYPE_INT), 'host': OpsField('host', dsz.TYPE_STRING)}, DszObject, single=False)
    traceroutecommand = OpsClass('traceroute', {'hopinfo': dszhopinfo}, DszCommandObject)
    cmd_definitions['traceroute'] = traceroutecommand