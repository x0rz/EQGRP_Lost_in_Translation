
from datetime import timedelta
import ops.cmd
import ops
import ops.db
import ops.project
ARP_MONITOR_TAG = 'OPS_ARP_MONITOR'
ARP_QUERY_TAG = 'OPS_ARP_QUERY'
NETSTAT_MONITOR_TAG = 'OPS_NETCONNECTIONS_MONITOR'
NETSTAT_PIPES_LIST_TAG = 'OPS_NETCONNECTIONS_PIPELIST'
MAX_CACHE_SIZE = 1

def get_arp_cache(maxage=timedelta(0), targetID=None, use_volatile=False, cmd_options=dict()):
    arp_cmd = ops.cmd.getDszCommand('arp', query=True, **cmd_options)
    try:
        arp_data = ops.project.generic_cache_get(arp_cmd, maxage=maxage, cache_tag=ARP_QUERY_TAG, targetID=targetID, use_volatile=False)
    except:
        raise ops.cmd.OpsCommandException('ARP command failed, probably because of no ARP data returned')
    return arp_data

def get_all_netconnections(maxage=timedelta(seconds=0), targetID=None, use_volatile=False, cmd_options=dict()):
    pass

def get_current_netconnections(maxage=timedelta(seconds=0), targetID=None, use_volatile=False, cmd_options=dict()):
    pass

def get_listeners(maxage=timedelta(seconds=0), targetID=None, use_volatile=False, cmd_options=dict()):
    pass

def get_pipes(maxage=timedelta(seconds=0), targetID=None, use_volatile=False, cmd_options=dict()):
    pipes_cmd = ops.cmd.getDszCommand('netconnections', complexity='PipesOnly', **cmd_options)
    return ops.project.generic_cache_get(pipes_cmd, maxage=maxage, cache_tag=NETSTAT_PIPES_LIST_TAG, targetID=targetID)