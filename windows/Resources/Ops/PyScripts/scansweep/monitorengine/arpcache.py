
import ops
import os.path
import imp
import re
import glob
import os
import sys
from xml.etree.ElementTree import ElementTree
import dsz
import ops.cmd
from monitorengine import monitor
DSZ_NS = '{urn:mca:db00db84-8b5b-2141-a632b5980175d3c6}'
COMMANDDATA_TAG = ('%sCommandData' % DSZ_NS)
COMMAND_TAG = ('%sCommand' % DSZ_NS)
ARPCACHE_PATTERN = 'Data/*arp*xml'
ARPTASKING_PATTERN = 'Tasking/*arp*xml'
ARGUMENT_TAG = ('%sArgument' % DSZ_NS)
ARPENTRY_TAG = ('%sArpEntry' % DSZ_NS)
IP_TAG = ('%sIP' % DSZ_NS)
PHYSICAL_TAG = ('%sPhysical' % DSZ_NS)
MACADDRESS_TAG = ('%sMacAddress' % DSZ_NS)
IPV4_TAG = ('%sIPv4Address' % DSZ_NS)
IPV6_TAG = ('%sIPv6Address' % DSZ_NS)

def _whats_your_job():
    return 'arpcache'

def _whats_your_name():
    return 'arpcache'

class arpcacheObj(object, ):

    def __init__(self):
        self.adapter = ''
        self.type = ''
        self.state = ''
        self.ip = ''
        self.iptype = ''
        self.macaddress = ''

class arpcache(monitor, ):

    def __init__(self, job):
        monitor.__init__(self, job, ARPCACHE_PATTERN)

    def parse_arptasking(self, file_to_read):
        if (not file_to_read):
            return
        f = open(file_to_read, 'r')
        tasking = f.readlines()
        f.close()
        for line in tasking:
            if (re.search('monitor', line) is not None):
                return True
        return False

    def parse_data(self, file_to_read):
        if (not file_to_read):
            return
        tasking_files = self.find_tasking(file_to_read)
        for file in tasking_files:
            if (self.parse_arptasking(file) is False):
                return (True, [])
        data_path = '/'.join([COMMANDDATA_TAG, '*', ARPENTRY_TAG])
        tree = ElementTree()
        try:
            tree.parse(file_to_read)
        except:
            dsz.ui.Echo(("Couldn't parse XML file: %s" % file_to_read), dsz.WARNING)
            return (False, None)
        arpentry_list = tree.findall(data_path)
        arp_list = []
        for arpentry in arpentry_list:
            this_arp = arpcacheObj()
            mac_tag = arpentry.find('/'.join([PHYSICAL_TAG, MACADDRESS_TAG]))
            if (mac_tag is None):
                continue
            this_arp.macaddress = mac_tag.text.strip()
            this_arp.adapter = arpentry.get('adapter').strip()
            if (arpentry.get('type') is not None):
                this_arp.type = arpentry.get('type').strip()
            else:
                this_arp.type = ''
            if (arpentry.get('state') is not None):
                this_arp.state = arpentry.get('state').strip()
            else:
                this_arp.state = ''
            ipv4_tag = arpentry.find('/'.join([IP_TAG, IPV4_TAG]))
            ipv6_tag = arpentry.find('/'.join([IP_TAG, IPV6_TAG]))
            if ((ipv4_tag is None) and (ipv6_tag is None)):
                continue
            if (ipv6_tag is not None):
                this_arp.ip = ipv6_tag.text.strip()
                arpcache.iptype = 'ipv6'
                this_arp.target = this_arp.ip
            if (ipv4_tag is not None):
                this_arp.ip = ipv4_tag.text.strip()
                arpcache.iptype = 'ipv4'
                this_arp.target = this_arp.ip
            arp_list.append(this_arp)
        return (True, arp_list)

    def check_escalation(self, escalation_rule, arpentry):
        arpcache = arpentry
        try:
            if eval(escalation_rule):
                return True
            else:
                return False
        except:
            return False

    def verify_escalation(self, escalation_rule):
        arpcache = arpcacheObj()
        try:
            eval_res = eval(escalation_rule)
            if ((eval_res == True) or (eval_res == False)):
                return True
            else:
                return False
        except:
            return False