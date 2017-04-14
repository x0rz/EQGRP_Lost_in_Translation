
import ops.cmd
import util.mac
import dsz
from scanengine2 import scan

def _whats_your_job():
    return 'netbios'

def _whats_your_name():
    return 'netbios'

def _support_ipv6():
    return False

class netbios(scan, ):

    def __init__(self, job, timeout=None):
        scan.__init__(self, job)
        self.scan_type = _whats_your_name()

    def execute_scan(self, verbose):
        netbioscmd = ops.cmd.getDszCommand('netbios', target=self.target, dszquiet=(not verbose))
        netbiosobject = netbioscmd.execute()
        if (netbiosobject is None):
            return False
        self.mac = []
        self.oui = []
        netbios_type_list = []
        if (len(netbiosobject.netbios) == 0):
            return
        for item in netbiosobject.netbios:
            self.target = item.ncb.callname
            if (self.target == None):
                continue
            mac = item.adapter.adapter_addr
            for service in item.adapter.names:
                netbios_type_list.append(service.type.strip())
                if (service.type == 'Domain Name'):
                    self.group = service.name.strip()
                elif (service.type == 'Workstation Service'):
                    self.name = service.name.strip()
            if (not (util.mac.normalize(mac.strip(), sep='-', case='upper') in self.mac)):
                self.mac.append(util.mac.normalize(mac.strip(), sep='-', case='upper'))
                gotten_oui = util.mac.getoui(mac)
                if (gotten_oui is not None):
                    self.oui.append(gotten_oui)
        self.mac = ','.join(self.mac)
        if ((self.oui is not None) and (len(self.oui) > 0)):
            self.oui = ','.join(self.oui)
        else:
            self.oui = ''
        if (self.target == None):
            return
        netbios_type_list.sort()
        lastitem = ''
        self.services = ''
        service_list = {}
        for item in netbios_type_list:
            if (item.lower() in service_list.values()):
                continue
            service_list[item] = item.lower()
        self.services = ', '.join(service_list.keys())
        self.target_id = self.search_project_data(macs=self.mac.split(','), hostname=self.name)
        self.timestamp = dsz.Timestamp()
        self.success = True

    def return_success_message(self):
        return ('Netbios result for %s' % self.target)

    def check_escalation(self, escalation_rule):
        netbios = self
        try:
            if eval(escalation_rule):
                return True
            else:
                return False
        except:
            return False

    def verify_escalation(self, escalation_rule):
        netbios = self
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
        return ['Internet Address', 'Physical Address', 'OUI', 'Name', 'Group Name', 'Services', 'Target ID', 'Time Stamp']

    def get_data_fields(self):
        return ['target', 'mac', 'oui', 'name', 'group', 'services', 'target_id', 'timestamp']

    def get_raw_fields(self):
        return (self.get_data_fields() + ['success'])

    def verify_job(self, job):
        if (not (len(job) == 1)):
            return False
        return True

    def min_time(self):
        return 15

    def min_range(self):
        return 5