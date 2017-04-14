
import sys
import dsz.lp, dsz.cmd
import random
import ops.networking.redirect
import util.ip
scans = ['1', '2', '3', '5', '7', '8', '9', '10', '13', '14', '15']
scanports = [{'port': '135', 'protocol': 'rpc_tcp', 'num': '1'}, {'port': '139', 'protocol': 'rpc_nbt', 'num': '2'}, {'port': '445', 'protocol': 'rpc_smb', 'num': '3'}, {'port': '80', 'protocol': 'rpc_http', 'num': '6'}]

def main(arguments):
    if (not ((len(arguments) == 3) or (len(arguments) == 5))):
        dsz.ui.Echo('Usage: rpc <target> <type> <port> [<localtargetip> <localtargetport>]', dsz.ERROR)
        printhelp(arguments)
        return 0
    resdir = dsz.lp.GetResourcesDirectory()
    target = arguments[0]
    type = arguments[1]
    port = arguments[2]
    localtargetip = '127.0.0.1'
    localtargetport = None
    if (len(arguments) == 5):
        if (not util.ip.validate(localtargetip)):
            dsz.ui.Echo('You must enter a valid localtargetip IP address', dsz.ERROR)
            return 0
        localtargetip = arguments[3]
        localtargetport = arguments[4]
    ourscan = None
    if (not (type in scans)):
        dsz.ui.Echo('You must enter a valid scan type', dsz.ERROR)
        printhelp(arguments)
        return 0
    for thisport in scanports:
        if (port == thisport['port']):
            ourscan = thisport
    if (ourscan is None):
        dsz.ui.Echo('You must enter a valid port', dsz.ERROR)
        printhelp(arguments)
        return 0
    if (not util.ip.validate(target)):
        dsz.ui.Echo('You must enter a valid target IP address', dsz.ERROR)
        return 0
    if ((type == '15') and (not ((port == '139') or (port == '445')))):
        dsz.ui.Echo('You must use port 139 or 445 with ELV touch', dsz.ERROR)
        return 0
    tunnel_port = None
    if (localtargetport is None):
        redir_cmd = startredir(localtargetport, target, port)
        if (redir_cmd is False):
            dsz.ui.Echo('Unknown error starting tunnel', dsz.ERROR)
            return 0
        tunnel_port = redir_cmd.listen_port
    else:
        tunnel_port = localtargetport
    dsz.ui.Echo(('RPCTOUCH (type %s, %s) on %s' % (type, port, target)))
    if (type == '15'):
        PATH_TO_ELV = ('%s\\LegacyWindowsExploits\\Exploits\\ELV 2.1.3\\ELV.exe' % resdir)
        cmd = ('log local run -command "%s -i %s -p %s -r 2 -t 1 -b %s -o 60 -rpc -h %s" -redirect' % (PATH_TO_ELV, localtargetip, tunnel_port, ourscan['num'], target))
        (scansucc, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
        if (not scansucc):
            dsz.ui.Echo('ELV failed', dsz.ERROR)
    else:
        PATH_TO_RPC = ('%s\\Ops\\Tools\\RPC2.exe' % resdir)
        cmd = ('log local run -command "%s -i %s -p %s -r %s -t 1 -b %s -h %s" -redirect' % (PATH_TO_RPC, localtargetip, tunnel_port, type, ourscan['num'], target))
        (scansucc, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
        if (not scansucc):
            dsz.ui.Echo('RPC2 failed', dsz.ERROR)
    if (localtargetport is None):
        ops.networking.redirect.stop_tunnel(dsz_cmd=redir_cmd)

def startredir(redirport, target, port):
    for i in range(0, 5):
        arg_list = ['-tcp', '-target', target, port, '-lplisten']
        if (redirport is not None):
            arg_list.append(redirport)
        redir_cmd = ops.networking.redirect.generate_tunnel_cmd(arg_list=arg_list, random=True)
        redir_output = ops.networking.redirect.start_tunnel(dsz_cmd=redir_cmd)
        if ((redir_output is not False) and (type(redir_output) is int)):
            return redir_cmd
    return False

def printhelp(args):
    dsz.ui.Echo('Usage: rpc <IP to scan> <probeType> <portTypes> [<localtargetip> <localtargetport>]')
    dsz.ui.Echo(' probeType: \n\t1=General\n\t2=RegProbe\n\t3=XP Home/Pro\n\t4=Atsvc port req.\n\t5=W2K SP4 Atsvc\n\t7=probe for DCOM patches\n\t8=W2K3\n\t9=MGMT Probe\n\t10=EPMP Probe\n\t13=W2K3 SP0\n\t14=64-BIT\n\t15=ELV probe')
    dsz.ui.Echo(' portTypes: 135, 139, 445, 80')
    dsz.ui.Echo(' localtargetip: causes no tunnel to be opened and for the rpc scan to go against this real IP, usually the Linux station')
    dsz.ui.Echo(' localtargetport: used with localtargetip to specify the port to hit, usually the entrance to your tunnel')
    dsz.ui.Echo((' You provided %s arguments' % len(args)))

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