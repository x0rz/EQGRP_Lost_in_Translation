
import os
import os.path
import sqlite3
import shutil
import pickle
import time
import dsz.lp.mutex
import ops
import ops.env
import datetime

def find_target_db_filename(targetID=None, project=None):
    if (targetID is None):
        targetID = ops.env.get('OPS_TARGET_ID')
    if (targetID is None):
        print 'Unable to get target DB for unknown target'
        raise Exception('Unable to get target.db, environment has not been initialized')
    if (project is None):
        project = ops.env.get('OPS_PROJECTNAME')
    if (str(ops.env.get('OPS_TARGET_DBS_READY')).upper() != 'TRUE'):
        copy_target_db_files()
    return os.path.join(ops.BASELOGDIR, project, 'targetdbs', ('%s.db' % targetID.lower()))
try:
    TARGET_DB = find_target_db_filename()
except:
    TARGET_DB = ''
PROJECT_DB = os.path.normpath(('%s/../project.db' % ops.LOGDIR))
VOLATILE_DB = os.path.normpath(('%s/../volatile.db' % ops.LOGDIR))
ELIST = os.path.normpath(('%s/Ops/Databases/SimpleProcesses.db' % ops.RESDIR))
DRIVERLIST = os.path.normpath(('%s/Ops/Databases/DriverList.db' % ops.RESDIR))

