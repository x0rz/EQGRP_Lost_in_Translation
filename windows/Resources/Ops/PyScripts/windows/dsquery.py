
import ops.cmd, ops
import dsz.control
import datetime
import dsz.menu
from ops.pprint import pprint
import ops.menu
import util.ip
import os.path

def convertUTCtoEPOCH(msDate):
    epoc = ((msDate - 116444736000000000L) / 10000000)
    now = datetime.datetime.fromtimestamp(epoc)
    return str(now)

def getmenubool(value):
    if (value == 'Enabled'):
        return True
    else:
        return False

def getldapcount(target, filter):
    attr = 'instanceType'
    cmd = ops.cmd.getDszCommand(('ldap -target %s -scope 2 -attributes "%s"' % (target, attr)))
    cmd.arglist.append(('-filter "%s"' % filter))
    ldapobj = cmd.execute()
    count = 0
    for ldapentries in ldapobj.ldapentries:
        for ldapentry in ldapentries.ldapentry:
            count += 1
    return count

def runldap(filter=None, menu=None, attr_want_dict=None, query=None):
    optdict = menu.all_states()
    print_disk = getmenubool(optdict['Configuration']['Print to disk'])
    print_screen = getmenubool(optdict['Configuration']['Print to screen'])
    target = optdict['Configuration']['Target']
    minimal = getmenubool(optdict['Configuration']['Minimal'])
    if ('Safety' in optdict['Configuration']):
        safety = int(optdict['Configuration']['Safety'])
    else:
        safety = 0
    want_dict = None
    if (not (attr_want_dict == '*')):
        for attr_key in attr_want_dict.keys():
            if filter.lower().startswith(attr_key.lower()):
                want_dict = attr_want_dict[attr_key]
    staged = False
    if (query is None):
        query = cleanchars(filter)
    if (safety > 0):
        count = getldapcount(target, filter)
        if (count > safety):
            dsz.ui.Echo(('Count is %s, which is higher then the safety count of %s.' % (count, safety)), dsz.WARNING)
            if (not dsz.ui.Prompt('Do you want to query anyway?', False)):
                return False
            if (query in ['Query_computers', 'Query_users']):
                if dsz.ui.Prompt('Do you want to stage the query?', True):
                    staged = True
    ldap_list = []
    alpha_list = 'qwertyuiopasdfghjklzxcvbnm1234567890'
    attr_list = []
    if (((minimal == False) or (want_dict is None)) and (staged is False)):
        cmd = ops.cmd.getDszCommand(('ldap -target %s -scope 2' % target))
        cmd.arglist.append(('-filter "%s"' % filter))
        ldapobj = cmd.execute()
        (ldap_list, attr_list) = processldap(ldapobj=ldapobj, dict=want_dict)
    elif (staged is False):
        cmd = ops.cmd.getDszCommand(('ldap -target %s -scope 2 -attributes "%s"' % (target, ','.join(want_dict))))
        cmd.arglist.append(('-filter "%s"' % filter))
        ldapobj = cmd.execute()
        (ldap_list, attr_list) = processldap(ldapobj=ldapobj, dict=want_dict)
    elif (query == 'Query_computers'):
        for alpha in alpha_list:
            if ((minimal == False) or (want_dict is None)):
                cmd = ops.cmd.getDszCommand(('ldap -target %s -scope 2' % target))
                cmd.arglist.append(('-filter "(&(objectCategory=computer)(sAMAccountName=%s*))"' % alpha))
            else:
                cmd = ops.cmd.getDszCommand(('ldap -target %s -scope 2  -attributes "%s"' % (target, ','.join(want_dict))))
                cmd.arglist.append(('-filter "(&(objectCategory=computer)(sAMAccountName=%s*))"' % alpha))
            ldapobj = cmd.execute()
            (return_list, return_attr) = processldap(ldapobj=ldapobj, dict=want_dict)
            for attr in return_attr:
                if (not (attr in attr_list)):
                    attr_list.append(attr)
            ldap_list.extend(return_list)
    elif (query == 'Query_users'):
        for alpha in alpha_list:
            if ((minimal == False) or (want_dict is None)):
                cmd = ops.cmd.getDszCommand(('ldap -target %s -scope 2' % (target,)))
                cmd.arglist.append(('-filter "(&(objectCategory=Person)(objectClass=User)(sAMAccountName=%s*))"' % alpha))
            else:
                cmd = ops.cmd.getDszCommand(('ldap -target %s -scope 2 -attributes "%s"' % (target, ','.join(want_dict))))
                cmd.arglist.append(('-filter "(&(objectCategory=Person)(objectClass=User)(sAMAccountName=%s*))"' % alpha))
            ldapobj = cmd.execute()
            (return_list, return_attr) = processldap(ldapobj=ldapobj, dict=want_dict)
            for attr in return_attr:
                if (not (attr in attr_list)):
                    attr_list.append(attr)
            ldap_list.extend(return_list)
    if (len(ldap_list) > 0):
        printldaplist(ldap_list=ldap_list, print_disk=print_disk, print_screen=print_screen, key_list=attr_list, query=query)
    else:
        print 'No data returned'
    return (ldap_list, attr_list)

