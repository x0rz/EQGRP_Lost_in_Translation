
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('runaschild' not in cmd_definitions):
    dszrunaschild = OpsClass('process', {'id': OpsField('id', dsz.TYPE_INT)}, DszObject, single=True)
    runaschildcommand = OpsClass('runaschild', {'process': dszrunaschild}, DszCommandObject)
    cmd_definitions['runaschild'] = runaschildcommand