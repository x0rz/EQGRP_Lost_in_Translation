
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('shares' not in cmd_definitions):
    dszmappedresource = OpsClass('mappedresource', {'remotepath': OpsField('remotepath', dsz.TYPE_STRING), 'localpath': OpsField('localpath', dsz.TYPE_STRING)}, DszObject, single=True)
    dszshare = OpsClass('share', {'password': OpsField('password', dsz.TYPE_STRING), 'localname': OpsField('localname', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING), 'domainname': OpsField('domainname', dsz.TYPE_STRING), 'remotename': OpsField('remotename', dsz.TYPE_STRING), 'username': OpsField('username', dsz.TYPE_STRING), 'status': OpsField('status', dsz.TYPE_STRING), 'referencecount': OpsField('referencecount', dsz.TYPE_INT), 'usecount': OpsField('usecount', dsz.TYPE_INT)}, DszObject, single=False)
    dszresouce = OpsClass('resouce', {'admin': OpsField('admin', dsz.TYPE_BOOL), 'description': OpsField('description', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING), 'path': OpsField('path', dsz.TYPE_STRING), 'caption': OpsField('caption', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING)}, DszObject, single=False)
    sharescommand = OpsClass('shares', {'mappedresource': dszmappedresource, 'share': dszshare, 'resouce': dszresouce}, DszCommandObject)
    cmd_definitions['shares'] = sharescommand