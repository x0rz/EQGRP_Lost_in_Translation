
from __future__ import print_function
import xml.etree.ElementTree
import dsz, dsz.lp
import util, util.menu
import json
import os
import ops.db
import sys
import traceback

def wrappers():
    dsz.ui.Echo(('-' * 50))
    dsz.ui.Echo('Registering global wrappers')
    dsz.ui.Echo(('-' * 50))
    with open(os.path.join(dsz.lp.GetResourcesDirectory(), 'Ops', 'Data', 'wrappers.json'), 'r') as input:
        wrappers = json.load(input)
    for wrapper in wrappers:
        dsz.cmd.Run(('wrappers -register %s -script %s -location all %s -project %s' % (wrapper['command'], wrapper['script'], ('-pre' if (('hook' not in wrapper.keys()) or (wrapper['hook'] == 'pre')) else '-post'), ('Ops' if ('project' not in wrapper.keys()) else wrapper['project']))))
        dsz.ui.Echo((wrapper['command'] if ('reason' not in wrapper.keys()) else ' - '.join([wrapper['command'], wrapper['reason']])))
    dsz.ui.Echo(('-' * 50))
    return True

def addlibrary():
    libpath = dsz.env.Get('_PYTHON_SUFFIX_LIB_PATH', addr='')
    if (libpath.find('%RESDIR%Ops/PyScripts/Lib') < 0):
        libpath += '%RESDIR%Ops/PyScripts/Lib;'
        dsz.env.Set('_PYTHON_SUFFIX_LIB_PATH', libpath, addr='')
        dsz.ui.Echo('Added Ops library to Python search path.', dsz.GOOD)
    else:
        dsz.ui.Echo('Ops library already in search path? *shrug* Not modifying.', dsz.GOOD)
    return True

def cp_check():
    if (dsz.script.Env['local_address'] != 'z0.0.0.1'):
        print()
        dsz.ui.Echo('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', dsz.ERROR)
        dsz.ui.Echo('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', dsz.ERROR)
        dsz.ui.Echo('ERROR: Your local CP address is not z0.0.0.1.', dsz.ERROR)
        dsz.ui.Echo('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', dsz.ERROR)
        dsz.ui.Echo('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', dsz.ERROR)
        print()
        print('YOU MUST RECONFIGURE YOUR SESSION TO CONTINUE!')
        print('YOU MUST RECONFIGURE YOUR SESSION TO CONTINUE!')
        print()
        dsz.lp.alias.DisableCommand('pc_listen')
        dsz.lp.alias.DisableCommand('pc_connect')
        print()
        print('YOU MUST RECONFIGURE YOUR SESSION TO CONTINUE!')
        print('YOU MUST RECONFIGURE YOUR SESSION TO CONTINUE!')
        return False
    else:
        dsz.ui.Echo('Local CP address is z0.0.0.1.', dsz.GOOD)
        return True

def detect_project_name():
    logdir = dsz.lp.GetLogsDirectory()
    projectdir = os.path.split(logdir)[0]
    [logroot, project] = os.path.split(projectdir)
    if ((logroot.lower()[3:] != 'logs') or (not project)):
        print()
        dsz.ui.Echo('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', dsz.ERROR)
        dsz.ui.Echo('ERROR: You did not correctly configure the LP logging directory.', dsz.ERROR)
        dsz.ui.Echo('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!', dsz.ERROR)
        print()
        dsz.lp.alias.DisableCommand('pc_listen')
        dsz.lp.alias.DisableCommand('pc_connect')
        print()
        print('Correct format: D:\\Logs\\<PROJECTNAME>')
        print(('You provided  : %s' % projectdir))
        print()
        print('YOU MUST RECONFIGURE YOUR SESSION TO CONTINUE.')
        print('CLEAN ANY EXTRANEOUS DATA CREATED BY THIS CONFIGURATION FROM THE LOGS DIRECTORY.')
        return False
    dsz.env.Set('OPS_PROJECTNAME', project, addr='')
    dsz.ui.Echo(("Setting environment variable OPS_PROJECTNAME to '%s'" % project.lower()), dsz.GOOD)
    return True

