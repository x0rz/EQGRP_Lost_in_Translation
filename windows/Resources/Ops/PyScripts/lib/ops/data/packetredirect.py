
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
if ('packetredirect' not in cmd_definitions):
    packetredirectcommand = OpsClass('packetredirect', {}, DszCommandObject)
    cmd_definitions['packetredirect'] = packetredirectcommand