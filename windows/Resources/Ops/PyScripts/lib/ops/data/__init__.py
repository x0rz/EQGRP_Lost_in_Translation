
import json
import sys, traceback
import dsz, dsz.cmd
import sqlite3
import ops.db
import ops.project
import datetime
from _errordata import getErrorFromCommandId, getLastError
IMPORT_MAP = {'time': 'dsztime'}

class OpsObject(object, ):

    def __init__(self, debug=False, datadict=None, cmdname=''):
        self.timestamp = datetime.datetime.now()
        if (datadict is not None):
            _load_cmd_json(datadict, cmdname)

    def _get_objage(self):
        if hasattr(self, 'cache_timestamp'):
            return (datetime.datetime.now() - self.cache_timestamp)
        else:
            raise Exception("Can't tell how old this data is!")
    dszobjage = property(_get_objage)

class OpsField(object, ):

    def __init__(self, name, dsztype, single=True):
        self.name = name
        self.dsztype = dsztype
        self.single = single

class OpsClass(OpsField, ):

    def __init__(self, name, fields, classobj=OpsObject, single=True):
        OpsField.__init__(self, name, dsz.TYPE_OBJECT, single)
        self.fields = fields
        self.classobj = classobj

def _ensure_definition(cmdname):
    if (cmdname not in cmd_definitions):
        if (cmdname in IMPORT_MAP):
            impname = IMPORT_MAP[cmdname]
        else:
            impname = cmdname
        try:
            __import__(('ops.data.%s' % impname))
        except ImportError:
            raise ImportError(('Could not find a data format for your command %s' % cmdname))

def make_dsz_object_from_row(row):
    jdict = json.loads(row['data'])
    retval = _load_cmd_json(jdict)
    retval.timestamp = datetime.datetime.fromtimestamp(float(row['timestamp']))
    metadata = OpsObject()
    for key in ['id', 'name', 'screenlog', 'parentid', 'taskid', 'destination', 'source', 'isrunning', 'status', 'bytessent', 'bytesreceived', 'fullcommand']:
        metadata.__setattr__(key, row[key])
    for listkey in ['xmllog', 'prefix', 'argument']:
        metadata.__setattr__(listkey, list())
        for item in row[key].split(','):
            metadata.__getattribute__(listkey).append(item)
    metadata.__setattr__('child', list())
    for item in row['children'].split(','):
        if (item == ''):
            break
        childid = OpsObject()
        childid.__setattr__('id', int(item))
        metadata.__getattribute__('child').append(childid)
    retval.__setattr__('commandmetadata', metadata)
    return retval

def getDszObject(cmdid=None, dszpath='', opsclass=None, dszparent=None, cmdname='', debug=False, instance_num=None, **kwargs):
    if (opsclass is not None):
        return opsclass.classobj(cmdid, cmdname, debug, **kwargs)
    elif (dszpath == ''):
        if ((cmdid is not None) or (instance_num is not None)):
            voldb = ops.db.open_or_create_voldb()
            if (instance_num is None):
                instance_num = ops.db.getInstanceNum()
            row = voldb.connection.execute('SELECT * FROM command WHERE instance_guid = ? and id = ?', (instance_num, cmdid)).fetchone()
            if (row is not None):
                return make_dsz_object_from_row(row)
        elif (cmdid == 0):
            cmdid = dsz.cmd.data.ObjectGet('commandmetadata', 'id', dsz.TYPE_INT)[0]
        if (cmdname == ''):
            cmdname = dsz.cmd.data.ObjectGet('CommandMetadata', 'Name', dsz.TYPE_STRING, cmdid)[0]
        _ensure_definition(cmdname)
        return cmd_definitions[cmdname].classobj(cmdid, cmdname, debug, **kwargs)
    else:
        raise NotImplementedError('You cannot currently use this function to directly create sub-objects')

