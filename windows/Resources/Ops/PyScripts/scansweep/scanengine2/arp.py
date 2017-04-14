
import ops.cmd
import util.mac
import dsz
from scanengine2 import scan

def _whats_your_job():
    return 'arp'

def _whats_your_name():
    return 'arp'

def _support_ipv6():
    return True

class arp(scan, ):

    def __init__(self, job, timeout=None):
        scan.__init__(self, job)
        self.scan_type = _whats_your_name()

    def execute_scan(self, verbose):
        arpcmd = ops.cmd.getDszCommand('arp', scan=self.target, dszquiet=(not verbose))
        arpobject = arpcmd.execute()
        if (arpobject is None):
            return False
        self.target = arpobject.entry[0].ip
        self.mac = arpobject.entry[0].mac
        self.state = arpobject.entry[0].state
        self.adapter = arpobject.entry[0].adapter
        self.timestamp = dsz.Timestamp()
        if (not ((self.mac == '') or (self.mac == '00-00-00-00-00-00'))):
            self.target_id = self.search_project_data(macs=[self.mac])
            self.oui = util.mac.getoui(self.mac)
            self.success = True

    def return_success_message(self):
        return ('Arp response for %s (%s)' % (self.target, self.mac))

    def check_escalation(self, escalation_rule):
        arp = self
        try:
            if eval(escalation_rule):
                return True
            else:
                return False
        except:
            return False

    def verify_escalation(self, escalation_rule):
        arp = self
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
        return ['Internet Address', 'Physical Address', 'OUI', 'Target ID', 'Time Stamp']

    def get_data_fields(self):
        return ['target', 'mac', 'oui', 'target_id', 'timestamp']

    def get_raw_fields(self):
        return (self.get_data_fields() + ['success'])

    def verify_job(self, job):
        if (not (len(job) == 1)):
            return False
        return True

    def min_time(self):
        return 1

    def min_range(self):
        return 2