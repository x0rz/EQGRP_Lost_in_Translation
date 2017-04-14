
import glob
import os
import sys
from table_print import pprint
from BeautifulSoup import BeautifulStoneSoup
from host_functions import host_from_dict, collapse_hosts, ip_address_to_int
global_host_list = []

def main(glob_path):
    all_hosts = []
    for input_file in glob.glob(os.path.join(glob_path, '*arp*xml')):
        all_hosts += parse_arp(input_file)
    for input_file in glob.glob(os.path.join(glob_path, '*config*xml')):
        all_hosts += parse_config(input_file)
    for input_file in glob.glob(os.path.join(glob_path, '*netbios*xml')):
        all_hosts += parse_netbios(input_file)
    for input_file in glob.glob(os.path.join(glob_path, '*netmap*xml')):
        all_hosts += parse_netmap(input_file)
    for input_file in glob.glob(os.path.join(glob_path, '*netconnections*xml')):
        all_hosts += parse_netconnections(input_file)
    for input_file in glob.glob(os.path.join(glob_path, '*ping*xml')):
        all_hosts += parse_ping(input_file)
    host_list = [host_from_dict(host) for host in all_hosts]
    host_list = collapse_hosts(host_list)
    host_list.sort(key=(lambda x: ip_address_to_int(x.ip_address)))
    pprint(host_list, ['IP Address', 'Host Name', 'Domain Name', 'MAC Address'], [2, 0, 1, 3])

def handler(input_file, function, output_dir):
    host_list = function(input_file)
    host_list = [host_from_dict(host) for host in host_list]
    if (not host_list):
        return
    global global_host_list
    global_host_list += host_list
    global_host_list = collapse_hosts(global_host_list)
    global_host_list.sort(key=(lambda x: ip_address_to_int(x.ip_address)))
    source_drive = os.path.splitdrive(os.path.abspath(input_file))[0]
    source_drive = source_drive.replace(':', '')
    output_file = ('hostmap_%s_drive.txt' % source_drive)
    pprint(data=global_host_list, header=['IP Address', 'Host Name', 'Domain Name', 'MAC Address'], dictorder=[2, 0, 1, 3], output_file=os.path.join(output_dir, output_file))

def handle_arp(file_to_read, output_dir):
    handler(file_to_read, parse_arp, output_dir)

def handle_config(file_to_read, output_dir):
    handler(file_to_read, parse_config, output_dir)

def handle_netbios(file_to_read, output_dir):
    handler(file_to_read, parse_netbios, output_dir)

def handle_netmap(file_to_read, output_dir):
    handler(file_to_read, parse_netmap, output_dir)

def handle_netconnections(file_to_read, output_dir):
    handler(file_to_read, parse_netconnections, output_dir)

def handle_ping(file_to_read, output_dir):
    handler(file_to_read, parse_ping, output_dir)

def parse_arp(file_to_read):
    parsed = BeautifulStoneSoup(file(file_to_read).read())
    mac_key = 'macaddress'
    ip_key = 'ipv4address'
    adapters = parsed.findAll('arpentry')
    if (not adapters):
        mac_key = 'physicaladdress'
        ip_key = 'ip'
        adapters = parsed.findAll('entry')
    ip_list = []
    for adapter in adapters:
        mac = (adapter.find(mac_key).string if adapter.find(mac_key) else '')
        mac = (mac.replace(' ', ':').replace('-', ':').lower() if mac else '')
        if ((mac == '00:00:00:00:00:00') or (not mac)):
            continue
        ip = (adapter.find(ip_key).string if adapter.find(ip_key) else '')
        if (not ip):
            continue
        ip_list.append({'ip_address': ip, 'mac_address': mac})
    return ip_list

