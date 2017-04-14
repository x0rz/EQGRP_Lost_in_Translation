
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('put' not in cmd_definitions):
    dszlocalfile = OpsClass('localfile', {'size': OpsField('size', dsz.TYPE_INT), 'name': OpsField('name', dsz.TYPE_STRING)}, DszObject, single=True)
    dszputfile = OpsClass('file', {'name': OpsField('name', dsz.TYPE_STRING)}, DszObject, single=True)
    putcommand = OpsClass('put', {'localfile': dszlocalfile, 'file': dszputfile}, DszCommandObject)
    cmd_definitions['put'] = putcommand