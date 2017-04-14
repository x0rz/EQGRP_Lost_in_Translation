
import dsz
import dsz.cmd
import dsz.version
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.project
from datetime import timedelta, datetime
ENVIRONMENT_TAG = 'OPS_ENVIRONMENT_TAG'
MAX_CACHE_SIZE = 3

def get_environment(cache_size=MAX_CACHE_SIZE, maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    env_cmd = ops.cmd.getDszCommand('environment -get')
    return ops.project.generic_cache_get(env_cmd, cache_tag=ENVIRONMENT_TAG, cache_size=MAX_CACHE_SIZE, maxage=maxage, targetID=targetID, use_volatile=use_volatile)

def get_environment_var(varname, maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    env = get_environment(maxage=maxage, targetID=targetID, use_volatile=use_volatile)
    for evar in env.environment.value:
        if (evar.name.lower() == varname.lower()):
            return evar
    return None