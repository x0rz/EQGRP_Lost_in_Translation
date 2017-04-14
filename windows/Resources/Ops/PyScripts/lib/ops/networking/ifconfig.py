
import datetime
import ops.cmd
import ops
import ops.db
import ops.project
IFCONFIG_TAG = 'OPS_IFCONFIG_DATA'
MAX_CACHE_SIZE = 5

def get_ifconfig(maxage=datetime.timedelta(seconds=0), targetID=None):
    status_cmd = ops.cmd.getDszCommand('ifconfig')
    return ops.project.generic_cache_get(status_cmd, cache_tag=IFCONFIG_TAG, cache_size=MAX_CACHE_SIZE, maxage=maxage, targetID=targetID)

def get_interfaces(maxage=datetime.timedelta(0), targetID=None):
    if (targetID is None):
        targetID = ops.project.getTargetID()
    ifconfig_data = get_ifconfig(maxage=maxage, targetID=targetID)
    return ifconfig_data.interfaceitem