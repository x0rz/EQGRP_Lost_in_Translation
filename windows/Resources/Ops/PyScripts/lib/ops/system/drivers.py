
import dsz
import dsz.cmd
import dsz.version
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.project
from datetime import timedelta, datetime
import time
from util.DSZPyLogger import DSZPyLogger
dzlogger = DSZPyLogger()
drvlog = dzlogger.getLogger('DRIVERLIST')
DRIVERS_TAG = 'OPS_DRIVERS_TAG'
MAX_SERVICES_CACHE_SIZE = 3

def start_hashhunter(maxage=3600, grdo=False, gath=False):
    voldb = ops.db.get_voldb()
    conn = voldb.connection
    with conn:
        curs = conn.execute('SELECT count(*) FROM hashhunter WHERE cpaddr=?', [ops.TARGET_ADDR])
    if (int(curs.fetchone()['count(*)']) == 0):
        return False
    arg_args = [('-a %s' % maxage)]
    if grdo:
        arg_args.append('--grdo')
    if gath:
        arg_args.append('--gath')
    command = ops.cmd.getDszCommand('python', arglist=[('hashhunter.py -args "%s"' % ' '.join(arg_args))], prefixes=['background'])
    command.execute()
    return True

def get_drivers_list(maxage=0, targetID=None, use_volatile=False, minimal=True):
    command = ops.cmd.getDszCommand('drivers -list')
    if minimal:
        command.minimal = True
    else:
        command.minimal = False
    return ops.project.generic_cache_get(command, cache_tag=DRIVERS_TAG, cache_size=2, maxage=timedelta(seconds=maxage), targetID=targetID, use_volatile=use_volatile).driveritem

def run_drivers_dirs(maxage=3600, targetID=None):
    sysdir = dsz.env.Get('OPS_SYSTEMDIR')
    command = ops.cmd.getDszCommand(('dir -mask * -path %s\\Drivers -hash sha1 -max 0' % sysdir))
    dirobj = ops.project.generic_cache_get(command, cache_tag='DRIVERLIST_DIRS_SYSDIR_DRIVERS', cache_size=1, maxage=timedelta(seconds=maxage), targetID=targetID, use_volatile=True)
    command = ops.cmd.getDszCommand(('dir -mask *.sys -path %s -hash sha1 -max 0' % sysdir))
    dirobj = ops.project.generic_cache_get(command, cache_tag='DRIVERLIST_DIRS_SYSDIR', cache_size=1, maxage=timedelta(seconds=maxage), targetID=targetID, use_volatile=True)

def run_drivers_grdo(maxage=3600, targetID=None, gath=False):
    sysdir = dsz.env.Get('OPS_SYSTEMDIR')
    command = ops.cmd.getDszCommand(('grdo_filescanner -mask * -path %s\\Drivers -maxscan 0 -maxresults 0 -chunksize 25000' % sysdir))
    if gath:
        command.arglist.append('-nofilehandle')
    grdoobj = ops.project.generic_cache_get(command, cache_tag='DRIVERLIST_GRDO_SYSDIR_DRIVERS', cache_size=1, maxage=timedelta(seconds=maxage), targetID=targetID, use_volatile=True)
    command = ops.cmd.getDszCommand(('grdo_filescanner -mask *.sys -path %s -maxscan 0 -maxresults 0 -chunksize 25000' % sysdir))
    if gath:
        command.arglist.append('-nofilehandle')
    grdoobj = ops.project.generic_cache_get(command, cache_tag='DRIVERLIST_GRDO_SYSDIR', cache_size=1, maxage=timedelta(seconds=maxage), targetID=targetID, use_volatile=True)

def get_driver_first_seen(project=None, targetid=None, driver=None, path=None, sha1=None):
    driver_items = check_drivertracker(project=project, targetid=targetid, driver=driver, path=path, sha1=sha1)
    earliest_seen = datetime.now().strftime('%Y-%m-%d')
    for driver_item in driver_items:
        if (driver_item['first_seen'] is None):
            continue
        if (datetime(*time.strptime(driver_item['first_seen'], '%Y-%m-%d')[0:6]) < datetime(*time.strptime(earliest_seen, '%Y-%m-%d')[0:6])):
            earliest_seen = driver_item['first_seen']
    return earliest_seen

