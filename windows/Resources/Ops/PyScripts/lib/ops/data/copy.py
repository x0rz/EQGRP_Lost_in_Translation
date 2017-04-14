
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('copy' not in cmd_definitions):
    dszcopy = OpsClass('copyresults', {'destination': OpsField('destination', dsz.TYPE_STRING), 'source': OpsField('source', dsz.TYPE_STRING)}, DszObject)
    copycommand = OpsClass('copy', {'copyresults': dszcopy}, DszCommandObject)
    cmd_definitions['copy'] = copycommand