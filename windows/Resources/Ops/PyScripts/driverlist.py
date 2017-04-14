
import ops.cmd, ops.db, ops, ops.project
import os.path
import dsz
from ops.pprint import pprint
import sys, re
from datetime import datetime
from datetime import timedelta
import ops.timehelper
import ops.system.drivers
import ops.survey
from ops.parseargs import ArgumentParser

def processdir(dirobj):
    h = {}
    for dir in dirobj.diritem:
        path = dir.path
        if path.endswith('\\'):
            path = path[0:(-1)]
        for file in dir.fileitem:
            if (file.name in ['.', '..']):
                continue
            if file.attributes.directory:
                continue
            name = file.name
            size = file.size
            sha1_hash = None
            for hash in file.filehash:
                if (hash.type.lower() == 'sha1'):
                    sha1_hash = hash.value
            modified = file.filetimes.modified.time
            accessed = file.filetimes.accessed.time
            created = file.filetimes.created.time
            h[os.path.join(path.lower(), name.lower())] = {'name': name, 'path': path, 'size': size, 'hash': sha1_hash, 'modified': modified, 'accessed': accessed, 'created': created}
    return h

def getgrdobool(value):
    if value.lower().startswith('true'):
        return True
    elif value.lower().startswith('false'):
        return False
    return value

def processgrdo(grdoobj):
    h = {}
    for fileentry in grdoobj.fileentry:
        this_entry = {'flags': []}
        wants = ['filename', 'signedstatus', 'dllexportname', 'signername', 'rootsignername', 'msstatus', 'resourceoriginalfilename', 'score']
        flags = ['pechecksumstatus', 'dotnetstatus', 'sectionnamesstatus', 'noresourcesstatus', 'relocatablestatus', 'keyloggerstatus', 'noversioninfostatus', 'headersizestatus', 'timestampstatus', 'resdatastatus', 'sectionorderingstatus', 'exporttimestampstatus', 'cachematchstatus', 'taildatastatus', 'sizeofcodestatus', 'invaliddrvlocstatus', 'packedstatus', 'invalidattributesstatus', 'linkerversiontimestatus', 'namematchstatus', 'adsfilenamestatus', 'linkerstatus']
        for hash in fileentry.hash:
            if (hash.type.lower() == 'sha1'):
                this_entry['hash'] = hash.value.lower()
        for want in wants:
            this_entry[want] = getattr(fileentry, want)
        for flag in flags:
            if (getgrdobool(getattr(fileentry, flag)) == True):
                this_entry['flags'].append(flag)
        h[this_entry['filename'].lower()] = this_entry
    return h

def gethashes(driver_names=[], maxage=3600):
    h = {}
    voldb = ops.db.get_voldb()
    all_dirs = []
    ops.system.drivers.run_drivers_dirs(maxage=maxage)
    all_dirs += voldb.load_ops_object_bytag('DRIVERLIST_DIRS_SYSDIR_DRIVERS')
    all_dirs += voldb.load_ops_object_bytag('DRIVERLIST_DIRS_SYSDIR')
    for driver in driver_names:
        try:
            this_dir = voldb.load_ops_object_bytag(('DRIVERLIST_DIRS_%s' % driver.upper()))
            if ((datetime.now() - this_dir[0].__dict__['cache_timestamp']) > timedelta(seconds=maxage)):
                continue
            all_dirs += this_dir
        except:
            continue
    for dirobj in all_dirs:
        h.update(processdir(dirobj))
    return h

def getgrdo(driver_names=[], maxage=3600, gath=False):
    h = {}
    voldb = ops.db.get_voldb()
    all_grdos = []
    ops.system.drivers.run_drivers_grdo(maxage=maxage, gath=gath)
    all_grdos += voldb.load_ops_object_bytag('DRIVERLIST_GRDO_SYSDIR_DRIVERS')
    all_grdos += voldb.load_ops_object_bytag('DRIVERLIST_GRDO_SYSDIR')
    for driver in driver_names:
        try:
            this_grdo = voldb.load_ops_object_bytag(('DRIVERLIST_GRDO_%s' % driver.upper()))
            if ((datetime.now() - this_grdo[0].__dict__['cache_timestamp']) > timedelta(seconds=maxage)):
                continue
            all_grdos += this_grdo
        except:
            continue
    for grdoobj in all_grdos:
        h.update(processgrdo(grdoobj))
    return h

