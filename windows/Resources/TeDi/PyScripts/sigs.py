
import datastore
import utils
import dsz.cmd
import dsz.lp
import os
from utils import limitedget, file_exists, reg_exists

def find_01():
    result = utils.reg_exists('L', 'software\\microsoft\\windows\\currentversion\\StrtdCfg', None, True)
    if result:
        return True
    for key in datastore.HKEY_USERS_DATA:
        result = utils.reg_exists('U', ('%s\\software\\microsoft\\windows\\currentversion\\StrtdCfg' % key), None, True)
        if result:
            return True
    return False

def find_02():
    result = utils.reg_exists('L', 'System\\CurrentControlSet\\Control\\CrashImage', None, True)
    if result:
        return True
    return False

def find_03():
    if ('driver32' in datastore.SYSTEMROOT_FILE_SET):
        return True
    return False

def find_04():
    if ('$NtUninstallQ817473$' in datastore.SYSPATH_FILE_SET):
        return True
    for f in ['Hd1', 'Hd2', 'IdeDrive1', 'IdeDrive2']:
        if utils.file_exists('\\\\.', (f + '\\')):
            return True
    return False

def find_05():
    if ('systmgmt' in datastore.SERVICE_NAME_SET):
        return True
    return False

def find_06():
    if utils.reg_exists('L', 'Software\\Microsoft\\Windows\\CurrentVersion\\policies\\Explorer\\Run\\ipmontr'):
        return True
    if utils.reg_exists('L', 'Software\\Microsoft\\WinKernel\\Explorer\\Run\\ipmontr'):
        return True
    return False

def find_07():
    return utils.reg_exists('L', 'Software\\Microsoft\\Windows\\CurrentVersion\\policies\\Explorer\\Run\\Internet32')

def find_08():
    if ('s7otbxsx.dll' in datastore.SYSTEMROOT_FILE_SET):
        return True
    if ('mrxcls' in datastore.SERVICE_NAME_SET):
        return True
    if utils.file_exists(('%s\\inf' % datastore.SYSPATH_STR), 'mdmcpq3.pnf'):
        return True
    return False

def find_09():
    (cmdStatus, cmdId) = dsz.cmd.RunEx(('dir -mask * -path "%s\\Common Files\\Microsoft Shared"' % datastore.PROGRAM_FILES_STR), dsz.RUN_FLAG_RECORD)
    if (not cmdStatus):
        return False
    try:
        names = dsz.cmd.data.Get('DirItem::FileItem::name', dsz.TYPE_STRING, cmdId)
    except RuntimeError:
        names = None
    if (names is not None):
        if (('msaudio' in names) or ('mssecuritymgr' in names) or ('MSAPackages' in names)):
            return True
    return False

def find_10():
    if ('icsvnt32.dll' in datastore.SYSTEMROOT_FILE_SET):
        return True
    (cmdStatus, cmdId) = dsz.cmd.RunEx('registryquery -hive L -key "SYSTEM\\CurrentControlCet\\Control\\timezoneinformation"', dsz.RUN_FLAG_RECORD)
    if (not cmdStatus):
        return False
    try:
        value_names = dsz.cmd.data.Get('key::value::name', dsz.TYPE_STRING, cmdId)
    except RuntimeError:
        value_names = None
    if (value_names is not None):
        if (('standarddatebias' in value_names) or ('standardtimebias' in value_names)):
            return True
    return False

def find_11():
    if (('ups32.exe' in datastore.PROCESS_NAME_SET) or ('utilman32.exe' in datastore.PROCESS_NAME_SET)):
        return True
    if ('ups32.exe' in datastore.DRIVERPATH_FILE_SET):
        return True
    search_set = set(('ups32.exe', 'utilman32.exe', 'utliman32.exe', 'msvcp11.dll', 'msxml10.dll'))
    if (not datastore.SYSTEMROOT_FILE_SET.isdisjoint(search_set)):
        return True
    return False

def find_12():
    if utils.file_exists(('%s\\All Users\\Application Data' % datastore.PROFILE_PATH), 'Network'):
        return True
    if utils.reg_exists('L', 'Software\\Microsoft\\MSFix'):
        return True
    for key in datastore.HKEY_USERS_DATA:
        if utils.reg_exists('U', ('%s\\Software\\Microsoft\\MSFix' % key)):
            return True
    return False

