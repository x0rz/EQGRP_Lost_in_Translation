
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('rmdir' not in cmd_definitions):
    dszrmdir = OpsClass('targetdirectory', {'path': OpsField('path', dsz.TYPE_STRING)}, DszObject, single=True)
    rmdircommand = OpsClass('rmdir', {'targetdirectory': dszrmdir}, DszCommandObject)
    cmd_definitions['rmdir'] = rmdircommand