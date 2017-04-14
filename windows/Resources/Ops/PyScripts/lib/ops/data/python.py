
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('python' not in cmd_definitions):
    pythoncommand = OpsClass('python', {}, DszCommandObject)
    cmd_definitions['python'] = pythoncommand