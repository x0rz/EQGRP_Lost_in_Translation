
import ops.cmd
import dsz
from scanengine2 import scan
import os.path

def _whats_your_job():
    return 'scanner\\|*'

def _whats_your_name():
    return 'scanner'

def _support_ipv6():
    return False

class scanner(scan, ):

    def __init__(self, job, timeout=None):
        scan.__init__(self, job)
        if (len(job) > 1):
            self.type = job[0].split('|')[1]
        self.scan_type = _whats_your_name()

    def execute_scan(self, verbose):
        service_dict = {'win_scan': {'protocol': '-tcp', 'port': '139'}, 'winn': {'protocol': '-udp', 'port': '137'}, 'http': {'protocol': '-tcp', 'port': '80'}, 'ssh': {'protocol': '-tcp', 'port': '22'}}
        redir_cmd = ops.networking.redirect.generate_tunnel_cmd(arg_list=[service_dict[self.type]['protocol'], '-target', self.target, service_dict[self.type]['port'], '-lplisten', service_dict[self.type]['port']], random=False)
        redir_output = ops.networking.redirect.start_tunnel(dsz_cmd=redir_cmd)
        if (not ((redir_output is not False) and (type(redir_output) is int))):
            return False
        PATH_TO_SCANNER = os.path.join(ops.TOOLS, 'scanner.exe')
        scannercmd = ops.cmd.getDszCommand('run', dszquiet=(not verbose))
        scannercmd.command = ('%s %s 127.0.0.1' % (PATH_TO_SCANNER, self.type))
        scannercmd.arglist.append('-redirect')
        scannercmd.prefixes.append('local')
        scannercmd.prefixes.append('log')
        scannerobject = scannercmd.execute()
        ops.networking.redirect.stop_tunnel(dsz_cmd=redir_cmd)
        data = ''
        first = False
        num_names = (-1)
        for processoutput in scannerobject.processoutput:
            lines = processoutput.output.split('\n')
            for line in lines:
                if (self.type == 'http'):
                    if line.startswith('Server:'):
                        data = line.strip().split(':')[1]
                        break
                elif (self.type == 'ssh'):
                    if line.startswith('---------------'):
                        first = True
                    elif first:
                        if line.startswith('--'):
                            break
                        data = line.strip()
                        break
                elif (self.type == 'win_scan'):
                    if (line.startswith('*') and (line[1] != '*')):
                        data = line.strip()
                        break
                elif (self.type == 'winn'):
                    if line.startswith('received'):
                        num_names = int(line.strip().split(' ')[1])
                    elif (num_names > 0):
                        if (not first):
                            first = True
                            data = ('%s <%s>' % (line.split('<')[0].strip(), line.split('<')[1].split('>')[0].strip()))
                        else:
                            data = ('%s, %s <%s>' % (data, line.split('<')[0].strip(), line.split('<')[1].split('>')[0].strip()))
                        num_names = (num_names - 1)
                    elif (num_names == 0):
                        break
        self.data = data
        self.timestamp = dsz.Timestamp()
        if (not (data == '')):
            self.success = True

    def return_success_message(self):
        return ('%s response for %s' % (self.type, self.target))

    def verify_escalation(self, escalation_rule):
        scanner = self
        try:
            eval_res = eval(escalation_rule)
            if ((eval_res == True) or (eval_res == False)):
                return True
            else:
                return False
        except:
            return False

    def check_escalation(self, escalation_rule):
        scanner = self
        try:
            if eval(escalation_rule):
                return True
            else:
                return False
        except:
            return False

    def return_data(self):
        return scan.return_data(self)

    def get_display_headers(self):
        return ['Targeted Address', 'Type', 'Data', 'Time Stamp']

    def get_data_fields(self):
        return ['target', 'type', 'data', 'timestamp']

    def get_raw_fields(self):
        return (self.get_data_fields() + ['success'])

    def verify_job(self, job):
        if ((not (len(job) == 2)) or (not (job[1] in ['http', 'win_scan', 'ssh', 'winn']))):
            return False
        return True

    def min_time(self):
        return 30

    def min_range(self):
        return 5