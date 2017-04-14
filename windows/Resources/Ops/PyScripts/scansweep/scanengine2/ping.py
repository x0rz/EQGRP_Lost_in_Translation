
import ops.cmd
import util.ip
import dsz
import util.ip
from scanengine2 import scan

def _whats_your_job():
    return 'ping'

def _whats_your_name():
    return 'ping'

def _support_ipv6():
    return True

class ping(scan, ):

    def __init__(self, job, timeout=5):
        scan.__init__(self, job)
        setattr(self, 'ttl', 0)
        self.scan_type = _whats_your_name()
        if (len(job) > 1):
            if (len(job[0].split('|')) > 1):
                self.broadcast = True
            else:
                self.broadcast = False
        self.response_list = []
        if (timeout >= 60):
            self.timeout = 59
        else:
            self.timeout = timeout

    def execute_scan(self, verbose):
        pingcmd = ops.cmd.getDszCommand('ping', broadcast=self.broadcast, timeout=self.timeout, dszquiet=(not verbose))
        pingcmd.arglist = [self.target]
        pingobject = pingcmd.execute()
        if ((pingobject is None) or (len(pingobject.response) == 0)):
            return False
        if (len(pingobject.response) > 1):
            self.multiple_responses = True
        for response in pingobject.response:
            data_dict = {}
            data_dict['responsetype'] = response.type
            data_dict['ttl'] = response.ttl
            data_dict['respondingip'] = response.fromaddr.addr
            data_dict['elapsed'] = response.elapsed
            data_dict['timestamp'] = dsz.Timestamp()
            data_dict['success'] = True
            if util.ip.validate_ipv6(self.target):
                data = response.data.data
                resptype = ('%s%s' % (data[0], data[1]))
                respcode = ('%s%s' % (data[2], data[3]))
                icmp_types_ref = icmp6types
                icmp_codes_ref = icmp6codes
                data_dict['sourceip'] = ''
            else:
                data = response.data.data
                resptype = ('%s%s' % (data[40], data[41]))
                respcode = ('%s%s' % (data[42], data[43]))
                icmp_types_ref = icmptypes
                icmp_codes_ref = icmpcodes
                data_dict['sourceip'] = util.ip.get_ip_from_hex_str(data[32:40])
            if ((int(resptype, 16) in icmp_codes_ref.keys()) and (int(respcode, 16) in icmp_codes_ref[int(resptype, 16)].keys())):
                data_dict['icmpcode'] = ('0x%s (%s)' % (respcode, icmp_codes_ref[int(resptype, 16)][int(respcode, 16)]))
            else:
                data_dict['icmpcode'] = ('0x%s' % respcode)
            if (int(resptype, 16) in icmp_types_ref.keys()):
                data_dict['icmptype'] = ('0x%s (%s)' % (resptype, icmp_types_ref[int(resptype, 16)]))
            else:
                data_dict['icmptype'] = ('0x%s' % resptype)
            if (self.multiple_responses is False):
                self.recall_data(data_dict)
            else:
                ping_response = ping(['ping', self.target])
                ping_response.recall_data(data_dict)
                self.response_list.append(ping_response)

    def return_success_message(self):
        if (self.ttl is None):
            return ('Ping response for %s (%s)' % (self.target, self.responsetype))
        else:
            return ('Ping response for %s (TTL %s, %s)' % (self.target, self.ttl, self.responsetype))

    def check_escalation(self, escalation_rule):
        ping = self
        try:
            if eval(escalation_rule):
                return True
            else:
                return False
        except:
            return False

    def verify_escalation(self, escalation_rule):
        ping = self
        try:
            eval_res = eval(escalation_rule)
            if ((eval_res == True) or (eval_res == False)):
                return True
            else:
                return False
        except:
            return False

    def return_data(self):
        if (self.multiple_responses == True):
            return self.response_list
        else:
            return scan.return_data(self)

    def get_display_headers(self):
        return ['Targeted Address', 'Responding Address', 'Source Address', 'TTL', 'Elapsed', 'Response Type', 'ICMP Type', 'ICMP Code', 'Time Stamp']

    def get_data_fields(self):
        return ['target', 'respondingip', 'sourceip', 'ttl', 'elapsed', 'responsetype', 'icmptype', 'icmpcode', 'timestamp']

    def get_raw_fields(self):
        return (self.get_data_fields() + ['success', 'broadcast'])

    def verify_job(self, job):
        if (not ((len(job) == 1) or ((len(job) == 2) and (job[1].lower() == 'broadcast')))):
            return False
        return True

    def min_time(self):
        return 15

    def min_range(self):
        return 5
icmptypes = {0: 'echo-reply', 3: 'dest-unreach', 4: 'source-quench', 5: 'redirect', 8: 'echo-request', 9: 'router-advertisement', 10: 'router-solicitation', 11: 'time-exceeded', 12: 'parameter-problem', 13: 'timestamp-request', 14: 'timestamp-reply', 15: 'information-request', 16: 'information-response', 17: 'address-mask-request', 18: 'address-mask-reply'}
icmpcodes = {3: {0: 'network-unreachable', 1: 'host-unreachable', 2: 'protocol-unreachable', 3: 'port-unreachable', 4: 'fragmentation-needed', 5: 'source-route-failed', 6: 'network-unknown', 7: 'host-unknown', 9: 'network-prohibited', 10: 'host-prohibited', 11: 'TOS-network-unreachable', 12: 'TOS-host-unreachable', 13: 'communication-prohibited', 14: 'host-precedence-violation', 15: 'precedence-cutoff'}, 5: {0: 'network-redirect', 1: 'host-redirect', 2: 'TOS-network-redirect', 3: 'TOS-host-redirect'}, 11: {0: 'ttl-zero-during-transit', 1: 'ttl-zero-during-reassembly'}, 12: {0: 'ip-header-bad', 1: 'required-option-missing'}}
icmp6types = {1: 'Destination unreachable', 2: 'Packet too big', 3: 'Time exceeded', 4: 'Parameter problem', 100: 'Private Experimentation', 101: 'Private Experimentation', 128: 'Echo Request', 129: 'Echo Reply', 130: 'MLD Query', 131: 'MLD Report', 132: 'MLD Done', 133: 'Router Solicitation', 134: 'Router Advertisement', 135: 'Neighbor Solicitation', 136: 'Neighbor Advertisement', 137: 'Redirect Message', 138: 'Router Renumbering', 139: 'ICMP Node Information Query', 140: 'ICMP Node Information Response', 141: 'Inverse Neighbor Discovery Solicitation Message', 142: 'Inverse Neighbor Discovery Advertisement Message', 143: 'Version 2 Multicast Listener Report', 144: 'Home Agent Address Discovery Request Message', 145: 'Home Agent Address Discovery Reply Message', 146: 'Mobile Prefix Solicitation', 147: 'Mobile Prefix Advertisement', 148: 'Certification Path Solicitation', 149: 'Certification Path Advertisement', 151: 'Multicast Router Advertisement', 152: 'Multicast Router Solicitation', 153: 'Multicast Router Termination', 200: 'Private Experimentation', 201: 'Private Experimentation'}
icmp6codes = {1: {0: 'No route to destination', 1: 'Administratively prohibited', 2: 'Beyond scope of source address', 3: 'Address unreachable', 4: 'Port unreachable', 5: 'Source address failed ingress/egress policy', 6: 'Reject route to destination'}, 3: {0: 'Hop limit exceeded in transit', 1: 'Fragment reassembly time exceeded'}, 4: {0: 'Erroneous header field encountered', 1: 'Unrecognized Next Header type encountered', 2: 'Unrecognized IPv6 option encountered'}}