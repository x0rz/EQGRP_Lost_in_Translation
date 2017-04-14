
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
NETCONNECTION_PATTERN = 'Data/*netconnections*xml'
CONNECTIONS_TAG = ('%sConnections' % DSZ_NS)
CONNECTION_TAG = ('%sConnection' % DSZ_NS)
REMOTE_IP_TAG = ('%sRemoteAddress' % DSZ_NS)
LOCAL_IP_TAG = ('%sLocalAddress' % DSZ_NS)
LOCAL_PORT_TAG = ('%sLocalPort' % DSZ_NS)
REMOTE_PORT_TAG = ('%sRemotePort' % DSZ_NS)
STARTED_TAG = ('%sStarted' % DSZ_NS)
PID_TAG = ('%sPid' % DSZ_NS)
IPV4_TAG = ('%sIPv4Address' % DSZ_NS)
IPV6_TAG = ('%sIPv6Address' % DSZ_NS)

def _whats_your_job():
    return 'netconnections'

def _whats_your_name():
    return 'netconnections'

class netconnectionObj(object, ):

    def __init__(self):
        self.localaddress = ''
        self.remoteaddress = ''
        self.localport = 0
        self.remoteport = 0
        self.pid = 0
        self.state = ''
        self.valid = False
        self.type = ''
        self.iptype = ''

class netconnections(monitor, ):

    def __init__(self, job):
        monitor.__init__(self, job, NETCONNECTION_PATTERN)

    def parse_data(self, file_to_read):
        if (not file_to_read):
            return
        data_path = '/'.join([COMMANDDATA_TAG, CONNECTIONS_TAG, STARTED_TAG, CONNECTION_TAG])
        tree = ElementTree()
        try:
            tree.parse(file_to_read)
        except:
            dsz.ui.Echo(("Couldn't parse XML file: %s" % file_to_read), dsz.WARNING)
            return (False, None)
        connections = tree.findall(data_path)
        netconnections_list = []
        for connection in connections:
            this_connection = netconnectionObj()
            this_connection.state = connection.get('state').strip()
            this_connection.valid = bool(connection.get('valid'))
            this_connection.type = connection.get('type').strip()
            remote_ip_tag = connection.find('/'.join([REMOTE_IP_TAG, IPV4_TAG]))
            local_ip_tag = connection.find('/'.join([LOCAL_IP_TAG, IPV4_TAG]))
            this_connection.iptype = 'ipv4'
            if (local_ip_tag is None):
                remote_ip_tag = connection.find('/'.join([REMOTE_IP_TAG, IPV6_TAG]))
                local_ip_tag = connection.find('/'.join([LOCAL_IP_TAG, IPV6_TAG]))
                this_connection.iptype = 'ipv6'
            if (local_ip_tag is None):
                continue
            this_connection.localaddress = local_ip_tag.text.strip().split('%')[0]
            this_connection.remoteaddress = remote_ip_tag.text.strip().split('%')[0]
            if (this_connection.localaddress == '127.0.0.1'):
                continue
            local_port_tag = connection.find(LOCAL_PORT_TAG)
            remote_port_tag = connection.find(REMOTE_PORT_TAG)
            this_connection.localport = int(local_port_tag.text.strip())
            this_connection.remoteport = int(remote_port_tag.text.strip())
            pid_tag = connection.find('/'.join([PID_TAG]))
            this_connection.pid = int(pid_tag.text.strip())
            this_connection.target = this_connection.remoteaddress
            netconnections_list.append(this_connection)
        return (True, netconnections_list)

    def check_escalation(self, escalation_rule, connection):
        netconnections = connection
        try:
            if eval(escalation_rule):
                return True
            else:
                return False
        except:
            return False

    def verify_escalation(self, escalation_rule):
        netconnections = netconnectionObj()
        try:
            eval_res = eval(escalation_rule)
            if ((eval_res == True) or (eval_res == False)):
                return True
            else:
                return False
        except:
            return False