
import os
import ops
import re
from sqlite3 import connect

def getoui(mac):
    norm_mac = normalize(mac, sep=None, case='upper')
    assert validate_ethii(norm_mac), 'MAC address must be valid'
    if norm_mac.startswith('0050C2'):
        oui = norm_mac[0:9]
        conn = connect(os.path.join(ops.OPSDIR, 'Databases', 'macs.db'))
        curs = conn.cursor()
        curs.execute(("select description from iabinformation where oui like '%s%%'" % oui))
        out = curs.fetchone()
    else:
        oui = norm_mac[0:6]
        conn = connect(os.path.join(ops.OPSDIR, 'Databases', 'macs.db'))
        curs = conn.cursor()
        curs.execute(("select description from arpinformation where oui like '%s%%'" % oui))
        out = curs.fetchone()
    if (out is not None):
        return out[0]
    else:
        return None

def normalize(mac, sep=None, case='lower', partial=False):
    assert ((type(mac) is str) or (type(mac) is unicode)), 'MAC must be a string representation.'
    assert ((case.lower() == 'lower') or (case.lower() == 'upper') or (case.lower() == 'none')), "Case must be 'lower' or 'upper' or 'none'."
    assert ((sep is None) or (len(sep) == 1)), 'Sep must be a single character or None.'
    for char in ['.', ':', '-', ' ']:
        mac = mac.replace(char, '')
    if (not partial):
        assert (len(mac) == 12), ("Stripped MAC ('%s') must be 12 characters in length." % mac)
    if (sep is not None):
        mac_pair = []
        for i in range(0, len(mac), 2):
            mac_pair.append(''.join([mac[i], mac[(i + 1)]]))
        mac = sep.join(mac_pair)
    if (case.lower() == 'lower'):
        return mac.lower()
    elif (case.lower() == 'upper'):
        return mac.upper()
    else:
        return mac

def validate_ethii(mac):
    assert ((type(mac) is str) or (type(mac) is unicode)), 'MAC must be a string representation.'
    assert (len(mac) == 12), 'Ethernet II MAC must be 12 characters in length'
    mac_re = re.compile('([0123456789ABCDEF]{2}){6}', re.IGNORECASE)
    if (not mac_re.match(mac)):
        return False
    else:
        return True

def validate(mac):
    assert ((type(mac) is str) or (type(mac) is unicode)), 'MAC must be a string representation.'
    norm_mac = normalize(mac)
    return validate_ethii(norm_mac)