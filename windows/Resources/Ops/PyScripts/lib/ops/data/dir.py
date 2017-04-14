
import ops.data, ops
import dsz
import sys, traceback
import os.path

class DirCommandObject(ops.data.DszCommandObject, ):

    def __init__(self, cmdid=None, cmdname='', debug=False, filelimit=20000, **kwargs):
        ops.data.DszCommandObject.__init__(self, cmdid, cmdname, debug)
        self.diritem = []
        self.filelimit = filelimit
        self.update(debug)

    def update(self, debug=False):
        self._updateMeta(debug)
        numdirs = len(dsz.cmd.data.Get('diritem', dsz.TYPE_OBJECT, self.cmdid))
        if (numdirs == 0):
            return
        numfiles = len(dsz.cmd.data.Get('diritem::fileitem', dsz.TYPE_OBJECT, self.cmdid))
        if (numfiles > self.filelimit):
            ops.warn(('Too many results (%d/%s), bailing to protect you' % (numfiles, self.filelimit)))
            raise RuntimeError('Too large of a result set to process')
        paths = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING, self.cmdid)
        try:
            denieds = dsz.cmd.data.Get('diritem::denied', dsz.TYPE_BOOL, self.cmdid)
        except:
            denieds = ([False] * len(paths))
        for i in range(len(self.diritem), len(paths)):
            self.diritem.append(DirItemObject(('diritem[%d]' % i), self.cmdid, self, debug))
            self.diritem[i].denied = denieds[i]
            self.diritem[i].path = unicode(paths[i], 'utf_8')

class DirItemObject(ops.data.DszObject, ):

    def __init__(self, dszpath='diritem[0]', cmdid=None, parent=None, debug=False):
        self.fileitem = []
        ops.data.DszObject.__init__(self, dszpath, cmdid, diritem, parent, debug)

    def update(self, dszpath='', cmdid=None, opsclass=None, debug=False):
        fileiteminfos = {}
        numfiles = len(dsz.cmd.data.Get('diritem::fileitem', dsz.TYPE_OBJECT, cmdid))
        for fieldname in fileitem.fields:
            field = fileitem.fields[fieldname]
            if ((type(field) != ops.data.OpsClass) and field.single):
                try:
                    fileiteminfos[fieldname] = dsz.cmd.data.ObjectGet((dszpath + '::fileitem'), fieldname, field.dsztype, cmdid)
                    if (field.dsztype == dsz.TYPE_STRING):
                        fileiteminfos[fieldname] = map((lambda x: unicode(x, 'utf_8')), fileiteminfos[fieldname])
                except:
                    fileiteminfos[fieldname] = None
                    if debug:
                        traceback.print_exc(sys.exc_info())
        if (fileiteminfos['name'] is None):
            return
        for fieldname in fileattributes.fields:
            field = fileattributes.fields[fieldname]
            try:
                fileiteminfos[fieldname] = dsz.cmd.data.ObjectGet((dszpath + '::fileitem::attributes'), fieldname, field.dsztype, cmdid)
                if (field.dsztype == dsz.TYPE_STRING):
                    fileiteminfos[fieldname] = map((lambda x: unicode(x, 'utf_8')), fileiteminfos[fieldname])
            except:
                fileiteminfos[fieldname] = None
                if debug:
                    traceback.print_exc(sys.exc_info())
        for fieldname in filetimes.fields:
            field = filetimes.fields[fieldname]
            try:
                fileiteminfos[(fieldname + 'time')] = dsz.cmd.data.ObjectGet((dszpath + ('::fileitem::filetimes::%s' % fieldname)), 'time', dsz.TYPE_STRING, cmdid)
                fileiteminfos[(fieldname + 'type')] = dsz.cmd.data.ObjectGet((dszpath + ('::fileitem::filetimes::%s' % fieldname)), 'type', dsz.TYPE_STRING, cmdid)
                fileiteminfos[(fieldname + 'time')] = map((lambda x: unicode(x, 'utf_8')), fileiteminfos[(fieldname + 'time')])
                fileiteminfos[(fieldname + 'type')] = map((lambda x: unicode(x, 'utf_8')), fileiteminfos[(fieldname + 'type')])
            except:
                fileiteminfos[fieldname] = None
                if debug:
                    traceback.print_exc(sys.exc_info())
        for i in range(len(fileiteminfos['name'])):
            self.fileitem.append(FileItemObject((dszpath + ('::fileitem[%d]' % i)), cmdid, self, debug))
            curfile = self.fileitem[i]
            for fieldname in filter((lambda x: (fileitem.fields[x].single and (type(fileitem.fields[x]) != ops.data.OpsClass))), fileitem.fields):
                try:
                    curfile.__setattr__(fieldname, fileiteminfos[fieldname][i])
                except:
                    curfile.__setattr__(fieldname, None)
                    if debug:
                        traceback.print_exc(sys.exc_info())
            curfile.attributes = ops.data.OpsObject()
            curfile.attributes.opsclass = fileattributes
            for fieldname in fileattributes.fields:
                field = fileattributes.fields[fieldname]
                try:
                    curfile.attributes.__setattr__(fieldname, fileiteminfos[fieldname][i])
                except:
                    curfile.attributes.__setattr__(fieldname, None)
                    if debug:
                        traceback.print_exc(sys.exc_info())
            curfile.filetimes = ops.data.OpsObject()
            curfile.filetimes.opsclass = filetimes
            for fieldname in filetimes.fields:
                field = filetimes.fields[fieldname]
                try:
                    curfile.filetimes.__setattr__(fieldname, ops.data.OpsObject())
                    curfile.filetimes.__getattribute__(fieldname).opsclass = filetime
                    curfile.filetimes.__getattribute__(fieldname).__setattr__('time', fileiteminfos[(fieldname + 'time')][i])
                    curfile.filetimes.__getattribute__(fieldname).__setattr__('type', fileiteminfos[(fieldname + 'type')][i])
                except:
                    curfile.filetimes.__setattr__(fieldname, None)
                    if debug:
                        traceback.print_exc(sys.exc_info())