def cleanchars(filter):
    tmpfilter = filter
    tmpfilter = tmpfilter.replace('/', '-')
    tmpfilter = tmpfilter.replace('\\', '-')
    tmpfilter = tmpfilter.replace(':', '-')
    tmpfilter = tmpfilter.replace('*', '-')
    tmpfilter = tmpfilter.replace('?', '-')
    tmpfilter = tmpfilter.replace('"', '-')
    tmpfilter = tmpfilter.replace('>', '-')
    tmpfilter = tmpfilter.replace('<', '-')
    tmpfilter = tmpfilter.replace('|', '-')
    return tmpfilter

def queryusers(menu=None, attr_want_dict=None, query=None):
    users = dsz.ui.GetString('Enter a user id (wildcards permitted):', '*')
    runldap(filter=('(&(objectCategory=Person)(objectClass=User)(sAMAccountName=%s))' % users), menu=menu, attr_want_dict=attr_want_dict, query=query)

def querygroups(menu=None, attr_want_dict=None, query=None):
    groups = dsz.ui.GetString('Enter a group id (wildcards permitted):', '*')
    runldap(filter=('(&(objectClass=group)(sAMAccountName=%s))' % groups), menu=menu, attr_want_dict=attr_want_dict, query=query)

def querycomps(menu=None, attr_want_dict=None, query=None):
    comps = dsz.ui.GetString('Enter a computer id (wildcards permitted):', '*')
    runldap(filter=('(&(objectCategory=computer)(sAMAccountName=%s))' % comps), menu=menu, attr_want_dict=attr_want_dict, query=query)

def queryuserbygroup(menu=None, attr_want_dict=None, query=None):
    optdict = menu.all_states()
    target = optdict['Configuration']['Target']
    cmd = ops.cmd.getDszCommand(('ldap -target %s -scope 2 -filter objectClass=group -attributes distinguishedName' % target))
    ldapobj = cmd.execute()
    group_list = []
    count = 1
    for ldapentries in ldapobj.ldapentries:
        for ldapentry in ldapentries.ldapentry:
            group_list.append({'index': count, 'group': ldapentry.attribute[0].value})
            count += 1
    pprint(group_list, header=['Index', 'Group'], dictorder=['index', 'group'])
    want_list = getlist(group_list)
    if (want_list == False):
        return False
    item_list = ''
    for item in want_list:
        item_list += ('(memberOf=%s)' % item['group'])
    group_filter = ('(&(objectCategory=Person)(objectClass=User)(|%s))' % item_list)
    attr_want_dict[group_filter] = ['cn', 'givenName', 'displayName', 'name', 'whenCreated', 'whenChanged', 'lastLogon', 'logonCount', 'badPwdCount', 'pwdLastSet', 'badPasswordTime', 'lastLogonTimestamp', 'accountExpires', 'logonCount', 'managedObjects', 'memberOf']
    runldap(filter=group_filter, menu=menu, attr_want_dict=attr_want_dict, query=query)

def getlist(itemlist):
    want = ''
    want = dsz.ui.GetString('Please provide a list of indexes you would like (ex: "1,3,5-7,13") (0 quits): ', want)
    wantlist = want.split(',')
    if ('0' in wantlist):
        dsz.ui.Echo('Quitting', dsz.ERROR)
        return False
    intlist = []
    for item in wantlist:
        if (len(item.split('-')) == 2):
            itemrange = item.split('-')
            for integer in range(int(itemrange[0]), (int(itemrange[1]) + 1)):
                try:
                    intlist.append(integer)
                except:
                    continue
        else:
            try:
                intlist.append(int(item))
            except:
                continue
    outlist = []
    for item in itemlist:
        if (item['index'] in intlist):
            outlist.append(item)
    return outlist

def printldaplist(ldap_list=None, print_disk=False, print_screen=True, key_list=[], query=None):
    global out_results
    out_results = os.path.join(ops.LOGDIR, 'Logs', ('dsquery_%s_%s.csv' % (query, datetime.datetime.now().microsecond)))
    print_list = []
    if (print_screen or print_disk):
        for item in ldap_list:
            temp_item = {}
            for key in key_list:
                if (not (key in item.keys())):
                    temp_item[key] = ''
                elif (item[key] is None):
                    temp_item[key] = ''
                elif (item[key] == False):
                    temp_item[key] = 'False'
                elif (item[key] == True):
                    temp_item[key] = 'True'
                else:
                    temp_item[key] = item[key]
            print_list.append(temp_item)
    if print_screen:
        if (len(key_list) > 0):
            pprint(print_list, header=key_list, dictorder=key_list)
        else:
            pprint(print_list)
    if print_disk:
        f = open(out_results, 'w')
        f.write(('|'.join(key_list) + '\n'))
        for item in print_list:
            print_vals = []
            for key in key_list:
                print_vals.append(unicode(item[key]).encode('utf-8'))
            f.write(('|'.join(print_vals) + '\n'))
        f.close()