class Database:

    def __init__(self, db=TARGET_DB, with_autocommit=True, timeout=10, isolation_level=None, detect_types=0, autoclose=True, nomutex=False):
        if (db is not None):
            self.connection = sqlite3.connect(db, timeout=timeout, isolation_level=isolation_level, detect_types=detect_types)
        else:
            self.connection = None
        self.autocommit = with_autocommit
        self.autoclose = autoclose
        self.nomutex = nomutex
        self.connection.row_factory = sqlite3.Row
        self.connection.text_factory = str
        self.mutex = dsz.lp.mutex.Mutex(name=((dsz.script.Env['target_address'] + '_') + os.path.split(db)[1].replace('.', '_')))

    def close(self):
        self.connection.close()

    def ensureTable(self, tablename, create_statement):
        curs = self.connection.execute("SELECT * FROM sqlite_master WHERE type = 'table' AND name = ?", (tablename,))
        for row in curs:
            return
        self.connection.execute(create_statement)

    def save_ops_object(self, opsobj, cache_id=(-1), tag='', targetID=None, autocommit=True):
        if (targetID is None):
            targetID = ops.project.getTargetID()
        self.ensureTable('command', 'CREATE TABLE command (cache_ID INTEGER PRIMARY KEY, instance_guid, target_id, id, name, timestamp, xmllog, screenlog, parentid, taskid, destination, source, isrunning, status, bytessent, bytesreceived, fullcommand, prefix, argument, children, data, tag)')
        if (not self.nomutex):
            self.mutex.acquire()
        try:
            datadict = self._prep_metadata_for_save(opsobj)
            datadict['data'] = pickle.dumps(opsobj)
            datadict['tag'] = tag
            if (cache_id == (-1)):
                self.connection.execute('INSERT INTO command (instance_guid, target_id, id, name, timestamp, xmllog, screenlog, parentid, taskid, destination, source, isrunning, status, bytessent, bytesreceived, fullcommand, prefix, argument, children, data, tag) \n                VALUES (:instance_guid, :target_id, :id, :name, :timestamp, :xmllog, :screenlog, :parentid, :taskid, :destination, :source, :isrunning, :status, :bytessent, :bytesreceived, :fullcommand, :prefix, :argument, :children, :data, :tag)', datadict)
                curs = self.connection.execute('SELECT MAX(cache_id) AS max_id FROM command', datadict)
                row = curs.fetchone()
                cache_id = row['max_id']
            else:
                datadict['cache_id'] = cache_id
                self.connection.execute('UPDATE command SET \n                        xmllog = :xmllog, screenlog = :screenlog, isrunning = :isrunning, \n                        status = :status, bytessent = :bytessent, bytesreceived = :bytesreceived, \n                        children = :children, data = :data, timestamp = :timestamp\n                    WHERE cache_id = :cache_id', datadict)
            if autocommit:
                self.connection.commit()
            return cache_id
        except Exception as ex:
            raise ex
        finally:
            if (not self.nomutex):
                self.mutex.release()

    def get_cache_ids_by_tag(self, tag, target_id=None):
        if (target_id is None):
            target_id = ops.project.getTargetID()
        self.ensureTable('command', 'CREATE TABLE command (cache_ID INTEGER PRIMARY KEY, instance_guid, target_id, id, name, timestamp, xmllog, screenlog, parentid, taskid, destination, source, isrunning, status, bytessent, bytesreceived, fullcommand, prefix, argument, children, data, tag)')
        retval = []
        curs = self.connection.execute('SELECT cache_id FROM command WHERE tag = ? AND target_id = ?', (tag, target_id))
        for row in curs:
            retval.append(row['cache_id'])
        return retval

    def load_ops_object_byid(self, cache_id):
        self.ensureTable('command', 'CREATE TABLE command (cache_ID INTEGER PRIMARY KEY, instance_guid, target_id, id, name, timestamp, xmllog, screenlog, parentid, taskid, destination, source, isrunning, status, bytessent, bytesreceived, fullcommand, prefix, argument, children, data, tag)')
        curs = self.connection.execute('SELECT data, timestamp FROM command WHERE cache_id = ?', (cache_id,))
        row = curs.fetchone()
        if (row is not None):
            retval = pickle.loads(str(row['data']))
            retval.__dict__['cache_timestamp'] = datetime.datetime.fromtimestamp(row['timestamp'])
            return retval
        else:
            raise Exception('Could not find cached object of that ID')

    def load_ops_object_bytag(self, tag, targetID=None):
        self.ensureTable('command', 'CREATE TABLE command (cache_ID INTEGER PRIMARY KEY, instance_guid, target_id, id, name, timestamp, xmllog, screenlog, parentid, taskid, destination, source, isrunning, status, bytessent, bytesreceived, fullcommand, prefix, argument, children, data, tag)')
        if (targetID is None):
            targetID = ops.project.getTargetID()
        curs = self.connection.execute('SELECT data, timestamp FROM command WHERE tag = ? and target_id = ?', (tag, targetID))
        retval = []
        for row in curs:
            val = pickle.loads(str(row['data']))
            val.__dict__['cache_timestamp'] = datetime.datetime.fromtimestamp(row['timestamp'])
            retval.append(val)
        return retval

    def list_tags(self, target_id=None):
        if (target_id is None):
            target_id = str(ops.project.getTargetID())
        curs = self.connection.execute("SELECT tag FROM command WHERE tag <> '' GROUP BY tag")
        retval = []
        for row in curs:
            retval.append(row['tag'])
        return retval

    def delete_ops_object_byid(self, cache_id):
        self.ensureTable('command', 'CREATE TABLE command (cache_ID INTEGER PRIMARY KEY, instance_guid, target_id, id, name, timestamp, xmllog, screenlog, parentid, taskid, destination, source, isrunning, status, bytessent, bytesreceived, fullcommand, prefix, argument, children, data, tag)')
        self.connection.execute('DELETE FROM command WHERE cache_id = ?', (cache_id,))

    def delete_ops_object_bytag(self, tag, target_id=None):
        if (target_id is None):
            target_id = str(ops.project.getTargetID())
        self.ensureTable('command', 'CREATE TABLE command (cache_ID INTEGER PRIMARY KEY, instance_guid, target_id, id, name, timestamp, xmllog, screenlog, parentid, taskid, destination, source, isrunning, status, bytessent, bytesreceived, fullcommand, prefix, argument, children, data, tag)')
        self.connection.execute('DELETE FROM command WHERE tag = ? and target_id = ?', (tag, target_id))

    def truncate_cache_size_bytag(self, tag, maxsize, target_id=None):
        if (target_id is None):
            target_id = str(ops.project.getTargetID())
        self.ensureTable('command', 'CREATE TABLE command (cache_ID INTEGER PRIMARY KEY, instance_guid, target_id, id, name, timestamp, xmllog, screenlog, parentid, taskid, destination, source, isrunning, status, bytessent, bytesreceived, fullcommand, prefix, argument, children, data, tag)')
        ids = self.get_cache_ids_by_tag(tag=tag, target_id=target_id)
        for cache_id in ids[0:(len(ids) - maxsize)]:
            self.delete_ops_object_byid(cache_id)

    def _prep_metadata_for_save(self, opsobj):
        datadict = dict()
        for key in ['id', 'name', 'screenlog', 'parentid', 'taskid', 'destination', 'source', 'isrunning', 'status', 'bytessent', 'bytesreceived', 'fullcommand']:
            datadict[key] = opsobj.commandmetadata.__dict__[key]
        for listkey in ['xmllog', 'prefix', 'argument']:
            thislist = opsobj.commandmetadata.__dict__[listkey]
            datadict[listkey] = ''
            if ((thislist is not None) and (len(thislist) > 0)):
                datadict[listkey] = thislist[0]
                for item in thislist[1:]:
                    thislist += (',' + item)
        datadict['children'] = ''
        if (len(opsobj.commandmetadata.child) > 0):
            datadict['children'] = str(opsobj.commandmetadata.child[0].id)
            for child in opsobj.commandmetadata.child[1:]:
                datadict['children'] += (',' + str(child.id))
        datadict['instance_guid'] = ops.db.getInstanceNum()
        datadict['timestamp'] = time.time()
        datadict['target_id'] = ops.project.getTargetID(datadict['destination'])
        return datadict

    def __enter__(self):
        if (not self.nomutex):
            self.mutex.acquire()
        return self.connection

    def __exit__(self, exc_type, exc_value, traceback):
        if self.connection:
            if self.autocommit:
                self.connection.commit()
        if self.autoclose:
            self.close()
        if (not self.nomutex):
            self.mutex.release()

