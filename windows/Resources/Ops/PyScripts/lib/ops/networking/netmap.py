
import dsz
import dsz.cmd
import dsz.version
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.project
from datetime import timedelta, datetime
import time
NETMAP_MINIMAL_TAG = 'OPS_NETMAP_MINIMAL'
MAX_CACHE_SIZE = 3

def get_minimal_netmap(maxage=timedelta(seconds=0), targetID=None, use_volatile=False, cmd_options=dict()):
    if ('minimal' in cmd_options):
        del cmd_options['minimal']
    netmap_cmd = ops.cmd.getDszCommand('netmap', minimal=True, **cmd_options)
    return ops.project.generic_cache_get(netmap_cmd, cache_tag=NETMAP_MINIMAL_TAG, maxage=maxage, use_volatile=use_volatile, targetID=targetID)

def get_netmap(maxage=timedelta(seconds=0), targetID=None, use_volatile=False, cmd_options=dict()):
    netmap_cmd = ops.cmd.getDszCommand('netmap', **cmd_options)
    if (('minimal' in cmd_options) and cmd_options['minimal']):
        return get_minimal_netmap(maxage=maxage, targetID=targetID, use_volatile=use_volatile, cmd_options=cmd_options)
    return ops.project.generic_cache_get(netmap_cmd, cache_tag=NETMAP_MINIMAL_TAG, maxage=maxage, use_volatile=use_volatile, targetID=targetID)