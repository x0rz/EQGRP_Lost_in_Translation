
import codecs
import datetime
import ntpath
import re
import ops.project
HANDLES_TAG = 'OPS_VOLATILE_HANDLES_CACHE_id_%s_all_%s_memory_%s'

def handles(id=None, all=False, memory=None, maxage=datetime.timedelta(seconds=0), cache_tag=None):
    if (cache_tag is None):
        cache_tag = (HANDLES_TAG % (id, all, memory))
    return ops.project.generic_cache_get(ops.cmd.getDszCommand('handles', all=all, id=id, memory=memory), cache_tag=cache_tag, maxage=maxage, use_volatile=True)

def grep_handles(pattern, id=None, all=False, memory=None, regex=False, any=False, maxage=datetime.timedelta(minutes=10), cache_tag=None):
    if (len(pattern) < 1):
        raise RuntimeError, 'Empty strings are not valid matching criteria.'
    pattern = re.sub('^(?i)(\\w:\\\\){1}', '', pattern)
    data = handles(id=id, all=all, memory=memory, maxage=maxage, cache_tag=cache_tag)
    if (data is None):
        return None
    elif (data.commandmetadata.status != 0):
        return data.commandmetadata.cmdid
    if (not regex):
        pattern = re.escape(pattern)
    regex = re.compile(pattern, re.IGNORECASE)
    found = []
    for proc in data.process:
        for handle in proc.handle:
            if ((not any) and (handle.type.lower() != 'file')):
                continue
            match = False
            if regex.search(handle.metadata):
                found.append({'process': proc.id, 'handle': handle.id, 'name': handle.metadata, 'type': handle.type})
    return found