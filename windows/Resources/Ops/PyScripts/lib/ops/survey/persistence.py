
from optparse import OptionParser
import datetime
import traceback
import os.path
import dsz
import ops, ops.survey
import ops.cmd
import ops.project
import ops.system.registry
import ops.files.dirs
import ops.system.environment

def main():
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of information to use before re-running commands for this module', type='int')
    (options, args) = parser.parse_args()
    maxage = datetime.timedelta(seconds=options.maxage)
    ops.survey.print_header('Persistence checks')
    vallist = [{'keyname': 'system\\currentcontrolset\\Services\\tcpip\\Parameters\\Winsock', 'vallist': ['HelperDllName'], 'cachetag': 'OPS_PERSIST_WINSOCKHELPER', 'knowngoods': [['wshtcpip.dll', '%%SystemRoot%%\\System32\\wshtcpip.dll']], 'isuser': False}, {'keyname': 'Software\\Microsoft\\Windows NT\\CurrentVersion\\Windows', 'vallist': ['AppInit_Dlls'], 'cachetag': 'OPS_PERSIST_APPINITDLLS', 'knowngoods': [['']], 'isuser': False}, {'keyname': 'Software\\Microsoft\\Windows NT\\CurrentVersion\\winlogon', 'vallist': ['Shell', 'Userinit'], 'cachetag': 'OPS_PERSIST_WINLOGON', 'knowngoods': [['explorer.exe'], ['C:\\Windows\\system32\\userinit.exe,']], 'isuser': False}]
    keylist = [{'keyname': 'Software\\Microsoft\\Windows\\CurrentVersion\\Run', 'cachetag': 'OPS_PERSIST_RUN', 'knownvals': {'VMware Tools': '"C:\\Program Files\\VMware\\VMware Tools\\VMwareTray.exe"', 'VMware User Process': '"C:\\Program Files\\VMware\\VMware Tools\\VMwareUser.exe"'}, 'isuser': False}, {'keyname': 'Software\\Microsoft\\Windows\\CurrentVersion\\RunOnce', 'cachetag': 'OPS_PERSIST_RUNONCE', 'knownvals': {}, 'isuser': False}, {'keyname': 'Software\\Microsoft\\Windows\\CurrentVersion\\RunOnceEx', 'cachetag': 'OPS_PERSIST_RUNONCEEX', 'knownvals': {}, 'isuser': False}, {'keyname': 'Software\\Microsoft\\Windows NT\\CurrentVersion\\AppCompatFlags\\Custom', 'cachetag': 'OPS_PERSIST_APPCOMPAT_REG', 'knownvals': {}, 'isuser': False}]
    winroot = ops.env.get('OPS_WINDOWSDIR')
    sysroot = ops.env.get('OPS_SYSTEMDIR')
    programdata = ops.system.environment.get_environment_var('ALLUSERSPROFILE', maxage=datetime.timedelta(seconds=14400)).value
    progfiles = ops.system.environment.get_environment_var('PROGRAMFILES', maxage=datetime.timedelta(seconds=14400)).value
    userprofiles = ops.system.get_userprofiles_dir()
    dirlist = [{'path': os.path.join(sysroot, 'AppPatch', 'Custom'), 'cachetag': 'OPS_PERSIST_APPCOMPAT_DIR', 'knownfiles': {}, 'isuser': False}]
    displays = list()
    codes = list()
    for pair in vallist:
        try:
            if (not pair['isuser']):
                keyval = ops.system.registry.get_registrykey('L', pair['keyname'], cache_tag=pair['cachetag'], cache_size=2, maxage=maxage)
                for i in range(len(pair['vallist'])):
                    valuename = pair['vallist'][i]
                    displays.append({'keydir': pair['keyname'], 'valfile': valuename, 'value': keyval.key[0][valuename].value})
                    if (keyval.key[0][valuename].value in pair['knowngoods'][i]):
                        codes.append(dsz.GOOD)
                    else:
                        codes.append(dsz.WARNING)
            else:
                pass
        except:
            pass
    for pair in keylist:
        try:
            if (not pair['isuser']):
                keyval = ops.system.registry.get_registrykey('L', pair['keyname'], cache_tag=pair['cachetag'], cache_size=2, maxage=maxage)
                for val in keyval.key[0].value:
                    if (val.name in pair['knownvals']):
                        if (pair['knownvals'][val.name] == val.value):
                            codes.append(dsz.GOOD)
                        else:
                            codes.append(dsz.ERROR)
                    else:
                        codes.append(dsz.DEFAULT)
                    displays.append({'keydir': pair['keyname'], 'valfile': val.name, 'value': val.value})
            else:
                pass
        except:
            pass
    for pair in dirlist:
        try:
            if (not pair['isuser']):
                dirval = ops.files.dirs.get_dirlisting(path=pair['path'], mask='*', cache_tag=pair['cachetag'], cache_size=2, maxage=maxage)
                for fileitem in dirval.diritem[0].fileitem:
                    displays.append({'keydir': pair['path'], 'valfile': fileitem.fullpath, 'value': ''})
                if (fileitem.name in pair['knownfiles']):
                    codes.append(dsz.GOOD)
                else:
                    codes.append(dsz.WARNING)
            else:
                pass
        except:
            pass
    ops.pprint.pprint(displays, echocodes=codes, dictorder=['keydir', 'valfile', 'value'], header=['Path/Key', 'File/Value', 'Data'])
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()