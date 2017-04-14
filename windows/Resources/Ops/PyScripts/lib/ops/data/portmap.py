
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('portmap' not in cmd_definitions):
    dszportmap = OpsClass('process', {'id': OpsField('id', dsz.TYPE_INT), 'name': OpsField('name', dsz.TYPE_STRING), 'port': OpsClass('port', {'sourceport': OpsField('sourceport', dsz.TYPE_INT), 'sourceaddr': OpsField('sourceaddr', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING), 'state': OpsField('state', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject, single=False)
    portmapcommand = OpsClass('portmap', {'process': dszportmap}, DszCommandObject)
    cmd_definitions['portmap'] = portmapcommand