def find_13():
    if ('WOWmanager' in datastore.SERVICE_NAME_SET):
        return True
    if ('winstat.pdr' in datastore.SYSPATH_FILE_SET):
        return True
    search_set = set(('winview.ocs', 'Mfc42l00.pdb', 'ISUninst.bin', 'mswmpdat.tlb', 'wmmini.swp', 'wowmgr.exe'))
    if (not datastore.SYSTEMROOT_FILE_SET.isdisjoint(search_set)):
        return True
    return False

def find_14():
    valid = False
    if utils.file_exists('c:\\win\\drivers', 'slidebar.exe'):
        vals = ['newval', 'WindowsFirewallSecurityServ', 'slidebar', 'MSDeviceDriver']
        keys = (['SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run'] * len(vals))
        valid = any(map(utils.reg_exists, (['L'] * len(vals)), keys, vals))
    return valid

def find_15():
    if ('TlbControl' in datastore.SERVICE_NAME_SET):
        return True
    if (('tlbcon32.exe' in datastore.SYSTEMROOT_FILE_SET) or ('con32.nls' in datastore.SYSTEMROOT_FILE_SET)):
        return True
    return False

def find_16():
    if ('indsvc32.ocx' in datastore.SYSTEMROOT_FILE_SET):
        return True
    if utils.file_exists(('%s\\temp' % datastore.SYSPATH_STR), 'indsvc32.ocx'):
        return True
    return False

def find_17():
    search_set = set(('ADWM.DLL', 'ASFIPC.DLL', 'BROWUI.DLL', 'CAPESPN.DLL', 'CFGKRNL3.DLL', 'CRYPTKRN.DLL', 'DESKKRNE.DLL', 'DSKMGR.DLL', 'EXPLORED.DLL', 'FMEM.DLL', 'HDDBACK4.DLL', 'HWMAP.DLL', 'ipnetd.dll', 'IPNETD.DLL', 'KNRLADD.DLL', 'MAILAPIC.DLL', 'MSGRTHLP.DLL', 'MSIAXCPL.DLL', 'MSID32.DLL', 'MSRECV40.DLL', 'NCFG.DLL', 'PARALEUI.DLL', 'secur16.dll', 'SECUR16.DLL', 'SOUNDLOC.DLL', 'WINF.DLL', 'WMCRT.DLL'))
    if (not datastore.SYSTEMROOT_FILE_SET.isdisjoint(search_set)):
        return True
    if utils.reg_exists('R', 'Lnkfile\\shellex\\IconHandler', 'OptionFlags'):
        return True
    return False

def find_18():
    if (('msprnt.exe' in datastore.SYSTEMROOT_FILE_SET) or ('fmem.dll' in datastore.SYSTEMROOT_FILE_SET)):
        return True
    search_set = set(('pnppci', 'ethio', 'ntdos505', 'ndisio'))
    if (not datastore.SERVICE_NAME_SET.isdisjoint(search_set)):
        return True
    (cmdStatus, cmdId) = dsz.cmd.RunEx(('dir -mask * -path "%s\\All Users\\Application Data"' % datastore.PROFILE_PATH), dsz.RUN_FLAG_RECORD)
    if (not cmdStatus):
        return False
    try:
        names = dsz.cmd.data.Get('DirItem::FileItem::name', dsz.TYPE_STRING, cmdId)
    except RuntimeError:
        names = None
    if (names is None):
        return False
    if (('msncp.exe' in names) or ('netsvcs.exe' in names)):
        return True
    (cmdStatus, cmdId) = dsz.cmd.RunEx(('dir -mask * -path "%s\\common files\\microsoft shared\\Triedit"' % datastore.PROGRAM_FILES_STR), dsz.RUN_FLAG_RECORD)
    if (not cmdStatus):
        return False
    try:
        names = dsz.cmd.data.Get('DirItem::FileItem::name', dsz.TYPE_STRING, cmdId)
    except RuntimeError:
        names = None
    if (names is None):
        return False
    if (('htmlprsr.exe' in names) or ('dhtmled.dll' in names) or ('TRIEDIT.TLB' in names)):
        return True
    return False

