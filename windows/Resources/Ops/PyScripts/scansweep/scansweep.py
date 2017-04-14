
import dsz, dsz.lp
import sys, random, time
import ops, util.ip, ops.timehelper
import os.path
import helper, scanbase
from math import floor
from datetime import datetime
import scanengine2
import monitorengine
import exceptions

def main(arguments):
    scanbase.setup_db()
    failout = False
    scansweepHelper = helper.scansweepHelper([x.lower() for x in arguments])
    scansweepHelper.check_env()
    create_mode = False
    if (scansweepHelper.options.database is not None):
        database_op = scansweepHelper.options.database
        if (not (database_op == 'create')):
            if (scansweepHelper.options.session is not None):
                scansweepHelper.database_display(database_op)
            else:
                scansweepHelper.database_display(database_op)
            return
        else:
            create_mode = True
    if (scansweepHelper.options.update is not None):
        scansweepHelper.handleupdate()
        return
    scanbase.write_metadata(scansweepHelper.scansweep_env, scansweepHelper.session, scansweepHelper.scansweep_logfile, scansweepHelper.scansweep_results, scansweepHelper.verbose)
    if (scansweepHelper.options.exclude is not None):
        scansweepHelper.parseexcludes(scansweepHelper.options.exclude)
    if (scansweepHelper.session == scansweepHelper.scansweep_env):
        if ((scansweepHelper.options.monitor is None) and (scansweepHelper.options.type is None)):
            dsz.ui.Echo('You must specify a type.', dsz.ERROR)
            return 0
        if ((scansweepHelper.options.monitor is None) and os.path.exists(scansweepHelper.options.type[0])):
            if (scansweepHelper.options.target is not None):
                dsz.ui.Echo('You cannot use -target when specifying a queue file.', dsz.ERROR)
                return 0
            queuefile = scansweepHelper.options.type[0]
            if (not scansweepHelper.verifyqueue(queuefile)):
                failout = True
            else:
                queuelist = scansweepHelper.getqueuefromfile(queuefile)
                for item in queuelist:
                    scansweepHelper.addtoqueue(item[0], item[1], scansweepHelper.scansweep_env)
        elif (scansweepHelper.options.type is not None):
            job_type = scansweepHelper.options.type[0].lower()
            job = '|'.join(scansweepHelper.options.type)
            if (not scansweepHelper.verifyjob(job_type, scansweepHelper.options.type)):
                dsz.ui.Echo('Invalid -type options, please verify your parameters.', dsz.ERROR)
                return 0
            candidate_list = []
            if (scansweepHelper.options.target is not None):
                if (type(scansweepHelper.options.target) == type([])):
                    for target_flag in scansweepHelper.options.target:
                        candidate_list.extend(scansweepHelper.parsetarget(target_flag))
                else:
                    candidate_list = scansweepHelper.parsetarget(scansweepHelper.options.target)
            else:
                dsz.ui.Echo('You must provide some targets with your scan.', dsz.ERROR)
                return 0
            if ((len(candidate_list) > 255) and (not scansweepHelper.options.cidroverride)):
                dsz.ui.Echo('You cannot specify more then 255 targets without the -cidroverride option', dsz.ERROR)
                failout = True
            else:
                scansweepHelper.addlisttoqueue({job: candidate_list})
        if (scansweepHelper.monitor is not None):
            for monitortype in scansweepHelper.monitor:
                if (scansweepHelper.verifymonitor(monitortype) is False):
                    dsz.ui.Echo(('%s is an invalid monitor type' % monitortype))
                    failout = True
        if ((scanbase.num_jobs(scansweepHelper.session) > 255) and (not scansweepHelper.options.cidroverride)):
            dsz.ui.Echo('You cannot specify more then 255 targets without the -cidroverride option', dsz.ERROR)
            failout = True
        if (scansweepHelper.options.escalate is not None):
            rulelist = scansweepHelper.parseescalate(scansweepHelper.options.escalate)
            if (len(rulelist) == 0):
                dsz.ui.Echo('You specified -escalate, but had only invalid rules. Exiting.', dsz.ERROR)
                failout = True
            for rule in rulelist:
                scantype = rule[1].split('|')[0]
                current_rulelist = scanbase.get_escalate_rules(scansweepHelper.session)
                if (rule not in current_rulelist):
                    scanbase.write_escalate_rule(scansweepHelper.session, rule)
                if (not (scantype == 'alert')):
                    scanbase.set_jobtype(scansweepHelper.session, scantype)
    elif ((scansweepHelper.options.type is not None) or (scansweepHelper.options.target is not None)):
        dsz.ui.Echo('You cannot specify -target or -type when using -session.', dsz.WARNING)
        failout = True
    else:
        dsz.ui.Echo('You are joining another session, and so will use the already available job queue and escalate rules.', dsz.WARNING)
    if (not scansweepHelper.verifytime(scanbase.get_jobtypes(scansweepHelper.session))):
        failout = True
    if failout:
        return 0
    scansweepHelper.printconfig()
    if create_mode:
        dsz.ui.Echo('Ran in create mode. Exiting.', dsz.WARNING)
        return
    dsz.lp.RecordToolUse('scansweep', scansweepHelper.toolversion, usage='EXERCISED', comment=' '.join([x.lower() for x in arguments]))
    try:
        scan(scansweepHelper)
    finally:
        dsz.ui.Echo(('=' * 100))
        scansweepHelper.showstats()
        print '\n\n'
        scansweepHelper.generateresults(quiet=False)

