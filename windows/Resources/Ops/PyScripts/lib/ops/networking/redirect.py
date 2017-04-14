
import ops.cmd
import ops
import glob
import os.path
from xml.etree.ElementTree import ElementTree
from xml.etree.ElementTree import Element
import dsz.version.checks.windows
import random
from ops.parseargs import ArgumentParser
import util.ip

def parse_redirect_args(arg_list=None, random=False):
    assert (type(random) == type(False)), 'Random must be a Boolean'
    assert (type(arg_list) == type([])), 'Your arg_list must be a list'
    parser = ArgumentParser()
    group_listentype = parser.add_mutually_exclusive_group(required=True)
    group_listentype.add_argument('--tcp', action='store_const', dest='protocol', const='tcp', help='Use TCP/IP as the redirection protocol')
    group_listentype.add_argument('--udp', action='store_const', dest='protocol', const='udp', help='Use UDP/IP as the redirection protocol')
    group_listenLocation = parser.add_mutually_exclusive_group(required=True)
    if random:
        group_listenLocation.add_argument('--lplisten', action='store', dest='lplisten', nargs='*', default=None, help='Listen for new connections on the LP-side (default bind=0.0.0.0).')
        group_listenLocation.add_argument('--implantlisten', action='store', dest='implantlisten', nargs='*', default=None, help='Listen for new connections on the Implant-side (default bind=0.0.0.0).')
    elif (not random):
        group_listenLocation.add_argument('--lplisten', action='store', dest='lplisten', nargs='+', default=None, help='Listen for new connections on the LP-side (default bind=0.0.0.0).')
        group_listenLocation.add_argument('--implantlisten', action='store', dest='implantlisten', nargs='+', default=None, help='Listen for new connections on the Implant-side (default bind=0.0.0.0).')
    parser.add_argument('--target', action='store', dest='target', required=True, nargs='*', help='The address / port to which data should be forwarded. NOTE: Data is always forwarded to the side opposite where the listening port is.')
    parser.add_argument('--portsharing', action='store', dest='portsharing', nargs=2, default=None, help='For use with FLAV')
    parser.add_argument('--connections', action='store', dest='connections', default=0, type=int, help='Sets the maximum number of concurrent connections allowed.(Default=0 / 0=Unlimited)')
    parser.add_argument('--limitconnections', action='store', dest='limitconnections', nargs=2, default=None, help='Limit connections to listen address to a specified IP range.')
    parser.add_argument('--sendnotify', action='store_true', dest='sendnotify', default=False, help='Send notification of target connection success / failure to connecting sockets.')
    parser.add_argument('--packetsize', action='store', dest='packetsize', default=8192, type=int, help='Sets the maximum size (in bytes) for recv/send calls.  This is of particular interest for datagram (ie, UDP) redirection (default=8192).')
    options = parser.parse_args(arg_list)
    if (options.portsharing is not None):
        assert util.ip.validate_port(options.portsharing[0]), 'clientSrcPort in portsharing must be a valid port'
        assert util.ip.validate(options.portsharing[1]), 'clientSrcAddr in portsharing must be a valid IP address'
    if (options.limitconnections is not None):
        assert util.ip.validate(options.limitconnections[0]), 'addr in limitconnections must be a valid IP address'
        assert util.ip.validate(options.limitconnections[1]), 'mask in limitconnections must be a valid IP address'
    if random:
        assert (len(options.target) in range(0, 5)), 'Target must be a list with 0-4 elements when using random.'
        for item in options.target:
            assert (util.ip.validate(item) or util.ip.validate_port(item)), 'Target items must be either a valid IP address or valid port when using random.'
    elif (not random):
        assert (len(options.target) in range(2, 5)), 'Target must be a list with 2-4 elements when not using random.'
        assert util.ip.validate(options.target[0]), 'addr in target must be a valid IP address'
        assert util.ip.validate_port(options.target[1]), 'destPort in target must be a valid IP address'
        if (len(options.target) == 3):
            assert util.ip.validate(options.target[2]), 'srcAddr in target must be a valid IP address'
        if (len(options.target) == 4):
            assert util.ip.validate_port(options.target[3]), 'srcPort in target must be a valid IP address'
    return options

