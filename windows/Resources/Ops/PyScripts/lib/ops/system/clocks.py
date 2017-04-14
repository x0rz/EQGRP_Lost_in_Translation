
import datetime
import ops.cmd
import ops.project
__all__ = ['gmtime', 'localtime']
TIME_TAG = 'OPS_TARGET_TIME_SKEW_INFO'

def _sync(maxage=datetime.timedelta.max, targetID=None):
    timeCmd = ops.cmd.getDszCommand('time')
    return (ops.project.generic_cache_get(timeCmd, TIME_TAG, maxage=maxage, targetID=targetID).timeitem, datetime.datetime.utcnow())

def skew(maxage=datetime.timedelta.max, targetID=None):
    (timeitem, now) = _sync(maxage, targetID)
    return timeitem.skew

def bias(maxage=datetime.timedelta.max, targetID=None):
    (timeitem, now) = _sync(maxage, targetID)
    return timeitem.friendlyBias

def gmtime(maxage=datetime.timedelta.max, targetID=None):
    (timeitem, now) = _sync(maxage, targetID)
    return (now + timeitem.skew)

def localtime(maxage=datetime.timedelta.max, targetID=None):
    (timeitem, now) = _sync(maxage, targetID)
    return ((now + timeitem.skew) + timeitem.friendlyBias)