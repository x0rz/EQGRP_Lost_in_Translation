
import dsz
import dsz.cmd
import dsz.version
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.project
from datetime import timedelta, datetime
NT_CURRENT_VERSION_KEY = 'WINDOWS_NT_CURRENTVERSION_REG_KEY_TAG'

def get_registrykey(hive, keyname, cache_tag='', cache_size=2, maxage=timedelta(seconds=0), targetID=None, use_volatile=False, **cmdargs):
    reg_cmd = ops.cmd.getDszCommand('registryquery', hive=hive, key=keyname, **cmdargs)
    return ops.project.generic_cache_get(reg_cmd, cache_tag=cache_tag, cache_size=cache_size, maxage=maxage, targetID=targetID)