
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
import ops
import os.path

class DriverData(DszObject, ):

    def __init__(self, dszpath='', cmdid=None, opsclass=None, parent=None, debug=False):
        DszObject.__init__(self, dszpath, cmdid, dszdriveritem, parent, debug)
        self._friendly = None
        self._drivertype = None

    def _populateDriverData(self):
        driverlist = ops.db.Database(ops.db.DRIVERLIST)
        curs = driverlist.connection.execute('SELECT * FROM drivers WHERE name = ?', (self.filename,))
        row = curs.fetchone()
        if (row is not None):
            self._friendly = row['comment']
            self._drivertype = row['type']
        else:
            self._friendly = ''
            self._drivertype = ''

    def _getFriendlyName(self):
        if (self._friendly is None):
            self._populateDriverData()
        return self._friendly
    friendlyname = property(_getFriendlyName)

    def _getFriendlyType(self):
        if (self._proctype is None):
            self._populateDriverData()
        return self._drivertype
    drivertype = property(_getFriendlyType)

    def _getFilename(self):
        return os.path.split(self.name)[1]
    filename = property(_getFilename)
if ('drivers' not in cmd_definitions):
    dszdriveritem = OpsClass('driveritem', {'base': OpsField('base', dsz.TYPE_INT), 'loadcount': OpsField('loadcount', dsz.TYPE_INT), 'flags': OpsField('flags', dsz.TYPE_INT), 'size': OpsField('size', dsz.TYPE_INT), 'license': OpsField('license', dsz.TYPE_STRING), 'dependencies': OpsField('dependencies', dsz.TYPE_STRING), 'loadparams': OpsField('loadparams', dsz.TYPE_STRING), 'description': OpsField('description', dsz.TYPE_STRING), 'usedbymods': OpsField('usedbymods', dsz.TYPE_STRING), 'filepath': OpsField('filepath', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING), 'author': OpsField('author', dsz.TYPE_STRING), 'alias': OpsField('alias', dsz.TYPE_STRING), 'version': OpsField('version', dsz.TYPE_STRING), 'signed': OpsField('signed', dsz.TYPE_BOOL)}, DriverData, single=False)
    drivescommand = OpsClass('drivers', {'driveritem': dszdriveritem}, DszCommandObject)
    cmd_definitions['drivers'] = drivescommand