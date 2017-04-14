
import dsz
import dsz.cmd
import dsz.path
import dsz.version
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.project
import ntpath
from datetime import timedelta, datetime

def get_dirlisting(path, cache_tag='', cache_size=2, maxage=timedelta(seconds=0), targetID=None, **cmdargs):
    dir_cmd = ops.cmd.getDszCommand('dir', path=path, **cmdargs)
    return ops.project.generic_cache_get(dir_cmd, cache_tag=cache_tag, cache_size=cache_size, maxage=maxage, targetID=targetID)