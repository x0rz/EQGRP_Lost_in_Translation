
import time, datetime, sys
import ops.db
import ops.project

def ensureMarkerTable(dbHandle=None):
    if (dbHandle is None):
        dbHandle = ops.db.Database(db=ops.db.TARGET_DB, isolation_level=None)
        curs = dbHandle.connection.cursor()
    else:
        curs = dbHandle.cursor()
    try:
        curs.execute('CREATE TABLE marker (name, last_date,  extra)')
    except:
        pass
    return curs

def set(name, data=None, dbHandle=None):
    if (dbHandle is None):
        dbHandle = ops.db.Database(db=ops.db.TARGET_DB, isolation_level=None)
    with dbHandle as db:
        curs = ensureMarkerTable(db)
        curs.execute('SELECT name, last_date, extra FROM marker WHERE name = :name', (name,))
        if curs.fetchone():
            curs.execute('UPDATE marker SET last_date = :date WHERE name = :name', (datetime.datetime.now(), name))
            if (data != None):
                ('UPDATE marker SET extra = :data WHERE name = :name', (data, name))
        else:
            if (data == None):
                data = ''
            curs.execute('INSERT INTO marker (name, last_date, extra) VALUES (:name, :now, :data)', (name, datetime.datetime.now(), data))

def set_target(name, data=None):
    return set(name, data, dbHandle=ops.db.Database(db=ops.db.TARGET_DB, isolation_level=None))

def set_volatile(name, data=None):
    return set(name, data, dbHandle=ops.db.open_or_create_voldb())

def set_project(name, data=None, proj_name=None):
    return set(name, data, dbHandle=ops.project.get_pdb(proj_name))

def clear(name, dbHandle=None):
    if (dbHandle is None):
        dbHandle = ops.db.Database(db=ops.db.TARGET_DB, isolation_level=None)
    with dbHandle as db:
        curs = ensureMarkerTable(db)
        curs = ensureMarkerTable(dbHandle)
        curs.execute('DELETE FROM marker WHERE name = :name', (name,))

def clear_target(name):
    return clear(name, dbHandle=ops.db.Database(db=ops.db.TARGET_DB, isolation_level=None))

def clear_volatile(name):
    return clear(name, dbHandle=ops.db.open_or_create_voldb())

def clear_project(name, proj_name=None):
    return clear(name, dbHandle=ops.project.get_pdb(proj_name))

def get(name, dbHandle=None):
    if (dbHandle is None):
        dbHandle = ops.db.Database(db=ops.db.TARGET_DB, isolation_level=None)
    with dbHandle as db:
        curs = ensureMarkerTable(db)
        curs.execute('SELECT name, last_date, extra FROM marker WHERE name = :name', (name,))
        marker = curs.fetchone()
        if (marker == None):
            return {'last_date': datetime.datetime.min, 'extra': ''}
        year = int(marker[1][0:4])
        month = int(marker[1][5:7])
        day = int(marker[1][8:10])
        hour = int(marker[1][11:13])
        minute = int(marker[1][14:16])
        second = int(marker[1][17:19])
        last_date = datetime.datetime(year, month, day, hour, minute, second)
        return {'last_date': last_date, 'extra': marker[2]}

def get_target(name):
    return get(name, dbHandle=ops.db.Database(db=ops.db.TARGET_DB, isolation_level=None))

def get_volatile(name):
    return get(name, dbHandle=ops.db.open_or_create_voldb())

def get_project(name, proj_name=None):
    return get(name, dbHandle=ops.project.get_pdb(proj_name))

def getAll(dbHandle=None):
    if (dbHandle is None):
        dbHandle = ops.db.Database(db=ops.db.TARGET_DB, isolation_level=None)
    with dbHandle as db:
        curs = ensureMarkerTable(db)
        retval = {}
        curs.execute('SELECT name, last_date, extra FROM marker')
        for marker in curs:
            year = int(marker[1][0:4])
            month = int(marker[1][5:7])
            day = int(marker[1][8:10])
            hour = int(marker[1][11:13])
            minute = int(marker[1][14:16])
            second = int(marker[1][17:19])
            last_date = datetime.datetime(year, month, day, hour, minute, second)
            retval[marker[0]] = {'last_date': last_date, 'extra': marker[2]}
        return retval

def getAll_target():
    return getAll(dbHandle=ops.db.Database(db=ops.db.TARGET_DB, isolation_level=None))

def getAll_volatile():
    return getAll(dbHandle=ops.db.open_or_create_voldb())

def getAll_project(proj_name=None):
    return getAll(dbHandle=ops.project.get_pdb(proj_name))