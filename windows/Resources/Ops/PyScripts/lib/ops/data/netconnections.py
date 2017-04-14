
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz

class NetConnectionsCommandData(DszCommandObject, ):

    def __init__(self, cmdid=None, cmdname='', debug=False, **kwargs):
        DszCommandObject.__init__(self, cmdid, cmdname, debug)
        self.update(debug)

    def _getAllConnectionData(self):
        retval = []
        retval.extend(self.initialconnectionlistitem.connectionitem)
        for start in self.startconnectionlistitem:
            retval.extend(start.connectionitem)
        for stop in self.stopconnectionlistitem:
            retval.extend(stop.connectionitem)
    allconnectiondata = property(_getAllConnectionData)
if ('netconnections' not in cmd_definitions):
    dszconnectionitem = OpsClass('connectionitem', {'valid': OpsField('valid', dsz.TYPE_BOOL), 'type': OpsField('type', dsz.TYPE_STRING), 'state': OpsField('state', dsz.TYPE_STRING), 'pid': OpsField('pid', dsz.TYPE_INT), 'local': OpsClass('local', {'portv4': OpsField('portv4', dsz.TYPE_STRING), 'ipv4': OpsField('ipv4', dsz.TYPE_STRING), 'portv6': OpsField('portv6', dsz.TYPE_STRING), 'ipv6': OpsField('ipv6', dsz.TYPE_STRING), 'port': OpsField('port', dsz.TYPE_STRING), 'address': OpsField('address', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING)}, DszObject), 'remote': OpsClass('remote', {'portv4': OpsField('portv4', dsz.TYPE_STRING), 'ipv4': OpsField('ipv4', dsz.TYPE_STRING), 'portv6': OpsField('portv6', dsz.TYPE_STRING), 'ipv6': OpsField('ipv6', dsz.TYPE_STRING), 'port': OpsField('port', dsz.TYPE_STRING), 'address': OpsField('address', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING)}, DszObject)}, DszObject, single=False)
    dszinitialconnectionlistitem = OpsClass('initialconnectionlistitem', {'connectionitem': dszconnectionitem}, DszObject)
    dszstartconnectionlistitem = OpsClass('startconnectionlistitem', {'connectionitem': dszconnectionitem}, DszObject, single=False)
    dszstopconnectionlistitem = OpsClass('stopconnectionlistitem', {'connectionitem': dszconnectionitem}, DszObject, single=False)
    netconnectionscommand = OpsClass('netconnections', {'initialconnectionlistitem': dszinitialconnectionlistitem, 'startconnectionlistitem': dszstartconnectionlistitem, 'stopconnectionlistitem': dszstopconnectionlistitem}, NetConnectionsCommandData)
    cmd_definitions['netconnections'] = netconnectionscommand