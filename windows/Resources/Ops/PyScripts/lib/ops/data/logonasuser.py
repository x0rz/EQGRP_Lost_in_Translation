
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('logonasuser' not in cmd_definitions):
    dszlogonasuser = OpsClass('logon', {'handle': OpsField('handle', dsz.TYPE_INT), 'alias': OpsField('alias', dsz.TYPE_STRING)}, DszObject)
    logonasusercommand = OpsClass('logonasuser', {'logon': dszlogonasuser}, DszCommandObject)
    cmd_definitions['logonasuser'] = logonasusercommand