
import ops.data, dsz
if ('ldap' not in ops.data.cmd_definitions):
    ldapentries = ops.data.OpsClass('ldapentries', {'ldapentry': ops.data.OpsClass('ldapentry', {'attribute': ops.data.OpsClass('attribute', {'type': ops.data.OpsField('type', dsz.TYPE_STRING), 'value': ops.data.OpsField('value', dsz.TYPE_STRING), 'datatype': ops.data.OpsField('datatype', dsz.TYPE_INT)}, classobj=ops.data.DszObject, single=False)}, classobj=ops.data.DszObject, single=False)}, classobj=ops.data.DszObject, single=False)
    ldapcommand = ops.data.OpsClass('ldap', {'ldapentries': ldapentries}, ops.data.DszCommandObject)
    ops.data.cmd_definitions['ldap'] = ldapcommand