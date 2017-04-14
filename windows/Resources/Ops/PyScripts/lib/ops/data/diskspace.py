
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('diskspace' not in cmd_definitions):
    dszdiskspace = OpsClass('drive', {'low_diskspace': OpsField('low_diskspace', dsz.TYPE_BOOL), 'total': OpsField('total', dsz.TYPE_INT), 'free': OpsField('free', dsz.TYPE_INT), 'available': OpsField('available', dsz.TYPE_INT), 'path': OpsField('path', dsz.TYPE_STRING)}, DszObject, single=False)
    diskspacecommand = OpsClass('diskspace', {'drive': dszdiskspace}, DszCommandObject)
    cmd_definitions['diskspace'] = diskspacecommand