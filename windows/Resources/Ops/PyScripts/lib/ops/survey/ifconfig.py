
import datetime
import ops
import ops.cmd
import ops.db
import ops.pprint
import dsz
import dsz.ui
import ops.networking.ifconfig
from optparse import OptionParser

def main(options=None, args=None):
    tdb = ops.db.get_tdb()
    if (options is None):
        maxage = datetime.timedelta(seconds=0)
    else:
        maxage = datetime.timedelta(seconds=options.maxage)
    last_ifconfig = ops.networking.ifconfig.get_ifconfig(maxage=datetime.timedelta.max)
    cur_ifconfig = ops.networking.ifconfig.get_ifconfig(maxage=maxage)
    iface_adds = list()
    iface_removes = list()
    iface_changes = list()
    for old_iface in filter((lambda x: (x.type.lower() not in ['local', 'tunnel encapsulation'])), last_ifconfig.interfaceitem):
        match_iface = filter((lambda x: (x.address == old_iface.address)), cur_ifconfig.interfaceitem)
        if (len(match_iface) == 0):
            iface_removes.append(old_iface)
        else:
            (adds, removes) = compare_interface_ips(old_iface, match_iface[0])
            if ((len(adds) + len(removes)) > 0):
                iface_changes.append((old_iface, match_iface[0]))
            if (old_iface.name != match_iface[0].name):
                iface_changes.append((old_iface, match_iface[0]))
            if (old_iface.dhcpenabled != match_iface[0].dhcpenabled):
                iface_changes.append((old_iface, match_iface[0]))
            if (old_iface.gateway.ip != match_iface[0].gateway.ip):
                iface_changes.append((old_iface, match_iface[0]))
            if (old_iface.enabled != match_iface[0].enabled):
                iface_changes.append((old_iface, match_iface[0]))
    for new_iface in filter((lambda x: (x.type.lower() not in ['local', 'tunnel encapsulation'])), cur_ifconfig.interfaceitem):
        match_iface = filter((lambda x: (x.address == new_iface.address)), last_ifconfig.interfaceitem)
        if (len(match_iface) == 0):
            iface_adds.append(new_iface)
    pretty_ip_list = list()
    for iface in filter((lambda x: (x.type.lower() not in ['local', 'tunnel encapsulation'])), cur_ifconfig.interfaceitem):
        for ipaddr in iface.ipaddress:
            if iface.dhcpenabled:
                dhcpinfo = iface.dhcp.ip
            else:
                dhcpinfo = 'Off'
            pretty_ip_list.append({'description': iface.description, 'ip': ipaddr.ip, 'mac': iface.address, 'gateway': iface.gateway.ip, 'netmask': iface.subnetmask, 'dhcp': ('%s' % dhcpinfo), 'name': iface.name})
    if (cur_ifconfig.fixeddataitem.domainname != ''):
        fqdn = ('%s.%s' % (cur_ifconfig.fixeddataitem.hostname, cur_ifconfig.fixeddataitem.domainname))
    else:
        fqdn = cur_ifconfig.fixeddataitem.hostname
    print ('FQDN: %s' % fqdn)
    print ('DNS Servers: %s' % ', '.join(map((lambda x: x.ip), cur_ifconfig.fixeddataitem.dnsservers.dnsserver)))
    ops.info(('Showing all non-local and non-tunnel encapsulation adapter information, see command %d for full interface list' % cur_ifconfig.commandmetadata.id))
    ops.pprint.pprint(pretty_ip_list, header=['Description', 'MAC', 'IP', 'Netmask', 'Gateway', 'DHCP Server', 'Name'], dictorder=['description', 'mac', 'ip', 'netmask', 'gateway', 'dhcp', 'name'])
    if ((last_ifconfig.fixeddataitem.hostname != cur_ifconfig.fixeddataitem.hostname) or (last_ifconfig.fixeddataitem.domainname != cur_ifconfig.fixeddataitem.domainname)):
        ops.warn(('Host and/or domain name have changed, was %s.%s, not %s.%s' % (last_ifconfig.fixeddataitem.hostname, last_ifconfig.fixeddataitem.domainname, cur_ifconfig.fixeddataitem.hostname, cur_ifconfig.fixeddataitem.domainname)))
    if (len(iface_adds) > 0):
        ops.warn('New interfaces found')
        ops.warn('--------------------')
        for iface in iface_adds:
            print_iface(iface)
    if (len(iface_removes) > 0):
        ops.warn('Interfaces removed')
        ops.warn('------------------')
        for iface in iface_removes:
            print_iface(iface)
    if (len(iface_changes) > 0):
        ops.warn('Interface changes')
        ops.warn('-----------------')
        i = 1
        for pair in iface_changes:
            ops.warn(('Change %d' % i))
            ops.warn('Old version')
            print_iface(pair[0])
            ops.warn('New version')
            print_iface(pair[1])
            i += 1

def print_iface(iface):
    print ('Name: %s - %s' % (iface.name, iface.description))
    print ('MAC: %s' % iface.address)
    print ('IPs: %s' % ', '.join(map((lambda x: ('%s/%s' % (x.ip, iface.subnetmask))), iface.ipaddress)))
    if iface.dhcpenabled:
        print ('DHCP server: %s' % iface.dhcp.ip)

def compare_interface_ips(iface1, iface2):
    ipadds = list()
    ipremoves = list()
    for ip1 in iface1.ipaddress:
        matches = filter((lambda x: (x.ip == ip1.ip)), iface2.ipaddress)
        if (len(matches) == 0):
            ipremoves.append(ip1.ip)
    for ip2 in iface2.ipaddress:
        matches = filter((lambda x: (x.ip == ip2.ip)), iface1.ipaddress)
        if (len(matches) == 0):
            ipadds.append(ip2.ip)
    return (ipadds, ipremoves)
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of auditing status information to use before re-running audit -status', type='int')
    (options, args) = parser.parse_args()
    main(options, args)