class DszObject(OpsObject, ):

    def __init__(self, dszpath='', cmdid=None, opsclass=None, dszparent=None, debug=False, **kwargs):
        if (cmdid is not None):
            self.cmdid = cmdid
        self.dszparent = dszparent
        self.opsclass = opsclass
        self.update(dszpath, cmdid, opsclass, debug, **kwargs)

    def __getattribute__(self, name):
        return object.__getattribute__(self, name)

    def __setattr__(self, name, val):
        return object.__setattr__(self, name, val)

    def update(self, dszpath, cmdid=None, opsclass=None, debug=False, **kwargs):
        if (cmdid is None):
            if (self.cmdid is None):
                self.cmdid = self.dszparent.cmdid
            cmdid = self.cmdid
        for fieldname in self.opsclass.fields:
            field = self.opsclass.fields[fieldname]
            try:
                if field.single:
                    if (field.dsztype == dsz.TYPE_OBJECT):
                        self.__setattr__(fieldname, field.classobj(((dszpath + '::') + field.name), cmdid, field, self, debug, **kwargs))
                    elif (field.dsztype == dsz.TYPE_STRING):
                        self.__setattr__(fieldname, unicode(dsz.cmd.data.ObjectGet(dszpath, field.name, field.dsztype, cmdid)[0], 'utf_8'))
                    elif (field.dsztype == dsz.TYPE_BOOL):
                        self.__setattr__(fieldname, bool(dsz.cmd.data.ObjectGet(dszpath, field.name, field.dsztype, cmdid)[0]))
                    else:
                        self.__setattr__(fieldname, dsz.cmd.data.ObjectGet(dszpath, field.name, field.dsztype, cmdid)[0])
                elif (field.dsztype == dsz.TYPE_OBJECT):
                    if (not hasattr(self, fieldname)):
                        self.__setattr__(fieldname, list())
                        start = 0
                    else:
                        start = len(self.__getattribute__(fieldname))
                    for i in range(0, start):
                        self.__getattribute__(fieldname)[i].update(('%s::%s[%d]' % (dszpath, field.name, i)))
                    for i in range(start, len(dsz.cmd.data.ObjectGet(dszpath, field.name, field.dsztype, cmdid))):
                        self.__getattribute__(fieldname).append(field.classobj(('%s::%s[%d]' % (dszpath, field.name, i)), cmdid, field, self, debug, **kwargs))
                elif (field.dsztype == dsz.TYPE_STRING):
                    self.__setattr__(fieldname, map((lambda x: unicode(x, 'utf_8')), dsz.cmd.data.ObjectGet(dszpath, field.name, field.dsztype, cmdid)))
                elif (field.dsztype == dsz.TYPE_BOOL):
                    self.__setattr__(fieldname, map((lambda x: bool(x)), dsz.cmd.data.ObjectGet(dszpath, field.name, field.dsztype, cmdid)))
                else:
                    self.__setattr__(fieldname, dsz.cmd.data.ObjectGet(dszpath, field.name, field.dsztype, cmdid))
            except RuntimeError as ex:
                self.__setattr__(fieldname, None)
                if debug:
                    traceback.print_exc(sys.exc_info())

    def __getcmdid(self):
        if hasattr(self, '_cmdid'):
            return self._cmdid
        else:
            return self.dszparent.cmdid

    def __setcmdid(self, val):
        self._cmdid = val
    cmdid = property(__getcmdid, __setcmdid)

    def _get_objage(self):
        if (self.dszparent is not None):
            return self.dszparent._get_objage()
        else:
            return OpsObject._get_objage(self)
    dszobjage = property(_get_objage)
OPSMETADATA = 'opsmetadata'

