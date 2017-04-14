
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('commands' not in cmd_definitions):
    commanditem = OpsClass('command', {'parentid': OpsField('parentid', dsz.TYPE_INT), 'id': OpsField('id', dsz.TYPE_INT), 'commandastyped': OpsField('commandastyped', dsz.TYPE_STRING), 'targetaddress': OpsField('targetaddress', dsz.TYPE_STRING), 'bytessent': OpsField('bytessent', dsz.TYPE_INT), 'bytesreceived': OpsField('bytesreceived', dsz.TYPE_INT), 'status': OpsField('status', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING), 'fullcommand': OpsField('fullcommand', dsz.TYPE_STRING), 'thread': OpsClass('thread', {'exception': OpsField('exception', dsz.TYPE_BOOL), 'cmdid': OpsField('cmdid', dsz.TYPE_INT), 'rpcid': OpsField('rpcid', dsz.TYPE_INT), 'id': OpsField('id', dsz.TYPE_INT), 'interface': OpsField('interface', dsz.TYPE_STRING), 'provider': OpsField('provider', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject, single=False)
    commandcommand = OpsClass('commands', {'command': commanditem}, DszCommandObject, single=False)
    cmd_definitions['commands'] = commandcommand