def scan(scansweepHelper):
    lastresults = 0
    alreadyoutput = []
    num_remaining = scanbase.num_jobs(scansweepHelper.session)
    sanity_string = ('[%s] Sanity output: %s jobs remaining, %s-%s remaining' % (dsz.Timestamp(), num_remaining, ops.timehelper.get_age_from_seconds((num_remaining * scansweepHelper.min_seconds)), ops.timehelper.get_age_from_seconds((num_remaining * scansweepHelper.max_seconds))))
    dsz.ui.Echo(sanity_string, dsz.GOOD)
    scansweepHelper.showstats()
    if (not os.path.exists(os.path.dirname(scansweepHelper.scansweep_logfile))):
        os.mkdir(os.path.dirname(scansweepHelper.scansweep_logfile))
    with open(scansweepHelper.scansweep_logfile, 'a') as f:
        f.write(('%s\n' % sanity_string))
    delta = time.time()
    scantime = time.time()
    originaltime = time.time()
    if (scansweepHelper.monitor is not None):
        scansweepHelper.activatemonitors()
    while True:
        if ((time.time() - originaltime) > scansweepHelper.maxtime):
            dsz.ui.Echo(('Maxtime of %s has been exceeded. Exiting.' % ops.timehelper.get_age_from_seconds(scansweepHelper.maxtime)), dsz.ERROR)
            break
        scan_job = scanbase.get_job(scansweepHelper.session)
        if (scan_job == False):
            if (scansweepHelper.monitor is None):
                break
        else:
            try:
                target = scan_job[1]
                job_info = scan_job[0].split('|')
                job_type = job_info[0]
                if (not util.ip.validate(target)):
                    target = scansweepHelper.resolvehostname(target)
                if (target == None):
                    continue
                target_scanner = scanengine2.get_scanengine(scan_job, scansweepHelper.timeout)
                target_scanner.execute_scan(False)
                if target_scanner.multiple_responses:
                    multi_response = target_scanner.return_data()
                    for response in multi_response:
                        scanbase.write_result(scansweepHelper.session, response.scan_type, response.target, response.return_data(), response.success, scan_job[0])
                else:
                    scanbase.write_result(scansweepHelper.session, target_scanner.scan_type, target_scanner.target, target_scanner.return_data(), target_scanner.success, scan_job[0])
                if target_scanner.success:
                    succ_out_string = ('[%s] %s (%s jobs remaining)' % (target_scanner.timestamp, target_scanner.return_success_message(), scanbase.num_jobs(scansweepHelper.session)))
                    dsz.ui.Echo(succ_out_string)
                    with open(scansweepHelper.scansweep_logfile, 'a') as f:
                        f.write(('%s\n' % succ_out_string))
                rulelist = scanbase.get_escalate_rules(scansweepHelper.session)
                for rule in rulelist:
                    if target_scanner.check_escalation(rule[0]):
                        if (rule[1] == 'alert'):
                            if (target_scanner.success == True):
                                esc_output_string = ('[%s]\t\tAlerting on %s by rule: (%s->%s)' % (dsz.Timestamp(), target, rule[0], rule[1]))
                            else:
                                esc_output_string = ('[%s] Alerting on %s by rule: (%s->%s)' % (dsz.Timestamp(), target, rule[0], rule[1]))
                            scansweepHelper.alert(esc_output_string)
                            dsz.ui.Echo(esc_output_string, dsz.WARNING)
                        else:
                            add_succ = scansweepHelper.addtoqueue(rule[1], target, scansweepHelper.scansweep_env)
                            if ((target_scanner.success == True) and add_succ):
                                esc_output_string = ('[%s]\t\tEscalating %s by rule: (%s->%s) (%s jobs remaining)' % (dsz.Timestamp(), target, rule[0], rule[1], scanbase.num_jobs(scansweepHelper.session)))
                            elif add_succ:
                                esc_output_string = ('[%s] Escalating %s by rule: (%s->%s) (%s jobs remaining)' % (dsz.Timestamp(), target, rule[0], rule[1], scanbase.num_jobs(scansweepHelper.session)))
                            dsz.ui.Echo(esc_output_string)
                        with open(scansweepHelper.scansweep_logfile, 'a') as f:
                            f.write(('%s\n' % esc_output_string))
            except Exception as e:
                if dsz.ui.Prompt(('The current job failed for some reason. Would you like to quit? %s' % e), False):
                    break
                else:
                    continue
        if scansweepHelper.monitor:
            for monitor_handler in scansweepHelper.monitorengines:
                found_connections = monitor_handler.execute_monitor()
                for connection in found_connections:
                    rulelist = scanbase.get_escalate_rules(scansweepHelper.session)
                    for rule in rulelist:
                        if monitor_handler.check_escalation(rule[0], connection):
                            found = False
                            add_succ = True
                            if (not scansweepHelper.internaloverride):
                                for network in scansweepHelper.local_networks:
                                    if util.ip.validate_ipv6(connection.target):
                                        if (util.ip.expand_ipv6(connection.target)[:19] == network[1]):
                                            found = True
                                            break
                                    elif ((not (network[0] == '')) and (scansweepHelper.getnetwork(connection.target, util.ip.get_cidr_from_subnet(network[0])) == network[1])):
                                        found = True
                                        break
                            if ((not scansweepHelper.internaloverride) and (not found)):
                                esc_output_string = ('[%s] Escalation failed (outside subnet) %s by rule: (%s->%s) (%s jobs remaining)' % (dsz.Timestamp(), connection.target, rule[0], rule[1], scanbase.num_jobs(scansweepHelper.session)))
                                dsz.ui.Echo(esc_output_string, dsz.WARNING)
                            elif (rule[1] == 'alert'):
                                esc_output_string = ('[%s] Alerting on %s by rule: (%s->%s)' % (dsz.Timestamp(), connection.target, rule[0], rule[1]))
                                scansweepHelper.alert(esc_output_string)
                                dsz.ui.Echo(esc_output_string, dsz.WARNING)
                            else:
                                add_succ = scansweepHelper.addtoqueue(rule[1], connection.target, scansweepHelper.scansweep_env)
                                if add_succ:
                                    esc_output_string = ('[%s] Escalating %s by rule: (%s->%s) (%s jobs remaining)' % (dsz.Timestamp(), connection.target, rule[0], rule[1], scanbase.num_jobs(scansweepHelper.session)))
                                    dsz.ui.Echo(esc_output_string)
                            if add_succ:
                                with open(scansweepHelper.scansweep_logfile, 'a') as f:
                                    f.write(('%s\n' % esc_output_string))
        newdelta = time.time()
        num_remaining = scanbase.num_jobs(scansweepHelper.session)
        if ((((num_remaining % 10) == 0) and (not (num_remaining in alreadyoutput))) or ((newdelta - delta) > (5 * 60))):
            maxremaining = int((scansweepHelper.maxtime - (time.time() - originaltime)))
            sanity_string = ('[%s] Sanity output: %s jobs remaining, %s-%s remaining (max %s), %0.1fs since last sanity' % (dsz.Timestamp(), num_remaining, ops.timehelper.get_age_from_seconds((num_remaining * scansweepHelper.min_seconds)), ops.timehelper.get_age_from_seconds((num_remaining * scansweepHelper.max_seconds)), ops.timehelper.get_age_from_seconds(maxremaining), (newdelta - delta)))
            dsz.ui.Echo(sanity_string, dsz.GOOD)
            with open(scansweepHelper.scansweep_logfile, 'a') as f:
                f.write(('%s\n' % sanity_string))
            scansweepHelper.showstats()
            alreadyoutput.append(scanbase.num_jobs(scansweepHelper.scansweep_env))
            delta = newdelta
            resultstotal = 0
            type_list = scanbase.get_jobtypes(scansweepHelper.session)
            for type in type_list:
                resultstotal = (resultstotal + scansweepHelper.findlistsize(type))
            if (not (lastresults == resultstotal)):
                scansweepHelper.generateresults(quiet=True)
            lastresults = resultstotal
        if scanbase.check_kill(scansweepHelper.session):
            dsz.ui.Echo(('This session (%s) is marked for death. Exiting.' % scansweepHelper.session), dsz.ERROR)
            break
        if ((not (scanbase.num_jobs(scansweepHelper.session) == 0)) or scansweepHelper.monitor):
            sleep_in_secs = random.randint(scansweepHelper.min_seconds, scansweepHelper.max_seconds)
            if (not scansweepHelper.nowait):
                if scansweepHelper.verbose:
                    dsz.ui.Echo(('[%s] Sleeping for %s seconds...' % (dsz.Timestamp(), sleep_in_secs)))
                try:
                    dsz.Sleep((sleep_in_secs * 1000))
                except exceptions.RuntimeError as e:
                    dsz.ui.Echo(('%s' % e), dsz.ERROR)
                    break
            elif ((time.time() - scantime) < sleep_in_secs):
                nowaitsleep = int((sleep_in_secs - floor((time.time() - scantime))))
                if scansweepHelper.verbose:
                    dsz.ui.Echo(('[%s] Sleeping for %s seconds (%s seconds remain)...' % (dsz.Timestamp(), sleep_in_secs, nowaitsleep)))
                try:
                    dsz.Sleep((sleep_in_secs * 1000))
                except exceptions.RuntimeError as e:
                    dsz.ui.Echo(('%s' % e), dsz.ERROR)
                    break
            elif scansweepHelper.verbose:
                dsz.ui.Echo(('[%s] Would sleep for %s seconds but we are overdue...' % (dsz.Timestamp(), sleep_in_secs)))
            scantime = time.time()
        if scanbase.check_kill(scansweepHelper.session):
            dsz.ui.Echo(('This session (%s) is marked for death. Exiting.' % scansweepHelper.session), dsz.ERROR)
            break
if (__name__ == '__main__'):
    main(sys.argv[1:])