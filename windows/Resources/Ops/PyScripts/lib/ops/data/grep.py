
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('grep' not in cmd_definitions):
    dszgrep = OpsClass('file', {'location': OpsField('location', dsz.TYPE_STRING), 'numlines': OpsField('numlines', dsz.TYPE_INT), 'line': OpsClass('line', {'position': OpsField('position', dsz.TYPE_INT), 'value': OpsField('value', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject, single=False)
    grepcommand = OpsClass('grep', {'file': dszgrep}, DszCommandObject)
    cmd_definitions['grep'] = grepcommand