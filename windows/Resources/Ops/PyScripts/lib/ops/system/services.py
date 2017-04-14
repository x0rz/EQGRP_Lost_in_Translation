
import dsz
import dsz.cmd
import dsz.version
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.project
from datetime import timedelta, datetime
SERVICES_TAG = 'OPS_SERVICES_TAG'
MAX_SERVICES_CACHE_SIZE = 3

def get_service_list(maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    command = ops.cmd.getDszCommand('services')
    return ops.project.generic_cache_get(command, cache_tag=SERVICES_TAG, cache_size=2, maxage=maxage, targetID=targetID, use_volatile=use_volatile).service

def get_running_services(maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    servlist = get_service_list(maxage=maxage, targetID=targetID)
    return filter((lambda x: (x.state == 'RUNNING')), servlist)