
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
USERS_LOCAL_TAG = 'OPS_USERS_LOCAL_TAG'
USERS_NETWORK_TAG = 'OPS_USERS_NETWORK_TAG'
GROUPS_LOCAL_TAG = 'OPS_GROUPS_LOCAL_TAG'
GROUPS_NETWORK_TAG = 'OPS_GROUPS_NETWORK_TAG'
USERGROUPS_TAG_BASE = 'OPS_USERGROUPS'
GROUPUSERS_TAG_BASE = 'OPS_GROUPUSERS'
MAX_CACHE_SIZE = 3

def get_users_local(maxage=timedelta(seconds=0), targetID=None, use_volatile=True):
    users_cmd = ops.cmd.getDszCommand('users -local')
    return ops.project.generic_cache_get(users_cmd, cache_tag=USERS_LOCAL_TAG, maxage=maxage, use_volatile=use_volatile, targetID=targetID)

def get_users_network(maxage=timedelta(seconds=0), targetID=None, use_volatile=True):
    users_cmd = ops.cmd.getDszCommand('users -network')
    return ops.project.generic_cache_get(users_cmd, cache_tag=USERS_NETWORK_TAG, maxage=maxage, use_volatile=use_volatile, targetID=targetID)

def get_groups_local(maxage=timedelta(seconds=0), targetID=None, use_volatile=True):
    groups_cmd = ops.cmd.getDszCommand('groups -local')
    return ops.project.generic_cache_get(groups_cmd, cache_tag=GROUPS_LOCAL_TAG, maxage=maxage, use_volatile=use_volatile, targetID=targetID)

def get_groups_network(maxage=timedelta(seconds=0), targetID=None, use_volatile=True):
    groups_cmd = ops.cmd.getDszCommand('groups -network')
    return ops.project.generic_cache_get(groups_cmd, cache_tag=USERS_NETWORK_TAG, maxage=maxage, use_volatile=use_volatile, targetID=targetID)

def get_groups_for_user(user, local=True, maxage=timedelta(seconds=0), targetID=None, use_volatile=True):
    groups_cmd = ops.cmd.getDszCommand('groups', local=local, network=(not local), user=user)
    local_string = ('local' if local else 'network')
    tag = ('%s_%s_%s' % (USERGROUPS_TAG_BASE, local_string.upper(), user.upper()))
    return ops.project.generic_cache_get(groups_cmd, cache_tag=tag, maxage=maxage, use_volatile=use_volatile, targetID=targetID)

def get_users_for_group(group, local=True, maxage=timedelta(seconds=0), targetID=None, use_volatile=True):
    users_cmd = ops.cmd.getDszCommand('users', local=local, network=(not local), group=group)
    local_string = ('local' if local else 'network')
    tag = ('%s_%s_%s' % (GROUPUSERS_TAG_BASE, local_string.upper(), group.upper()))
    return ops.project.generic_cache_get(users_cmd, cache_tag=tag, maxage=maxage, use_volatile=use_volatile, targetID=targetID)