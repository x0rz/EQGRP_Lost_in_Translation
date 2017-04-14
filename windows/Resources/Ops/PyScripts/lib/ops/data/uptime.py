
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('uptime' not in cmd_definitions):
    dszuptime = OpsClass('uptime', {'days': OpsField('days', dsz.TYPE_INT), 'hours': OpsField('hours', dsz.TYPE_INT), 'minutes': OpsField('minutes', dsz.TYPE_INT), 'seconds': OpsField('seconds', dsz.TYPE_INT)}, DszObject)
    uptimecommand = OpsClass('uptime', {'idletime': dszuptime, 'uptime': dszuptime}, DszCommandObject)
    cmd_definitions['uptime'] = uptimecommand