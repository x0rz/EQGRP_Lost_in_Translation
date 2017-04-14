
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('domaincontroller' not in cmd_definitions):
    dszdomaincontroller = OpsClass('domaincontroller', {'domainname': OpsField('domainname', dsz.TYPE_STRING), 'dcsitename': OpsField('dcsitename', dsz.TYPE_STRING), 'dnsforestname': OpsField('dnsforestname', dsz.TYPE_STRING), 'dcname': OpsField('dcname', dsz.TYPE_STRING), 'clientsitename': OpsField('clientsitename', dsz.TYPE_STRING), 'dcaddress': OpsField('dcaddress', dsz.TYPE_STRING), 'domainguid': OpsField('domainguid', dsz.TYPE_STRING), 'dcfullname': OpsField('dcfullname', dsz.TYPE_STRING)}, DszObject, single=False)
    domaincontrollercommand = OpsClass('domaincontroller', {'domaincontroller': dszdomaincontroller}, DszCommandObject)
    cmd_definitions['domaincontroller'] = domaincontrollercommand