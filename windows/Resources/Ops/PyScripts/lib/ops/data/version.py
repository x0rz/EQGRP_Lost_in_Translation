
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('version' not in cmd_definitions):
    dszversion = OpsClass('versionitem', {'implant': OpsClass('implant', {'compiled': OpsClass('compiled', {'major': OpsField('major', dsz.TYPE_INT), 'minor': OpsField('minor', dsz.TYPE_INT), 'fix': OpsField('fix', dsz.TYPE_INT)}, DszObject, single=True)}, DszObject, single=True), 'listeningpost': OpsClass('listeningpost', {'base': OpsClass('base', {'major': OpsField('major', dsz.TYPE_INT), 'minor': OpsField('minor', dsz.TYPE_INT), 'fix': OpsField('fix', dsz.TYPE_INT), 'build': OpsField('build', dsz.TYPE_INT), 'description': OpsField('description', dsz.TYPE_STRING)}, DszObject, single=True), 'compiled': OpsClass('compiled', {'major': OpsField('major', dsz.TYPE_INT), 'minor': OpsField('minor', dsz.TYPE_INT), 'fix': OpsField('fix', dsz.TYPE_INT)}, DszObject, single=True)}, DszObject, single=True)}, DszObject, single=True)
    versioncommand = OpsClass('version', {'versionitem': dszversion}, DszCommandObject)
    cmd_definitions['version'] = versioncommand