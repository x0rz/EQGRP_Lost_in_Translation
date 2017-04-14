
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('kisu_survey' not in cmd_definitions):
    kisu_survey_data = OpsClass('persistence', {'method': OpsClass('method', {'type': OpsField('type', dsz.TYPE_STRING), 'compatible': OpsField('compatible', dsz.TYPE_BOOL), 'reason': OpsField('reason', dsz.TYPE_STRING)}, DszObject, single=False)}, DszObject)
    kisu_survey_command = OpsClass('persistence', {'persistence': kisu_survey_data}, DszCommandObject)
    cmd_definitions['kisu_survey'] = kisu_survey_command