def find_19():
    return ('nsecm.dll' in datastore.SYSTEMROOT_FILE_SET)

def find_20():
    if ('svchost00000000-0000-0000-0000-0000-00000000.dat' in datastore.SYSTEMROOT_FILE_SET):
        return True
    if utils.file_exists(('%s\\All Users\\MSI' % datastore.PROFILE_PATH), 'update.msi'):
        return True
    if utils.file_exists(('%s\\All Users\\Application Data\\MSI' % datastore.PROFILE_PATH), 'update.msi'):
        return True
    if ('ProgramData' in datastore.ENV_VARS):
        prog_data = datastore.ENV_VARS.get('ProgramData')
        if utils.file_exists(('%s\\MSI' % prog_data), 'update.msi'):
            return True
    if utils.file_exists(('%s\\Common Files' % datastore.PROGRAM_FILES_STR), 'wusvcd.exe'):
        return True
    if utils.file_exists(('%s\\Common Files\\%s' % (datastore.PROGRAM_FILES_STR, 'wusvcd')), 'wusvcd.exe'):
        return True
    if (('WinMI32' in datastore.SERVICE_NAME_SET) or ('wusvcd' in datastore.SERVICE_NAME_SET)):
        return True
    if ('Microsoft' in datastore.SYSTEMROOT_FILE_SET):
        if utils.file_exists(('%s\\Microsoft' % datastore.SYSTEMROOT_STR), 'Windows Management Infrastructure'):
            return True
    return False

def find_21():
    if utils.file_exists(('%s\\temp' % datastore.SYSPATH_STR), 'temp56273.pdf'):
        return True
    for ud in datastore.USER_DIRS_LIST:
        if utils.file_exists(('%s\\%s\\Local Settings\\History\\cache' % (datastore.PROFILE_PATH, ud)), 'iecache.dll'):
            return True
    return False

def find_22():
    if utils.file_exists(('%s\\etc' % datastore.DRIVERPATH_STR), 'network.ics'):
        return True
    if ('acelpvc.dll' in datastore.SYSTEMROOT_FILE_SET):
        return True
    (cmdStatus, cmdId) = dsz.cmd.RunEx('registryquery -hive L -key "Software\\Sun\\1.1.2"', dsz.RUN_FLAG_RECORD)
    if (not cmdStatus):
        return False
    try:
        subkeys = dsz.cmd.data.Get('key::subkey::name', dsz.TYPE_STRING, cmdId)
    except RuntimeError:
        subkeys = None
    if (subkeys is not None):
        if (('AppleTlk' in subkeys) or ('IsoTp' in subkeys)):
            return True
    try:
        values = dsz.cmd.data.Get('key::value::name', dsz.TYPE_STRING, cmdId)
    except RuntimeError:
        values = None
    if (values is not None):
        if (('AppleTlk' in values) or ('IsoTp' in values)):
            return True
    return False

def find_23():
    for key in datastore.HKEY_USERS_DATA:
        if utils.reg_exists('U', ('%s\\software\\microsoft\\NetWin' % key)):
            return True
    return False

def find_24():
    if (('mfc64comm.sys' in datastore.DRIVERPATH_FILE_SET) or ('adap64info.sys' in datastore.DRIVERPATH_FILE_SET)):
        return True
    return False

def find_25():
    pass

def find_26():
    if utils.reg_exists('L', 'Software\\Adobe\\Fix'):
        return True
    search_set = set(('result.dat', 'data.dat', 'Acrobat.dll', 'first.tmp'))
    for ud in datastore.USER_DIRS_LIST:
        (cmdStatus, cmdId) = dsz.cmd.RunEx(('dir -mask * -path "%s\\%s\\Local Settings\\Temp"' % (datastore.PROFILE_PATH, ud)), dsz.RUN_FLAG_RECORD)
        if cmdStatus:
            try:
                names = set(dsz.cmd.data.Get('DirItem::FileItem::name', dsz.TYPE_STRING, cmdId))
            except RuntimeError:
                names = None
            if ((names is not None) and (not names.isdisjoint(search_set))):
                return True
    return False