def processldap(ldapobj=None, dict=[]):
    dictorder = []
    ldap_list = []
    attr_list = []
    if (dict is None):
        dict = []
    for ldapentries in ldapobj.ldapentries:
        attr_dict = {}
        for ldapentry in ldapentries.ldapentry:
            attr_dict = {}
            attr_out = []
            for attribute in ldapentry.attribute:
                if ((len(dict) > 0) and (attribute.type not in dict)):
                    continue
                if (attribute.type in attr_dict.keys()):
                    if (type(attr_dict[attribute.type]) is not list):
                        attr_dict[attribute.type] = [attr_dict[attribute.type]]
                    attr_dict[attribute.type].append(attribute.value)
                elif (attribute.datatype == 10):
                    dictorder.append(attribute.type)
                    try:
                        attr_dict[attribute.type] = convertUTCtoEPOCH(int(attribute.value))
                    except:
                        attr_dict[attribute.type] = attribute.value
                else:
                    dictorder.append(attribute.type)
                    attr_dict[attribute.type] = attribute.value
            for key in dict:
                if (not (key in attr_dict.keys())):
                    attr_dict[key] = None
            for key in attr_dict:
                if (not (key in attr_list)):
                    attr_list.append(key)
            for attr in attr_dict.keys():
                if (type(attr_dict[attr]) is list):
                    attr_dict[attr] = ','.join(attr_dict[attr])
            if (len(attr_dict) > 0):
                ldap_list.append(attr_dict)
    return (ldap_list, attr_list)

def manual(menu=None, attr_want_dict=None):
    ldapquery = dsz.ui.GetString('Enter a valid ldap query: ')
    attributes = dsz.ui.GetString('Enter a comma seperated list of attributes you want (or * if you want all): ')
    if (not (attributes == '*')):
        attr_want_dict = {}
        attr_want_dict[ldapquery] = attributes.split(',')
    else:
        attr_want_dict = '*'
    return runldap(filter=ldapquery, menu=menu, attr_want_dict=attr_want_dict)

def monitor(menu=None):
    ldapquery = dsz.ui.GetString('Enter a valid ldap query: ')
    attributes = dsz.ui.GetString('Enter a comma seperated list of attributes you want to monitor (or * if you want all): ')
    monitor_dict = {'Configuration': {'Minimal': 'Enabled', 'Target': '127.0.0.1', 'Print to disk': 'Disabled', 'Print to screen': 'Disabled', 'Safety': 0}}
    output_dict = []
    while True:
        (ldap_list, attr_list) = runldap(filter=ldapquery, menu=monitor_dict, attr_want_dict=attributes.split(','))
        if (len(output_dict) == 0):
            for item in ldap_list:
                output_dict.append('|'.join(item))
        else:
            for item in ldap_list:
                if (not ('|'.join(item) in output_dict)):
                    dsz.ui.Echo(('The following item has changed: %s' % '|'.join(item)), dsz.GOOD)
                    output_dict.append('|'.join(item))
        dsz.Sleep((60 * 1000))

