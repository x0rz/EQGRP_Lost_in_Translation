
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('memory' not in cmd_definitions):
    dszmemoryitem = OpsClass('memoryitem', {'physicalload': OpsField('physicalload', dsz.TYPE_INT), 'virtualavail': OpsField('virtualavail', dsz.TYPE_INT), 'physicaltotal': OpsField('physicaltotal', dsz.TYPE_INT), 'pageavail': OpsField('pageavail', dsz.TYPE_INT), 'pagetotal': OpsField('pagetotal', dsz.TYPE_INT), 'physicalavail': OpsField('physicalavail', dsz.TYPE_INT), 'virtualtotal': OpsField('virtualtotal', dsz.TYPE_INT)}, DszObject)
    memorycommand = OpsClass('memory', {'memoryitem': dszmemoryitem}, DszCommandObject)
    cmd_definitions['memory'] = memorycommand