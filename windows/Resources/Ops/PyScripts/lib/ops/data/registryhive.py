
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('registryhive' not in cmd_definitions):
    dszhiveitem = OpsClass('hive', {'hive': OpsField('hive', dsz.TYPE_STRING), 'permanent': OpsField('permanent', dsz.TYPE_STRING), 'srcfile': OpsField('srcfile', dsz.TYPE_STRING), 'key': OpsField('key', dsz.TYPE_STRING)}, DszObject)
    reghivecommand = OpsClass('registryhive', {'hive': dszhiveitem}, DszCommandObject)
    cmd_definitions['registryhive'] = reghivecommand