def main():
    attr_want_dict = {}
    attr_want_dict['objectCategory=computer'] = ['cn', 'description', 'displayname', 'name', 'whenCreated', 'whenChanged', 'lastLogon', 'logonCount', 'operatingSystem', 'operatingSystemVersion', 'operatingSystemServicePack', 'dNSHostName']
    attr_want_dict['(&(objectCategory=Person)(objectClass=User))'] = ['cn', 'givenName', 'displayName', 'name', 'whenCreated', 'whenChanged', 'lastLogon', 'logonCount', 'badPwdCount', 'pwdLastSet', 'badPasswordTime', 'lastLogonTimestamp', 'accountExpires', 'logonCount', 'managedObjects', 'memberOf']
    attr_want_dict['objectClass=group'] = ['distinguishedName', 'description', 'memberOf']
    attr_want_dict['(|(objectClass=site)(objectCategory=organizationalUnit)(objectCategory=domainDNS))'] = ['canonicalName', 'distinguishedName', 'gPLink']
    attr_want_dict['(|(objectCategory=organizationalUnit)(objectCategory=domainDNS))'] = ['canonicalName', 'distinguishedName', 'gPLink']
    attr_want_dict['objectClass=PrintQueue'] = ['distinguishedName', 'serverName', 'driverName']
    attr_want_dict['objectClass=rRASAdministrationConnectionPoint'] = ['distinguishedName', 'whenCreated', 'whenChanged']
    attr_want_dict['objectClass=site'] = ['distinguishedName', 'whenCreated', 'whenChanged']
    attr_want_dict['objectClass=trustedDomain'] = ['distinguishedName', 'trustDirection', 'trustType', 'flatName']
    attr_want_dict['objectCategory=organizationalUnit'] = ['distinguishedName', 'description', 'whenCreated', 'whenChanged']
    ops.preload('ldap')
    ds_menu = ops.menu.Menu()
    header = '===========   Dsquery (ldap)   ==========='
    header = ((((('=' * len(header)) + '\n') + header) + '\n') + ('=' * len(header)))
    ds_menu.set_heading(header)
    ds_menu.add_toggle_option(option='Print to disk', section='Configuration', state='Enabled', enabled='Enabled', disabled='Disabled')
    ds_menu.add_toggle_option(option='Print to screen', section='Configuration', state='Disabled', enabled='Enabled', disabled='Disabled')
    ds_menu.add_toggle_option(option='Minimal', section='Configuration', state='Disabled', enabled='Enabled', disabled='Disabled')
    ds_menu.add_ipv4_option(option='Target', section='Configuration', ip='127.0.0.1')
    ds_menu.add_int_option(option='Safety', section='Configuration', state=100)
    ds_menu.add_option(option='Query computers', section='Default Queries', callback=runldap, filter='objectCategory=computer', menu=ds_menu, attr_want_dict=attr_want_dict, query='Query_computers')
    ds_menu.add_option(option='Query users', section='Default Queries', callback=runldap, filter='(&(objectCategory=Person)(objectClass=User))', menu=ds_menu, attr_want_dict=attr_want_dict, query='Query_users')
    ds_menu.add_option(option='Query groups', section='Default Queries', callback=runldap, filter='objectClass=group', menu=ds_menu, attr_want_dict=attr_want_dict, query='Query_groups')
    ds_menu.add_option(option='Query audit policy w/ sites (logs to GC server)', section='Default Queries', callback=runldap, filter='(|(objectClass=site)(objectCategory=organizationalUnit)(objectCategory=domainDNS))', menu=ds_menu, attr_want_dict=attr_want_dict, query='Query_audit_policy_with_sites')
    ds_menu.add_option(option='Query audit policy w/o sites', section='Default Queries', callback=runldap, filter='(|(objectCategory=organizationalUnit)(objectCategory=domainDNS))', menu=ds_menu, attr_want_dict=attr_want_dict, query='Query_audit_policy_without_sites')
    ds_menu.add_option(option='Query printers', section='Default Queries', callback=runldap, filter='objectClass=PrintQueue', menu=ds_menu, attr_want_dict=attr_want_dict, query='Query_printers')
    ds_menu.add_option(option='Query rras', section='Default Queries', callback=runldap, filter='objectClass=rRASAdministrationConnectionPoint', menu=ds_menu, attr_want_dict=attr_want_dict, query='Query_rras')
    ds_menu.add_option(option='Query sites (logs to GC server)', section='Default Queries', callback=runldap, filter='objectClass=site', menu=ds_menu, attr_want_dict=attr_want_dict, query='Query_sites')
    ds_menu.add_option(option='Query trusts', section='Default Queries', callback=runldap, filter='objectClass=trustedDomain', menu=ds_menu, attr_want_dict=attr_want_dict, query='Query_trusts')
    ds_menu.add_option(option='Query organizational units', section='Default Queries', callback=runldap, filter='objectCategory=organizationalUnit', menu=ds_menu, attr_want_dict=attr_want_dict, query='Query_organizational_units')
    ds_menu.add_option(option='Search for computers', section='Default Searches', callback=querycomps, menu=ds_menu, attr_want_dict=attr_want_dict, query='Search_for_computers')
    ds_menu.add_option(option='Search for users', section='Default Searches', callback=queryusers, menu=ds_menu, attr_want_dict=attr_want_dict, query='Search_for_users')
    ds_menu.add_option(option='Search for groups', section='Default Searches', callback=querygroups, menu=ds_menu, attr_want_dict=attr_want_dict, query='Search_for_groups')
    ds_menu.add_option(option='Search for users by group', section='Default Searches', callback=queryuserbygroup, menu=ds_menu, attr_want_dict=attr_want_dict, query='Search_for_users_by_group')
    ds_menu.add_option(option='Manual ldap query', section='Advanced', callback=manual, menu=ds_menu)
    ds_menu.execute(exiton=[0], default=0)
    return 0
if (__name__ == '__main__'):
    try:
        main()
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)