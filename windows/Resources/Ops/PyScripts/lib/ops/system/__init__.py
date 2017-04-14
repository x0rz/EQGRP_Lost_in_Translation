
import datetime
import ops.cmd
import ops
import ops.db
import ops.project
import ops.processes.processlist
import ops.system.registry
import clocks

def get_uptime(targetID=None):
    procs = ops.processes.processlist.get_processlist(targetID=targetID, maxage=datetime.timedelta(seconds=60))
    for proc in procs:
        if (proc.created.time != '00:00:00'):
            (h, m, s) = (proc.created.time[0:2], proc.created.time[3:5], proc.created.time[6:8])
            (y, mo, d) = (proc.created.date[0:4], proc.created.date[5:7], proc.created.date[8:10])
            boot = datetime.datetime(int(y), int(mo), int(d), int(h), int(m), int(s))
            uptime = (clocks.gmtime() - boot)
            return uptime

def get_userprofiles_dir(targetID=None):
    return ops.system.registry.get_registrykey('L', 'Software\\Microsoft\\Windows NT\\CurrentVersion\\ProfileList', cache_tag='OPS_SYSTEM_PROFILESPATH', use_volatile=False).key[0]['ProfilesDirectory'].value