
import datetime
import ops.cmd
import ops
import ops.db
import ops.project
ROUTES_TAG = 'OPS_ROUTE_DATA'
MAX_CACHE_SIZE = 5

def get_routes(maxage=datetime.timedelta(seconds=0), targetID=None, cmd_options=dict()):
    route_cmd = ops.cmd.getDszCommand('route', query=True, **cmd_options)
    return ops.project.generic_cache_get(route_cmd, cache_tag=ROUTES_TAG, cache_size=MAX_CACHE_SIZE, maxage=maxage, targetID=targetID)