def rundriverlist(tdb, minimal=True, maxage=3600):
    driverlist = ops.system.drivers.get_drivers_list(maxage=maxage, targetID=None, use_volatile=False, minimal=minimal)
    return driverlist

def gathget(targetfilename=None, recordid=None):
    if ((targetfilename is None) and (recordid is None)):
        return False
    gathcmd = ops.cmd.getDszCommand('gangsterthief')
    if (recordid is not None):
        gathcmd.arglist.append(('-get %s' % recordid))
    else:
        gathcmd.arglist.append('-get')
    if (targetfilename is not None):
        gathcmd.arglist.append(('-path "%s"' % targetfilename))
    gathobj = gathcmd.execute()
    if (gathobj.commandmetadata.status != 0):
        return False
    localfilename = os.path.join(ops.LOGDIR, gathobj.filelocalname.subdir, gathobj.filelocalname.localname)
    return localfilename

def freshscan(driver_list, autofreshscan=False, gath=None):
    count = 1
    unidentified_list = []
    for driver in driver_list:
        if (not ('UNIDENTIFIED' in driver['flags'])):
            continue
        driver['index'] = count
        count += 1
        project_name = ops.project.getTarget().project.name
        targetid = ops.project.getTargetID()
        pulled_date = ops.system.drivers.get_driver_report_date(driver=driver['file'].lower(), path=driver['dir'].lower(), sha1=driver['hash'], field='pulled')
        driver['pulled_date'] = pulled_date
        unidentified_list.append(driver)
    if (len(unidentified_list) == 0):
        return
    print '\n'
    dsz.ui.Echo(('[%s] The following drivers were unidentified and have no associated name' % ops.timestamp()))
    if (autofreshscan == False):
        dsz.ui.Echo('Which would you like to freshscan?')
    else:
        dsz.ui.Echo(('These will be automatically sent to freshscan using userid %s' % autofreshscan))
    pprint(unidentified_list, header=['Index', 'Driver', 'Path', 'Last Pulled', 'Size', 'Modified', 'Accessed', 'Created'], dictorder=['index', 'file', 'dir', 'pulled_date', 'size', 'modified', 'accessed', 'created'])
    intlist = []
    if (autofreshscan == False):
        want = ''
        want = dsz.ui.GetString('Please provide a list of indexes you would like (ex: "1,3,5-7,13") (0 quits): ', want)
        wantlist = want.split(',')
        if ('0' in wantlist):
            dsz.ui.Echo('Quitting', dsz.ERROR)
            return False
        for item in wantlist:
            if (len(item.split('-')) == 2):
                itemrange = item.split('-')
                for integer in range(int(itemrange[0]), (int(itemrange[1]) + 1)):
                    try:
                        intlist.append(integer)
                    except:
                        continue
            else:
                try:
                    intlist.append(int(item))
                except:
                    continue
        outlist = []
        userid = dsz.ui.GetInt('Please enter your ID')
    else:
        for item in range(1, (len(unidentified_list) + 1)):
            intlist.append(item)
        userid = autofreshscan
    if ((gath is None) or (gath == False)):
        usegath = dsz.ui.Prompt('Do you want to use GATH to get the drivers? (You must know if it is safe to do so)')
    else:
        usegath = True
    for item in unidentified_list:
        if (item['index'] in intlist):
            try:
                if usegath:
                    dsz.ui.Echo(('Using GATH to get %s' % os.path.join(item['dir'], item['file'])))
                    localfile = gathget(targetfilename=os.path.join(item['dir'], item['file']))
                    if (localfile is not False):
                        ops.system.drivers.database_report_driver(driver=item['file'].lower(), path=item['dir'].lower(), sha1=item['hash'], field='pulled')
                        dsz.ui.Echo((('Running: %s' % 'python windows/freshscan.py -args "-local %s -userid %s"') % (localfile, userid)))
                        cmd = ops.cmd.getDszCommand('python', arglist=['windows/freshscan.py'], args=('"-local %s -userid %s"' % (localfile, userid)))
                        cmd.execute()
                    else:
                        dsz.ui.Echo('Failed to get file via GATH.')
                else:
                    ops.system.drivers.database_report_driver(driver=item['file'].lower(), path=item['dir'].lower(), sha1=item['hash'], field='pulled')
                    dsz.ui.Echo((('Running: %s' % 'python windows/freshscan.py -args "-remote %s -userid %s"') % (os.path.join(item['dir'], item['file']), userid)))
                    cmd = ops.cmd.getDszCommand('python', arglist=['windows/freshscan.py'], args=('"-remote %s -userid %s"' % (os.path.join(item['dir'], item['file']), userid)))
                    cmd.execute()
            except:
                dsz.ui.Echo(('Could not freshscan %s' % item['file']), dsz.ERROR)