def generate_tunnel_cmd(arg_list=None, random=False):
    options = parse_redirect_args(arg_list=arg_list, random=random)
    redir_cmd = ops.cmd.getDszCommand('redirect')
    redir_cmd.protocol = options.protocol
    listen_type = None
    if (options.implantlisten is not None):
        listen_type = options.implantlisten
    else:
        listen_type = options.lplisten
    if random:
        if (len(listen_type) == 0):
            listen_type = [get_random_port()]
            pass
        elif (len(listen_type) == 2):
            pass
        elif util.ip.validate(listen_type[0]):
            listen_type = [get_random_port(), listen_type[0]]
            pass
        else:
            pass
    if (options.implantlisten is not None):
        redir_cmd.implantlisten = ' '.join(listen_type)
    else:
        redir_cmd.lplisten = ' '.join(listen_type)
    if (options.portsharing is not None):
        redir_cmd.optdict['port_sharing'] = ' '.join(options.portsharing)
    if random:
        if ((len(options.target) == 0) and (options.implantlisten is not None)):
            options.target = ['127.0.0.1', listen_type[0]]
        elif (len(options.target) == 1):
            if ((not util.ip.validate(options.target[0])) and (options.implantlisten is not None)):
                options.target = ['127.0.0.1', options.target[0]]
            else:
                options.target = [options.target[0], listen_type[0]]
            pass
        elif util.ip.validate(options.target[1]):
            if (len(options.target) == 2):
                options.target = [options.target[0], listen_type[0], options.target[1]]
            else:
                options.target = [options.target[0], listen_type[0], options.target[1], options.target[2]]
            pass
        else:
            pass
    redir_cmd.target = ' '.join(options.target)
    redir_cmd.optdict['connections'] = options.connections
    if (options.limitconnections is not None):
        redir_cmd.optdict['limitconnections'] = ' '.join(options.limitconnections)
    redir_cmd.redir_notify = options.sendnotify
    redir_cmd.optdict['packetsize'] = options.packetsize
    return redir_cmd

def start_tunnel(dsz_cmd=None):
    assert verify_dsz_cmd_redirect_object(dsz_cmd), 'Given dsz_cmd must be a valid ops.cmd object for the redirect plugin.'
    tunnel = verify_tunnel(id=None, dsz_cmd=dsz_cmd, return_status=False)
    if (tunnel is not False):
        return int(tunnel.id)
    redir_obj = dsz_cmd.execute()
    if (dsz_cmd.success == 1):
        return int(redir_obj.cmdid)
    elif (dsz_cmd.success == 0):
        return get_tunnel_failure_information(id=redir_obj.cmdid)
    else:
        return False

def stop_tunnel(id=None, dsz_cmd=None):
    assert ((id is None) or (dsz_cmd is None)), 'You cannot specify both an id and a dsz_cmd.'
    assert ((id is None) and (dsz_cmd is None)), 'You must specify either id or dsz_cmd.'
    assert (type(id) is int), 'Given id must be an int.'
    assert verify_dsz_cmd_redirect_object(dsz_cmd), 'Given dsz_cmd must be a valid ops.cmd object for the redirect plugin.'
    tunnel_list = get_tunnel_list()
    for tunnel in tunnel_list:
        if (((id is not None) and (tunnel.id == id)) or ((dsz_cmd is not None) and convert_str(ops.cmd.getDszCommand(convert_str(tunnel.fullcommand))).endswith(convert_str(dsz_cmd)))):
            stop_cmd = ops.cmd.getDszCommand(('stop %s' % tunnel.id))
            stop_cmd.execute()
            if (stop_cmd.success == 1):
                return tunnel.id
            else:
                return False
    return True

