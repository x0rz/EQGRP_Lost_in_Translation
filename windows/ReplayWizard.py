
from __future__ import print_function
import glob
import math
import os
import subprocess
import sys
import time
import traceback
SLEEP = 5
LETTERS = 'BCDEFGHIJKLMNOPQRSTUVWXYZ'
REFRESH_LIST = 'REFRESH LIST'
REPLAY_DRIVE = 'D:\\'
MAIN_HEADER = "\nReplayWizard 2013-05-09\n\nLEAVE THIS WINDOW OPEN WHILE YOU WORK!\n\nIf you accidently close this window, re-run this script.\n\nThe following menu will help you launch an appropriate replay\nview for each shared drive and project. Use 'REFRESH LIST' to \nupdate the list in cases where the project directories have not \nyet been created on the WinOp station.\n\nWhen the op is complete, close all DSZ windows and choose QUIT.\n"

def main():
    print(MAIN_HEADER)
    first_run = True
    sentinel_children = []
    while True:
        drive_menu = [('%s:' % x) for x in LETTERS if glob.glob(('%s:/DSZOpsDisk*' % x))]
        if (first_run and (len(drive_menu) == 1)):
            choice = drive_menu[0]
            print(('Only one share found, selecting %s drive...' % choice))
            first_run = False
        else:
            choice = menu(drive_menu, quitmsg='QUIT', text="Select the drive or share with the Windows OPS disk you'd like to use:")
        if (choice is None):
            for child in sentinel_children:
                print(('Stopping sentinel process: %s' % child.pid))
                child.terminate()
            break
        if (choice == REFRESH_LIST):
            continue
        ops_disk_path = glob.glob(('%s/DSZOpsDisk*' % choice))[0]
        replay_disk_path = os.path.join(REPLAY_DRIVE, 'ReplayDisk')
        if (not os.path.exists(replay_disk_path)):
            create_replay_disk(ops_disk_path, replay_disk_path)
        logs_path = os.path.join(os.path.dirname(ops_disk_path), 'Logs')
        if (not os.path.exists(logs_path)):
            print(("\nCouldn't find the logs dir at %s" % logs_path))
            print('\nTry again when the WinOP DSZ GUI has launched.\n')
            continue
        output_dir = os.path.dirname(replay_disk_path)
        sentinel_child = sentinel_prompts(ops_disk_path, output_dir)
        sentinel_children.append(sentinel_child)
        project_menu(ops_disk_path, replay_disk_path)

