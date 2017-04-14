
from __future__ import division
from math import floor

def get_cidr_from_subnet(subnet):
    if (not validate_ipv4(subnet)):
        raise ValueError, 'Subnet must be valid.'
    subnetsplit = subnet.split('.')
    cidr = 0
    for oct in subnetsplit:
        cidr = (cidr + list(bin(int(oct))).count('1'))
    return cidr

def get_subnet_from_cidr(cidr):
    if (not ((type(cidr) is int) or (type(cidr) is long))):
        raise TypeError, 'Value must be an integer or a long.'
    num = 0
    for i in range(0, cidr):
        num = (num | (2 ** (31 - i)))
    return get_ip_from_int(num)

def get_ip_from_int(num):
    if (not ((type(num) is int) or (type(num) is long))):
        raise TypeError, 'Value must be an integer or a long.'
    one = floor((num // (2 ** 24)))
    two = floor(((num - (one * (2 ** 24))) // (2 ** 16)))
    three = floor((((num - (one * (2 ** 24))) - (two * (2 ** 16))) // (2 ** 8)))
    four = (((num - (one * (2 ** 24))) - (two * (2 ** 16))) - (three * (2 ** 8)))
    if validate_ipv4(('%d.%d.%d.%d' % (one, two, three, four))):
        return ('%d.%d.%d.%d' % (one, two, three, four))
    else:
        return False

def get_ip_from_hex_str(data):
    if (not (isinstance(data, str) or isinstance(data, unicode))):
        raise TypeError, 'Must supply a hex string.'
    if (len(data) != 8):
        raise ValueError, 'Hex string must be in 8 characters in length'
    one = ((int(data[0], 16) * 16) + int(data[1], 16))
    two = ((int(data[2], 16) * 16) + int(data[3], 16))
    three = ((int(data[4], 16) * 16) + int(data[5], 16))
    four = ((int(data[6], 16) * 16) + int(data[7], 16))
    if validate_ipv4(('%s.%s.%s.%s' % (one, two, three, four))):
        return ('%s.%s.%s.%s' % (one, two, three, four))
    else:
        return False

def get_int_from_ip(ip):
    if (not validate_ipv4(ip)):
        raise ValueError, 'IP must be valid.'
    splitwork = ip.split('.')
    if (len(splitwork) != 4):
        return ip
    return ((((int(splitwork[0]) * (2 ** 24)) + (int(splitwork[1]) * (2 ** 16))) + (int(splitwork[2]) * (2 ** 8))) + int(splitwork[3]))

def expand_ipv6(address):
    if (not validate_ipv6(address)):
        raise ValueError, 'Address must be a IPv6 notation.'
    half = address.split('::')
    if (len(half) == 2):
        half[0] = half[0].split(':')
        half[1] = half[1].split(':')
        nodes = ((half[0] + (['0'] * (8 - (len(half[0]) + len(half[1]))))) + half[1])
    else:
        nodes = half[0].split(':')
    return ':'.join((('%04x' % int((i or '0'), 16)) for i in nodes))

def get_broadcast_from_subnet(ip, subnet):
    if (not ((type(subnet) is str) or (type(subnet) is unicode))):
        raise TypeError, 'Subnet must be a string representation.'
    if (not validate_ipv4_subnet(subnet)):
        raise TypeError, 'Subnet must be a valid subnet mask.'
    if (not ((type(ip) is str) or (type(ip) is unicode))):
        raise TypeError, 'IP must be a string representation.'
    if (not validate_ipv4(ip)):
        raise TypeError, 'IP must be a valid IP address.'
    network = get_network_from_subnet(ip, subnet)
    net_split = network.split('.')
    sub_split = subnet.split('.')
    broadcast = []
    for i in range(0, 4):
        broadcast.append(str((int(net_split[i]) | (int(sub_split[i]) ^ 255))))
    return '.'.join(broadcast)

def get_network_from_subnet(ip, subnet):
    if (not ((type(subnet) is str) or (type(subnet) is unicode))):
        raise TypeError, 'Subnet must be a string representation.'
    if (not validate_ipv4_subnet(subnet)):
        raise TypeError, 'Subnet must be a valid subnet mask.'
    if (not ((type(ip) is str) or (type(ip) is unicode))):
        raise TypeError, 'IP must be a string representation.'
    if (not validate_ipv4(ip)):
        raise TypeError, 'IP must be a valid IP address.'
    ip_split = ip.split('.')
    sub_split = subnet.split('.')
    network = []
    for i in range(0, 4):
        network.append(str((int(ip_split[i]) & int(sub_split[i]))))
    return '.'.join(network)

def validate_ipv4_subnet(subnet):
    if (not ((type(subnet) is str) or (type(subnet) is unicode))):
        raise TypeError, 'Subnet must be a string representation.'
    if (not validate_ipv4(subnet)):
        return False
    found_zero = False
    for item in subnet.split('.'):
        if ((not found_zero) and (item == '255')):
            continue
        if (found_zero and (not (item == '0'))):
            return False
        digit = int(item)
        for i in range(0, 8):
            if ((digit & (2 ** (7 - i))) == 0):
                found_zero = True
            elif found_zero:
                return False
    return True

def validate_ipv4(ip):
    if (not ((type(ip) is str) or (type(ip) is unicode))):
        raise TypeError, 'IP must be a string representation.'
    octets = ip.split('.')
    if (len(octets) != 4):
        return False
    for octet in octets:
        try:
            i = int(octet)
        except ValueError:
            return False
        if ((i < 0) or (i > 255)):
            return False
    else:
        return True

def validate_ipv6(ip):
    if (not ((type(ip) is str) or (type(ip) is unicode))):
        raise TypeError, 'IP must be a string representation.'
    nodes = ip.split('%')
    if (len(nodes) not in [1, 2]):
        return False
    addr = nodes[0]
    if (len(nodes) == 2):
        try:
            int(nodes[1])
        except ValueError:
            return False
    if (addr.count('::') > 1):
        return False
    groups = addr.split(':')
    if ((len(groups) > 8) or (len(groups) < 3)):
        return False
    for group in groups:
        if (group == ''):
            continue
        try:
            i = int(group, 16)
        except ValueError:
            return False
        if ((i < 0) or (i > 65535)):
            return False
    else:
        return True

def validate(ip):
    if (not ((type(ip) is str) or (type(ip) is unicode))):
        raise TypeError, 'IP must be a string representation.'
    if (':' in ip):
        return validate_ipv6(ip)
    elif ('.' in ip):
        return validate_ipv4(ip)
    else:
        return False

def validate_port(port):
    if (not ((type(port) is int) or (type(port) is long))):
        raise TypeError, 'Port must be an int or long representation.'
    if ((port >= 0) and (port <= 65535)):
        return True
    return False