
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('banner' not in cmd_definitions):
    dsztaskinginfo = OpsClass('taskinginfo', {'tasktype': OpsClass('tasktype', {'value': OpsField('value', dsz.TYPE_STRING)}, DszObject), 'searchmask': OpsClass('searchmask', {'value': OpsField('value', dsz.TYPE_STRING)}, DszObject), 'target': OpsClass('target', {'location': OpsField('location', dsz.TYPE_STRING)}, DszObject)}, DszObject)
    dsztransfer = OpsClass('transfer', {'text': OpsField('text', dsz.TYPE_STRING), 'data': OpsField('data', dsz.TYPE_STRING), 'address': OpsField('address', dsz.TYPE_STRING), 'data_size': OpsField('data_size', dsz.TYPE_INT), 'port': OpsField('port', dsz.TYPE_INT)}, DszObject, single=False)
    bannercommand = OpsClass('banner', {'taskinginfo': dsztaskinginfo, 'transfer': dsztransfer}, DszCommandObject)
    cmd_definitions['banner'] = bannercommand