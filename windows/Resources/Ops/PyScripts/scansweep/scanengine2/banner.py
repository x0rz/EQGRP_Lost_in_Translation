
import ops.cmd
import util.mac
import dsz
from scanengine2 import scan
import glob
import os.path

def _whats_your_job():
    return 'banner\\|*\\|*'

def _whats_your_name():
    return 'banner'

def _support_ipv6():
    return True

class banner(scan, ):

    def __init__(self, job, timeout=10):
        scan.__init__(self, job)
        setattr(self, 'datasize', 0)
        if (len(job) > 1):
            self.type = job[0].split('|')[1]
            self.port = job[0].split('|')[2]
        self.scan_type = _whats_your_name()
        if (timeout >= 60):
            self.timeout = 59
        else:
            self.timeout = timeout

    def execute_scan(self, verbose):
        bannercmd = ops.cmd.getDszCommand('banner', ip=self.target, port=self.port, wait=self.timeout, dszquiet=(not verbose))
        bannercmd.optdict[self.type] = True
        bannerobject = bannercmd.execute()
        if (bannerobject is None):
            return False
        success = bannercmd.success
        self.respondingip = bannerobject.taskinginfo.target.location
        if (len(bannerobject.transfer) > 0):
            self.firsttextline = bannerobject.transfer[0].text
            self.returnip = bannerobject.transfer[0].address
            self.datasize = bannerobject.transfer[0].data_size
        try:
            self.firsttextline = self.firsttextline.split('\n')[0]
        except:
            pass
        self.moduleerror = ''
        self.oserror = ''
        banner_files = glob.glob(os.path.join(ops.LOGDIR, 'Data', ('%05d-banner*' % bannerobject.cmdid)))
        for datafile in banner_files:
            f = open(datafile, 'r')
            output = f.readlines()
            f.close()
            for line in output:
                if line.strip().startswith('<ModuleError'):
                    self.moduleerror = line.split("'")[1]
                    if (self.moduleerror == '4105'):
                        break
                elif line.strip().startswith('<OsError'):
                    self.oserror = line.split("'")[1]
                    break
        if (self.moduleerror == '4105'):
            self.error = '4105: Open (Timeout waiting)'
        elif (self.moduleerror == '11'):
            self.error = '11: Open (Timeout waiting)'
        elif ((self.moduleerror == '4101') or (self.moduleerror == '7')):
            if (self.oserror == '10060'):
                self.error = ('%s: No response' % '-'.join([self.moduleerror, self.oserror]))
            elif (self.oserror == '10061'):
                self.error = ('%s: Actively refused' % '-'.join([self.moduleerror, self.oserror]))
            elif (self.oserror == '10051'):
                self.error = ('%s: Unreachable network' % '-'.join([self.moduleerror, self.oserror]))
            else:
                self.error = ('%s: Unknown' % '-'.join([self.moduleerror, self.oserror]))
        elif (self.moduleerror == '10'):
            self.error = '10: Error receiving data'
        else:
            self.error = ('%s: Unknown' % '-'.join([self.moduleerror, self.oserror]))
        self.timestamp = dsz.Timestamp()
        if ((self.moduleerror == '4105') or (self.moduleerror == '11')):
            pass
        if (not (self.oserror == '10060')):
            self.success = True

    def return_success_message(self):
        return ('Banner timeout waiting on %s' % self.target)

    def check_escalation(self, escalation_rule):
        banner = self
        try:
            if eval(escalation_rule):
                return True
            else:
                return False
        except:
            return False

    def verify_escalation(self, escalation_rule):
        banner = self
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
        return ['Targeted Address', 'Responding Address', 'Return Address', 'Type', 'Port', 'Error', 'Datasize', 'First Text Line', 'Time Stamp']

    def get_data_fields(self):
        return ['target', 'respondingip', 'returnip', 'type', 'port', 'error', 'datasize', 'firsttextline', 'timestamp']

    def get_raw_fields(self):
        return (self.get_data_fields() + ['success', 'moduleerror', 'oserror'])

    def verify_job(self, job):
        if ((not (len(job) == 3)) or (not (job[1] in ['tcp', 'udp'])) or (not ((int(job[2]) <= 65535) and (int(job[2]) >= 1)))):
            return False
        return True

    def min_time(self):
        return 1

    def min_range(self):
        return 2