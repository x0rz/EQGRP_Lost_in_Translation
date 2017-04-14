
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('addresses' not in cmd_definitions):
    dszaddress = OpsClass('address', {'address': OpsField('address', dsz.TYPE_STRING), 'arch': OpsField('arch', dsz.TYPE_STRING), 'compiledarch': OpsField('compiledarch', dsz.TYPE_STRING), 'platform': OpsField('platform', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING), 'metadata': OpsField('metadata', dsz.TYPE_STRING), 'major': OpsField('major', dsz.TYPE_INT), 'minor': OpsField('minor', dsz.TYPE_INT), 'other': OpsField('other', dsz.TYPE_INT), 'build': OpsField('build', dsz.TYPE_INT), 'clibmajor': OpsField('clibmajor', dsz.TYPE_INT), 'clibminor': OpsField('clibminor', dsz.TYPE_INT), 'clibrevision': OpsField('clibrevision', dsz.TYPE_INT), 'pid': OpsField('pid', dsz.TYPE_INT)}, DszObject, single=False)
    addr_command = OpsClass('addresses', {'local': dszaddress, 'remote': dszaddress}, DszCommandObject)
    cmd_definitions['addresses'] = addr_command