def cleanuptdb(tdb):
    tag_ids = tdb.get_cache_ids_by_tag(ops.system.drivers.DRIVERS_TAG)
    if (tag_ids > 3):
        tag_ids = tag_ids[:(-3)]
    for tag in tag_ids:
        tdb.delete_ops_object_byid(tag)
    return

def setup_voldb():
    voldb = ops.db.get_voldb()
    voldb.ensureTable('hashhunter', 'CREATE TABLE hashhunter (cpaddr, mask, path)')

def hashhunter_add(cpaddr, mask, path):
    voldb = ops.db.get_voldb()
    conn = voldb.connection
    with conn:
        conn.execute('INSERT INTO hashhunter (cpaddr, mask, path) VALUES (?,?,?)', [cpaddr, mask, path])

def helpinghand(driver_to_find):
    target_objects = ops.project.getAllTargets()
    other_targets = []
    found_drivers = ops.system.drivers.check_drivertracker(driver=driver_to_find, path=None, sha1=None)
    for target in target_objects:
        if (target.target_id == ops.project.getTargetID()):
            continue
        for found in found_drivers:
            if (found['targetid'] == target.target_id):
                other_targets.append(target.hostname)
                break
    return other_targets

def randomdrivercheck(name):
    name = name.lower()
    re_out = re.search('^a.{7}\\.sys$', name)
    if (re_out is not None):
        return ('*** POSSIBLE Alcohol Soft/DAEMON Tools ***', 'WARNING')
    re_out = re.search('^sp..\\.sys$', name)
    if (re_out is not None):
        return ('*** POSSIBLE Alcohol Soft/DAEMON Tools ***', 'WARNING')
    re_out = re.search('^sptd\\d{4}\\.sys$', name)
    if (re_out is not None):
        return ('*** POSSIBLE Alcohol Soft/DAEMON Tools ***', 'WARNING')
    re_out = re.search('^mpksl[0-9a-f]{8}\\.sys$', name)
    if (re_out is not None):
        return ('!!! POSSIBLE PSP: Microsoft Security Essentials !!!', 'SECURITY_PRODUCT')
    re_out = re.search('^dump_.*\\.sys$', name)
    if (re_out is not None):
        return ('!!! POSSIBLE driver mem dump !!!', 'WARNING')
    return (None, None)

def checktype(driver_types, type_lists):
    for type in type_lists:
        if (type in driver_types):
            return True
    return False

