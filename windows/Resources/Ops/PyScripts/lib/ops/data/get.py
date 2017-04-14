
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('get' not in cmd_definitions):
    dszlocalgetdirectory = OpsClass('localgetdirectory', {'path': OpsField('path', dsz.TYPE_STRING)}, DszObject)
    dszfilestart = OpsClass('filestart', {'id': OpsField('id', dsz.TYPE_STRING), 'filename': OpsField('filename', dsz.TYPE_STRING), 'originalname': OpsField('originalname', dsz.TYPE_STRING), 'size': OpsField('size', dsz.TYPE_INT), 'filetimes': OpsClass('filetimes', {'accessed': OpsClass('accessed', {'time': OpsField('time', dsz.TYPE_STRING), 'locale': OpsField('locale', dsz.TYPE_STRING)}, DszObject), 'created': OpsClass('created', {'time': OpsField('time', dsz.TYPE_STRING), 'locale': OpsField('locale', dsz.TYPE_STRING)}, DszObject), 'modified': OpsClass('modified', {'time': OpsField('time', dsz.TYPE_STRING), 'locale': OpsField('locale', dsz.TYPE_STRING)}, DszObject)}, DszObject)}, DszObject, single=False)
    dszfilelocalname = OpsClass('filelocalname', {'id': OpsField('id', dsz.TYPE_STRING), 'localname': OpsField('localname', dsz.TYPE_STRING), 'subdir': OpsField('subdir', dsz.TYPE_STRING)}, DszObject, single=False)
    dszfilewrite = OpsClass('filewrite', {'id': OpsField('id', dsz.TYPE_STRING), 'bytes': OpsField('bytes', dsz.TYPE_INT)}, DszObject, single=False)
    dszfilestop = OpsClass('filestop', {'id': OpsField('id', dsz.TYPE_STRING), 'successful': OpsField('successful', dsz.TYPE_BOOL), 'written': OpsField('written', dsz.TYPE_INT)}, DszObject, single=False)
    dszconclusion = OpsClass('conclusion', {'numsuccess': OpsField('numsuccess', dsz.TYPE_INT), 'numpartial': OpsField('numpartial', dsz.TYPE_INT), 'numfailed': OpsField('numfailed', dsz.TYPE_INT), 'numskipped': OpsField('numskipped', dsz.TYPE_INT)}, DszObject)
    getcommand = OpsClass('get', {'localgetdirectory': dszlocalgetdirectory, 'filestart': dszfilestart, 'filelocalname': dszfilelocalname, 'filewrite': dszfilewrite, 'filestop': dszfilestop, 'conclusion': dszconclusion}, DszCommandObject)
    cmd_definitions['get'] = getcommand