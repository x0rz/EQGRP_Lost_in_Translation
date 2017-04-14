
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('processoptions' not in cmd_definitions):
    dszprocessoptions = OpsClass('options', {'permanent': OpsField('permanent', dsz.TYPE_BOOL), 'executionenabled': OpsField('executionenabled', dsz.TYPE_BOOL), 'executiondisabled': OpsField('executiondisabled', dsz.TYPE_BOOL), 'executedispatchenabled': OpsField('executedispatchenabled', dsz.TYPE_BOOL), 'disablethunkemulation': OpsField('disablethunkemulation', dsz.TYPE_BOOL), 'imagedispatchenabled': OpsField('imagedispatchenabled', dsz.TYPE_BOOL), 'disableexceptionchainvalidation': OpsField('disableexceptionchainvalidation', dsz.TYPE_BOOL), 'value': OpsField('value', dsz.TYPE_INT), 'processid': OpsField('processid', dsz.TYPE_INT)}, DszObject, single=True)
    processoptionscommand = OpsClass('processoptions', {'options': dszprocessoptions}, DszCommandObject)
    cmd_definitions['processoptions'] = processoptionscommand