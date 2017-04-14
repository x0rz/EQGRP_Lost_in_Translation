
import ops.cmd
import util.mac
import dsz
from scanengine2 import scan
import os.path
import re

def _whats_your_job():
    return 'rpctouch\\|*'

def _whats_your_name():
    return 'rpctouch'

def _support_ipv6():
    return False

class rpctouch(scan, ):

    def __init__(self, job, timeout=60):
        scan.__init__(self, job)
        if (len(job) > 1):
            self.port = job[0].split('|')[1]
        self.scan_type = _whats_your_name()
        self.timeout = timeout

    def execute_scan(self, verbose):
        redir_cmd = scan.gettunnel(self, self.target, 'tcp', self.port)
        PATH_TO_RPCTOUCH = scan.find_newest_touch(self, 'Rpctouch', 'exe')
        PATH_TO_RPCXML = scan.find_newest_touch(self, 'Rpctouch', 'xml')
        rpccmd = ops.cmd.getDszCommand('run', dszquiet=(not verbose))
        rpc_cmd_list = []
        rpc_cmd_list.append(('--InConfig %s' % PATH_TO_RPCXML))
        rpc_cmd_list.append(('--TargetIp %s' % '127.0.0.1'))
        rpc_cmd_list.append(('--TargetPort %s' % redir_cmd.lplisten))
        rpc_cmd_list.append(('--NetworkTimeout %s' % self.timeout))
        if (int(self.port) == 445):
            rpc_cmd_list.append(('--Protocol %s' % 'SMB'))
        elif (int(self.port) == 139):
            rpc_cmd_list.append(('--Protocol %s' % 'NBT'))
        rpc_cmd_list.append(('--NetBIOSName %s' % '*SMBSERVER'))
        rpc_cmd_list.append(('--TouchLanguage %s' % 'False'))
        rpc_cmd_list.append(('--TouchArchitecture %s' % 'False'))
        outconfig = os.path.join(ops.LOGDIR, 'Logs', ('%s_%s_%s.xml' % (os.path.basename(PATH_TO_RPCTOUCH), self.target, dsz.Timestamp())))
        rpc_cmd_list.append(('--OutConfig %s' % outconfig))
        rpc_cmd_string = ((PATH_TO_RPCTOUCH + ' ') + ' '.join(rpc_cmd_list))
        rpccmd.command = ('cmd /C %s' % rpc_cmd_string)
        rpccmd.arglist.append('-redirect')
        rpccmd.arglist.append(('-directory %s' % os.path.join(ops.DSZDISKSDIR, 'lib', 'x86-Windows')))
        rpccmd.prefixes.append('local')
        rpccmd.prefixes.append('log')
        rpcobject = rpccmd.execute()
        ops.networking.redirect.stop_tunnel(dsz_cmd=redir_cmd)
        cmd_output = {}
        cmd_output['error'] = None
        screenlog = os.path.join(ops.PROJECTLOGDIR, rpcobject.commandmetadata.screenlog)
        f = open(screenlog, 'r')
        screenlog_lines = f.readlines()
        f.close()
        error = False
        for line in screenlog_lines:
            re_out = re.search('] SMB String:', line.strip())
            if (re_out is not None):
                self.os = line.split(':')[(-1)].strip()
        if ((self.os is None) or (self.os == '(none)')):
            error = True
        self.timestamp = dsz.Timestamp()
        if (error == False):
            self.success = True

    def return_success_message(self):
        return ('RPCtouch response for %s' % self.target)

    def verify_escalation(self, escalation_rule):
        rpctouch = self
        try:
            eval_res = eval(escalation_rule)
            if ((eval_res == True) or (eval_res == False)):
                return True
            else:
                return False
        except:
            return False

    def check_escalation(self, escalation_rule):
        rpctouch = self
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
        return ['Targeted Address', 'Port', 'OS', 'Time Stamp']

    def get_data_fields(self):
        return ['target', 'port', 'os', 'timestamp']

    def get_raw_fields(self):
        return (self.get_data_fields() + ['success'])

    def verify_job(self, job):
        if ((not (len(job) == 2)) or (not (int(job[1]) in [139, 445]))):
            return False
        return True

    def min_time(self):
        return 30

    def min_range(self):
        return 5