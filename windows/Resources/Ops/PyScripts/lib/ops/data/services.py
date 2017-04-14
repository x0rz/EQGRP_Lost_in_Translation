
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz

class ServicesCommandData(DszCommandObject, ):

    def __init__(self, cmdid=None, cmdname='', debug=False, **kwargs):
        DszCommandObject.__init__(self, cmdid, cmdname, debug)
        self.update(debug)
        self._quickdict = None

    def _makedict(self):
        self._quickdict = dict()
        for service in self.service:
            self._quickdict[service.servicename.lower()] = service

    def __contains__(self, key):
        key = key.lower()
        if (self._quickdict is None):
            self._makedict()
        return (key in self._quickdict)

    def __getitem__(self, key):
        key = key.lower()
        if (self._quickdict is None):
            self._makedict()
        if (key in self._quickdict):
            return self._quickdict[key]
        raise KeyError(('There is no service named %s in the service list' % key))
if ('services' not in cmd_definitions):
    dszservice = OpsClass('service', {'servicename': OpsField('servicename', dsz.TYPE_STRING), 'state': OpsField('state', dsz.TYPE_STRING), 'displayname': OpsField('displayname', dsz.TYPE_STRING), 'acceptedcodes': OpsClass('acceptedcodes', {'acceptspowerevent': OpsField('acceptspowerevent', dsz.TYPE_BOOL), 'acceptsshutdown': OpsField('acceptsshutdown', dsz.TYPE_BOOL), 'acceptsnetbindchange': OpsField('acceptsnetbindchange', dsz.TYPE_BOOL), 'acceptspausecontinue': OpsField('acceptspausecontinue', dsz.TYPE_BOOL), 'acceptshardwareprofchange': OpsField('acceptshardwareprofchange', dsz.TYPE_BOOL), 'acceptsparamchange': OpsField('acceptsparamchange', dsz.TYPE_BOOL), 'acceptssessionchange': OpsField('acceptssessionchange', dsz.TYPE_BOOL), 'acceptsstop': OpsField('acceptsstop', dsz.TYPE_BOOL), 'value': OpsField('value', dsz.TYPE_INT)}, DszObject, single=True), 'servicetype': OpsClass('servicetype', {'servicesharesprocess': OpsField('servicesharesprocess', dsz.TYPE_BOOL), 'servicefilesystemdriver': OpsField('servicefilesystemdriver', dsz.TYPE_BOOL), 'serviceownprocess': OpsField('serviceownprocess', dsz.TYPE_BOOL), 'servicedevicedriver': OpsField('servicedevicedriver', dsz.TYPE_BOOL), 'serviceinteractiveprocess': OpsField('serviceinteractiveprocess', dsz.TYPE_BOOL), 'value': OpsField('value', dsz.TYPE_INT)}, DszObject, single=True)}, DszObject, single=False)
    servicescommand = OpsClass('services', {'service': dszservice}, ServicesCommandData)
    cmd_definitions['services'] = servicescommand