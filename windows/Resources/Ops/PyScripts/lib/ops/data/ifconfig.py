
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz

class IfconfigCommandData(DszCommandObject, ):

    def __init__(self, cmdid=None, cmdname='', debug=False, **kwargs):
        DszCommandObject.__init__(self, cmdid, cmdname, debug)
        self.update(debug)

    def _getAllIPs(self):
        retval = []
        for interface in self.interfaceitem:
            for ipaddr in interface.ipaddress:
                retval.append(ipaddr.ip)
        return retval
    all_ips = property(_getAllIPs)

    def _getAllMacs(self):
        retval = []
        for interface in self.interfaceitem:
            retval.append(interface.address)
        return retval
    all_macs = property(_getAllMacs)
if ('ifconfig' not in cmd_definitions):
    interface = OpsClass('interfaceitem', {'dhcpenabled': OpsField('dhcpenabled', dsz.TYPE_BOOL), 'enabled': OpsField('enabled', dsz.TYPE_BOOL), 'enabledarp': OpsField('enabledarp', dsz.TYPE_BOOL), 'havewinws': OpsField('havewins', dsz.TYPE_BOOL), 'mtu': OpsField('mtu', dsz.TYPE_INT), 'type': OpsField('type', dsz.TYPE_STRING), 'address': OpsField('address', dsz.TYPE_STRING), 'description': OpsField('description', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING), 'status': OpsField('status', dsz.TYPE_STRING), 'dnssuffix': OpsField('dnssuffix', dsz.TYPE_STRING), 'subnetmask': OpsField('subnetmask', dsz.TYPE_STRING), 'gateway': OpsClass('gateway', {'ip': OpsField('ip', dsz.TYPE_STRING)}, DszObject), 'dhcp': OpsClass('dhcp', {'ip': OpsField('ip', dsz.TYPE_STRING)}, DszObject), 'lease': OpsClass('lease', {'obtained': OpsClass('obtained', {'time': OpsField('time', dsz.TYPE_STRING), 'date': OpsField('date', dsz.TYPE_STRING)}, DszObject), 'expires': OpsClass('obtained', {'time': OpsField('time', dsz.TYPE_STRING), 'date': OpsField('date', dsz.TYPE_STRING)}, DszObject)}, DszObject), 'wins': OpsClass('wins', {'primary': OpsClass('primary', {'ip': OpsField('ip', dsz.TYPE_STRING)}, DszObject), 'secondary': OpsClass('secondary', {'ip': OpsField('ip', dsz.TYPE_STRING)}, DszObject)}, DszObject), 'ipaddress': OpsClass('ipaddress', {'ip': OpsField('ip', dsz.TYPE_STRING)}, DszObject, single=False), 'ipaddressv6': OpsClass('ipaddressv6', {'ip': OpsField('ip', dsz.TYPE_STRING)}, DszObject, single=False), 'dnsservers': OpsClass('dnsservers', {'dnsserver': OpsClass('dnsserver', {'ip': OpsField('ip', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject)}, DszObject, single=False)
    fixed = OpsClass('fixeddataitem', {'enableproxy': OpsField('enableproxy', dsz.TYPE_BOOL), 'enablerouting': OpsField('enablerouting', dsz.TYPE_BOOL), 'enabledns': OpsField('enabledns', dsz.TYPE_BOOL), 'domainname': OpsField('domainname', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING), 'hostname': OpsField('hostname', dsz.TYPE_STRING), 'scopeid': OpsField('scopeid', dsz.TYPE_STRING), 'description': OpsField('description', dsz.TYPE_STRING), 'dnsservers': OpsClass('dnsservers', {'dnsserver': OpsClass('dnsserver', {'ip': OpsField('ip', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject)}, DszObject)
    ifconfigcommand = OpsClass('ifconfig', {'fixeddataitem': fixed, 'interfaceitem': interface}, IfconfigCommandData)
    cmd_definitions['ifconfig'] = ifconfigcommand