def get_tdb(targetID=None):
    return find_target_db(targetID)

def get_voldb():
    retval = open_or_create_voldb()
    return retval

def get_pdb(proj_name=None):
    retval = ops.project.get_pdb(proj_name)
    return retval

def get_this_db(this_db):
    retval = open_or_create_db(this_db)
    return retval

def find_target_db(targetID=None, project=None):
    tdbfilename = find_target_db_filename(targetID, project)
    if (not os.path.exists(tdbfilename)):
        create_new_tdb(tdbfilename)
    return Database(tdbfilename)

def copy_target_db_files():
    try:
        os.mkdir(ops.PREPS)
    except:
        pass
    try:
        os.mkdir(ops.PROJECT_PREPS)
    except:
        pass
    for project in os.listdir(ops.PREPS):
        projlog = os.path.join(ops.BASELOGDIR, project)
        projprep = os.path.join(ops.PREPS, project)
        logtdbs = os.path.join(projlog, 'targetdbs')
        preptdbs = os.path.join(projprep, 'targetdbs')
        if (not os.path.isdir(projprep)):
            continue
        for newdir in [projlog, projprep, logtdbs, preptdbs]:
            try:
                os.mkdir(newdir)
            except:
                pass
        for dbfile in os.listdir(preptdbs):
            shutil.copy(os.path.join(preptdbs, dbfile), os.path.join(logtdbs, dbfile))
    ops.env.set('OPS_TARGET_DBS_READY', 'TRUE', addr='')

def tdb_clear_volatile(dbpath=''):
    if (dbpath == ''):
        dbpath = TARGET_DB
    with Database(dbpath) as db:
        c = db.cursor()
        try:
            c.execute('DELETE FROM processlist')
            c.execute('DELETE FROM loaded_drivers')
        except:
            pass

def create_new_tdb(dbpath=''):
    if (dbpath == ''):
        dbpath = TARGET_DB
    if (not os.path.exists(dbpath)):
        try:
            os.makedirs(os.path.split(dbpath)[0])
        except:
            pass
        f = open(dbpath, 'w')
        f.close()
    with Database(dbpath) as db:
        c = db.cursor()
        c.execute('CREATE TABLE command (cache_ID INTEGER PRIMARY KEY, instance_guid, target_id, id, name, timestamp, xmllog, screenlog, parentid, taskid, destination, source, isrunning, status, bytessent, bytesreceived, fullcommand, prefix, argument, children, data, tag)')
        c.execute('CREATE TABLE targets (target_id UNIQUE NOT NULL, target_name, implant_id, crypto_guid, hostname)')

def open_or_create_db(this_db_file):
    this_db = Database(this_db_file)
    this_db.connection.row_factory = sqlite3.Row
    return this_db

def open_or_create_voldb():
    db_exists = os.path.exists(VOLATILE_DB)
    voldb = Database(VOLATILE_DB)
    voldb.connection.row_factory = sqlite3.Row
    if (not db_exists):
        voldb.connection.execute('CREATE TABLE command (cache_ID INTEGER PRIMARY KEY, instance_guid, target_id, id, name, timestamp, xmllog, screenlog, parentid, taskid, destination, source, isrunning, status, bytessent, bytesreceived, fullcommand, prefix, argument, children, data, tag)')
        voldb.connection.execute('CREATE TABLE cpconnection (cpaddr, connection_guid UNIQUE NOT NULL, target_id, target_db_file)')
        voldb.connection.execute('CREATE UNIQUE INDEX command_unique ON command (instance_guid, id)')
    return voldb

def getInstanceNum():
    instnum = ops.env.get('_OP_GUID')
    if (instnum is not None):
        return instnum
    else:
        voldb = ops.db.open_or_create_voldb()
        return ops.env.get('_OP_GUID')