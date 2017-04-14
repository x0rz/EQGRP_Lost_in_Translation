
import dsz, dsz.control, dsz.cmd, dsz.lp, dsz.path, dsz.env, dsz.version
import sys
import ops.data, ops.cmd
from ops.pprint import pprint
import util.mac

def arpquery(vista):
    arpcmd = ops.cmd.getDszCommand('arp', query=True)
    arpobject = arpcmd.execute()
    arp_list = []
    color_list = []
    for entry in arpobject.entry:
        oui = ''
        if (not ((entry.mac == '') or (entry.mac is None) or ((entry.mac == '00-00-00-00-00-00') or (entry.mac == '00-00-00-00-00-00-00-00-00-00-00-00-00-00')))):
            oui = util.mac.getoui(entry.mac)
            if ((oui is None) or (oui == '')):
                oui = '<unknown oui>'
        else:
            oui = '<blank mac or error>'
        if vista:
            arp_list.append({'adapter': entry.adapter, 'ip': entry.ip, 'iptype': entry.iptype, 'mac': entry.mac, 'isrouter': entry.isrouter, 'isunreachable': entry.isunreachable, 'oui': oui, 'state': entry.state})
        else:
            arp_list.append({'adapter': entry.adapter, 'type': entry.type, 'ip': entry.ip, 'mac': entry.mac, 'isrouter': entry.isrouter, 'isunreachable': entry.isunreachable, 'oui': oui})
        if (oui == '<unknown oui>'):
            color_list.append(dsz.WARNING)
        elif (oui == '<blank mac or error>'):
            color_list.append(dsz.ERROR)
        else:
            color_list.append(dsz.DEFAULT)
    if vista:
        header = ['IP', 'MAC', 'OUI', 'State', 'IPType', 'Adapter', 'IsRouter', 'IsUnreachable']
    else:
        header = ['IP', 'MAC', 'OUI', 'Type', 'Adapter', 'IsRouter', 'IsUnreachable']
    dictorder = [column.lower() for column in header]
    pprint(arp_list, header=header, dictorder=dictorder, echocodes=color_list)
    return 1

def getmaclist(args):
    mac_list = []
    for mac in args:
        if (not util.mac.validate(mac)):
            mac_list.append({'mac': mac, 'oui': 'invalid mac'})
            continue
        mac_list.append({'mac': mac, 'oui': util.mac.getoui(mac)})
    pprint(mac_list, ['MAC', 'OUI'], ['mac', 'oui'])
    return 1

def main(args):
    if (len(args) > 0):
        getmaclist(args)
        return 1
    if dsz.version.checks.windows.IsVistaOrGreater():
        arpquery(vista=True)
    else:
        arpquery(vista=False)
if (__name__ == '__main__'):
    try:
        main(sys.argv[1:])
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)