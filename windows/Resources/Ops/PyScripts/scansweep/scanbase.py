
import ops
import ops.db
import os.path
import random
import pickle
import dsz
import sqlite3

def get_job(session):
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string='SELECT rowid FROM scansweep_queue WHERE session=? AND inprogress=? AND complete=?', query_list=[session, 'False', 'False'], no_return=False, max_tries=10)
    job_list = []
    for row in curs:
        job_list.append(row)
    if (len(job_list) == 0):
        return False
    random.shuffle(job_list)
    job = job_list.pop()
    query_execute_wrapper(conn, query_string="UPDATE scansweep_queue SET inprogress='True' WHERE session=? AND rowid=? AND inprogress=? AND complete=?", query_list=[session, job['rowid'], 'False', 'False'], max_tries=10)
    curs = query_execute_wrapper(conn, query_string='SELECT job,target FROM scansweep_queue WHERE rowid=?', query_list=[job['rowid']], no_return=False, max_tries=10)
    for row in curs:
        return (row['job'], row['target'])

def write_job(session, job, target):
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string='SELECT count(*) FROM scansweep_queue WHERE session=? AND job=? AND target=?', query_list=[session, job, target], no_return=False)
    if (int(curs.fetchone()['count(*)']) > 0):
        return False
    query_execute_wrapper(conn, query_string='INSERT INTO scansweep_queue (session, job, target, inprogress, complete) VALUES (?,?,?,?,?)', query_list=[session, job, target, 'False', 'False'])
    return True

def write_job_list(session, job_list):
    conn = get_database_conn()
    with conn:
        curs = conn.executemany(('INSERT INTO scansweep_queue (session, job, target, inprogress, complete) VALUES ("%s",?,?,"False","False")' % session), job_list)
    return True

def reset_jobs(session):
    conn = get_database_conn()
    query_execute_wrapper(conn, query_string="UPDATE scansweep_queue SET inprogress='False' WHERE session=? AND inprogress=? AND complete=?", query_list=[session, 'True', 'False'])
    query_execute_wrapper(conn, query_string="UPDATE scansweep_metadata SET kill='False' WHERE session=?", query_list=[session])
    return True

def list_jobs(session, inprogress='False'):
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string="SELECT * FROM scansweep_queue WHERE session=? AND inprogress=? AND complete='False'", query_list=[session, inprogress], no_return=False)
    job_list = []
    for row in curs:
        job_list.append({'job': row['job'], 'target': row['target']})
    return job_list

def num_jobs(session, inprogress='False', type=None):
    conn = get_database_conn()
    if (type is None):
        curs = query_execute_wrapper(conn, query_string="SELECT count(*) FROM scansweep_queue WHERE session=? AND inprogress=? AND complete='False'", query_list=[session, inprogress], no_return=False)
    else:
        curs = query_execute_wrapper(conn, query_string="SELECT count(*) FROM scansweep_queue WHERE session=? AND job LIKE ? AND inprogress=? AND complete='False'", query_list=[session, ('%s%%' % type), inprogress], no_return=False)
    num = curs.fetchone()['count(*)']
    return num

def all_num_jobs(session):
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string='SELECT job,inprogress,complete FROM scansweep_queue WHERE session=?', query_list=[session], no_return=False)
    num = []
    for row in curs:
        num.append({'type': row['job'].split('|')[0], 'inprogress': row['inprogress'], 'complete': row['complete']})
    return num

def set_jobtype(session, type):
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string='INSERT INTO scansweep_jobtype (session, type) VALUES (?,?)', query_list=[session, type])
    return True

def get_jobtypes(session):
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string='SELECT type FROM scansweep_jobtype WHERE session=?', query_list=[session], no_return=False)
    type_dict = {}
    for row in curs:
        type_dict[row['type']] = True
    return type_dict

def get_metadata(scansweep_env, var=None):
    conn = get_database_conn()
    if (var is None):
        curs = query_execute_wrapper(conn, query_string='SELECT * FROM scansweep_metadata WHERE scansweep_env=?', query_list=[scansweep_env], no_return=False)
        metadata = curs.fetchone()
    else:
        curs = query_execute_wrapper(conn, query_string=('SELECT %s FROM scansweep_metadata WHERE scansweep_env=?' % var), query_list=[scansweep_env], no_return=False)
        metadata = curs.fetchone()
        if (metadata is not None):
            metadata = metadata[var]
        else:
            return ''
    return metadata

def write_metadata(scansweep_env, session, scansweep_logfile, scansweep_results, verbose):
    conn = get_database_conn()
    query_execute_wrapper(conn, query_string='INSERT INTO scansweep_metadata (scansweep_env, session, scansweep_logfile, scansweep_results, verbose, kill) VALUES (?,?,?,?,?,?)', query_list=[scansweep_env, session, scansweep_logfile, scansweep_results, verbose, 'False'])
    return True

def kill_session(session):
    conn = get_database_conn()
    query_execute_wrapper(conn, query_string="UPDATE scansweep_metadata SET kill='True' WHERE session=?", query_list=[session])
    return True

def check_kill(session):
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string='SELECT kill FROM scansweep_metadata WHERE session=?', query_list=[session], no_return=False)
    kill_data = curs.fetchone()
    if (kill_data['kill'] == 'True'):
        return True
    else:
        return False

