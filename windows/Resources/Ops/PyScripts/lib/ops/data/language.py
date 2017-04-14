
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('language' not in cmd_definitions):
    dszuilanguage = OpsClass('uilanguage', {'value': OpsField('value', dsz.TYPE_INT), 'native': OpsField('native', dsz.TYPE_STRING), 'english': OpsField('english', dsz.TYPE_STRING)}, DszObject)
    dszinstlanguage = OpsClass('installedlanguage', {'value': OpsField('value', dsz.TYPE_INT), 'native': OpsField('native', dsz.TYPE_STRING), 'english': OpsField('english', dsz.TYPE_STRING)}, DszObject)
    dszlocalelanguage = OpsClass('localelanguage', {'value': OpsField('value', dsz.TYPE_INT), 'native': OpsField('native', dsz.TYPE_STRING), 'english': OpsField('english', dsz.TYPE_STRING)}, DszObject)
    dszmultilanguage = OpsClass('oslanguage', {'value': OpsField('value', dsz.TYPE_INT), 'native': OpsField('native', dsz.TYPE_STRING), 'english': OpsField('english', dsz.TYPE_STRING)}, DszObject, single=False)
    dszoslanguages = OpsClass('oslanguages', {'oslanguage': dszmultilanguage}, DszObject)
    languagedata = OpsClass('languages', {'installedlanguage': dszinstlanguage, 'localelanguage': dszlocalelanguage, 'uilanguage': dszuilanguage, 'oslanguages': dszoslanguages}, DszObject)
    languagecommand = OpsClass('languages', {'languages': languagedata}, DszCommandObject)
    cmd_definitions['language'] = languagecommand