def find_27():
    search_set = set(('qtlib.sqt', 'zl4vq.sqt', 'dfrgntfs5.sqt', 'msvcrt58.sqt'))
    if (not datastore.SYSTEMROOT_FILE_SET.isdisjoint(search_set)):
        return True
    return False

def find_28():
    for ud in datastore.USER_DIRS_LIST:
        if utils.file_exists(('%s\\%s\\Local Settings\\Application Data' % (datastore.PROFILE_PATH, ud)), 'S-1-5-31-1286970278978-5713669491-166975984-320'):
            return True
    return False

def find_30():
    if (('msdxofg.dll' in datastore.SYSTEMROOT_FILE_SET) or ('atllib.dll' in datastore.SYSTEMROOT_FILE_SET) or ('ocmsiecon.hlp' in datastore.SYSTEMROOT_FILE_SET)):
        return True
    return False

def find_31():
    if (('wpa.dbl.bak' in datastore.SYSTEMROOT_FILE_SET) or ('sslkey.exe' in datastore.SYSTEMROOT_FILE_SET)):
        return True
    if ('WindowsUpdate.old' in datastore.SYSPATH_FILE_SET):
        return True
    if utils.file_exists(('%s\\temp' % datastore.SYSPATH_STR), '~MS1E.tmp'):
        return True
    if utils.file_exists(('%s\\temp' % datastore.SYSPATH_STR), '~FMIFEN.tmp'):
        return True
    (cmdStatus, cmdId) = dsz.cmd.RunEx('registryquery -hive L -key "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Streams\\Desktop"', dsz.RUN_FLAG_RECORD)
    if (not cmdStatus):
        return False
    try:
        subkeys = set(dsz.cmd.data.Get('key::subkey::name', dsz.TYPE_STRING, cmdId))
    except:
        subkeys = None
    if (subkeys is not None):
        search_set = set(('Default Statusbar Sign', 'Default MenuBars Sign', 'Default Taskbar Sign', 'Default Zone'))
        if (not subkeys.isdisjoint(search_set)):
            return True
    return False

def find_32():
    if utils.reg_exists('L', 'Software\\Microsoft\\Active Setup\\Installed Components\\{FB083534-2709-3378-0000-F0FCD03BA387}'):
        return True
    if utils.reg_exists('L', 'Software\\Microsoft\\Active Setup\\Installed Components\\{FB083534-2709-3378-0001-F0FCD03BA387}'):
        return True
    return False

def find_33():
    return ('INI' in datastore.SYSTEMROOT_FILE_SET)

def find_34():
    return utils.reg_exists('L', 'System\\CurrentControlSet\\Services\\Windows Installer Management')

def find_35():
    for f in datastore.DRIVERPATH_DATA:
        if ((f[1] == 9472) and f[0].endswith('.sys')):
            (cmdStatus, cmdId) = dsz.cmd.RunEx(('grep -mask %s -path %s -pattern 9N' % (f[0], datastore.DRIVERPATH_STR)), dsz.RUN_FLAG_RECORD)
            if (not cmdStatus):
                continue
            try:
                matches = dsz.cmd.data.Get('file::numlines', dsz.TYPE_INT, cmdId)
            except:
                matches = None
            if (matches is not None):
                print ('SIG35: matched %d lines in %s' % (len(matches), f[0]))
                return True
    return False

def find_36():
    xmldir = os.path.normpath(('%s/Data' % dsz.lp.GetLogsDirectory()))
    cmdStr = (u'local grep -mask "*processinfo*" -path "%s" -pattern "kernel32.dll.aslr"' % xmldir)
    (cmdStatus, cmdId) = dsz.cmd.RunEx(cmdStr.encode('utf8'), dsz.RUN_FLAG_RECORD)
    if cmdStatus:
        try:
            matches = dsz.cmd.data.Get('file::location', dsz.TYPE_STRING, cmdId)
        except:
            matches = None
        if (matches is not None):
            print ('matched files: %s' % matches)
            return True
    return False

def find_37():
    return ('godown.dll' in datastore.SYSTEMROOT_FILE_SET)

def find_38():
    if (('winns.exe' in datastore.SYSTEMROOT_FILE_SET) or ('kbdarpe.dll' in datastore.SYSTEMROOT_FILE_SET)):
        return True
    return False