def driverlist(wait=False, quiet=False, maxage=3600, minimal=True, grabhashes=True, showall=False, autofreshscan=False, dofreshscan=True, gath=False, grdo=False):
    tdb = ops.db.get_tdb()
    setup_voldb()
    ops.system.drivers.verify_drivertracker()
    this_projectname = ops.project.getTarget().project.name
    this_targetid = ops.project.getTargetID()
    filelist = {}
    driver_out = []
    driver_final = []
    colorcodes = []
    report_list = []
    lookup_list_hash = []
    lookup_list_name = []
    grdo_list = {}
    if (not quiet):
        dsz.ui.Echo(('[%s] Getting a driver list at most %s seconds old' % (ops.timestamp(), maxage)))
    this_driverlist = rundriverlist(tdb, minimal, maxage=maxage)
    driver_names = []
    for driver in this_driverlist:
        driver_names.append('.'.join(os.path.basename(driver.name.lower()).split('.')[:(-1)]))
    if (grabhashes and (not grdo)):
        if (not quiet):
            dsz.ui.Echo(('[%s] Running a series of dirs to get your driver hashes' % ops.timestamp()))
        filelist = gethashes(driver_names=driver_names, maxage=maxage)
    if grdo:
        if (not quiet):
            dsz.ui.Echo(('[%s] Running a series of grdo_filescanners to get your driver info' % ops.timestamp()))
        grdo_list = getgrdo(driver_names=driver_names, maxage=maxage, gath=gath)
    if (not quiet):
        dsz.ui.Echo(('[%s] Comparing information pulled with the dirs we have access to' % ops.timestamp()))
    for driver in this_driverlist:
        sysdir = dsz.env.Get('OPS_SYSTEMDIR')
        windir = dsz.env.Get('OPS_WINDOWSDIR')
        name = None
        if driver.name.lower().startswith('\\systemroot\\system32'):
            name = driver.name.lower().replace('\\systemroot\\system32', sysdir)
        elif driver.name.lower().startswith('\\windows'):
            name = driver.name.lower().replace('\\windows', windir)
        elif driver.name.lower().startswith('\\winnt'):
            name = driver.name.lower().replace('\\winnt', windir)
        elif driver.name.lower().startswith('\\??\\'):
            name = driver.name.lower().replace('\\??\\', '')
        else:
            name = driver.name.lower()
        (dir, file) = os.path.split(name)
        sha1 = None
        modified = None
        accessed = None
        created = None
        size = None
        grdo_data = None
        flags = []
        signed = driver.signed
        if (signed == False):
            flags.append('UNSIGNED')
        if (wait and (not filelist.has_key(os.path.join(dir.lower(), file.lower()))) and (not (((dir is None) or (dir == '')) and filelist.has_key(os.path.join(sysdir.lower(), 'drivers', file.lower()))))):
            dircmd = ops.cmd.getDszCommand('dir -hash sha1 -max 0')
            dircmd.mask = file
            dircmd.path = dir
            cache_tag = ('DRIVERLIST_DIRS_%s' % file.upper().split('.')[0])
            dirobj = ops.project.generic_cache_get(dircmd, cache_tag=cache_tag, cache_size=1, maxage=timedelta(seconds=maxage), targetID=None, use_volatile=True)
            filelist.update(processdir(dirobj))
        if filelist.has_key(os.path.join(dir.lower(), file.lower())):
            this_file = os.path.join(dir.lower(), file.lower())
            sha1 = filelist[this_file]['hash']
            modified = filelist[this_file]['modified']
            accessed = filelist[this_file]['accessed']
            created = filelist[this_file]['created']
            size = filelist[this_file]['size']
        elif (((dir is None) or (dir == '')) and filelist.has_key(os.path.join(sysdir.lower(), 'drivers', file.lower()))):
            this_file = os.path.join(sysdir.lower(), 'drivers', file.lower())
            sha1 = filelist[this_file]['hash']
            modified = filelist[this_file]['modified']
            accessed = filelist[this_file]['accessed']
            created = filelist[this_file]['created']
            size = filelist[this_file]['size']
        if grdo_list.has_key(os.path.join(dir.lower(), file.lower())):
            this_file = os.path.join(dir.lower(), file.lower())
            sha1 = grdo_list[this_file]['hash']
            grdo_data = grdo_list[this_file]
        if (sha1 == None):
            if ((dir is not None) and (not (dir == ''))):
                path = ('"%s"' % dir)
            else:
                path = '""'
            if (not wait):
                hashhunter_add(ops.TARGET_ADDR, file, path)
        else:
            lookup_list_hash.append(sha1)
        lookup_list_name.append(file)
        first_seen = ops.system.drivers.get_driver_first_seen(project=this_projectname, targetid=this_targetid, driver=file)
        driver_out.append({'name': name, 'dir': dir, 'file': file, 'size': size, 'hash': sha1, 'modified': modified, 'accessed': accessed, 'created': created, 'comment': [], 'type': [], 'color': dsz.DEFAULT, 'flags': flags, 'signed': signed, 'db_name': [], 'first_seen': first_seen, 'other_targets': '', 'grdo_data': grdo_data})
    driver_out.sort(key=(lambda x: x['file']))
    if (not quiet):
        dsz.ui.Echo(('[%s] Comparing information pulled with the driver database' % ops.timestamp()))
    found_hashes = ops.system.drivers.query_driver_database(hash=lookup_list_hash)
    found_names = ops.system.drivers.query_driver_database(name=lookup_list_name)
    if (not quiet):
        dsz.ui.Echo(('[%s] Processing the data from the driver database' % ops.timestamp()))
    for driver in driver_out:
        found_matches = []
        for found in found_hashes:
            if ((driver['hash'] is not None) and (found['hash'].lower() == driver['hash'].lower())):
                found_matches.append(found)
        if (len(found_matches) == 1):
            driver['db_name'] = [found_matches[0]['name'].lower()]
            driver['comment'] = [found_matches[0]['comment']]
            driver['type'] = [found_matches[0]['type']]
            driver['flags'].append('HASH_MATCH')
        elif (len(found_matches) > 1):
            driver['flags'].append('HASH_MATCH')
            driver['flags'].append('MULTI_MATCH')
            for item in found_matches:
                if (not (item['name'] in driver['db_name'])):
                    driver['db_name'].append(item['name'].lower())
                if (not (item['comment'] in driver['comment'])):
                    driver['comment'].append(item['comment'])
                if (not (item['type'] in driver['type'])):
                    driver['type'].append(item['type'])
        else:
            found_matches = []
            for found in found_names:
                if (found['name'].lower() == driver['file'].lower()):
                    found_matches.append(found)
            if (len(found_matches) == 1):
                driver['db_name'] = [found_matches[0]['name'].lower()]
                driver['comment'] = [found_matches[0]['comment']]
                driver['type'] = [found_matches[0]['type']]
                if ('ISO_HASH' in driver['type']):
                    driver['type'] = ['ISO_NAME']
                driver['flags'].append('NAME_MATCH')
            elif (len(found_matches) > 1):
                if ('ISO_HASH' in driver['type']):
                    driver['type'].remove('ISO_HASH')
                    driver['type'].append('ISO_NAME')
                driver['flags'].append('NAME_MATCH')
                for item in found_matches:
                    if (not (item['name'] in driver['db_name'])):
                        driver['db_name'].append(item['name'].lower())
                    if (not (item['comment'] in driver['comment'])):
                        driver['comment'].append(item['comment'])
                    if (not (item['type'] in driver['type'])):
                        driver['type'].append(item['type'])
            else:
                pass
        if checktype(driver['type'], ['ISO_HASH']):
            if (not showall):
                continue
        else:
            if (driver['hash'] is not None):
                is_new = ops.system.drivers.try_add_driver(driver=driver['file'], path=driver['dir'], sha1=driver['hash'])
            else:
                is_new = ops.system.drivers.try_add_driver(driver=driver['file'], path=driver['dir'])
            if (is_new == True):
                driver['flags'].append('NEW')
        driver['score'] = None
        driver['grdo_flags'] = None
        if (grdo and (driver['grdo_data'] is not None)):
            driver['score'] = driver['grdo_data']['score']
            driver['grdo_flags'] = ','.join(driver['grdo_data']['flags'])
            re_out = re.search('(Signed by Catalog)|(TRUSTED SIGNATURE)|(NOT TESTED)', driver['grdo_data']['signedstatus'], re.IGNORECASE)
            if (re_out is None):
                flags.append('UNSIGNED')
        if (len(driver['comment']) == 0):
            (randcomment, randtype) = randomdrivercheck(driver['file'])
            if (randcomment is None):
                driver['flags'].append('UNIDENTIFIED')
                driver['comment'] = ''
            else:
                driver['comment'] = randcomment
                driver['type'] = [randtype]
                driver['flags'].append('RANDOM')
        else:
            temp_comment_list = {}
            for comment in driver['comment']:
                if (not temp_comment_list.has_key(comment.lower())):
                    temp_comment_list[comment.lower()] = comment
            if (len(temp_comment_list.values()) > 1):
                driver['flags'].append('MULTI_MATCH')
            driver['comment'] = ' -OR- '.join(temp_comment_list.values())
        if (not ('HASH_MATCH' in driver['flags'])):
            ops.system.drivers.report_driver(driver)
            report_list.append(driver)
        if checktype(driver['type'], ['SECURITY_PRODUCT', 'MALWARE', 'SIG']):
            if ('HASH_MATCH' in driver['flags']):
                driver['color'] = dsz.ERROR
            else:
                driver['color'] = dsz.ERROR
        elif checktype(driver['type'], ['WARNING', 'MENTAL', 'TOOL', 'ISO_NAME']):
            if ('HASH_MATCH' in driver['flags']):
                driver['color'] = dsz.WARNING
            else:
                driver['color'] = dsz.WARNING
        elif checktype(driver['type'], ['NORMAL', 'ISO_HASH']):
            if ('HASH_MATCH' in driver['flags']):
                driver['color'] = dsz.GOOD
            else:
                driver['color'] = dsz.WARNING
        else:
            driver['color'] = dsz.ERROR
        if (not (driver['type'] is None)):
            driver['type'] = ' -OR- '.join(driver['type'])
        else:
            driver['type'] = ''
        if (driver['hash'] is None):
            if grabhashes:
                driver['flags'].append('NO_HASH')
                driver['color'] = dsz.ERROR
        if (driver['signed'] == False):
            driver['color'] = dsz.ERROR
        if ((len(driver['db_name']) > 0) and (not (driver['file'].lower() in driver['db_name']))):
            driver['flags'].append('NAME_MISMATCH')
            driver['color'] = dsz.ERROR
        if (len(driver['db_name']) > 1):
            if (not ('MULTI_MATCH' in driver['flags'])):
                driver['flags'].append('MULTI_MATCH')
        driver['flags'] = ','.join(driver['flags'])
        if (not ('HASH_MATCH' in driver['flags'])):
            other_targets = helpinghand(driver['file'])
            if (len(other_targets) > 5):
                driver['other_targets'] = ('%d other targets' % len(other_targets))
            else:
                driver['other_targets'] = ','.join(other_targets)
        driver_final.append(driver)
        colorcodes.append(driver['color'])
    outheader = ['Driver', 'Path', 'Flags', 'Comment', 'Type', 'First Seen', 'Also On']
    outdictorder = ['file', 'dir', 'flags', 'comment', 'type', 'first_seen', 'other_targets']
    if grdo:
        outheader.extend(['Score', 'GRDO Flags'])
        outdictorder.extend(['score', 'grdo_flags'])
    pprint(driver_final, header=outheader, dictorder=outdictorder, echocodes=colorcodes)
    if (not grabhashes):
        dsz.ui.Echo('Driverlist was run without hashes!', dsz.ERROR)
    if (grabhashes and (not wait)):
        ops.system.drivers.start_hashhunter(maxage=maxage, grdo=grdo, gath=gath)
    if dofreshscan:
        freshscan(report_list, autofreshscan=autofreshscan, gath=gath)

