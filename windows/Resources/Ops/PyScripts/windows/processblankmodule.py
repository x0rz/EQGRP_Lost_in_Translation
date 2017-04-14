
import os, stat, sys
import shutil
import dsz, dsz.env, dsz.version
import ops, ops.db, ops.survey, ops.data
import util
from ops.pprint import pprint
BAD_PROCS = os.path.normpath(('%s/Ops/Data/bad_processes.txt' % ops.RESDIR))

def main(args):
    bad = []
    with open(BAD_PROCS) as input:
        for i in input:
            bad.append(i.strip().lower())
    pids = []
    dsz.control.echo.Off()
    cmd = 'processes -list'
    (succ, proccmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    procobject = None
    try:
        procobject = ops.data.getDszObject(cmdid=proccmdid, cmdname='processes')
    except:
        dsz.ui.Echo('There was an issue with the ops.data.getDszObject.', dsz.ERROR)
        return 0
    ourpid = dsz.env.Get('_PID')
    dsz.ui.Echo('===========================================', dsz.WARNING)
    dsz.ui.Echo(('= We are currently executing from PID %s =' % ourpid), dsz.WARNING)
    dsz.ui.Echo('===========================================', dsz.WARNING)
    proclist = []
    for process in procobject.initialprocesslistitem.processitem:
        if ((process.name == 'System') or (process.name == '') or (process.id == 0)):
            ops.info(('Skipping PID %s (%s)' % (process.id, process.name)))
            continue
        if (process.name.strip().lower() in bad):
            ops.warn(('Skipping PID %s (%s), something might catch us.' % (process.id, process.name)))
            continue
        proclist.append({'pid': process.id, 'name': process.name, 'path': process.path, 'user': process.user})
    for proc in proclist:
        dsz.control.echo.Off()
        cmd = ('processinfo -id %s' % proc['pid'])
        (succ, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
        dsz.control.echo.On()
        if (not succ):
            ops.error(('Could not query process info for PID %s (%s)' % (proc['pid'], proc['name'])))
        else:
            ops.info(('Got processinfo for PID %s (%s)' % (proc['pid'], proc['name'])))
        procinfoobj = None
        try:
            procinfoobj = ops.data.getDszObject(cmdid=cmdid, cmdname='processinfo')
        except:
            dsz.ui.Echo('There was an issue with the ops.data.getDszObject. Please try re-running the command with the same parameters.', dsz.ERROR)
            return 0
        modulelist = []
        zerolist = []
        for module in procinfoobj.processinfo.modules.module:
            outsiderange = False
            if (((module.baseaddress + module.imagesize) < module.entrypoint) or ((module.baseaddress > module.entrypoint) and (module.entrypoint != 0))):
                outsiderange = True
                dsz.ui.Echo(('\tFound module in %s which has an entrypoint outside the image' % proc['pid']), dsz.ERROR)
                dsz.ui.Echo(('\t\tName: %s' % module.modulename), dsz.ERROR)
                dsz.ui.Echo(('\t\tEntry Point: 0x%011x' % module.entrypoint), dsz.ERROR)
                dsz.ui.Echo(('\t\tImage Size: 0x%08x' % module.imagesize), dsz.ERROR)
                dsz.ui.Echo(('\t\tBase Address: 0x%011x' % module.baseaddress), dsz.ERROR)
                for checksum in module.checksum:
                    if (checksum.type is None):
                        continue
                    dsz.ui.Echo(('\t\t\t%s: %s' % (checksum.type, checksum.value)), dsz.ERROR)
            elif ((module.entrypoint == 0) and (not checkzeroentry(module))):
                outsiderange = True
                sha1 = None
                for checksum in module.checksum:
                    if (checksum.type is None):
                        continue
                    if (checksum.type == 'SHA1'):
                        sha1 = checksum.value
                zerolist.append({'base': ('0x%011x' % module.baseaddress), 'img': ('0x%08x' % module.imagesize), 'entry': ('0x%011x' % module.entrypoint), 'modulename': module.modulename, 'sha1': sha1})
            if (module.modulename == ''):
                entrypointoffset = None
                if (not outsiderange):
                    entrypointoffset = ('0x%08x' % (module.entrypoint - module.baseaddress))
                base = ('0x%011x' % module.baseaddress)
                imagesize = ('0x%08x' % module.imagesize)
                entrypoint = ('0x%011x' % module.entrypoint)
                modulelist.append({'base': base, 'img': imagesize, 'entry': entrypoint, 'modulename': module.modulename, 'entrypointoffset': entrypointoffset})
        if (len(zerolist) > 0):
            dsz.ui.Echo('=======================================================', dsz.WARNING)
            dsz.ui.Echo(('= Found modules with entrypoint of 0x00000000 in %s =' % proc['pid']), dsz.WARNING)
            dsz.ui.Echo('=======================================================', dsz.WARNING)
            zerolist.sort(key=(lambda x: x['modulename']))
            pprint(zerolist, ['Entry Point', 'Image Size', 'Base Address', 'Module Name', 'SHA1'], ['entry', 'img', 'base', 'modulename', 'sha1'])
        if (len(modulelist) > 0):
            if (int(proc['pid']) == int(ourpid)):
                dsz.ui.Echo('==========================================================', dsz.WARNING)
                dsz.ui.Echo(('= Found blank modules in %s, which matches our PID %s =' % (proc['pid'], ourpid)), dsz.WARNING)
                dsz.ui.Echo('==========================================================', dsz.WARNING)
            else:
                dsz.ui.Echo('=================================================================', dsz.ERROR)
                dsz.ui.Echo(('= Found blank modules in %s, which DOES NOT match our PID %s =' % (proc['pid'], ourpid)), dsz.ERROR)
                dsz.ui.Echo('=================================================================', dsz.ERROR)
            modulelist.sort(key=(lambda x: x['entry']))
            pprint(modulelist, ['Entry Point', 'Image Size', 'Base Address', 'Entry Point Offset'], ['entry', 'img', 'base', 'entrypointoffset'])

def checkzeroentry(module):
    white_list = [{'name': 'ntdll.dll', 'imagesize': 794624, 'baseaddress': 2088763392}, {'name': 'ntdll.dll', 'imagesize': 1753088, 'baseaddress': 1996226560}, {'name': 'ntdll.dll', 'imagesize': 1748992, 'baseaddress': 1996423168}]
    for item in white_list:
        if ((module.modulename.lower().endswith(item['name']) or (module.modulename == item['name'])) and (item['imagesize'] == module.imagesize) and (item['baseaddress'] == module.baseaddress)):
            return True
    return False
if (__name__ == '__main__'):
    try:
        main(sys.argv[1:])
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)