
import dsz
import dsz.cmd
import dsz.version
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.project
import ops.system.systemversion
from datetime import timedelta, datetime
SCHEDULER_TAG_BASE = 'OPS_SCHEDULER'
MAX_SCHEDULER_CACHE_SIZE = 3

def get_all_schedulers_local(maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    gui_command = ops.cmd.getDszCommand('scheduler', query='gui')
    at_command = ops.cmd.getDszCommand('scheduler', query='at')
    srv_command = ops.cmd.getDszCommand('scheduler', query='service')
    sysver = ops.system.systemversion.get_os_version(maxage=timedelta(seconds=86400))
    srv_tagname = ('%s_SERVICE' % SCHEDULER_TAG_BASE)
    gui_tagname = ('%s_GUI' % SCHEDULER_TAG_BASE)
    at_tagname = ('%s_AT' % SCHEDULER_TAG_BASE)
    retval = {}
    try:
        retval['gui'] = ops.project.generic_cache_get(gui_command, cache_tag=gui_tagname, cache_size=MAX_SCHEDULER_CACHE_SIZE, maxage=maxage, targetID=targetID, use_volatile=use_volatile)
    except:
        ops.warn('Unable to get "gui" scheduler data')
    if ((sysver.versioninfo.major <= 6) and (sysver.versioninfo.minor < 2)):
        try:
            retval['at'] = ops.project.generic_cache_get(at_command, cache_tag=at_tagname, cache_size=MAX_SCHEDULER_CACHE_SIZE, maxage=maxage, targetID=targetID, use_volatile=use_volatile)
        except:
            ops.warn('Unable to get "at" scheduler data')
    if (sysver.versioninfo.major > 5):
        try:
            retval['service'] = ops.project.generic_cache_get(srv_command, cache_tag=srv_tagname, cache_size=MAX_SCHEDULER_CACHE_SIZE, maxage=maxage, targetID=targetID, use_volatile=use_volatile)
        except:
            ops.warn('Unable to get "service" scheduler data')
    return retval

def get_scheduler_list_local(querygroup, maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    command = ops.cmd.getDszCommand('scheduler', query=querygroup)
    tagname = ('%s_%s' % (SCHEDULER_TAG_BASE, querygroup.upper()))
    return ops.project.generic_cache_get(command, cache_tag=tagname, cache_size=MAX_SCHEDULER_CACHE_SIZE, maxage=maxage, targetID=targetID, use_volatile=use_volatile)

def get_scheduler_list_remote(querygroup, targetIP, maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    command = ops.cmd.getDszCommand('scheduler', query=query)
    tagname = ('%s_%s' % (SCHEDULER_TAG_BASE, query.upper()))
    return ops.project.generic_cache_get(command, cache_tag=SERVICES_TAG, cache_size=MAX_SCHEDULER_CACHE_SIZE, maxage=maxage, targetID=targetID, use_volatile=use_volatile)