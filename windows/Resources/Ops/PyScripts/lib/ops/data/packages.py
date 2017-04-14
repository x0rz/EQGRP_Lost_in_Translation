
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz

class PackageData(DszObject, ):

    def __init__(self, dszpath='', cmdid=None, opsclass=None, parent=None, debug=False, **kwargs):
        DszObject.__init__(self, dszpath, cmdid, dszpackage, parent, debug, **kwargs)

    def _getIsUpdate(self):
        return ((self.name.find('Security Update') > (-1)) or (self.name.lower().find('hotfix') > (-1)))
    isupdate = property(_getIsUpdate)
if ('packages' not in cmd_definitions):
    dsztaskinginfo = OpsClass('taskinginfo', {'recursive': OpsField('recursive', dsz.TYPE_BOOL), 'target': OpsClass('target', {'local': OpsField('local', dsz.TYPE_BOOL), 'location': OpsField('location', dsz.TYPE_STRING)}, DszObject)}, DszObject)
    dszpackage = OpsClass('package', {'size': OpsField('size', dsz.TYPE_INT), 'installdate': OpsField('installdate', dsz.TYPE_STRING), 'installtime': OpsField('installtime', dsz.TYPE_STRING), 'description': OpsField('description', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING), 'version': OpsField('version', dsz.TYPE_STRING), 'revision': OpsField('revision', dsz.TYPE_STRING)}, PackageData, single=False)
    packagescommand = OpsClass('packages', {'package': dszpackage, 'taskinginfo': dsztaskinginfo}, DszCommandObject)
    cmd_definitions['packages'] = packagescommand