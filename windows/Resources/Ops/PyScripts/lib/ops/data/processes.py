
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions, OpsObject
import dsz
import ops.db
import os.path

class ProcessesCommandData(DszCommandObject, ):

    def __init__(self, cmdid=None, cmdname='', debug=False, **kwargs):
        DszCommandObject.__init__(self, cmdid, cmdname, debug)
        self.update(debug)

    def _getActiveProcessList(self):
        retval = []
        retval.extend(self.initialprocesslistitem.processitem)
        for startevent in self.startprocesslistitem:
            for proc in startevent.processitem:
                retval.append(proc)
        for endevent in self.stopprocesslistitem:
            for proc in endevent.processitem:
                endproc = filter((lambda x: (x.id == proc.id)), retval)
                if (len(endproc) > 0):
                    retval.remove(endproc[0])
        return retval
    processlist = property(_getActiveProcessList)

class ProcessData(DszObject, ):

    def __init__(self, dszpath='', cmdid=None, opsclass=None, parent=None, debug=False):
        DszObject.__init__(self, dszpath, cmdid, dszprocessitem, parent, debug)
        self._friendly = None
        self._proctype = None

    def _populateElistData(self):
        elist = ops.db.Database(ops.db.ELIST)
        curs = elist.connection.execute('SELECT comment, type FROM ProcessInformation WHERE name = ?', (self.name,))
        row = curs.fetchone()
        if (row is not None):
            self._friendly = row['comment']
            self._proctype = row['type']
        else:
            self._friendly = ''
            self._proctype = ''

    def _getFriendlyName(self):
        if (self._friendly is None):
            self._populateElistData()
        return self._friendly
    friendlyname = property(_getFriendlyName)

    def _getFriendlyType(self):
        if (self._proctype is None):
            self._populateElistData()
        return self._proctype
    proctype = property(_getFriendlyType)

    def _getFullBinPath(self):
        if (self.path != ''):
            return os.path.join(self.path, self.name)
        else:
            return self.name
    fullpath = property(_getFullBinPath)
if ('processes' not in cmd_definitions):
    dszprocessitem = OpsClass('processitem', {'id': OpsField('id', dsz.TYPE_INT), 'parentid': OpsField('parentid', dsz.TYPE_INT), 'description': OpsField('description', dsz.TYPE_STRING), 'name': OpsField('name', dsz.TYPE_STRING), 'path': OpsField('path', dsz.TYPE_STRING), 'display': OpsField('display', dsz.TYPE_STRING), 'user': OpsField('user', dsz.TYPE_STRING), 'is64bit': OpsField('is64bit', dsz.TYPE_BOOL), 'created': OpsClass('created', {'typevalue': OpsField('typevalue', dsz.TYPE_INT), 'type': OpsField('type', dsz.TYPE_STRING), 'time': OpsField('time', dsz.TYPE_STRING), 'date': OpsField('date', dsz.TYPE_STRING)}, DszObject), 'cputime': OpsClass('cputime', {'minutes': OpsField('minutes', dsz.TYPE_INT), 'seconds': OpsField('seconds', dsz.TYPE_INT), 'hours': OpsField('hours', dsz.TYPE_INT)}, DszObject)}, ProcessData, single=False)
    dszinitialprocesslistitem = OpsClass('initialprocesslistitem', {'processitem': dszprocessitem}, DszObject)
    dszstartprocesslistitem = OpsClass('startprocesslistitem', {'processitem': dszprocessitem}, DszObject, single=False)
    dszstopprocesslistitem = OpsClass('stopprocesslistitem', {'processitem': dszprocessitem}, DszObject, single=False)
    processescommand = OpsClass('processes', {'initialprocesslistitem': dszinitialprocesslistitem, 'startprocesslistitem': dszstartprocesslistitem, 'stopprocesslistitem': dszstopprocesslistitem}, ProcessesCommandData)
    cmd_definitions['processes'] = processescommand