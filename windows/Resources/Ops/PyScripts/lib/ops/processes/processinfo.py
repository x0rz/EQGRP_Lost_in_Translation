
import datetime
import ops.cmd
import ops
import ops.db
import ops.project
PROCESSINFO_TAG_BASE = 'OPS_PROCESSINFO_'
MAX_CACHE_SIZE = 3

def get_processinfo(pid, maxage=datetime.timedelta(seconds=0), targetID=None, **kwargs):
    pinfo_cmd = ops.cmd.getDszCommand('processinfo', id=pid, **kwargs)
    cache_tag = ('%s%s' % (PROCESSINFO_TAG_BASE, pid))
    return ops.project.generic_cache_get(pinfo_cmd, cache_tag=cache_tag, cache_size=MAX_CACHE_SIZE, maxage=maxage, targetID=targetID, use_volatile=True)