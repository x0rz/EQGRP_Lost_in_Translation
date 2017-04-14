
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('activity' not in cmd_definitions):
    dszlastactivity = OpsClass('lastactivity', {'days': OpsField('days', dsz.TYPE_INT), 'hours': OpsField('hours', dsz.TYPE_INT), 'minutes': OpsField('minutes', dsz.TYPE_INT), 'seconds': OpsField('seconds', dsz.TYPE_INT)}, DszObject)
    dsznewactivity = OpsClass('newactivity', {'type': OpsField('type', dsz.TYPE_INT), 'days': OpsField('days', dsz.TYPE_INT), 'hours': OpsField('hours', dsz.TYPE_INT), 'minutes': OpsField('minutes', dsz.TYPE_INT), 'seconds': OpsField('seconds', dsz.TYPE_INT), 'nanos': OpsField('nanos', dsz.TYPE_INT), 'typevalue': OpsField('typevalue', dsz.TYPE_INT)}, DszObject, single=False)
    activitycommand = OpsClass('activity', {'lastactivity': dszlastactivity, 'newactivity': dsznewactivity}, DszCommandObject)
    cmd_definitions['activity'] = activitycommand