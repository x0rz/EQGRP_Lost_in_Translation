
import ops.cmd
import util.mac
import dsz
from scanengine2 import scan
import os.path
import re
from xml.etree.ElementTree import ElementTree
from xml.etree.ElementTree import Element

def _whats_your_job():
    return 'smbtouch\\|*'

def _whats_your_name():
    return 'smbtouch'

def _support_ipv6():
    return False

class smbtouch(scan, ):

    def __init__(self, job, timeout=60):
        scan.__init__(self, job)
        if (len(job) > 1):
            self.port = job[0].split('|')[1]
        self.scan_type = _whats_your_name()
        self.timeout = timeout

    def execute_scan(self, verbose):
        redir_cmd = scan.gettunnel(self, self.target, 'tcp', self.port)
        PATH_TO_SMBTOUCH = scan.find_newest_touch(self, 'Smbtouch', 'exe')
        PATH_TO_SMBXML = scan.find_newest_touch(self, 'Smbtouch', 'xml')
        smbcmd = ops.cmd.getDszCommand('run', dszquiet=(not verbose))
        smb_cmd_list = []
        smb_cmd_list.append(('--InConfig %s' % PATH_TO_SMBXML))
        smb_cmd_list.append(('--TargetIp %s' % '127.0.0.1'))
        smb_cmd_list.append(('--TargetPort %s' % redir_cmd.lplisten))
        smb_cmd_list.append(('--NetworkTimeout %s' % self.timeout))
        if (int(self.port) == 445):
            smb_cmd_list.append(('--Protocol %s' % 'SMB'))
        elif (int(self.port) == 139):
            smb_cmd_list.append(('--Protocol %s' % 'NBT'))
        smb_cmd_list.append(('--Credentials %s' % 'Anonymous'))
        outconfig = os.path.join(ops.LOGDIR, 'Logs', ('%s_%s_%s.xml' % (os.path.basename(PATH_TO_SMBTOUCH), self.target, dsz.Timestamp())))
        smb_cmd_list.append(('--OutConfig %s' % outconfig))
        smb_cmd_string = ((PATH_TO_SMBTOUCH + ' ') + ' '.join(smb_cmd_list))
        smbcmd.command = ('cmd /C %s' % smb_cmd_string)
        smbcmd.arglist.append('-redirect')
        smbcmd.arglist.append(('-directory %s' % os.path.join(ops.DSZDISKSDIR, 'lib', 'x86-Windows')))
        smbcmd.prefixes.append('local')
        smbcmd.prefixes.append('log')
        smbobject = smbcmd.execute()
        ops.networking.redirect.stop_tunnel(dsz_cmd=redir_cmd)
        cmd_output = {}
        cmd_output['error'] = None
        screenlog = os.path.join(ops.PROJECTLOGDIR, smbobject.commandmetadata.screenlog)
        f = open(screenlog, 'r')
        screenlog_lines = f.readlines()
        f.close()
        vulnerable = []
        not_vulnerable = []
        not_supported = []
        for line in screenlog_lines:
            re_out = re.search('Error 0x', line)
            if (re_out is not None):
                cmd_output['error'] = line.split('-')[(-1)].strip()
            re_out = re.search('ETERNAL', line)
            if (re_out is not None):
                line_split = line.split('-')
                exploit = line_split[0].strip()
                if (exploit == 'ETERNALBLUE'):
                    exploit = 'ETEB'
                elif (exploit == 'ETERNALROMANCE'):
                    exploit = 'ETRO'
                elif (exploit == 'ETERNALCHAMPION'):
                    exploit = 'ETCH'
                elif (exploit == 'ETERNALSYNERGY'):
                    exploit = 'ETSY'
                if ((re.search('FB', line) is not None) or (re.search('DANE', line) is not None)):
                    vulnerable.append(exploit)
                elif (re.search('not supported', line) is not None):
                    not_supported.append(exploit)
                else:
                    not_vulnerable.append(exploit)
        self.vulnerable = ','.join(vulnerable)
        self.not_vulnerable = ','.join(not_vulnerable)
        self.not_supported = ','.join(not_supported)
        if (cmd_output['error'] is None):
            tree = ElementTree()
            tree.parse(outconfig)
            root = tree.getroot()
            outparams = root.find('{urn:trch}outputparameters').getchildren()
            for ele in outparams:
                try:
                    cmd_output[ele.get('name')] = ele.find('{urn:trch}value').text
                except:
                    continue
        if ('Target' in cmd_output.keys()):
            self.os = cmd_output['Target']
        if ('TargetOsArchitecture' in cmd_output.keys()):
            self.arch = cmd_output['TargetOsArchitecture']
        if ('PipeName' in cmd_output.keys()):
            self.pipe = cmd_output['PipeName']
        if ('ShareName' in cmd_output.keys()):
            self.share = cmd_output['ShareName']
        if ('Credentials' in cmd_output.keys()):
            self.credentials = cmd_output['Credentials']
        self.error = cmd_output['error']
        self.timestamp = dsz.Timestamp()
        if ((cmd_output['error'] is None) or (not (cmd_output['error'] == 'ErrorConnectionTimedOut'))):
            self.success = True

    def return_success_message(self):
        return ('SMBtouch response for %s' % self.target)

    def verify_escalation(self, escalation_rule):
        smbtouch = self
        try:
            eval_res = eval(escalation_rule)
            if ((eval_res == True) or (eval_res == False)):
                return True
            else:
                return False
        except:
            return False

    def check_escalation(self, escalation_rule):
        smbtouch = self
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
        return ['Targeted Address', 'Port', 'OS', 'Arch', 'Creds', 'Pipe', 'Error', 'Vulnerable', 'Not Vulnerable', 'Not Supported', 'Time Stamp']

    def get_data_fields(self):
        return ['target', 'port', 'os', 'arch', 'credentials', 'pipe', 'error', 'vulnerable', 'not_vulnerable', 'not_supported', 'timestamp']

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