def get_excludes(session):
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string='SELECT * FROM scansweep_excludes WHERE session=?', query_list=[session], no_return=False)
    excludes_list = []
    for row in curs:
        excludes_list.append(row['target'])
    if (len(excludes_list) == 0):
        return []
    return excludes_list

def write_excludes(session, target):
    conn = get_database_conn()
    query_execute_wrapper(conn, query_string='INSERT INTO scansweep_excludes (session, target) VALUES (?,?)', query_list=[session, target])
    return True

def write_excludes_list(session, target_list):
    conn = get_database_conn()
    input_list = []
    for target in target_list:
        input_list.append([target])
    with conn:
        curs = conn.executemany(('INSERT INTO scansweep_excludes (session, target) VALUES ("%s",?)' % session), input_list)
    return True

def list_sessions():
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string='SELECT session FROM scansweep_metadata', no_return=False)
    session_list = []
    for row in curs:
        session_list.append(row['session'])
    return session_list

def write_escalate_rule(session, rule):
    conn = get_database_conn()
    pickled_data = pickle.dumps(rule)
    query_execute_wrapper(conn, query_string='INSERT INTO scansweep_escalate (session, rule) VALUES (?,?)', query_list=[session, pickled_data])
    return True

def delete_escalate_rule(session, rule):
    conn = get_database_conn()
    pickled_data = pickle.dumps(rule)
    query_execute_wrapper(conn, query_string='DELETE FROM scansweep_escalate WHERE session=? AND rule=?', query_list=[session, pickled_data])
    return True

def get_escalate_rules(session):
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string='SELECT * FROM scansweep_escalate WHERE session=?', query_list=[session], no_return=False)
    rule_list = []
    for row in curs:
        unpickled_data = pickle.loads(row['rule'])
        rule_list.append(unpickled_data)
    return rule_list

def check_escalation(session):
    rule_list = get_escalate_rules(session)
    if (len(rule_list) > 0):
        return True
    else:
        return False

def get_results(session, type, success=True):
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string='SELECT * FROM scansweep_results WHERE session=? AND type=? AND success=?', query_list=[session, type, success], no_return=False)
    results_list = []
    for row in curs:
        unpickled_data = pickle.loads(row['data'])
        results_list.append({'target': row['target'], 'data': unpickled_data})
    return results_list

def num_results(session, type, success):
    conn = get_database_conn()
    curs = query_execute_wrapper(conn, query_string='SELECT count(*) FROM scansweep_results WHERE session=? AND type=? AND success=?', query_list=[session, type, success], no_return=False)
    num = curs.fetchone()['count(*)']
    return num

def write_result(session, type, target, data, success, job):
    conn = get_database_conn()
    pickled_data = pickle.dumps(data)
    query_execute_wrapper(conn, query_string='INSERT INTO scansweep_results (session, type, target, data, success) VALUES (?,?,?,?,?)', query_list=[session, type, target, pickled_data, success], max_tries=10)
    query_execute_wrapper(conn, query_string="UPDATE scansweep_queue SET inprogress='False', complete='True' WHERE session=? AND job=? AND target=? AND inprogress=? AND complete=?", query_list=[session, job, target, 'True', 'False'], max_tries=10)
    return True

def get_database_conn():
    scansweepdb = get_database()
    return scansweepdb.connection

def get_database():
    scansweep_db_file = os.path.join(ops.PROJECTLOGDIR, 'scansweep.db')
    scansweepdb = ops.db.get_this_db(scansweep_db_file)
    return scansweepdb

def query_execute_wrapper(db_conn, query_string=None, query_list=None, max_tries=3, no_return=True):
    for i in range(0, max_tries):
        try:
            with db_conn:
                if (query_list is None):
                    curs = db_conn.execute(query_string)
                else:
                    curs = db_conn.execute(query_string, query_list)
            if no_return:
                return None
            else:
                return curs
        except sqlite3.OperationalError:
            dsz.Sleep(((1 + i) * random.randint(250, 1250)))
            continue
    raise 

def setup_db():
    scansweepdb = get_database()
    scansweepdb.ensureTable('scansweep_queue', 'CREATE TABLE scansweep_queue (session, job, target, inprogress, complete)')
    scansweepdb.ensureTable('scansweep_results', 'CREATE TABLE scansweep_results (session, type, target, data, success)')
    scansweepdb.ensureTable('scansweep_metadata', 'CREATE TABLE scansweep_metadata (scansweep_env, session, scansweep_logfile, scansweep_results, verbose, kill)')
    scansweepdb.ensureTable('scansweep_escalate', 'CREATE TABLE scansweep_escalate (session, rule)')
    scansweepdb.ensureTable('scansweep_jobtype', 'CREATE TABLE scansweep_jobtype (session, type)')
    scansweepdb.ensureTable('scansweep_excludes', 'CREATE TABLE scansweep_excludes (session, target)')
    return True

def delete_db():
    conn = get_database_conn()
    with conn:
        conn.execute('DROP TABLE if exists scansweep_queue')
        conn.execute('DROP TABLE if exists scansweep_results')
        conn.execute('DROP TABLE if exists scansweep_metadata')
        conn.execute('DROP TABLE if exists scansweep_escalate')
        conn.execute('DROP TABLE if exists scansweep_jobtype')
        conn.execute('DROP TABLE if exists scansweep_excludes')
    return True