class DszCommandObject(DszObject, ):

    def __init__(self, cmdid=None, cmdname=None, debug=False, dszpydataformat=None, **kwargs):
        self.dszparent = None
        if (cmdid is None):
            cmdid = dsz.cmd.data.ObjectGet('commandmetadata', 'id', dsz.TYPE_INT)[0]
            self.cmdid = cmdid
        else:
            self.cmdid = cmdid
        if (cmdname is None):
            self.cmdname = dsz.cmd.data.ObjectGet('CommandMetadata', 'Name', dsz.TYPE_STRING, cmdid)[0]
        else:
            self.cmdname = cmdname
        if (self.cmdname == 'python'):
            if dszpydataformat:
                self.cmdname = dszpydataformat
            else:
                try:
                    self.cmdname = dsz.cmd.data.ObjectGet(OPSMETADATA, 'name', dsz.TYPE_STRING, cmdid)[0]
                except RuntimeError:
                    pass
        if (self.cmdname not in cmd_definitions):
            try:
                exec ('import ops.data.%s' % self.cmdname)
            except:
                raise ImportError('Could not find a data format for your command')
        if (type(self) == DszCommandObject):
            self.update(debug, **kwargs)
        self.opsclass = cmd_definitions[self.cmdname]

    def _updateMeta(self, debug=False):
        self.commandmetadata = DszCommandMetaData('commandmetadata', self.cmdid, cmd_metadata, self, debug)

    def update(self, debug=False, **kwargs):
        self._updateMeta(debug)
        fieldlist = cmd_definitions[self.cmdname].fields
        for fieldname in fieldlist:
            field = fieldlist[fieldname]
            try:
                if field.single:
                    if (field.dsztype == dsz.TYPE_OBJECT):
                        if hasattr(self, fieldname):
                            self.__getattribute__(fieldname).update(fieldname)
                        else:
                            self.__setattr__(fieldname, field.classobj(fieldname, self.cmdid, field, self, debug, **kwargs))
                    elif (field.dsztype == dsz.TYPE_STRING):
                        self.__setattr__(fieldname, unicode(dsz.cmd.data.Get(fieldname, field.dsztype, self.cmdid)[0], 'utf_8'))
                    elif (field.dsztype == dsz.TYPE_BOOL):
                        self.__setattr__(fieldname, bool(dsz.cmd.data.Get(fieldname, field.dsztype, self.cmdid)[0]))
                    else:
                        self.__setattr__(fieldname, dsz.cmd.data.Get(fieldname, field.dsztype, self.cmdid)[0])
                elif (field.dsztype == dsz.TYPE_OBJECT):
                    if (not hasattr(self, fieldname)):
                        self.__setattr__(fieldname, list())
                        start = 0
                    else:
                        start = len(self.__getattribute__(fieldname))
                    for i in range(0, start):
                        self.__getattribute__(fieldname)[i].update(('%s[%d]' % (fieldname, i)))
                    for i in range(start, len(dsz.cmd.data.Get(fieldname, field.dsztype, self.cmdid))):
                        self.__getattribute__(fieldname).append(field.classobj(('%s[%d]' % (fieldname, i)), self.cmdid, field, self, debug, **kwargs))
                elif (field.dsztype == dsz.TYPE_STRING):
                    self.__setattr__(fieldname, map((lambda x: unicode(x, 'utf_8')), dsz.cmd.data.Get(fieldname, field.dsztype, self.cmdid)))
                elif (field.dsztype == dsz.TYPE_BOOL):
                    self.__setattr__(fieldname, bool(dsz.cmd.data.Get(fieldname, field.dsztype, self.cmdid)))
                else:
                    self.__setattr__(fieldname, dsz.cmd.data.Get(fieldname, field.dsztype, self.cmdid))
            except:
                self.__setattr__(fieldname, None)
                if debug:
                    traceback.print_exc(sys.exc_info())

class DszCommandMetaData(DszObject, ):

    def __init__(self, dszpath='', cmdid=None, opsclass=None, parent=None, debug=False):
        DszObject.__init__(self, dszpath, cmdid, cmd_metadata, parent, debug)
        self._friendlyerrors = None

    @property
    def friendlyerrors(self):
        if (self._friendlyerrors is None):
            self._friendlyerrors = getErrorFromCommandId(cmdid=self.id)
        return self._friendlyerrors
cmd_metadata = OpsClass('commandmetadata', {'id': OpsField('id', dsz.TYPE_INT), 'name': OpsField('name', dsz.TYPE_STRING), 'xmllog': OpsField('xmllog', dsz.TYPE_STRING), 'screenlog': OpsField('screenlog', dsz.TYPE_STRING), 'parentid': OpsField('parentid', dsz.TYPE_INT), 'taskid': OpsField('taskid', dsz.TYPE_INT), 'destination': OpsField('destination', dsz.TYPE_STRING), 'source': OpsField('source', dsz.TYPE_STRING), 'isrunning': OpsField('isrunning', dsz.TYPE_BOOL), 'status': OpsField('status', dsz.TYPE_INT), 'bytessent': OpsField('bytessent', dsz.TYPE_INT), 'bytesreceived': OpsField('bytesreceived', dsz.TYPE_INT), 'fullcommand': OpsField('fullcommand', dsz.TYPE_STRING), 'prefix': OpsField('prefix', dsz.TYPE_STRING, single=False), 'argument': OpsField('argument', dsz.TYPE_STRING, single=False), 'child': OpsClass('child', {'id': OpsField('id', dsz.TYPE_INT)}, DszObject, single=False)}, DszCommandMetaData)
cmd_definitions = {}
null_data_commands = ['redirect', 'stop']
for null_data in null_data_commands:
    cmd_definitions[null_data] = OpsClass(null_data, {}, DszCommandObject)

