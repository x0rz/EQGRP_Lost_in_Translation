
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('performance' not in cmd_definitions):
    _counter = OpsClass('counter', {'helpIndex': OpsField('helpIndex', dsz.TYPE_INT), 'nameIndex': OpsField('nameIndex', dsz.TYPE_INT), 'type': OpsField('type', dsz.TYPE_INT), 'valueType': OpsField('valueType', dsz.TYPE_STRING), 'help': OpsField('help', dsz.TYPE_STRING), 'valueSuffix': OpsField('valueSuffix', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING), 'value': OpsField('value', dsz.TYPE_STRING)}, DszObject, single=False)
    _instance = OpsClass('instance', {'id': OpsField('id', dsz.TYPE_INT), 'parent': OpsField('parent', dsz.TYPE_INT), 'name': OpsField('name', dsz.TYPE_STRING), 'counter': _counter}, DszObject, single=False)
    _object = OpsClass('object', {'helpIndex': OpsField('helpIndex', dsz.TYPE_INT), 'nameIndex': OpsField('nameIndex', dsz.TYPE_INT), 'help': OpsField('help', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING), 'counter': _counter, 'instance': _instance}, DszObject, single=False)
    _performance = OpsClass('performance', {'perfCountsPerSecond': OpsField('perfCountsPerSecond', dsz.TYPE_INT), 'perfTime100nSec': OpsField('perfTime100nSec', dsz.TYPE_INT), 'perfCount': OpsField('perfCount', dsz.TYPE_INT), 'systemName': OpsField('systemName', dsz.TYPE_STRING), 'object': _object}, DszObject)
    _performance_cmd = OpsClass('performance', {'performance': _performance}, DszCommandObject)
    cmd_definitions['performance'] = _performance_cmd