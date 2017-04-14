
import ops
import ops.cmd
import ops.db
import ops.project
from datetime import timedelta, datetime
import time
import ops.cmd
import ops.project
from datetime import timedelta
PASSWORDDUMP_TAG = 'OPS_PASSWORDDUMP_TAG'
MAX_CACHE_SIZE = 3

def get_passwords(maxage=timedelta(seconds=0), targetID=None, use_volatile=False, cmd_options={}):
    pwdump_cmd = ops.cmd.getDszCommand('passworddump', **cmd_options)
    retval = ops.project.generic_cache_get(pwdump_cmd, cache_tag=PASSWORDDUMP_TAG, maxage=maxage)
    return retval

def get_password_for_user(user, maxage=timedelta(seconds=0), targetID=None, use_volatile=False, cmd_options={}):
    passwords = get_passwords(maxage=maxage, targetID=targetID, use_volatile=use_volatile, cmd_options=cmd_options)
    for right_user in filter((lambda x: (x.user.lower() == user.lower())), passwords.windowspassword):
        return right_user