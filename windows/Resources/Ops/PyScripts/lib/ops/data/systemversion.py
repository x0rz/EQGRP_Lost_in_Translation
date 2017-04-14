
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz

class SystemVersionData(DszObject, ):

    def __init__(self, dszpath='', cmdid=None, opsclass=None, parent=None, debug=False):
        DszObject.__init__(self, dszpath, cmdid, dszversioninfo, parent, debug)
        self._friendlyplatform = None

    @property
    def friendlyplatform(self):
        if (self._friendlyplatform is None):
            if (self.major == 5):
                if (self.minor == 0):
                    self._friendlyplatform = 'Windows 2000'
                elif (self.minor == 1):
                    self._friendlyplatform = 'Windows XP'
                elif (self.minor == 2):
                    if self.flags.workstation:
                        self._friendlyplatform = 'Windows XP'
                    else:
                        self._friendlyplatform = 'Windows 2003'
            elif (self.major == 6):
                if (self.minor == 0):
                    if self.flags.workstation:
                        self._friendlyplatform = 'Windows Vista'
                    else:
                        self._friendlyplatform = 'Windows 2008'
                elif (self.minor == 1):
                    if self.flags.workstation:
                        self._friendlyplatform = 'Windows 7'
                    else:
                        self._friendlyplatform = 'Windows 2008 R2'
                elif (self.minor == 2):
                    if self.flags.workstation:
                        self._friendlyplatform = 'Windows 8'
                    else:
                        self._friendlyplatform = 'Windows 2012'
            assert (self._friendlyplatform is not None), 'Could not determine friendly name of platform; must be Windows Super Special Awesome, which is unsupported.'
        return self._friendlyplatform
if ('systemversion' not in cmd_definitions):
    dszversioninfo = OpsClass('versioninfo', {'minor': OpsField('minor', dsz.TYPE_INT), 'revisionminor': OpsField('revisionminor', dsz.TYPE_INT), 'revisionmajor': OpsField('revisionmajor', dsz.TYPE_INT), 'build': OpsField('build', dsz.TYPE_INT), 'major': OpsField('major', dsz.TYPE_INT), 'platform': OpsField('platform', dsz.TYPE_STRING), 'arch': OpsField('arch', dsz.TYPE_STRING), 'extrainfo': OpsField('extrainfo', dsz.TYPE_STRING), 'flags': OpsClass('flags', {'smallbusiness': OpsField('smallbusiness', dsz.TYPE_BOOL), 'datacenter': OpsField('datacenter', dsz.TYPE_BOOL), 'enterprise': OpsField('enterprise', dsz.TYPE_BOOL), 'workstation': OpsField('workstation', dsz.TYPE_BOOL), 'embeddednt': OpsField('embeddednt', dsz.TYPE_BOOL), 'personal': OpsField('personal', dsz.TYPE_BOOL), 'smallbusinessrestricted': OpsField('smallbusinessrestricted', dsz.TYPE_BOOL), 'terminal': OpsField('terminal', dsz.TYPE_BOOL), 'domaincontroller': OpsField('domaincontroller', dsz.TYPE_BOOL), 'singleuserts': OpsField('singleuserts', dsz.TYPE_BOOL), 'blade': OpsField('blade', dsz.TYPE_BOOL), 'server': OpsField('server', dsz.TYPE_BOOL), 'backoffice': OpsField('backoffice', dsz.TYPE_BOOL), 'value': OpsField('value', dsz.TYPE_INT)}, DszObject, single=True)}, SystemVersionData, single=True)
    systemversioncommand = OpsClass('systemversion', {'versioninfo': dszversioninfo}, DszCommandObject)
    cmd_definitions['systemversion'] = systemversioncommand