def register_null_command(cmdname):
    cmd_definitions[cmdname] = OpsClass(cmdname, {}, DszCommandObject)

def getDszObjectJSON(dszobj):
    return json.dumps(dszobj, default=_cmd_data_json_encoder)

def _cmd_data_json_encoder(dszobj):
    retval = _dump_json(dszobj)
    retval['cmdname'] = dszobj.cmdname
    retval['cmdid'] = dszobj.cmdid
    return retval

def _dump_json(dszobj):
    retval = dict()
    for fieldname in dszobj.opsclass.fields:
        field = dszobj.opsclass.fields[fieldname]
        if (field.dsztype == dsz.TYPE_OBJECT):
            if field.single:
                retval[fieldname] = _dump_json(dszobj.__dict__[fieldname])
            else:
                retval[fieldname] = list()
                for obj in dszobj.__dict__[fieldname]:
                    if (obj is None):
                        retval[fieldname] = None
                    else:
                        retval[fieldname].append(_dump_json(obj))
        else:
            retval[fieldname] = dszobj.__dict__[fieldname]
    return retval

def _load_cmd_json(bigdict, cmdname=''):
    retval = OpsObject()
    if (('cmdname' not in bigdict) and (cmdname == '')):
        return
    elif ('cmdname' in bigdict):
        cmdname = bigdict['cmdname']
    if ('cmdid' in bigdict):
        retval.cmdid = bigdict['cmdid']
    else:
        retval.cmdid = (-1)
    _ensure_definition(cmdname)
    retval.opsclass = cmd_definitions[cmdname]
    retval.cmdname = cmdname
    for key in bigdict:
        if (key in ['cmdid', 'cmdname']):
            continue
        field = retval.opsclass.fields[key]
        if (field.dsztype == dsz.TYPE_OBJECT):
            if field.single:
                if (bigdict[key] is None):
                    retval.__dict__[key] = None
                else:
                    retval.__dict__[key] = _load_json(retval, field, bigdict[key])
            else:
                retval.__dict__[key] = list()
                for objstr in bigdict[key]:
                    retval.__dict__[key].append(_load_json(retval, field, objstr))
        else:
            retval.__dict__[key] = bigdict[key]
    return retval

def _load_json(parent, opsclass, bigdict):
    retval = OpsObject()
    retval.dszparent = parent
    for key in bigdict:
        if (key in ['cmdid', 'cmdname']):
            continue
        field = opsclass.fields[key]
        if (field.dsztype == dsz.TYPE_OBJECT):
            if field.single:
                if (bigdict[key] is None):
                    retval.__dict__[key] = None
                else:
                    retval.__dict__[key] = _load_json(retval, field, bigdict[key])
            else:
                retval.__dict__[key] = list()
                for objstr in bigdict[key]:
                    retval.__dict__[key].append(_load_json(retval, field, objstr))
        else:
            retval.__dict__[key] = bigdict[key]
    return retval

def script_export(dataobj):
    import dsz.script

    def _recurse(dataobj, level):
        if (type(dataobj) is list):
            for obj in dataobj:
                dsz.script.data.Start(obj.opsclass.name)
                _recurse(obj, (level + 1))
                if (level == 0):
                    dsz.script.data.Store()
                else:
                    dsz.script.data.End()
        else:
            for fieldname in dataobj.opsclass.fields:
                if (dataobj.opsclass.fields[fieldname].dsztype == dsz.TYPE_OBJECT):
                    _recurse(dataobj.__getattribute__(fieldname), level)
                else:
                    x = dataobj.__getattribute__(fieldname)
                    if (level < 1):
                        raise RuntimeError, 'cannot properly export the data format; attempt to add data before starting a data object will result in a DszLpCore crash.'
                    if (type(x) is list):
                        for i in x:
                            dsz.script.data.Add(fieldname, (i.encode('utf8') if (unicode is type(i)) else str(i)), dataobj.opsclass.fields[fieldname].dsztype)
                    else:
                        dsz.script.data.Add(fieldname, (x.encode('utf8') if (unicode is type(x)) else str(x)), dataobj.opsclass.fields[fieldname].dsztype)
    dsz.script.data.Start(OPSMETADATA)
    _recurse(dataobj.commandmetadata, level=1)
    dsz.script.data.Store()
    _recurse(dataobj, level=0)