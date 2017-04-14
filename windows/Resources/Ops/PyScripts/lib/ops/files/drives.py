
import datetime
import ops.cmd
import ops.db
import ops.project
DRIVELIST_TAG = 'OPS_DRIVELIST'
MAX_DRIVELIST_CACHE_SIZE = 3
DISKSPACE_TAG_BASE = 'OPS_DISKSPACE_'
MAX_DRIVESPACE_CACHE_SIZE = 3

def get_drivelist(maxage=datetime.timedelta(seconds=0), targetID=None):
    drives_cmd = ops.cmd.getDszCommand('drives')
    return ops.project.generic_cache_get(drives_cmd, cache_tag=DRIVELIST_TAG, cache_size=MAX_DRIVELIST_CACHE_SIZE, maxage=maxage, targetID=targetID)

def get_diskspace(drive, maxage=datetime.timedelta(seconds=0), targetID=None):
    diskspace_cmd = ops.cmd.getDszCommand(('diskspace %s:\\' % drive))
    return ops.project.generic_cache_get(diskspace_cmd, cache_tag=('%s%s' % (DISKSPACE_TAG_BASE, drive.upper())), cache_size=MAX_DRIVESPACE_CACHE_SIZE, maxage=maxage, targetID=targetID).drive[0]