def check_drivertracker(project=None, targetid=None, driver=None, path=None, sha1=None):
    if ((driver is None) and (path is None) and (sha1 is None)):
        return False
    driver_items = []
    projects_list = ops.project.getAllProjectNames()
    pdb_list = []
    if (project is None):
        for item in projects_list:
            verify_drivertracker(project=item)
            pdb_list.append(ops.project.get_pdb(project=item))
    else:
        verify_drivertracker(project=project)
        pdb_list.append(ops.project.get_pdb(project=project))
    for pdb in pdb_list:
        conn = pdb.connection
        with conn:
            item_list = []
            query_list = []
            querystring = 'SELECT * FROM drivertracker WHERE'
            if (driver is not None):
                item_list.append('driver=?')
                query_list.append(driver.lower())
            if (path is not None):
                item_list.append('path=?')
                query_list.append(path.lower())
            if (sha1 is not None):
                item_list.append('sha1=?')
                query_list.append(sha1.lower())
            querystring = ('%s %s' % (querystring, ' AND '.join(item_list)))
            curs = conn.execute(querystring, query_list)
        for row in curs:
            if ((targetid is not None) and (not (row['targetid'] == targetid))):
                continue
            driver_items.append({'targetid': row['targetid'], 'driver': row['driver'], 'path': row['path'], 'first_seen': row['first_seen'], 'sha1': row['sha1'], 'reported': row['reported'], 'pulled': row['pulled']})
    return driver_items

def query_driver_database(name=None, comment=None, drv_type=None, hash=None, size=None, date_added=None):
    if ((name is None) and (comment is None) and (drv_type is None) and (hash is None) and (size is None) and (date_added is None)):
        return []
    item_list = []
    query_list = []
    querystring = 'SELECT * FROM drivers WHERE'
    if (name is not None):
        if (type(name) == type([])):
            item_list.append((('(' + ' OR '.join((len(name) * ['name=?']))) + ')'))
            for item in name:
                query_list.append(item.lower())
        else:
            item_list.append('name=?')
            query_list.append(name.lower())
    if (comment is not None):
        if (type(comment) == type([])):
            item_list.append((('(' + ' OR '.join((len(comment) * ['comment=?']))) + ')'))
            for item in comment:
                query_list.append(item.lower())
        else:
            item_list.append('comment=?')
            query_list.append(comment)
    if (drv_type is not None):
        if (type(drv_type) == type([])):
            item_list.append((('(' + ' OR '.join((len(drv_type) * ['type=?']))) + ')'))
            for item in drv_type:
                query_list.append(item.lower())
        else:
            item_list.append('type=?')
            query_list.append(drv_type)
    if (hash is not None):
        if (type(hash) == type([])):
            item_list.append((('(' + ' OR '.join((len(hash) * ['hash=?']))) + ')'))
            for item in hash:
                query_list.append(item.lower())
        else:
            item_list.append('hash=?')
            query_list.append(hash.lower())
    if (size is not None):
        if (type(size) == type([])):
            item_list.append((('(' + ' OR '.join((len(size) * ['size=?']))) + ')'))
            for item in size:
                query_list.append(item.lower())
        else:
            item_list.append('size=?')
            query_list.append(size)
    if (date_added is not None):
        if (type(date_added) == type([])):
            item_list.append((('(' + ' OR '.join((len(date_added) * ['date_added=?']))) + ')'))
            for item in date_added:
                query_list.append(item.lower())
        else:
            item_list.append('date_added=?')
            query_list.append(date_added)
    querystring = ('%s %s' % (querystring, ' AND '.join(item_list)))
    with ops.db.Database(ops.db.DRIVERLIST) as db:
        conn = db.cursor()
        curs = conn.execute(querystring, query_list)
        result_list = []
        for row in curs:
            temp_dict = {}
            for key in row.keys():
                temp_dict[key] = row[key]
            result_list.append(temp_dict)
    return result_list

