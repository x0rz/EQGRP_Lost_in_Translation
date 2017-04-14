
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('arp' not in cmd_definitions):
    dszarp = OpsClass('entry', {'adapter': OpsField('adapter', dsz.TYPE_STRING), 'type': OpsField('type', dsz.TYPE_STRING), 'state': OpsField('state', dsz.TYPE_STRING), 'ip': OpsField('ip', dsz.TYPE_STRING), 'iptype': OpsField('iptype', dsz.TYPE_STRING), 'mac': OpsField('mac', dsz.TYPE_STRING), 'isrouter': OpsField('isrouter', dsz.TYPE_BOOL), 'isunreachable': OpsField('isunreachable', dsz.TYPE_BOOL)}, DszObject, single=False)
    arpcommand = OpsClass('arp', {'entry': dszarp}, DszCommandObject)
    cmd_definitions['arp'] = arpcommand