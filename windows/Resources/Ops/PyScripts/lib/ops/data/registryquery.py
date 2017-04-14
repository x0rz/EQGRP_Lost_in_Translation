
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz

class RegistryValueData(DszObject, ):

    def __init__(self, dszpath='', cmdid=None, opsclass=None, parent=None, debug=False):
        DszObject.__init__(self, dszpath, cmdid, dszregvalue, parent, debug)

class RegistrySubkeyData(DszObject, ):

    def __init__(self, dszpath='', cmdid=None, opsclass=None, parent=None, debug=False):
        DszObject.__init__(self, dszpath, cmdid, dszsubkey, parent, debug)

class RegistryKeyData(DszObject, ):

    def __init__(self, dszpath='', cmdid=None, opsclass=None, parent=None, debug=False):
        DszObject.__init__(self, dszpath, cmdid, dszregistrykey, parent, debug)
        self._quickdict = None

    def _makekeyvaldict(self):
        if (self._quickdict is None):
            self._quickdict = dict()
            for subkey in self.subkey:
                self._quickdict[subkey.name.lower()] = subkey
            for valval in self.value:
                self._quickdict[valval.name.lower()] = valval

    def __contains__(self, key):
        self._makekeyvaldict()
        return (key in self._quickdict)

    def __getitem__(self, key):
        self._makekeyvaldict()
        key = key.lower()
        if (key in self._quickdict):
            return self._quickdict[key]
        raise KeyError(('There is no subkey or value named %s in the registry key %s' % (key, self.name)))

class RegistryQueryCommandData(DszCommandObject, ):

    def __init__(self, cmdid=None, cmdname='', debug=False, **kwargs):
        DszCommandObject.__init__(self, cmdid, cmdname, debug)
        self.update(debug)
if ('registryquery' not in cmd_definitions):
    dszsubkey = OpsClass('subkey', {'name': OpsField('name', dsz.TYPE_STRING), 'updatedate': OpsField('updatedate', dsz.TYPE_STRING), 'updatetime': OpsField('updatetime', dsz.TYPE_STRING)}, RegistrySubkeyData, single=False)
    dszregvalue = OpsClass('value', {'typevalue': OpsField('typevalue', dsz.TYPE_INT), 'value': OpsField('value', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING)}, RegistryValueData, single=False)
    dszregistrykey = OpsClass('key', {'updatedate': OpsField('updatedate', dsz.TYPE_STRING), 'updatetime': OpsField('updatetime', dsz.TYPE_STRING), 'hive': OpsField('hive', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING), 'class': OpsField('class', dsz.TYPE_STRING), 'subkey': dszsubkey, 'value': dszregvalue}, RegistryKeyData, single=False)
    registryquerycommand = OpsClass('registryquery', {'key': dszregistrykey}, RegistryQueryCommandData)
    cmd_definitions['registryquery'] = registryquerycommand