
from math import floor
import util.ip, util.mac
import dsz, dsz.ui
import os.path
import ops.env, ops, ops.cmd, ops.project
import re
import subprocess
import random
import scanbase
from ops.pprint import pprint
import glob
import ops.networking.ifconfig
import exceptions
from ops.parseargs import ArgumentParser
from datetime import datetime
import scanengine2, monitorengine

class scansweepHelper(object, ):

    def __init__(self, arguments):
        self.DEBUG = False
        self.ipv6 = False
        self.toolversion = '5.0.7'
        self.options = self.parse_scansweep(arguments)
        self.scansweep_env = ('scansweep_%s' % dsz.Timestamp())
        self.session = self.scansweep_env
        if (self.options.session is not None):
            self.session = self.options.session
        try:
            os.makedirs(os.path.join(ops.LOGDIR, 'Logs'))
        except WindowsError:
            pass
        self.scansweep_logfile = os.path.join(ops.LOGDIR, 'Logs', ('%s_log_out.txt' % self.scansweep_env))
        self.scansweep_results = os.path.join(ops.LOGDIR, 'Logs', ('%s_results_out.txt' % self.scansweep_env))
        self.scansweep_queuefile = os.path.join(ops.LOGDIR, 'Logs', ('%s_queue_out.txt' % self.scansweep_env))
        if (self.options.update is not None):
            self.scansweep_updatefile = self.options.update
        self.verbose = self.options.verbose
        self.nowait = self.options.nowait
        self.timeout = self.options.timeout
        self.override = self.options.override
        self.cidroverride = self.options.cidroverride
        if (self.options.database is None):
            self.local_addresses = self.get_local_addresses()
            self.local_networks = self.get_local_networks()
        else:
            self.local_addresses = None
            self.local_networks = None
        self.kill = scanbase.get_metadata(self.scansweep_env, 'kill')
        (self.min_seconds, self.max_seconds) = self.options.period
        if (self.options.type is not None):
            self.scan_type = self.options.type[0].lower()
        else:
            self.scan_type = None
        if (self.options.monitor is not None):
            self.monitor = []
            for item in self.options.monitor:
                if (type(item) == type('')):
                    self.monitor.append(item.lower())
        else:
            self.monitor = None
        self.maxtime = self.options.maxtime[0]
        self.internaloverride = self.options.internaloverride
        self.colorseed = 0
        self.monitorengines = []

    def check_env(self):
        env_out = ops.cmd.getDszCommand('local environment -get -var PATH').execute()
        path = env_out.environment.value[0].value.strip()
        fixed_path = os.path.join(ops.DSZDISKSDIR, 'lib', 'x86-Windows').replace('\\', '\\\\')
        if (re.search(fixed_path, path) is None):
            env_cmd = ops.cmd.getDszCommand('local environment')
            env_cmd.arglist.append('-var PATH')
            env_cmd.arglist.append(('-set "%s;%s"' % (path, os.path.join(ops.DSZDISKSDIR, 'lib', 'x86-Windows'))))
            env_cmd.execute()

    def activatemonitors(self):
        for monitor_type in self.monitor:
            self.monitorengines.append(monitorengine.get_monitorengine([monitor_type]))

    def display_escalate_rules(self):
        rule_list = scanbase.get_escalate_rules(self.session)
        for rule in rule_list:
            dsz.ui.Echo(('%s->%s' % (rule[0], rule[1])))
        return

    def generateresults(self, quiet=False):
        f = open(self.scansweep_results, 'w')
        f.write('')
        f.close()
        type_list = scanbase.get_jobtypes(self.session)
        for key in type_list.keys():
            returned_results = scanbase.get_results(self.session, key)
            results = [x['data'] for x in returned_results]
            target_scanner = scanengine2.get_scanengine([key])
            self.printresults(key, results, target_scanner.get_display_headers(), target_scanner.get_data_fields(), 'sort_field', sort2=None, quiet=quiet)

    def printresults(self, name, dict, titles, keys, sort1, sort2=None, quiet=False):
        bannerstring = ('========== %s Results ==============' % name)
        bannerhead = (len(bannerstring) * '=')
        if (not quiet):
            dsz.ui.Echo(bannerhead, dsz.GOOD)
            dsz.ui.Echo(bannerstring, dsz.GOOD)
            dsz.ui.Echo(bannerhead, dsz.GOOD)
        if (len(dict) > 0):
            dict.sort(key=(lambda x: x[sort1]))
            if (not (sort2 == None)):
                dict.sort(key=(lambda x: x[sort2]))
            if (not quiet):
                pprint(dict, titles, keys)
            pprint(dict, titles, keys, print_handler=self.pprintout)
        else:
            with open(self.scansweep_results, 'a') as f:
                f.write(('No %s data was returned\n' % name))
            if (not quiet):
                dsz.ui.Echo(('No %s data was returned' % name), dsz.WARNING)
        with open(self.scansweep_results, 'a') as f:
            f.write('\n\n')
        if (not quiet):
            print '\n\n'

    def writequeuetofile(self):
        dsz.ui.Echo(('Writing queue file to disk: %s' % self.scansweep_queuefile))
        f = open(self.scansweep_queuefile, 'w')
        job_list = scanbase.list_jobs(self.session)
        for item in job_list:
            if ((not item.has_key('port_type')) or (item['port_type'] is None)):
                f.write(('%s %s\n' % (item['job'], item['target'])))
            elif ((not item.has_key('port')) or (item['port'] is None)):
                f.write(('%s|%s %s\n' % (item['job'], item['port_type'], item['target'])))
            else:
                f.write(('%s|%s|%s %s\n' % (item['job'], item['port_type'], item['port'], item['target'])))
        f.close()

    def pprintout(self, stringtoprint, end):
        with open(self.scansweep_results, 'a') as f:
            f.write(('%s\n' % stringtoprint))

    def showstats(self, session_to_display=None, screenonly=False):
        if (session_to_display is None):
            session_to_display = self.session
        header_list = ['*INFO*']
        dictorder = ['name']
        output_dict = {'queued': {'name': 'Queued', 'total': 0}, 'running': {'name': 'Running', 'total': 0}, 'attempted': {'name': 'Attempted', 'total': 0}, 'results': {'name': 'Results', 'total': 0}}
        job_info = scanbase.all_num_jobs(session_to_display)
        job_types = []
        for job in job_info:
            if (not (job['type'] in job_types)):
                job_types.append(job['type'])
                output_dict['attempted'][job['type']] = 0
                output_dict['running'][job['type']] = 0
                output_dict['queued'][job['type']] = 0
            if (job['complete'] == 'True'):
                output_dict['attempted'][job['type']] += 1
            elif (job['inprogress'] == 'True'):
                output_dict['running'][job['type']] += 1
            else:
                output_dict['queued'][job['type']] += 1
        for type in job_types:
            output_dict['results'][type] = self.findlistsize(type, session=session_to_display)
            output_dict['queued']['total'] += output_dict['queued'][type]
            output_dict['running']['total'] += output_dict['running'][type]
            output_dict['attempted']['total'] += output_dict['attempted'][type]
            output_dict['results']['total'] += output_dict['results'][type]
        for type in ['arp', 'ping', 'netbios', 'banner', 'rpc2', 'scanner', 'rpctouch', 'smbtouch']:
            if (type in job_types):
                dictorder.append(type)
                header_list.append(type)
                job_types.remove(type)
        for type in job_types:
            dictorder.append(type)
            header_list.append(type)
        dictorder.append('total')
        header_list.append('TOTAL')
        pprint([output_dict['queued'], output_dict['running'], output_dict['attempted'], output_dict['results']], header=header_list, dictorder=dictorder)
        if (not screenonly):
            pprint([output_dict['queued'], output_dict['running'], output_dict['attempted'], output_dict['results']], header=header_list, dictorder=dictorder, print_handler=self.pprintout)

    def printconfig(self):
        escalate = scanbase.check_escalation(self.session)
        rulelist = scanbase.get_escalate_rules(self.session)
        type_list = scanbase.get_jobtypes(self.session)
        dsz.ui.Echo(('=' * 100))
        dsz.ui.Echo(('Environment: %s' % self.scansweep_env))
        dsz.ui.Echo(('Session: %s' % self.session))
        if self.override:
            dsz.ui.Echo('Override: Enabled', dsz.WARNING)
        else:
            dsz.ui.Echo('Override: Disabled')
        if self.cidroverride:
            dsz.ui.Echo('Cidroverride: Enabled', dsz.WARNING)
        else:
            dsz.ui.Echo('Cidroverride: Disabled')
        if self.internaloverride:
            dsz.ui.Echo('Internaloverride: Enabled', dsz.WARNING)
        else:
            dsz.ui.Echo('Internaloverride: Disabled')
        if self.verbose:
            dsz.ui.Echo('Verbosity: Enabled', dsz.WARNING)
        else:
            dsz.ui.Echo('Verbosity: Disabled')
        if scanbase.check_escalation(self.session):
            dsz.ui.Echo('Escalation: Enabled', dsz.WARNING)
        else:
            dsz.ui.Echo('Escalation: Disabled')
        for rule in rulelist:
            dsz.ui.Echo(('\tEscalation rule enabled: %s->%s' % (rule[0], rule[1])))
        self.printflav()
        dsz.ui.Echo(('Log file: %s' % self.scansweep_logfile))
        dsz.ui.Echo(('Output file: %s' % self.scansweep_results))
        dsz.ui.Echo(('=' * 100))

    def display_excludes(self):
        excludes = scanbase.get_excludes(self.session)
        for target in excludes:
            dsz.ui.Echo(target)

    def addlisttoqueue(self, target_dict):
        excludes = scanbase.get_excludes(self.session)
        for rule in target_dict.keys():
            target_list = target_dict[rule]
            job = rule.strip().split(' ')[0]
            job_type = job.split('|')[0].lower()
            job_info = job.split('|')
            while (len(job) < 3):
                job_info.append('')
            if (not self.verifyjob(job_type, job_info)):
                continue
            job_list = []
            for target in target_list:
                if (util.ip.validate_ipv6(target) and (not self.ipv6)):
                    dsz.ui.Echo(('Target %s is an IPv6 address; redirector has no IPv6 address, not queueing' % (target, job_type)), dsz.WARNING)
                    return False
                if (util.ip.validate_ipv6(target) and (not self.supportipv6(job_type))):
                    dsz.ui.Echo(('Target %s is an IPv6 address; %s does not support IPv6, not queueing' % (target, job_type)), dsz.WARNING)
                    return False
                if (target in self.local_addresses):
                    dsz.ui.Echo(('Target %s is one of the IP addresses on our redirector, not queueing' % target), dsz.WARNING)
                    continue
                elif (util.ip.validate_ipv6(target) and (util.ip.expand_ipv6(target) in self.local_addresses)):
                    dsz.ui.Echo(('Target %s is one of the IP addresses on our redirector, not queueing' % target), dsz.WARNING)
                    continue
                if (target in excludes):
                    continue
                job_list.append([job, target])
            scanbase.set_jobtype(self.session, job_type)
            scanbase.write_job_list(self.session, job_list)

    def addtoqueue(self, rule, target, remove=False):
        success = False
        target = target.encode('ascii')
        job = rule.strip().split(' ')[0]
        job_type = job.split('|')[0].lower()
        job_info = job.split('|')
        while (len(job) < 3):
            job_info.append('')
        if (not self.verifyjob(job_type, job_info)):
            return success
        if (util.ip.validate_ipv6(target) and (not self.ipv6)):
            dsz.ui.Echo(('Target %s is an IPv6 address; redirector has no IPv6 address, not queueing' % (target, job_type)), dsz.WARNING)
            return False
        if (util.ip.validate_ipv6(target) and (not self.supportipv6(job_type))):
            dsz.ui.Echo(('Target %s is an IPv6 address; %s does not support IPv6, not queueing' % (target, job_type)), dsz.WARNING)
            return False
        if (target in self.local_addresses):
            dsz.ui.Echo(('Target %s is one of the IP addresses on our redirector, not queueing' % target), dsz.WARNING)
            return False
        elif (util.ip.validate_ipv6(target) and (util.ip.expand_ipv6(target) in self.local_addresses)):
            dsz.ui.Echo(('Target %s is one of the IP addresses on our redirector, not queueing' % target), dsz.WARNING)
            return False
        excludes = scanbase.get_excludes(self.session)
        if (target in excludes):
            return False
        success = scanbase.write_job(self.session, job, target)
        scanbase.set_jobtype(self.session, job_type)
        if (not success):
            dsz.ui.Echo(('Job %s for target %s already exists' % (job, target)), dsz.WARNING)
        return success

    def findlistsize(self, type, session=None):
        if (session is None):
            session = self.session
        return scanbase.num_results(session, type, True)

    def resolvehostname(self, target):
        cmd = ops.cmd.getDszCommand(('nameserverlookup %s' % target))
        obj = cmd.execute()
        if (obj is None):
            return False
        for hostinfo in obj.hostinfo:
            if util.ip.validate_ipv4(hostinfo.info):
                dsz.ui.Echo(('[%s] Resolution successful: %s to %s' % (dsz.Timestamp(), target, hostinfo.info.strip())), dsz.WARNING)
                return hostinfo.info.strip()
        dsz.ui.Echo(('[%s] Resolution failed: %s' % (dsz.Timestamp(), target)), dsz.WARNING)
        return None

    def scansweep_argparser(self):
        parser = ArgumentParser(version=self.toolversion, description='scansweep does automated scanning through DSZ')
        group_types = parser.add_argument_group('Type flags', 'These flags determine what job types scansweep executes')
        group_types.add_argument('--type', action='store', dest='type', nargs='+', help='Type of scan to conduct, or a queue file containing line seperated (job ip,ip,ip,...) entries')
        group_types.add_argument('--escalate', action='store', dest='escalate', nargs='*', help='Escalate when a arp/ping is found, [rule] replaces this and can be a list of rules or a file')
        group_types.add_argument('--monitor', action='store', dest='monitor', nargs='+', help='Type of monitors to parse, then apply escalation rules, if there are any defined.')
        group_target = parser.add_argument_group('Target input flags', 'These flags determine what targets scansweep executes against')
        group_target.add_argument('--target', action='store', dest='target', nargs='+', metavar='ip,ip-ip,ip/net,ip/netmask,file,host', help='Specification of targets to scan')
        group_target.add_argument('--exclude', action='store', dest='exclude', nargs='+', metavar='ip,ip-ip,ip/net,ip/netmask,file,host', help='Specification of targets NOT to scan')
        group_target.add_argument('--cidroverride', action='store_true', dest='cidroverride', default=False, help='Override the safety restriction of maximum of 255 hosts')
        group_target.add_argument('--internaloverride', action='store_true', dest='internaloverride', default=False, help='Override the safety restriction for monitor tasking, which by default disallows escalating outside our current subnet')
        group_time = parser.add_argument_group('Timing flags', 'These flags adjust how fast or slow scansweep executes')
        group_time.add_argument('--period', action='store', dest='period', default='15s-45s', type=ops.timehelper.parse_interval_string, metavar='Xs-Xm', help='Period at which to run the command (ex. 30s 10-20m) (default: 15s-45s)')
        group_time.add_argument('--maxtime', action='store', dest='maxtime', default='4h', type=ops.timehelper.parse_interval_string, metavar='Xh', help='Maximum time for the command to run (ex. 30s 10-20m) (default: 4h)')
        group_time.add_argument('--nowait', action='store_true', dest='nowait', default=False, help='Toggles counting since beginning of last scan rather then the end of last scan')
        group_time.add_argument('--timeout', action='store', dest='timeout', type=int, metavar='XX', help='Sets the timeout in seconds to pass to a command (used in ping, banner, rpctouch, smbtouch, rpc2)')
        group_time.add_argument('--override', action='store_true', dest='override', default=False, help='Override the safety restriction of 15s minimum scan range on ping and netbios')
        group_database = parser.add_argument_group('Database flags', 'These advanced flags allow you to work with the database')
        group_database.add_argument('--database', action='store', dest='database', choices=['sessions', 'jobs', 'results', 'dump', 'reset', 'kill', 'rules', 'excludes', 'create', 'reescalate'], help='Allows dumping of database info')
        group_database.add_argument('--session', action='store', dest='session', metavar='scansweep_YYYY_MM_DD_HHhMMmSSs.XXX', help='Allows you to re-use an old incomplete scan or to "join" another scan')
        group_database.add_argument('--update', action='store', dest='update', metavar='updatefile.txt', help='Allows updating a currently running session by adding/removing jobs and rules')
        group_misc = parser.add_argument_group('Misc flags', 'Flags that have no home')
        group_misc.add_argument('--verbose', action='store_true', dest='verbose', default=False, help='Enables output of the commands run to the screen')
        return parser

    def parse_scansweep(self, args):
        parser = self.scansweep_argparser()
        options = parser.parse_args(args)
        return options

    def printflav(self):
        modcmd = ops.cmd.getDszCommand('moduletoggle -list')
        modobj = modcmd.execute()
        if self.checkflav(modobj, 'banner'):
            dsz.ui.Echo('FLAV banner plugin is enabled', dsz.WARNING)
        if self.checkflav(modobj, 'redirect'):
            dsz.ui.Echo('FLAV redirect plugin is enabled', dsz.WARNING)
        if self.checkflav(modobj, 'ping'):
            dsz.ui.Echo('FLAV ping plugin is enabled', dsz.WARNING)
        return

    def parseexcludes(self, target_flag):
        exclude_list = []
        if (type(target_flag) == type([])):
            for flag in target_flag:
                exclude_list.extend(self.parsetarget(flag))
        else:
            exclude_list = self.parsetarget(target_flag)
        scanbase.write_excludes_list(self.session, exclude_list)

    def parserange(self, ip_range):
        candidate_list = []
        if util.ip.validate_ipv4(ip_range.split('-')[0]):
            if (not self.verifyrange(ip_range)):
                return []
            start = ip_range.split('-')[0]
            end = ip_range.split('-')[1]
            if (not util.ip.validate(end)):
                end_list = end.split('.')
                start_list = start.split('.')
                end = '.'.join((start_list[0:(4 - len(end_list))] + end_list))
            for target in range(util.ip.get_int_from_ip(start), (util.ip.get_int_from_ip(end) + 1)):
                candidate_list.append(util.ip.get_ip_from_int(target))
        elif util.ip.validate_ipv6(ip_range.split('-')[0]):
            start = ip_range.split('-')[0]
            end = ip_range.split('-')[1]
            start = util.ip.expand_ipv6(start)
            if (not util.ip.validate(end)):
                end = (start[0:(- len(end))] + end)
            else:
                end = util.ip.expand_ipv6(end)
            start = start.replace(':', '')
            end = end.replace(':', '')
            mask = ''
            end_bits = 0
            start_bits = 0
            for i in range(1, 33):
                if end.startswith(start[:(- i)]):
                    mask = start[:(- i)]
                    start_bits = int(start[len(mask):], 16)
                    end_bits = int(end[len(mask):], 16)
                    break
            for i in range(start_bits, (end_bits + 1)):
                candidate_list.append(self.correctexpandedipv6((mask + hex(i)[2:])))
        return candidate_list

    def parsesubnet(self, subnet_notation):
        (ip, notation) = subnet_notation.split('/')
        if util.ip.validate_ipv4(ip):
            if util.ip.validate(notation):
                if (not self.verifysubnet(subnet_notation)):
                    return []
                return self.getsubnet(ip, util.ip.get_cidr_from_subnet(notation))
            else:
                if (not self.verifycidr(subnet_notation)):
                    return []
                return self.getsubnet(ip, notation)
        elif util.ip.validate_ipv6(ip):
            if (int(notation) < 115):
                dsz.ui.Echo(('Bad CIDR (%s): CIDR mask excessively large' % cidr), dsz.ERROR)
                return []
            orig_mask = util.ip.expand_ipv6(ip).replace(':', '')
            mask = int(orig_mask[(-4):], 16)
            mask = (mask >> (128 - int(notation)))
            mask = (mask << (128 - int(notation)))
            candidate_list = []
            for i in range(1, ((2 ** (128 - int(notation))) - 1)):
                candidate_list.append(self.correctexpandedipv6((orig_mask[:(-4)] + hex((mask + i))[2:])))
            return candidate_list

    def correctexpandedipv6(self, ipv6missingcolons):
        ipv6without = ipv6missingcolons.replace(':', '')
        ipv6list = []
        for i in range(0, 29, 4):
            ipv6list.append(ipv6without[i:(i + 4)])
        return ':'.join(ipv6list)

    def parsetarget(self, target_flag):
        candidate_list = []
        for item in target_flag.split(','):
            item.strip()
            if util.ip.validate(item):
                candidate_list.append(item)
            elif ((item.count('-') == 1) and util.ip.validate(item.split('-')[0])):
                candidate_list.extend(self.parserange(item))
            elif (item.count('/') == 1):
                candidate_list.extend(self.parsesubnet(item))
            elif os.path.exists(item):
                candidate_list.extend(self.getlistfromfile(item))
            else:
                candidate_list.append(item)
        return candidate_list

    def checksubnet(self, subnet):
        return util.ip.validate_ipv4_subnet(subnet)

    def getqueuefromfile(self, file):
        f = open(file, 'r')
        output = f.readlines()
        f.close()
        queuelist = []
        for line in output:
            try:
                target_csv = line.split(' ')[1:]
                target_csv = ''.join(target_csv)
                candidate_list = self.parsetarget(target_csv.strip())
                for target in candidate_list:
                    try:
                        queuelist.append([line.split(' ')[0], target.strip()])
                    except:
                        continue
            except:
                continue
        return queuelist

    def getrulesfromfile(self, file):
        f = open(file, 'r')
        output = f.readlines()
        f.close()
        return output

    def getsubnet(self, network, bits):
        bits = int(bits)
        bitwork = util.ip.get_int_from_ip(network)
        netmask = (floor((bitwork / (2 ** (32 - bits)))) * (2 ** (32 - bits)))
        host_list = []
        for item in range(1, ((2 ** (32 - bits)) - 1)):
            host_list.append(util.ip.get_ip_from_int(int((netmask + item))))
        return host_list

    def getlistfromfile(self, file):
        ip_re_pattern = re.compile('\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}')
        f = open(file, 'r')
        output = f.readlines()
        f.close()
        list = []
        for line in output:
            re_out = ip_re_pattern.findall(line)
            for ip in re_out:
                if util.ip.validate(ip):
                    list.append(ip)
        return list

    def checkflav(self, module_obj, command_to_check):
        for system in module_obj.moduletoggle.system:
            if system.name.upper().startswith(command_to_check.upper()):
                if (system.selected == 'FLAV'):
                    return True
                else:
                    return False
        return False

    def database_display(self, database_op):
        if (database_op.lower() == 'sessions'):
            session_list = scanbase.list_sessions()
            unique_sessions = []
            for session in session_list:
                if (not (session in unique_sessions)):
                    unique_sessions.append(session)
                    dsz.ui.Echo(('Displaying statistics for session: %s' % session))
                    self.showstats(session_to_display=session, screenonly=True)
        elif (database_op.lower() == 'jobs'):
            dsz.ui.Echo(('Displaying job list for session: %s' % self.session))
            dsz.ui.Echo(((('=' * 10) + ' Queued: ') + ('=' * 10)))
            job_list = scanbase.list_jobs(self.session, inprogress='False')
            for job in job_list:
                dsz.ui.Echo(('%s %s' % (job['job'], job['target'])))
            dsz.ui.Echo(((('=' * 10) + ' Running: ') + ('=' * 10)))
            job_list = scanbase.list_jobs(self.session, inprogress='True')
            for job in job_list:
                dsz.ui.Echo(('%s %s' % (job['job'], job['target'])))
        elif (database_op.lower() == 'results'):
            dsz.ui.Echo(('Displaying results for session: %s' % self.session))
            self.generateresults()
        elif (database_op.lower() == 'dump'):
            dsz.ui.Echo(('Dumping jobs for session: %s' % self.session))
            self.writequeuetofile()
        elif (database_op.lower() == 'reset'):
            dsz.ui.Echo(('Resetting running jobs to queued jobs for session: %s' % self.session))
            scanbase.reset_jobs(self.session)
        elif (database_op.lower() == 'kill'):
            dsz.ui.Echo(('Marking the following session for death: %s' % self.session))
            scanbase.kill_session(self.session)
        elif (database_op.lower() == 'rules'):
            dsz.ui.Echo(('Outputting the escalation rules for session: %s' % self.session))
            self.display_escalate_rules()
        elif (database_op.lower() == 'excludes'):
            dsz.ui.Echo(('Outputting the excludes for session: %s' % self.session))
            self.display_excludes()
        elif (database_op.lower() == 'reescalate'):
            dsz.ui.Echo(('Applying current escalate rules to completed data for session: %s' % self.session))
            self.re_escalate()
        else:
            dsz.ui.Echo(('Invalid database operation %s' % database_op), dsz.ERROR)
            return

    def parseescalate(self, params):
        rulelist = []
        if (len(params) == 0):
            if self.monitor:
                rulelist.append(["netconnections.state in ['ESTABLISHED','TIME_WAIT']", 'ping'])
                rulelist.append(["arpcache.macaddress not in ['00-00-00-00-00-00','']", 'ping'])
            else:
                rulelist.append(['arp.success', 'ping'])
                rulelist.append(["ping.success and ping.responsetype == 'REPLY' and (ping.ttl > 64 and ping.ttl <= 128)", 'netbios'])
        else:
            for escalation in params:
                if os.path.exists(escalation):
                    rulescandidate_list = self.getrulesfromfile(escalation)
                elif (escalation.count('->') == 0):
                    dsz.ui.Echo(('Escalate parameter is neither a rule nor a file path: %s' % escalation), dsz.ERROR)
                    rulescandidate_list = []
                else:
                    rulescandidate_list = escalation.split('|||')
                for item in rulescandidate_list:
                    item = item.strip(' \r\n').strip()
                    item_split = item.split('->')
                    scantype = item_split[1].strip().split('|')[0].lower()
                    if (((not self.verifyjob(scantype, item_split[1].strip().split('|'))) and (not (item_split[1].strip() == 'alert'))) or (not self.verifyrule(item_split[0].strip()))):
                        dsz.ui.Echo(('Invalid rule: %s' % item), dsz.ERROR)
                        continue
                    rulelist.append([item_split[0].strip(), item_split[1].strip()])
        return rulelist

    def verifyrange(self, range):
        if (not (len(range.split('-')) == 2)):
            dsz.ui.Echo(("Bad range (%s): Must be two IP addresses seperated by a dash ('-')" % range), dsz.ERROR)
            return False
        start = range.split('-')[0]
        end = range.split('-')[1]
        if (not util.ip.validate(start)):
            dsz.ui.Echo(('Bad range (%s): Start must be a valid IP address' % range), dsz.ERROR)
            return False
        if util.ip.validate(end):
            start = util.ip.get_int_from_ip(start)
            end = util.ip.get_int_from_ip(end)
        else:
            end_list = end.split('.')
            start_list = start.split('.')
            octet_regex = '(2([0-4][0-9])|(5[0-5]))|(1?[0-9]?[0-9])'
            partial_ip_pattern = re.compile(('%s(.%s){1,3}?' % (octet_regex, octet_regex)))
            if (not partial_ip_pattern.match(end)):
                dsz.ui.Echo(('Bad range (%s): End must be a valid IP address or partial IP address' % range), dsz.ERROR)
                return False
            end = '.'.join((start_list[0:(4 - len(end_list))] + end_list))
            end = util.ip.get_int_from_ip(end)
            start = util.ip.get_int_from_ip(start)
        if (start > end):
            dsz.ui.Echo(('Bad range (%s): End IP must be after start IP' % range), dsz.ERROR)
            return False
        if ((end - start) >= (8192 - 2)):
            dsz.ui.Echo(('Bad range (%s): Range is excessively large' % range), dsz.ERROR)
            return False
        return True

    def verifycidr(self, cidr):
        if (not util.ip.validate(cidr.split('/')[0])):
            dsz.ui.Echo(('Bad CIDR (%s): First part of CIDR must be a valid IP address' % cidr), dsz.ERROR)
            return False
        if (not (int(cidr.split('/')[1]) in range(1, 32))):
            dsz.ui.Echo(('Bad CIDR (%s): Second part of CIDR must be a valid CIDR mask' % cidr), dsz.ERROR)
            return False
        if (int(cidr.split('/')[1]) in range(1, (18 + 1))):
            dsz.ui.Echo(('Bad CIDR (%s): CIDR mask excessively large' % cidr), dsz.ERROR)
            return False
        return True

    def verifyqueue(self, queue):
        if (not (dsz.path.IsFullPath(queue) and os.path.exists(queue))):
            dsz.ui.Echo('You must specify a valid file', dsz.ERROR)
            return False
        return True

    def verifysubnet(self, subnet):
        if (not util.ip.validate(subnet.split('/')[0])):
            dsz.ui.Echo(('Bad subnet (%s): First part of subnet must be a valid IP address' % subnet), dsz.ERROR)
            return False
        if (not self.checksubnet(subnet.split('/')[1])):
            dsz.ui.Echo(('Bad subnet (%s): Second part of subnet must be a valid subnet mask' % subnet), dsz.ERROR)
            return False
        if (util.ip.get_int_from_ip(subnet.split('/')[1]) < util.ip.get_int_from_ip('255.255.224.0')):
            dsz.ui.Echo(('Bad subnet (%s): Subnet mask is excessively large' % subnet), dsz.ERROR)
            return False
        return True

    def verifytime(self, type_list):
        success = True
        if (not self.override):
            for type in type_list:
                temp_engine = scanengine2.get_scanengine([type])
                min_time = temp_engine.min_time()
                min_range = temp_engine.min_range()
                if (self.min_seconds < min_time):
                    dsz.ui.Echo(('You must specify a minimum time larger then %ss when doing a %s scan' % (min_time, type)), dsz.ERROR)
                    success = False
                if ((self.max_seconds - self.min_seconds) < min_range):
                    dsz.ui.Echo(('You must specify a range time larger then %ss when doing a %s scan' % (min_range, type)), dsz.ERROR)
                    success = False
            if (self.monitor is not None):
                for monitor_type in self.monitor:
                    tempeng = monitorengine.get_monitorengine([monitor_type])
                    monitor_min = tempeng.min_time()
                    monitor_range = tempeng.min_range()
                    if (self.min_seconds < monitor_min):
                        dsz.ui.Echo(('You must specify a minimum time larger then %ss when using -monitor %s' % (monitor_min, monitor_type)), dsz.ERROR)
                        success = False
                    if ((self.max_seconds - self.min_seconds) < monitor_range):
                        dsz.ui.Echo(('You must specify a range time larger then %ss when using -monitor %s' % (monitor_range, monitor_type)), dsz.ERROR)
                        success = False
        if (self.min_seconds == self.max_seconds):
            dsz.ui.Echo('You must specify two different times for your period', dsz.ERROR)
            success = False
        if (self.min_seconds == 0):
            dsz.ui.Echo('You cannot specify a 0s starting period', dsz.ERROR)
            success = False
        return success

    def verifyrule(self, rule):
        for import_job in monitorengine.monitor_description.keys():
            name = monitorengine.monitor_description[import_job]._whats_your_name()
            if monitorengine.monitor_description[import_job].__dict__[name]([import_job]).verify_escalation(rule):
                return True
        for import_job in scanengine2.scan_job_description.keys():
            name = scanengine2.scan_job_description[import_job]._whats_your_name()
            if scanengine2.scan_job_description[import_job].__dict__[name]([import_job]).verify_escalation(rule):
                return True
        return False

    def verifymonitor(self, monitor_type):
        tempeng = monitorengine.get_monitorengine([monitor_type])
        if (tempeng is False):
            return False
        return True

    def supportipv6(self, job_type):
        for import_job in scanengine2.scan_job_description.keys():
            name = scanengine2.scan_job_description[import_job]._whats_your_name()
            if (name == job_type):
                return scanengine2.scan_job_description[import_job]._support_ipv6()
        return False

    def verifyjob(self, job_type, job):
        tempeng = scanengine2.get_scanengine([job_type])
        if (tempeng is False):
            return False
        return tempeng.verify_job(job)

    def get_local_addresses(self):
        ip_list = []
        ifconfig_obj = ops.networking.ifconfig.get_ifconfig()
        for interfaceitem in ifconfig_obj.interfaceitem:
            for ipaddress in interfaceitem.ipaddress:
                ip_list.append(ipaddress.ip)
            for ipaddressv6 in interfaceitem.ipaddressv6:
                ip_list.append(util.ip.expand_ipv6(ipaddressv6.ip.split('%')[0]))
                self.ipv6 = True
        return ip_list

    def getnetwork(self, network, bits):
        bits = int(bits)
        bitwork = util.ip.get_int_from_ip(network)
        netmask = (floor((bitwork / (2 ** (32 - bits)))) * (2 ** (32 - bits)))
        return netmask

    def get_local_networks(self):
        network_list = []
        ifconfig_obj = ops.networking.ifconfig.get_ifconfig()
        for interfaceitem in ifconfig_obj.interfaceitem:
            if self.checksubnet(interfaceitem.subnetmask):
                for ipaddress in interfaceitem.ipaddress:
                    network_list.append([interfaceitem.subnetmask, self.getnetwork(ipaddress.ip, util.ip.get_cidr_from_subnet(interfaceitem.subnetmask))])
            for ipaddressv6 in interfaceitem.ipaddressv6:
                network_list.append(['', util.ip.expand_ipv6(ipaddressv6.ip.split('%')[0])[:19]])
        return network_list

    def re_escalate(self):
        type_list = scanbase.get_jobtypes(self.session)
        for type in type_list.keys():
            results = (scanbase.get_results(self.session, type, success=False) + scanbase.get_results(self.session, type, success=True))
            for item in results:
                temp_engine = scanengine2.get_scanengine([type])
                temp_engine.recall_data(item['data'])
                target = temp_engine.target
                rulelist = scanbase.get_escalate_rules(self.session)
                for rule in rulelist:
                    if temp_engine.check_escalation(rule[0]):
                        if (rule[1] == 'alert'):
                            esc_output_string = ('[%s] Alerting on %s by rule: (%s->%s)' % (dsz.Timestamp(), target, rule[0], rule[1]))
                            self.alert(esc_output_string)
                            dsz.ui.Echo(esc_output_string, dsz.WARNING)
                        else:
                            self.addtoqueue(rule[1], target, self.scansweep_env)
                            esc_output_string = ('[%s] Escalating %s by rule: (%s->%s) (%s jobs remaining)' % (dsz.Timestamp(), target, rule[0], rule[1], scanbase.num_jobs(self.session)))
                            dsz.ui.Echo(esc_output_string)
                        with open(self.scansweep_logfile, 'a') as f:
                            f.write(('%s\n' % esc_output_string))

    def alert(self, alertstring):
        ops.cmd.getDszCommand('warn', arglist=[('"%s"' % alertstring), '-warning']).execute()
        self.colorseed = ((self.colorseed + 1) % 8)
        outstring = (':Start\r\nCLS\r\necho "%s"\r\nCOLOR %sf\r\nping -n 2 127.0.0.1 >nul\r\nCLS\r\necho "%s"\r\nCOLOR f%s\r\nping -n 2 127.0.0.1 >nul\r\nGOTO Start' % (alertstring, self.colorseed, alertstring, self.colorseed))
        alertbat = os.path.join(ops.LOGDIR, 'Logs', ('%s_%s_alert.bat' % (self.scansweep_env, dsz.Timestamp())))
        f = open(alertbat, 'w')
        f.write(outstring)
        f.close()
        subprocess.Popen(('cmd /K %s' % alertbat))

    def handleupdate(self):
        dsz.ui.Echo(('Updating the queue for session: %s' % self.scansweep_env))
        (newrulelist, newqueuelist, removerule, removequeue) = self.checkupdate(self.scansweep_updatefile)
        if (len(newrulelist) > 0):
            for rule in newrulelist:
                rulelist = scanbase.get_escalate_rules(self.session)
                if (rule not in rulelist):
                    scanbase.write_escalate_rule(self.session, rule)
                    dsz.ui.Echo(('Escalation rule enabled: %s->%s' % (rule[0], rule[1])))
                    scanbase.set_jobtype(self.session, rule[1].split('|')[0])
        if (len(newqueuelist) > 0):
            for item in newqueuelist:
                if self.addtoqueue(item[0], item[1], self.scansweep_env):
                    dsz.ui.Echo(('Job added: %s %s' % (item[0], item[1])))
        if (len(removerule) > 0):
            for rule in removerule:
                rulelist = scanbase.get_escalate_rules(self.session)
                if (rule in rulelist):
                    scanbase.delete_escalate_rule(self.session, rule)
                    dsz.ui.Echo(('Escalation rule removed: %s->%s' % (rule[0], rule[1])))
        if (len(removequeue) > 0):
            for item in removequeue:
                if self.addtoqueue(item[0], item[1], self.scansweep_env, remove=True):
                    dsz.ui.Echo(('Job removed: %s %s' % (item[0], item[1])))
                    pass

    def checkupdate(self, updatefile):
        rulelist = []
        queuelist = []
        removerule = []
        removequeue = []
        if (not os.path.exists(updatefile)):
            return (rulelist, queuelist, removerule, removequeue)
        f = open(updatefile, 'r')
        output = f.readlines()
        f.close()
        for line in output:
            remove = False
            if line.startswith('REMOVE'):
                remove = True
                line = line[6:]
            line = line.strip()
            if (line.count('->') == 1):
                try:
                    item = line.strip(' \r\n').strip()
                    item_split = item.split('->')
                    scantype = item_split[1].strip().split('|')[0].lower()
                    if ((not self.verifyjob(scantype, item_split[1].strip().split('|'))) or (not self.verifyrule(item_split[0].strip()))):
                        dsz.ui.Echo(('Invalid rule: %s' % item), dsz.ERROR)
                        continue
                    if remove:
                        removerule.append([item_split[0].strip(), item_split[1].strip()])
                    else:
                        rulelist.append([item_split[0].strip(), item_split[1].strip()])
                except:
                    continue
            else:
                try:
                    target_csv = line.split(' ')[1:]
                    target_csv = ''.join(target_csv)
                    candidate_list = self.parsetarget(target_csv.strip())
                    for target in candidate_list:
                        try:
                            if remove:
                                removequeue.append([line.split(' ')[0], target.strip()])
                            else:
                                queuelist.append([line.split(' ')[0], target.strip()])
                        except:
                            continue
                except:
                    continue
        return (rulelist, queuelist, removerule, removequeue)