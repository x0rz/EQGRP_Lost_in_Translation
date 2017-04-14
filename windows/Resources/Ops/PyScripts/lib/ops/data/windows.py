
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('windows' not in cmd_definitions):
    dszwindowstation = OpsClass('windowstation', {'visible': OpsField('visible', dsz.TYPE_BOOL), 'status': OpsField('status', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING), 'desktop': OpsClass('desktop', {'name': OpsField('name', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject, single=False)
    dzsscreenshot = OpsClass('screenshot', {'filename': OpsField('filename', dsz.TYPE_STRING), 'path': OpsField('path', dsz.TYPE_STRING), 'subdir': OpsField('subdir', dsz.TYPE_STRING)}, DszObject, single=True)
    dszwindow = OpsClass('window', {'visible': OpsField('visible', dsz.TYPE_BOOL), 'minimized': OpsField('minimized', dsz.TYPE_BOOL), 'hparent': OpsField('hparent', dsz.TYPE_INT), 'hwnd': OpsField('hwnd', dsz.TYPE_INT), 'pid': OpsField('pid', dsz.TYPE_INT), 'text': OpsField('text', dsz.TYPE_STRING)}, DszObject, single=False)
    dszbutton = OpsClass('button', {'enabled': OpsField('enabled', dsz.TYPE_BOOL), 'id': OpsField('id', dsz.TYPE_INT), 'text': OpsField('text', dsz.TYPE_STRING)}, DszObject, single=False)
    windowscommand = OpsClass('windows', {'windowstation': dszwindowstation, 'screenshot': dzsscreenshot, 'window': dszwindow, 'button': dszbutton}, DszCommandObject)
    cmd_definitions['windows'] = windowscommand