
import os
import sqlite3
import sys
from datetime import date
from glob import glob
from collections import namedtuple
Host = namedtuple('Host', 'host_name domain_name ip_address mac_address')

def host_from_dict(host_dict):
    if (not host_dict):
        return None
    name = (host_dict['host_name'] if host_dict.has_key('host_name') else None)
    domain_name = (host_dict['domain_name'] if host_dict.has_key('domain_name') else None)
    ip = (host_dict['ip_address'] if host_dict.has_key('ip_address') else None)
    if host_dict.has_key('mac_address'):
        mac = host_dict['mac_address']
        mac = ('%s (%s)' % (mac, getoui(mac)))
    else:
        mac = None
    if ((ip == '') or (ip == '0.0.0.0') or (ip == 'unknown')):
        ip = None
        mac = None
    if ((mac == '') or (mac == '00:00:00:00:00:00')):
        mac = None
    try:
        host = Host(name, domain_name, ip, mac)
    except:
        host = None
    return host

def collapse_hosts(host_list):
    for (i, host) in enumerate(host_list):
        for next_index in range((i + 1)):
            to_check = host_list[next_index]
            if (((host.ip_address == to_check.ip_address) and host.ip_address) or ((host.mac_address == to_check.mac_address) and host.mac_address) or ((host.host_name == to_check.host_name) and host.host_name)):
                combined_host = combine_if_appropriate(host, to_check)
                if combined_host:
                    host_list[i] = host_list[next_index] = host = combined_host
    return list(set(host_list))

def combine_if_appropriate(host1, host2):
    if (host1.ip_address and host2.ip_address and (host1.ip_address != host2.ip_address)):
        return None
    if (host1.host_name and host2.host_name and (host1.host_name != host2.host_name)):
        return None
    if (host1.domain_name and host2.domain_name and (host1.domain_name != host2.domain_name)):
        return None
    if (host1.mac_address and host2.mac_address and (host1.mac_address != host2.mac_address)):
        return None
    ip_address = (host1.ip_address if host1.ip_address else host2.ip_address)
    mac_address = (host1.mac_address if host1.mac_address else host2.mac_address)
    host_name = (host1.host_name if host1.host_name else host2.host_name)
    domain_name = (host1.domain_name if host1.domain_name else host2.domain_name)
    return Host(host_name, domain_name, ip_address, mac_address)

def ip_address_to_int(ip_address):
    if (not ip_address):
        return None
    quads = ip_address.split('.')
    if (len(quads) != 4):
        return None
    total = long(quads[3])
    total += (long(quads[2]) * (2 ** 8))
    total += (long(quads[1]) * (2 ** 16))
    total += (long(quads[0]) * (2 ** 24))
    return total

def getoui(mac):
    if (not mac):
        return ''
    norm_mac = mac.upper().replace(' ', '').replace('-', '').replace(':', '')
    if norm_mac.startswith('0050C2'):
        table = 'iabinformation'
        oui = norm_mac[0:9]
    else:
        table = 'arpinformation'
        oui = norm_mac[0:6]
    db_path = os.path.join(os.path.dirname(__file__), '..', '..', '..', 'Databases', 'macs.db')
    conn = sqlite3.connect(db_path)
    curs = conn.cursor()
    curs.execute(("select description from %s where oui like '%s%%'" % (table, oui)))
    out = curs.fetchone()
    return (out[0] if (out is not None) else 'Unknown')