def disk_info():
    logdir = dsz.lp.GetLogsDirectory()
    projectdir = os.path.split(logdir)[0]
    infofile = os.path.join(projectdir, 'disk-version.txt')
    if os.path.exists(infofile):
        dsz.ui.Echo(('Disk version already logged; if you switched disks for some reason, rename %s and restart the LP please.' % infofile), dsz.GOOD)
        return True
    opsdisk_root = os.path.normpath((dsz.lp.GetResourcesDirectory() + '/..'))
    dszfiles = util.listdir(opsdisk_root, '^DSZOpsDisk-.+\\.zip$')
    disk = None
    if (len(dszfiles) == 1):
        disk = dszfiles[0]
    elif (len(dszfiles) > 1):
        menu = util.menu.Menu('Found mulitple DSZOpsDisk zips:', dszfiles, None, 'Which one are you executing? ')
        index = (menu.show()[0] - 1)
        if ((index > 0) and (index < len(dszfiles))):
            disk = dszfiles[index]
        else:
            dsz.ui.Echo('Could not determine which opsdisk is running. Version NOT recorded.', dsz.ERROR)
            return False
    else:
        dsz.ui.Echo('Could not find DSZOpsDisk zip. Disk version NOT recorded.', dsz.ERROR)
        return False
    with open(infofile, 'w') as output:
        output.write(('%s\n' % disk))
    dsz.ui.Echo(('Disk version %s recorded to %s.' % (disk, infofile)), dsz.GOOD)
    return True

def bgprecompile():
    dsz.cmd.Run('background python pythonPreCompiler.py -project Ops')
    return True

def setwindowtitle():
    logdir = dsz.lp.GetLogsDirectory()
    projectdir = os.path.split(logdir)[0]
    infofile = os.path.join(projectdir, 'disk-version.txt')
    if os.path.exists(infofile):
        with open(infofile, 'r') as input:
            diskver = input.read().strip()
    else:
        diskver = '<unknown>'
    dszdir = os.path.join(dsz.lp.GetResourcesDirectory(), 'Dsz')
    baseversion = os.path.join(dszdir, 'Version.xml')
    if os.path.exists(baseversion):
        tree = xml.etree.ElementTree.ElementTree(file=baseversion)
        v = tree.getroot()
        major = v.get('major')
        minor = v.get('minor')
        fix = v.get('fix')
        build = v.get('build')
        dszver = ('%s.%s.%s.%s' % (major, minor, fix, build))
    else:
        dszver = '<unknown>'
    if dsz.env.Check('OPS_PROJECTNAME'):
        proj = dsz.env.Get('OPS_PROJECTNAME')
    else:
        proj = '<unknown>'
    dsz.cmd.Run(('gui -command ".setwindowtitle %s -- DanderSpritz %s (%s)"' % (proj, dszver, diskver)))
    return True

def prep_target_dbs():
    good = False
    try:
        ops.db.copy_target_db_files()
        good = True
    except:
        pass
    return good
TASKS = [wrappers, addlibrary, cp_check, detect_project_name, disk_info, bgprecompile, setwindowtitle, prep_target_dbs]

def main():
    print()
    dsz.control.echo.Off()
    failures = 0
    for func in TASKS:
        try:
            ret = func()
            if (ret != True):
                failures += 1
        except:
            traceback.print_exc()
            dsz.ui.Echo('Exception in startup task. You must determine if it is safe to proceed.', dsz.WARNING)
            failures += 1
    if (failures > 0):
        dsz.ui.Echo(('%d of %d startup items indicated failure to execute correctly.' % (failures, len(TASKS))), dsz.ERROR)
        return False
    elif (failures < 0):
        dsz.ui.Echo('You are a negative failure.', dsz.WARNING)
        return False
    else:
        return True
if (__name__ == '__main__'):
    if (not dsz.script.IsLocal()):
        dsz.ui.Echo('This script is run automatically at startup and is not run on remote targets.', dsz.ERROR)
        sys.exit((-1))
    if (not main()):
        dsz.ui.Echo('Session did not pass configuration sanity check. Close, clean up if necessary, and try again.', dsz.ERROR)
        sys.exit((-1))
    print()