class FileItemObject(ops.data.DszObject, ):

    def __init__(self, dszpath='', cmdid=None, parent=None, debug=False):
        self.dszparent = parent
        self.opsclass = fileitem
        self.update(dszpath, cmdid, debug)

    def update(self, dszpath='', cmdid=None, debug=False):
        self.filehash = []
        for ahash in dsz.cmd.data.ObjectGet(dszpath, 'hash', dsz.TYPE_OBJECT):
            self.filehash.append(ops.data.DszObject(ahash, cmdid, filehash, 'dir', debug=True))

    def _getFullPath(self):
        return os.path.join(self.dszparent.path, self.name)
    fullpath = property(_getFullPath)
if ('dir' not in ops.data.cmd_definitions):
    filehash = ops.data.OpsClass('filehash', {'size': ops.data.OpsField('size', dsz.TYPE_INT), 'type': ops.data.OpsField('type', dsz.TYPE_STRING), 'value': ops.data.OpsField('value', dsz.TYPE_STRING)}, ops.data.DszObject, False)
    filetime = ops.data.OpsClass('filetime', {'type': ops.data.OpsField('type', dsz.TYPE_STRING), 'time': ops.data.OpsField('time', dsz.TYPE_STRING)}, ops.data.DszObject)
    filetimes = ops.data.OpsClass('filetimes', {'modified': filetime, 'accessed': filetime, 'created': filetime}, ops.data.DszObject)
    fileattributes = ops.data.OpsClass('attributes', {'directory': ops.data.OpsField('directory', dsz.TYPE_BOOL), 'accessdenied': ops.data.OpsField('accessdenied', dsz.TYPE_BOOL), 'compressed': ops.data.OpsField('compressed', dsz.TYPE_BOOL), 'archive': ops.data.OpsField('archive', dsz.TYPE_BOOL), 'encrypted': ops.data.OpsField('encrypted', dsz.TYPE_BOOL), 'hidden': ops.data.OpsField('hidden', dsz.TYPE_BOOL), 'offline': ops.data.OpsField('offline', dsz.TYPE_BOOL), 'read-only': ops.data.OpsField('read-only', dsz.TYPE_BOOL), 'system': ops.data.OpsField('system', dsz.TYPE_BOOL), 'temporary': ops.data.OpsField('temporary', dsz.TYPE_BOOL), 'afunixfamilysocket': ops.data.OpsField('afunixfamilysocket', dsz.TYPE_BOOL), 'blockspecialfile': ops.data.OpsField('blockspecialfile', dsz.TYPE_BOOL), 'characterspecialfile': ops.data.OpsField('characterspecialfile', dsz.TYPE_BOOL), 'namedpipe': ops.data.OpsField('namedpipe', dsz.TYPE_BOOL), 'symboliclink': ops.data.OpsField('symboliclink', dsz.TYPE_BOOL), 'virtual': ops.data.OpsField('virtual', dsz.TYPE_BOOL), 'notindexed': ops.data.OpsField('notindexed', dsz.TYPE_BOOL), 'device': ops.data.OpsField('device', dsz.TYPE_BOOL)}, ops.data.DszObject)
    fileitem = ops.data.OpsClass('fileitem', {'name': ops.data.OpsField('name', dsz.TYPE_STRING), 'altname': ops.data.OpsField('altname', dsz.TYPE_STRING), 'size': ops.data.OpsField('size', dsz.TYPE_INT), 'filehash': filehash, 'filetimes': filetimes, 'attributes': fileattributes}, FileItemObject, False)
    diritem = ops.data.OpsClass('diritem', {'denied': ops.data.OpsField('denied', dsz.TYPE_BOOL), 'path': ops.data.OpsField('path', dsz.TYPE_STRING), 'fileitem': fileitem}, DirItemObject, False)
    dircommand = ops.data.OpsClass('dir', {'diritem': diritem}, DirCommandObject)
    ops.data.cmd_definitions['dir'] = dircommand