def main():
    parser = ArgumentParser()
    parser.add_argument('--maxage', action='store', dest='maxage', default='1h', type=ops.timehelper.get_seconds_from_age, help='Default age is 1h. Accepts seconds, minutes, hours, days, weeks, years. (Ex: 2h10m50s)')
    parser.add_argument('--nominimal', action='store_false', dest='minimal', default=True, help='Do not use -minimal when running the drivers -list (dangerous)')
    parser.add_argument('--nohashes', action='store_false', dest='grabhashes', default=True, help='Do not run the hashing functions to get our wonderful hashes')
    parser.add_argument('--showall', action='store_true', dest='showall', default=False, help='Show all drivers. By default, ISO_HASH items are excluded')
    parser.add_argument('--autofreshscan', action='store', dest='autofreshscan', default=False, type=int, help='Automatically freshscan UNIDENTIFIED drivers. Requires userid')
    parser.add_argument('--nofreshscan', action='store_false', dest='dofreshscan', default=True, help='Disable the freshscan prompt for UNIDENTIFIED drivers at the end of the script')
    parser.add_argument('--verbose', action='store_false', dest='quiet', default=True, help='Enable helpful output messages that state the progress of the script')
    parser.add_argument('--wait', action='store_true', dest='wait', default=False, help="Instead of running hashhunter, run the dir's from within the script")
    parser.add_argument('--grdo', action='store_true', dest='grdo', default=False, help='Run GRDO_FILESCANNER to get some extra information')
    parser.add_argument('--gath', action='store_true', dest='gath', default=False, help='Use GANGSTERTHIEF where we can (for grdo_filescanner and for freshscan)')
    options = parser.parse_args()
    if (options.autofreshscan is not False):
        re_out = re.search('^[0-9]{5}$', options.autofreshscan)
        if (re_out is None):
            dsz.ui.Echo('Invalid user id for autofreshscan, must be five digits', dsz.ERROR)
            return False
    if ((options.autofreshscan is not False) and (dofreshscan == False)):
        dsz.ui.Echo('You cannot enable autofreshscan and disable freshscan', dsz.ERROR)
        return False
    driverlist(wait=options.wait, quiet=options.quiet, maxage=options.maxage, minimal=options.minimal, grabhashes=options.grabhashes, showall=options.showall, autofreshscan=options.autofreshscan, dofreshscan=options.dofreshscan, gath=options.gath, grdo=options.grdo)
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()