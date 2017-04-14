
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('groups' not in cmd_definitions):
    dszgroup = OpsClass('group', {'groupid': OpsField('groupid', dsz.TYPE_INT), 'group': OpsField('group', dsz.TYPE_STRING), 'comment': OpsField('comment', dsz.TYPE_STRING), 'attributes': OpsClass('attributes', {'mask': OpsField('mask', dsz.TYPE_STRING), 'groupmandatory': OpsField('groupmandatory', dsz.TYPE_BOOL), 'groupenabled': OpsField('groupenabled', dsz.TYPE_BOOL), 'grouplogonid': OpsField('grouplogonid', dsz.TYPE_BOOL), 'groupresource': OpsField('groupresource', dsz.TYPE_BOOL), 'groupenabledbydefault': OpsField('groupenabledbydefault', dsz.TYPE_BOOL), 'groupusefordenyonly': OpsField('groupusefordenyonly', dsz.TYPE_BOOL), 'groupowner': OpsField('groupowner', dsz.TYPE_STRING)}, DszObject)}, DszObject, single=False)
    groupscommand = OpsClass('groups', {'group': dszgroup}, DszCommandObject)
    cmd_definitions['groups'] = groupscommand