def parse_config(file_to_read):
    parsed = BeautifulStoneSoup(file(file_to_read).read())
    adapters = parsed.findAll('adapter')
    if (not adapters):
        adapters = parsed.findAll('interface')
    host_tag = parsed.find('hostname')
    if host_tag:
        host_name = host_tag.string.lower()
    else:
        host_name = None
    domain_tag = parsed.find('domainname')
    if domain_tag:
        domain_name = domain_tag.string
        if domain_name:
            domain_name = domain_name.lower()
    else:
        domain_name = None
    ip_list = []
    for adapter in adapters:
        mac = (adapter.find('address').string if adapter.find('address') else None)
        if mac:
            mac = mac.replace('-', ':').lower()
        adapter_ips = adapter.findAll('adapterip')
        for adapter_ip_node in adapter_ips:
            if (not adapter_ip_node):
                continue
            ip = ''
            for ip_address in adapter_ip_node.find('ip'):
                ip = ip_address.string.strip()
                if (not ip):
                    continue
                info = {'host_name': host_name, 'domain_name': domain_name, 'ip_address': ip, 'mac_address': mac}
                if ((info not in ip_list) and (ip != '127.0.0.1') and (':' not in ip)):
                    ip_list.append(info)
    return ip_list

def parse_netbios(file_to_read):
    parsed = BeautifulStoneSoup(file(file_to_read).read())
    adapters = parsed.findAll('adapter')
    if adapters:
        call_name = parsed.find('callname').string
        if call_name[0].isdigit():
            ip_address = unicode(call_name.strip())
        else:
            ip_address = None
    netbios_list = []
    for adapter in adapters:
        mac_address = adapter['adapter_addr'].replace('.', ':').strip()
        names_list = adapter.findAll('names')
        host_name = None
        domain_name = None
        for names_elements in names_list:
            type = names_elements.find('type')
            name = names_elements.find('name')
            if (type.string == 'Workstation Service'):
                host_name = unicode(name.string.strip()).lower()
            elif (type.string == 'Domain Name'):
                domain_name = unicode(name.string.strip()).lower()
        netbios_list += [{'host_name': host_name, 'domain_name': domain_name, 'ip_address': ip_address, 'mac_address': mac_address}]
    return netbios_list

def parse_netmap(file_to_read):
    parsed = BeautifulStoneSoup(file(file_to_read).read())
    entries = parsed.findAll('entry')
    host_list = []
    for entry in entries:
        if (entry.find('type').string.lower() != 'server'):
            continue
        host_name = (entry.find('remotename').string if entry.find('remotename') else None)
        host_name = host_name.replace('\\', '').lower()
        domain_name = (entry.find('parentname').string if entry.find('parentname') else None)
        domain_name = domain_name.lower()
        ips = entry.findAll('addr')
        for ip in ips:
            ip = (None if (ip == '\n') else ip)
            if (':' in str(ip)):
                continue
            host_list.append({'ip_address': ip.string, 'host_name': host_name, 'domain_name': domain_name})
    return host_list

def parse_netconnections(file_to_read):
    parsed = BeautifulStoneSoup(file(file_to_read).read())
    entries = parsed.findAll('connection')
    host_list = []
    for entry in entries:
        if (not entry.has_key('state')):
            continue
        if ((entry['state'].lower() != 'established') and (entry['state'].lower() != 'time_wait')):
            continue
        remote_ip = entry.find('remoteaddress')
        if (not remote_ip):
            continue
        ip = remote_ip.find('ipv4address').string
        if (ip in ('127.0.0.1', '::1')):
            continue
        host_list.append({'ip_address': ip})
    return host_list

def parse_ping(file_to_read):
    parsed = BeautifulStoneSoup(file(file_to_read).read())
    entries = parsed.findAll('response')
    host_list = []
    for entry in entries:
        remote_ip = entry.find('fromaddr')
        if (not remote_ip):
            continue
        ip = remote_ip.find('ipv4address')
        if (not ip):
            continue
        ip = ip.string
        if (ip in ('127.0.0.1', '::1')):
            continue
        host_list.append({'ip_address': ip})
    return host_list
if (__name__ == '__main__'):
    main(sys.argv[1])