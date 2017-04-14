
import ops.cmd
import util.mac
import dsz
from scanengine2 import scan
import ops
import os.path
import ops.networking.redirect
import re

def _whats_your_job():
    return 'rpc2\\|*\\|*'

def _whats_your_name():
    return 'rpc2'

def _support_ipv6():
    return False

class rpc2(scan, ):

    def __init__(self, job, timeout=30):
        scan.__init__(self, job)
        if (len(job) > 1):
            self.type = job[0].split('|')[1]
            self.port = job[0].split('|')[2]
        self.scan_type = _whats_your_name()
        if (timeout < 30):
            self.timeout = 30
        else:
            self.timeout = timeout

    def execute_scan(self, verbose):
        self.error = ''
        redir_cmd = scan.gettunnel(self, self.target, 'tcp', self.port)
        PROT_TYPE = 'rpc_tcp'
        PROT_NUM = '1'
        if (int(self.port) == 139):
            pass
        elif (int(self.port) == 445):
            PROT_TYPE = 'rpc_smb'
            PROT_NUM = '3'
        elif (int(self.port) == 80):
            PROT_TYPE = 'rpc_http'
            PROT_NUM = '6'
        PATH_TO_RPC = os.path.join(ops.TOOLS, 'RPC2.exe')
        rpccmd = ops.cmd.getDszCommand('run', dszquiet=(not verbose))
        rpccmd.command = ('%s -i 127.0.0.1 -p %s -t 1 -b %s -r %s -o %s -h %s' % (PATH_TO_RPC, redir_cmd.lplisten, PROT_NUM, self.type, self.timeout, self.target))
        rpccmd.arglist.append('-redirect')
        rpccmd.prefixes.append('local')
        rpccmd.prefixes.append('log')
        rpcobject = rpccmd.execute()
        ops.networking.redirect.stop_tunnel(dsz_cmd=redir_cmd)
        for processoutput in rpcobject.processoutput:
            lines = processoutput.output.split('\n')
            for line in lines:
                if line.startswith('NativeOS'):
                    self.nativeos = line.strip('NativeOS:').strip()
                elif line.startswith('NativeLanMan'):
                    self.nativelanman = line.strip('NativeLanMan:').strip()
                elif line.startswith('PrimaryDomain'):
                    self.primarydomain = line.strip('PrimaryDomain:').strip()
                elif line.startswith('OemDomainName'):
                    self.oemdomain = line.strip('OemDomainName=').strip()
                elif line.startswith('Looks like '):
                    self.lookslike = line.strip('Looks like ').strip()
                elif (re.search('failed: 10054', line.strip()) is not None):
                    self.error = line.strip()
                elif (re.search('ErrorConnectionTimedOut', line.strip()) is not None):
                    self.error = line.strip()
                elif line.startswith('FAULT: Status'):
                    self.error = line.strip()
        self.timestamp = dsz.Timestamp()
        if ((re.search('failed: 10054', self.error) is None) and (re.search('ErrorConnectionTimedOut', self.error) is None)):
            self.success = True

    def return_success_message(self):
        return ('RPC2 response for %s' % self.target)

    def verify_escalation(self, escalation_rule):
        rpc2 = self
        try:
            eval_res = eval(escalation_rule)
            if ((eval_res == True) or (eval_res == False)):
                return True
            else:
                return False
        except:
            return False

    def check_escalation(self, escalation_rule):
        rpc2 = self
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
        return ['Targeted Address', 'Type', 'Port', 'NativeOS', 'NativeLanMan', 'PrimaryDomain', 'OemDomainName', 'Looks Like', 'Error', 'Time Stamp']

    def get_data_fields(self):
        return ['target', 'type', 'port', 'nativeos', 'nativelanman', 'primarydomain', 'oemdomain', 'lookslike', 'error', 'timestamp']

    def get_raw_fields(self):
        return (self.get_data_fields() + ['success'])

    def verify_job(self, job):
        if ((not (len(job) == 3)) or (not (int(job[1]) in [1])) or (not (int(job[2]) in [135, 139, 445, 80]))):
            return False
        return True

    def min_time(self):
        return 30

    def min_range(self):
        return 5