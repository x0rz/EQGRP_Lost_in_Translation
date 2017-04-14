
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
import datetime

class TimeData(DszObject, ):

    def __init__(self, dszpath='', cmdid=None, opsclass=None, parent=None, debug=False):
        DszObject.__init__(self, dszpath, cmdid, (opsclass if opsclass else dsztime), parent, debug)
        self.__friendlyGMTTime = None
        self.__friendlyLocalTime = None
        self.__friendlyBias = None
        self.__skew = None
        self.__datainit = datetime.datetime.utcnow()
        self.__commandstart = None

    @property
    def friendlyGMTTime(self):
        if (self.__friendlyGMTTime is None):
            self.__friendlyGMTTime = datetime.datetime.utcfromtimestamp(self.gmttimeseconds.value)
        return self.__friendlyGMTTime

    @property
    def friendlyLocalTime(self):
        if (self.__friendlyLocalTime is None):
            self.__friendlyLocalTime = datetime.datetime.utcfromtimestamp(self.localtimeseconds.value)
        return self.__friendlyLocalTime

    @property
    def skew(self):
        if (self.__skew is None):
            self.__skew = (self.datainit - self.friendlyGMTTime)
        return self.__skew

    @property
    def datainit(self):
        return self.__datainit

    @property
    def friendlyBias(self):
        return (self.friendlyLocalTime - self.friendlyGMTTime)
if ('time' not in cmd_definitions):
    dsztime = OpsClass('timeitem', {'localtime': OpsClass('localtime', {'time': OpsField('time', dsz.TYPE_STRING), 'nanoseconds': OpsField('nanoseconds', dsz.TYPE_STRING), 'date': OpsField('date', dsz.TYPE_STRING)}, DszObject), 'gmttime': OpsClass('gmttime', {'time': OpsField('time', dsz.TYPE_STRING), 'nanoseconds': OpsField('nanoseconds', dsz.TYPE_STRING), 'date': OpsField('date', dsz.TYPE_STRING)}, DszObject), 'localtimeseconds': OpsClass('localtimeseconds', {'value': OpsField('value', dsz.TYPE_INT)}, DszObject), 'gmttimeseconds': OpsClass('gmttimeseconds', {'value': OpsField('value', dsz.TYPE_INT)}, DszObject), 'daylightsavingstime': OpsClass('daylightsavingstime', {'standard': OpsClass('standard', {'month': OpsField('month', dsz.TYPE_INT), 'day': OpsField('day', dsz.TYPE_INT), 'week': OpsField('week', dsz.TYPE_INT), 'name': OpsField('name', dsz.TYPE_STRING), 'bias': OpsField('bias', dsz.TYPE_STRING)}, DszObject), 'daylight': OpsClass('daylight', {'month': OpsField('month', dsz.TYPE_INT), 'day': OpsField('day', dsz.TYPE_INT), 'week': OpsField('week', dsz.TYPE_INT), 'name': OpsField('name', dsz.TYPE_STRING), 'bias': OpsField('bias', dsz.TYPE_STRING)}, DszObject)}, DszObject), 'currentstate': OpsField('currentstate', dsz.TYPE_STRING), 'bias': OpsField('bias', dsz.TYPE_STRING)}, TimeData)
    timecommand = OpsClass('time', {'timeitem': dsztime}, DszCommandObject)
    cmd_definitions['time'] = timecommand