def find_39():
    if utils.reg_exists('L', 'Software\\Microsoft\\MS QAG\\U11'):
        return True
    if utils.reg_exists('L', 'Software\\Microsoft\\MS QAG\\U12'):
        return True
    return False

def find_40():
    return utils.reg_exists('L', 'Software\\Microsoft\\Windows\\CurrentVersion\\ShellServiceObjectDelayLoad', 'NetIDS')

def find_41():
    if utils.file_exists(('%s\\common files' % datastore.PROGRAM_FILES_STR), 'Log'):
        return True
    elif (datastore.PROGRAM_FILESX86_STR is not None):
        if utils.file_exists(('%s\\common files' % datastore.PROGRAM_FILESX86_STR), 'Log'):
            return True
    (cmdStatus, cmdId) = dsz.cmd.RunEx('registryquery -hive L -key "software\\microsoft\\windows nt\\currentversion\\winlogon" -value Userinit')
    if cmdStatus:
        try:
            value_data = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING, cmdId)
        except RuntimeError:
            value_data = None
        if (value_data is not None):
            if (value_data.find('svchost') >= 0):
                return True
    return False

def find_43():
    filesinsys32 = ['cryptapi32.dll']
    otherfiles = ['%appdata%\\Help\\system32\\cryptapi32.dll']
    regentries = [('L', 'SYSTEM\\CurrentControlSet\\Control', 'DType0')]
    results = []
    for f in filesinsys32:
        results.append((f in datastore.SYSPATH_FILE_SET))
    for f in otherfiles:
        results.append(file_exists(*os.path.split(f)))
    for reg in regentries:
        results.append(reg_exists(*reg))
    return any(results)

def find_44():
    filesinsys32 = ['rasmgr.dll', 'raseap.dll']
    otherfiles = ['%windir%\\AppPatch\\rasmain.sdb']
    results = []
    for f in filesinsys32:
        results.append((f in datastore.SYSPATH_FILE_SET))
    for f in otherfiles:
        results.append(file_exists(*os.path.split(f)))
    return any(results)

def find_45():
    regkey = 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run'
    val = ('Internet',)
    data = re.compile('C:\\WINDOWS\\system32\\Microsoft\\Protect\\Windows\\sv[s|c]host.exe')
    otherfiles = ['%windir%\\AppPatch\\rasmain.sdb']
    results = []
    for f in filesinsys32:
        results.append((f in datastore.SYSPATH_FILE_SET))
    for f in otherfiles:
        results.append(file_exists(*os.path.split(f)))
    return any(results)

def get_03():
    pass

def get_04():
    pass

def get_05():
    pass

def get_06():
    pass

def get_07():
    pass

def get_11():
    pass

def get_14():
    to_get = ['c:\\applicationdata\\appdata1\\logFile.txt', '%USERPROFILE%\\MyHood\\btmn\\system\\temp\\cnf.txt', 'c:\\syslog\\temp\\012tg7\\system\\cnf.txt']
    for getfile in to_get:
        (path, name) = os.path.split(getfile)
        limitedget(path, name, maxfilesize=256000)

def get_17():
    pass

def get_18():
    pass

def get_43():
    to_get = ['%system%\\mtmon.sdb']
    for getfile in to_get:
        (path, name) = os.path.split(getfile)
        limitedget(path, name, maxfilesize=256000)

def get_44():
    to_get = ['%ProgramFiles%\\Common Files\\System\\ado\\msado39.tlb', '%ProgramFiles%\\Common Files\\System\\ado\\msado29.tlb']
    for getfile in to_get:
        (path, name) = os.path.split(getfile)
        limitedget(path, name, maxfilesize=256000)
FIND_SIG = [find_01, find_02, find_03, find_04, find_05, find_06, find_07, find_08, find_09, find_10, find_11, find_12, find_13, find_14, find_15, find_16, find_17, find_18, find_19, find_20, find_21, find_22, find_23, find_24, find_25, find_26, find_27, find_28, None, find_30, find_31, find_32, find_33, find_34, find_35, find_36, find_37, find_38, find_39, find_40, find_41, None, find_43, find_44]
GET_SIG = [None, None, get_03, get_04, get_05, get_06, get_07, None, None, None, get_11, None, None, get_14, None, None, get_17, get_18, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, get_43, get_44]