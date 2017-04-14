
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('eventlogclear' not in cmd_definitions):
    dszeventlogclear = OpsClass('taskinginfo', {'recursive': OpsField('recursive', dsz.TYPE_BOOL), 'searchpath': OpsClass('searchpath', {'value': OpsField('value', dsz.TYPE_STRING)}, DszObject), 'target': OpsClass('target', {'location': OpsField('location', dsz.TYPE_STRING), 'local': OpsField('local', dsz.TYPE_BOOL)}, DszObject)}, DszObject)
    eventlogclearcommand = OpsClass('eventlogclear', {'taskinginfo': dszeventlogclear}, DszCommandObject)
    cmd_definitions['eventlogclear'] = eventlogclearcommand