def try_add_driver(driver=None, path=None, sha1=None, reported='0', pulled='0'):
    if ((driver is None) and (path is None)):
        return False
    verify_drivertracker()
    projectdb = ops.project.get_pdb()
    targetid = ops.project.getTargetID()
    conn = projectdb.connection
    with conn:
        if (sha1 is not None):
            curs = conn.execute('SELECT count(*) FROM drivertracker WHERE targetid=? and driver=? AND path=? AND sha1=?', [targetid, driver.lower(), path.lower(), sha1.lower()])
        else:
            curs = conn.execute('SELECT count(*) FROM drivertracker WHERE targetid=? and driver=? AND path=?', [targetid, driver.lower(), path.lower()])
    if (int(curs.fetchone()['count(*)']) > 0):
        return False
    with conn:
        today = datetime.now().strftime('%Y-%m-%d')
        if (sha1 is None):
            sha1 = ''
        curs = conn.execute('INSERT INTO drivertracker (targetid, driver, path, first_seen, sha1, reported, pulled) VALUES (?,?,?,?,?,?,?)', [targetid, driver.lower(), path.lower(), today, sha1.lower(), '0', '0'])
    return True

def database_report_driver(driver=None, path=None, sha1=None, field='reported'):
    if (not (field in ['reported', 'pulled'])):
        return False
    if ((driver is None) and (path is None)):
        return False
    verify_drivertracker()
    projectdb = ops.project.get_pdb()
    targetid = ops.project.getTargetID()
    conn = projectdb.connection
    with conn:
        today = datetime.now().strftime('%Y-%m-%d')
        if (sha1 is not None):
            curs = conn.execute(("UPDATE drivertracker SET %s='%s' WHERE targetid=? and driver=? AND path=? AND sha1=?" % (field, today)), [targetid, driver.lower(), path.lower(), sha1.lower()])
        else:
            curs = conn.execute(("UPDATE drivertracker SET %s='%s' WHERE targetid=? and driver=? AND path=?" % (field, today)), [targetid, driver.lower(), path.lower()])

def get_driver_report_date(project=None, targetid=None, driver=None, path=None, sha1=None, field='reported'):
    if (not (field in ['reported', 'pulled'])):
        return False
    driver_items = check_drivertracker(project=project, targetid=targetid, driver=driver, path=path, sha1=sha1)
    last_reported = ''
    for driver_item in driver_items:
        if (driver_item[field] == '0'):
            continue
        elif (last_reported == ''):
            last_reported = driver_item[field]
        elif (datetime(*time.strptime(driver_item[field], '%Y-%m-%d')[0:6]) > datetime(*time.strptime(last_reported, '%Y-%m-%d')[0:6])):
            last_reported = driver_item[field]
    return last_reported

def report_driver(driver):
    loginfo = ','.join([str(driver['name']), str(driver['size']), str(driver['hash']), str(driver['comment'])])
    project_name = ops.project.getTarget().project.name
    targetid = ops.project.getTargetID()
    reported_date = get_driver_report_date(project=project_name, targetid=targetid, driver=driver['file'], path=driver['dir'], sha1=driver['hash'], field='reported')
    if ((reported_date == '') or ((datetime.now() - datetime(*time.strptime(reported_date, '%Y-%m-%d')[0:6])) > timedelta(days=30))):
        database_report_driver(driver=driver['file'], path=driver['dir'], sha1=driver['hash'], field='reported')
        drvlog.info(('Unknown driver: %s' % loginfo))

def verify_drivertracker(project=None):
    if (project is None):
        projectdb = ops.project.get_pdb()
    else:
        projectdb = ops.project.get_pdb(project=project)
    projectdb.ensureTable('drivertracker', 'CREATE TABLE drivertracker (targetid, driver, path, first_seen, sha1, reported, pulled)')