
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('route' not in cmd_definitions):
    dszroute = OpsClass('route', {'metric': OpsField('metric', dsz.TYPE_INT), 'gateway': OpsField('gateway', dsz.TYPE_STRING), 'destination': OpsField('destination', dsz.TYPE_STRING), 'networkmask': OpsField('networkmask', dsz.TYPE_STRING), 'interface': OpsField('interface', dsz.TYPE_STRING), 'origin': OpsField('origin', dsz.TYPE_STRING), 'routetype': OpsField('routetype', dsz.TYPE_STRING), 'flagloopback': OpsField('flagloopback', dsz.TYPE_BOOL), 'flagautoconfigure': OpsField('flagautoconfigure', dsz.TYPE_BOOL), 'flagpermanent': OpsField('flagpermanent', dsz.TYPE_BOOL), 'flagpublish': OpsField('flagpublish', dsz.TYPE_BOOL)}, DszObject, single=False)
    routecommand = OpsClass('route', {'route': dszroute}, DszCommandObject)
    cmd_definitions['route'] = routecommand