def create_replay_disk(ops_disk_path, replay_disk_path):
    print(('\nCopying replay from %s (may take a moment)...' % ops_disk_path))
    os.chdir(ops_disk_path)
    script_path = os.path.join(ops_disk_path, 'CreateReplay.py')
    proc = subprocess.Popen(('python %s' % script_path), stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
    proc.communicate(('%s\n' % replay_disk_path))

def sentinel_prompts(ops_disk_path, output_dir):
    get_files = False
    if yn_prompt('\nAutomatically rename GetFiles to closely match on-target names?'):
        print(('\nFiles will save to %sGetFiles_Renamed' % output_dir))
        get_files = True
    host_map = False
    if yn_prompt('\nAutomatically aggregate network info across targets?'):
        print(('\nFiles will save to %shostmap.txt' % output_dir))
        host_map = True
    if ((not get_files) and (not host_map)):
        print()
        return
    python_file = ('%s/Resources/Ops/PyScripts/Windows/sentinel/fsmon.py' % ops_disk_path)
    if (not os.path.exists(python_file)):
        print("\nCouldn't find sentinel! Skipping...")
        return
    command_line = ('python %s --fresh --output-dir %s' % (python_file, output_dir))
    if get_files:
        command_line += ' --get-files'
    if host_map:
        command_line += ' --host-table'
    logs_path = os.path.join(os.path.dirname(ops_disk_path), 'Logs')
    command_line += (' ' + logs_path)
    print(('\n\nRunning: %s\n' % command_line))
    return subprocess.Popen(command_line)

def project_menu(ops_disk_path, replay_disk_path):
    logs_path = os.path.join(os.path.dirname(ops_disk_path), 'Logs')
    first_run = True
    while True:
        projects = [path for path in os.listdir(logs_path) if os.path.isdir(os.path.join(logs_path, path))]
        if (first_run and (len(projects) == 1)):
            choice = projects[0]
            print(('Only one project found, auto-selecting %s...' % choice))
            first_run = False
        else:
            choice = menu(projects, quitmsg='BACK TO SHARES LIST', text='Select a project to open the DSZ GUI:')
        if (choice is None):
            break
        if (choice == REFRESH_LIST):
            continue
        project_log_dir = os.path.join(logs_path, choice)
        write_user_defaults_file(replay_disk_path, normpath(project_log_dir))
        print(("\nLaunching GUI for '%s'... " % choice), end='')
        script_path = os.path.join(replay_disk_path, 'start_lp.py')
        subprocess.Popen(('python %s' % script_path))
        print('done.\n')
        print(('Sleeping for %s seconds, then you can select another project... ' % SLEEP), end='')
        time.sleep(SLEEP)
        print('done.\n\n')

def write_user_defaults_file(replay_disk_path, project_log_dir):
    config_dir = normpath(os.path.join(replay_disk_path, 'UserConfiguration'))
    resource_dir = normpath(os.path.join(replay_disk_path, 'Resources'))
    defaults_path = os.path.join(replay_disk_path, 'user.defaults')
    with open(defaults_path, 'w') as output:
        output.write('BuildType=true\n')
        output.write(('LogDir=%s\n' % project_log_dir))
        output.write('GuiType=true\n')
        output.write('wait.for.output=false\n')
        output.write('thread.dump=false\n')
        output.write(('ConfigDir=%s\n' % config_dir))
        output.write('OpMode=false\n ')
        output.write('LoadPrevious=true\n')
        output.write(('ResourceDir=%s\n' % resource_dir))
        output.write(('OpsDisk=%s\n' % normpath(replay_disk_path)))
        output.write('LocalAddress=00000001\n')
        output.write('LocalMode=false\n')
        output.write('replay.DSZ_KEYWORD=Extended')

def normpath(path):
    norm_path = os.path.normpath(path)
    return norm_path.replace('\\', '\\\\')

def menu(menu_list, text=None, quitmsg=None):
    menu_list = ([REFRESH_LIST] + menu_list)
    while True:
        optspace = int(math.log(len(menu_list), 10))
        if text:
            print(('\n' + text))
        if quitmsg:
            print(((('%' + str(optspace)) + 'd. %s') % (0, quitmsg)))
        else:
            print('0. Quit')
        items = 0
        for i in menu_list:
            items += 1
            print(((('%' + str(optspace)) + 'd. %s') % (items, i)))
        result = None
        while ((result is None) or (result > len(menu_list)) or (result < 0)):
            result = prompt('Enter selection: ')
            try:
                result = int(result)
            except ValueError:
                result = None
            except TypeError:
                result = None
        if (result == 0):
            return None
        return menu_list[(result - 1)]

def prompt(text, default=None):
    if default:
        text += (' [%s] ' % default)
    result = raw_input(text)
    if (result == ''):
        return (None if (default is None) else str(default))
    else:
        return result

def yn_prompt(text, default=True):
    footer = (' [Y/n] > ' if default else ' [y/N] > ')
    result = raw_input((text + footer)).lower().strip()
    if (not result):
        result = ('y' if default else 'n')
    return (result[0].find('n') < 0)
if (__name__ == '__main__'):
    try:
        main()
    except:
        print()
        traceback.print_exc()
        print()
        print('An unrecoverable error has occured. Cannot be wizardly for you.')
        print()
        raw_input('Press enter to exit.')