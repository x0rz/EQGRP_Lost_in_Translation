
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('systempaths' not in cmd_definitions):
    dszsystemdir = OpsClass('systemdir', {'location': OpsField('location', dsz.TYPE_STRING)}, DszObject, single=True)
    dszwindowsdir = OpsClass('windowsdir', {'location': OpsField('location', dsz.TYPE_STRING)}, DszObject, single=True)
    dsztempdir = OpsClass('tempdir', {'location': OpsField('location', dsz.TYPE_STRING)}, DszObject, single=True)
    systempathscommand = OpsClass('systempaths', {'systemdir': dszsystemdir, 'windowsdir': dszwindowsdir, 'tempdir': dsztempdir}, DszCommandObject)
    cmd_definitions['systempaths'] = systempathscommand