def get_tunnel_failure_information(id=None):
    assert (type(id) is int), 'Given id must be an int.'
    return_errors = {'ModuleError': {'value': '', 'text': ''}, 'OsError': {'value': '', 'text': ''}}
    redir_files = glob.glob(os.path.join(ops.LOGDIR, 'Tasking', ('%05d-redirect*' % id)))
    redir_files.extend(glob.glob(os.path.join(ops.LOGDIR, 'Data', ('%05d-redirect*' % id))))
    for file in redir_files:
        tree = ElementTree()
        tree.parse(file)
        root = tree.getroot()
        for ele in root.getchildren():
            if (not (ele.tag.endswith('CommandTasking') or ele.tag.endswith('CommandData'))):
                continue
            for sub_ele in ele.getchildren():
                if (not sub_ele.tag.endswith('Errors')):
                    continue
                for error in sub_ele.getchildren():
                    if error.tag.endswith('ModuleError'):
                        return_errors['ModuleError']['value'] = error.get('value')
                        return_errors['ModuleError']['text'] = error.text
                    elif error.tag.endswith('OsError'):
                        return_errors['OsError']['value'] = error.get('value')
                        return_errors['OsError']['text'] = error.text
    return return_errors

def get_tunnel_list(remote=False):
    channels_cmd = ops.cmd.getDszCommand('commands', prefixes=['stopaliasing'], all=False, any=False, astyped=False, verbose=False, dszquiet=True, remote=remote)
    channels_data = channels_cmd.execute()
    tunnel_list = []
    for command_data in channels_data.command:
        if (convert_str(command_data.name) == 'redirect'):
            tunnel_list.append(command_data)
    return tunnel_list

def verify_remote_tunnel(id=None, return_status=False):
    assert (type(id) is int), 'Given id must be an int.'
    tunnel_list = get_tunnel_list(remote=True)
    if (len(tunnel_list) == 0):
        return False
    for tunnel in tunnel_list:
        if (tunnel.id == id):
            if return_status:
                return True
            return tunnel
    return False

def verify_local_tunnel(id=None, dsz_cmd=None, return_status=False):
    assert ((id is None) or (dsz_cmd is None)), 'You cannot specify both an id and a dsz_cmd.'
    assert ((id is None) and (dsz_cmd is None)), 'You must specify either id or dsz_cmd.'
    assert (type(id) is int), 'Given id must be an int.'
    assert verify_dsz_cmd_redirect_object(dsz_cmd), 'Given dsz_cmd must be a valid ops.cmd object for the redirect plugin.'
    tunnel_list = get_tunnel_list(remote=False)
    if (len(tunnel_list) == 0):
        return False
    for tunnel in tunnel_list:
        if (tunnel.id == id):
            if return_status:
                return True
            return tunnel
        if convert_str(ops.cmd.getDszCommand(convert_str(tunnel.fullcommand))).endswith(convert_str(dsz_cmd)):
            if return_status:
                return True
            return tunnel
    return False

def convert_str(dsz_cmd):
    return str(dsz_cmd).lower().strip()

def verify_dsz_cmd_redirect_object(dsz_cmd):
    if (not (type(dsz_cmd) == type(ops.cmd.getDszCommand('redirect')))):
        return False
    if (not (convert_str(dsz_cmd.plugin) == 'redirect')):
        return False
    return True

def verify_tunnel(id=None, dsz_cmd=None, return_status=False):
    assert ((id is None) or (dsz_cmd is None)), 'You cannot specify both an id and a dsz_cmd.'
    assert ((id is None) and (dsz_cmd is None)), 'You must specify either id or dsz_cmd.'
    assert (type(id) is int), 'Given id must be an int.'
    assert verify_dsz_cmd_redirect_object(dsz_cmd), 'Given dsz_cmd must be a valid ops.cmd object for the redirect plugin.'
    local_tunnel = verify_local_tunnel(id=id, dsz_cmd=dsz_cmd)
    if (local_tunnel is False):
        return False
    remote_tunnel = verify_remote_tunnel(id=int(local_tunnel.id))
    if (remote_tunnel is False):
        return False
    if return_status:
        return True
    return local_tunnel

def get_random_port(os=None):
    if ((os is None) or (os.lower() in ['win', 'windows'])):
        if dsz.version.checks.windows.IsVistaOrGreater():
            return str(random.randint(49152, 65535))
        else:
            return str(random.randint(1025, 5000))
    elif (os.lower() in ['linux']):
        return str(random.randint(32768, 61000))
    elif (os.lower() in ['bsd']):
        return str(random.randint(1024, 5000))
    elif (os.lower() in ['freebsd']):
        return str(random.randint(49152, 65535))
    else:
        return str(random.randint(49152, 65535))