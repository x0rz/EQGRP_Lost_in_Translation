
import dsz.ui
import dsz.version.checks
import dsz.cmd
import ops, ops.db, ops.data
import ops.processes.processlist
import ops.system.registry
import datetime
import os, re
from util.DSZPyLogger import getLogger, WARNING, DEBUG
psplog = getLogger('PSPHelpers')
psplog.setFileLogLevel(WARNING)
pyScriptsDir = os.path.realpath(os.path.join(ops.OPSDIR, 'PyScripts'))
TABLE_MAX_LENGTH = 80
WOW64REGQUERIES = []
regquerycmdids = {}

def GetRegistryQuery(hive, subkey, forcerequery=False):
    wow32 = False
    try:
        sksplit = subkey.lower().split('\\', 2)
        if ((sksplit[0] == 'software') and (sksplit[1] in WOW64REGQUERIES)):
            wow32 = True
    except:
        psplog.debug('Unexpected error trying to convert regquery to Wow64 reg query.', exc_info=True)
    dictkey = 'PSP_REG_{2}_{0}\\{1}'.format(hive, subkey, wow32)
    if forcerequery:
        maxage = datetime.timedelta(seconds=0)
    else:
        maxage = datetime.timedelta(minutes=5)
    result = None
    try:
        result = ops.system.registry.get_registrykey(hive, subkey, cache_tag=dictkey, maxage=maxage, wow32=wow32)
    except:
        if ((dsz.version.Info().arch == 'x64') and (not wow32)):
            try:
                wow32 = True
                dictkey = 'PSP_REG_{2}_{0}\\{1}'.format(hive, subkey, wow32)
                result = ops.system.registry.get_registrykey(hive, subkey, cache_tag=dictkey, maxage=maxage, wow32=wow32)
                sksplit = subkey.lower().split('\\', 2)
                WOW64REGQUERIES.append(sksplit[1])
            except Exception as ex:
                result = None
    return result

class PSPAttribute(object, ):

    def __init__(self, attrname, attrval=None, config=False, displayas=None):
        self.name = attrname
        self.value = attrval
        self.config = config
        self.display = (displayas or self.name)

    def __repr__(self):
        return '({0}) {1}={2}'.format(repr(self.display), repr(self.name), repr(self.value))

    def __unicode__(self):
        return u'({0}) {1}={2}'.format(self.display, self.name, self.value)

    def __str__(self):
        return '({0}) {1}={2}'.format(str(self.display), str(self.name), str(self.value))

class comattribs:
    vendor = PSPAttribute('vendor', config=True, displayas='Vendor')
    product = PSPAttribute('product', config=True, displayas='Product')
    version = PSPAttribute('version', config=True, displayas='Version')
    installdate = PSPAttribute('installdate', config=True, displayas='Install Date')
    defupdates = PSPAttribute('defupdates', config=True, displayas='Definition Updates')
    logfile = PSPAttribute('logfile', config=False, displayas='Log File')
    quarantine = PSPAttribute('quarantine', config=False, displayas='Quarantine')
    information = PSPAttribute('information', config=False, displayas='Information')
DB_PSP_TABLE_NAME = u'PSPs'
DB_PSP_ATTRIBUTES_TABLE_NAME = u'PSPAttributes'
_dbinfoToPSPMap = {'vendor': comattribs.vendor.name, 'product': comattribs.product.name, 'version': comattribs.version.name}

def __createPSPTable(c):
    c.execute('CREATE TABLE IF NOT EXISTS PSPs(\n                 vendor TEXT, \n                 product TEXT, \n                 version TEXT, \n                 PRIMARY KEY (vendor, product, version))')
    c.execute('CREATE TABLE IF NOT EXISTS PSPAttributes(\n                 pspid TEXT,\n                 attribName TEXT, \n                 attribValue TEXT,\n                 config INTEGER,\n                 displayas TEXT,\n                 PRIMARY KEY (pspid, attribName))')

class PSP(object, ):

    def __init__(self, attribs=[]):
        self._dataToSave = {}
        defaultattribs = [comattribs.vendor, comattribs.product, comattribs.version, comattribs.installdate, comattribs.defupdates, comattribs.logfile, comattribs.quarantine, comattribs.information]
        for attrib in defaultattribs:
            self.SaveAttribute(attrib)
        for attr in attribs:
            self.SaveAttribute(attr)

    def RegQueryAndSave(self, hive, subkey, searchvalues, haltonerror=False):
        try:
            regdata = RegQuery(hive, subkey, searchvalues.keys(), haltonerror=haltonerror)
        except AttributeError:
            psplog.critical('searchvalues must be a dictionary object! See log for more info', exc_info=True)
            exit((-1))
        rtnvals = dict()
        for value in regdata.keys():
            if (not (regdata[value] == '')):
                if (searchvalues[value] is None):
                    rtnvals[searchvalues[value]] = regdata[value]
                else:
                    self[searchvalues[value]] = regdata[value]
        return rtnvals

    def SaveAttribute(self, attr, value=None, config=False):
        if (not isinstance(attr, PSPAttribute)):
            attr = PSPAttribute(attr, attrval=value, config=config)
        self[attr.name.lower()] = attr.value
        self._dataToSave[attr.name.lower()] = attr

    def GetAttributesToSave(self):
        ret = {}
        for attr in self._dataToSave.values():
            ret[attr.name] = self[attr.name]
        return ret

    def GetConfigAttributes(self):
        ret = {}
        for attr in self._dataToSave.values():
            if attr.config:
                ret[attr.name] = self[attr.name]
        return ret

    def GetAttributeDisplay(self, attr):
        if isinstance(attr, PSPAttribute):
            attr = attr.name
        try:
            atobj = self._dataToSave[attr.lower()]
            return atobj.display
        except:
            return ''

    def __iter__(self):
        return iter(self.__dict__)

    def __contains__(self, val):
        return (val in self.__dict__)

    def __getitem__(self, attr):
        if isinstance(attr, PSPAttribute):
            attr = attr.name
        try:
            return object.__getattribute__(self, attr)
        except:
            return None

    def __getattribute__(self, name):
        try:
            return object.__getattribute__(self, name)
        except:
            return object.__getattribute__(self, name.lower())

    def __setitem__(self, attr, value):
        if isinstance(attr, PSPAttribute):
            attr = attr.name
        return object.__setattr__(self, attr, value)

    def __repr__(self):
        return '<PSP {0}>'.format([(x, repr(self.__dict__[x])) for x in filter((lambda x: (not x.startswith('__'))), self.__dict__)])

    def __unicode__(self):
        return u'<PSP {0}>'.format([(x, self.__dict__[x]) for x in filter((lambda x: (not x.startswith('__'))), self.__dict__)])

class UNFINISHEDPSP(PSP, ):

    def __init__(self, vendor):
        self.vendor = vendor
        self._dataToSave = {}

class RegistryError(Exception, ):
    msg = ''
    regcmd = ''

    def __init__(self, msg, hive=None, subkey=None):
        self.msg = msg
        self.hive = hive
        self.subkey = subkey

    def __str__(self):
        return '{0} hive={1}, subkey={2}'.format(repr(self.msg), repr(self.hive), repr(self.subkey))

    def __unicode__(self):
        return u'{0} hive={1}, subkey={2}'.format(self.msg, self.hive, self.subkey)

class RequiredDataError(Exception, ):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

    def __unicode__(self):
        return unicode(self.value)

class UnrecoverableError(Exception, ):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

    def __unicode__(self):
        return unicode(self.value)

class UserQuitError(Exception, ):

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)

    def __unicode__(self):
        return unicode(self.value)

def RegQuery(hive, subkey, searchterms, searchvalues=True, searchkeys=False, haltonerror=False, **kwargs):
    subkeys = None
    values = None
    regdata = GetRegistryQuery(hive, subkey, **kwargs)
    ret = dict()
    if (regdata is not None):
        try:
            if searchkeys:
                subkeys = regdata.key[0].subkey
            if searchvalues:
                values = regdata.key[0].value
        except:
            psplog.debug('This is probably just an error because there are no keys and/or values.', exc_info=True)
            if (subkeys is None):
                subkeys = []
            if (values is None):
                values = []
        if ((searchterms is None) or (len(searchterms) == 0)):
            if searchkeys:
                for key in subkeys:
                    ret[key.name] = None
            if searchvalues:
                for val in values:
                    ret[val.name] = val.value
        else:
            if isinstance(searchterms, str):
                searchterms = [searchterms]
            for search in searchterms:
                if searchkeys:
                    matches = filter((lambda x: (x.name == search)), subkeys)
                    if (len(matches) > 0):
                        ret[search] = None
                if searchvalues:
                    matches = filter((lambda x: (x.name == search)), values)
                    if (len(matches) > 0):
                        ret[search] = matches[0].value
    elif haltonerror:
        raise RegistryError('Could not open subkey: {0}'.format(subkey), hive=hive, subkey=subkey)
    return ret

def GetPreviousConfig(vendor=None):
    prevPSPs = []
    with ops.db.get_tdb() as db:
        c = db.cursor()
        __createPSPTable(c)
        if (vendor is not None):
            c.execute('SELECT _ROWID_ as pspid,* FROM PSPs WHERE vendor LIKE ?', (vendor,))
        else:
            c.execute('SELECT _ROWID_ as pspid,* FROM PSPs')
        info = c.fetchall()
        pspcols = c.description
        c.execute('SELECT * FROM PSPAttributes')
        attribs = c.fetchall()
        psplog.debug('info: {0}'.format(info))
        psplog.debug('attribs: {0}'.format(attribs))
    pspdata = []
    for row in info:
        pspattribs = []
        for (ndx, col) in enumerate(pspcols):
            if (col[0] == 'pspid'):
                continue
            if (row[ndx] is not None):
                tmp = row[ndx].decode('utf-8')
            else:
                tmp = None
            pspattribs.append(PSPAttribute(_dbinfoToPSPMap.get(col[0], col[0]), tmp, config=False))
        for row in filter((lambda x: (str(x[0]) == str(row[0]))), attribs):
            pspattribs.append(PSPAttribute(_dbinfoToPSPMap.get(row[1].decode('utf-8'), row[1].decode('utf-8')), row[2].decode('utf-8'), config=(row[3] == 1), displayas=row[4].decode('utf-8')))
        pspdata.append(pspattribs)
    for attribdata in pspdata:
        prevPSPs.append(PSP(attribdata))
    return prevPSPs

def CheckProcList():
    toRun = dict()
    toCreate = dict()
    procs = ops.processes.processlist.get_processlist()
    for secproduct in filter((lambda x: (x.proctype == 'SECURITY_PRODUCT')), procs):
        psps = re.search('^!!! (.*) !!!$', secproduct.friendlyname)
        psps = re.split('\\sor\\s', psps.group(1))
        for psp in psps:
            psp = psp.split(' ')[0].lower()
            if (os.path.exists(os.path.join(pyScriptsDir, 'lib', 'ops', 'psp', '{0}.py'.format(psp))) or os.path.exists(os.path.join(ops.DATA, 'pspFPs', '{0}-fp.xml'.format(psp)))):
                toRun[psp] = None
            else:
                toCreate[psp] = None
    return (toRun.keys(), toCreate.keys())

def RunList(toRun):
    results = []
    for script in toRun:
        dsz.control.echo.Off()
        result = None
        DSZPrint(boxify(['{0: ^40}'.format(script)]), dsz.WARNING)
        try:
            try:
                import ops.psp.genericPSP as PSPScript
                try:
                    result = PSPScript.main(script)
                except UserQuitError:
                    DSZPrint(['You quit the script.  Using previous config (if any) for now.'], dsz.ERROR)
                    result = UNFINISHEDPSP(script)
                except:
                    psplog.error('Unhandled exception from genericPSP!', exc_info=True)
                    result = UNFINISHEDPSP(script)
            except:
                psplog.error('Could not find genericPSP.', exc_info=True)
                continue
        except:
            psplog.info('Could not find the fingerprint for {0}. Trying script.'.format(script), exc_info=True)
            PSPmodule = __import__('ops.psp.{0}'.format(script))
            PSPmethod = PSPmodule.__dict__['main']
            try:
                result = PSPmethod()
            except UserQuitError:
                DSZPrint(['You quit the script.  Using previous config (if any).'], dsz.ERROR)
                result = UNFINISHEDPSP(script)
            except:
                psplog.error('Unhandled exception from {0}!'.format(script), exc_info=True)
                result = UNFINISHEDPSP(script)
        if ((result is not None) and ((not isinstance(result, PSP)) and ((type(result) is list) and (not all(chkinstances(result)))))):
            dsz.ui.Echo('Script MUST return a PSP Object (or None if no PSP) from main()!', dsz.ERROR)
            continue
        dsz.control.echo.On()
        if (result is not None):
            if (not all(chkvendors(result))):
                dsz.ui.Echo('Script MUST at least set the Vendor (or return None if there is no PSP).', dsz.ERROR)
                continue
            results.extend((result if (type(result) is list) else [result]))
    return results

def chkinstances(lst):
    return ((lambda psp: isinstance(psp, PSP)), lst)

def chkvendors(lst):
    if (not (type(lst) == list)):
        lst = [lst]
    return ((lambda psp: (not (psp.vendor == None))), lst)

def CompareConfigs(currentpsps, historicpsps):
    dsz.ui.Echo('Checking for a change in configuration\n')
    unfins = filter((lambda x: isinstance(x, UNFINISHEDPSP)), currentpsps)
    currentpsps = filter((lambda x: (not isinstance(x, UNFINISHEDPSP))), currentpsps)
    for unfin in unfins:
        for historic in historicpsps:
            if (historic.vendor.lower() == unfin.vendor.lower()):
                currentpsps.append(historic)
    current = currentpsps[:]
    previous = historicpsps[:]
    unchangedPSP = []
    for prev in previous[:]:
        for curr in current[:]:
            if ((prev['vendor'] == curr['vendor']) and (prev['product'] == curr['product']) and (prev['version'] == curr['version'])):
                current.remove(curr)
                if (prev in previous):
                    previous.remove(prev)
                changed = []
                psplog.debug(('prev keys: %s' % prev.GetConfigAttributes().keys()))
                psplog.debug(('curr keys: %s' % curr.GetConfigAttributes().keys()))
                changed.extend(filter((lambda key: (((key in curr) and (not (prev[key] == curr[key]))) or (not (key in curr)))), prev.GetConfigAttributes().keys()))
                changed.extend(filter((lambda key: (not (key in prev))), curr.GetConfigAttributes().keys()))
                psplog.debug('Previous: {0}'.format(prev))
                psplog.debug('Current: {0}'.format(curr))
                psplog.debug('Changes: {0}'.format(changed))
                if (len(changed) > 0):
                    dsz.ui.Echo(u'There was a change in this PSP:\n  {0} {1} {2}'.format(prev['vendor'], prev['product'], prev['version']).encode('UTF-8'), dsz.WARNING)
                    lines = []
                    lines.append(['Previous', 'Current'])
                    for change in changed:
                        if (change in prev):
                            prevattr = prev[change]
                            display = prev.GetAttributeDisplay(change)
                        else:
                            prevattr = '-'
                        if (change in curr):
                            currattr = curr[change]
                            display = curr.GetAttributeDisplay(change)
                        else:
                            currattr = '-'
                        lines.append([display, prevattr, currattr])
                    for line in tableify(lines):
                        dsz.ui.Echo(line, dsz.WARNING)
                    dsz.ui.Echo('\n')
                    dsz.ui.Echo('Full list of settings:')
                    printPSPSettings(curr)
                else:
                    unchangedPSP.append(prev)
    checks = [['The following PSPs had NO changes:', unchangedPSP, dsz.GOOD], ['The following PSPs were removed from target:', previous, dsz.WARNING], ['The following PSPs were NEWLY ADDED to target:', current, dsz.ERROR]]
    for check in checks:
        if (len(check[1]) > 0):
            dsz.ui.Echo(check[0], check[2])
            for psp in check[1]:
                dsz.ui.Echo(u'  {0} {1} {2}'.format(psp['vendor'], (psp['product'] or '[UNKNOWN PRODUCT]'), (psp['version'] or '[UNKNOWN VERSION]')).encode('UTF-8'), check[2])
                if (check[2] != dsz.WARNING):
                    printPSPSettings(psp)
    return currentpsps

def printPSPSettings(psp=None):
    psps = None
    if (psp is None):
        psps = GetPreviousConfig()
    elif isinstance(psp, PSP):
        psps = [psp]
    elif isinstance(psp, str):
        vendor = psp
        psp = getPSPFromVendor(vendor)
        if (psp is None):
            dsz.ui.Echo(u'No Products found for {0}.'.format(vendor).encode('UTF-8'))
            return False
        psps = [psp]
    elif isinstance(psp, list):
        psps.extend(psp)
    if (psps is not None):
        for psp in psps:
            _printPSPSettings(psp)
    return True

def _printPSPSettings(psp):
    if (psp is not None):
        lines = []
        lines.append([u'Setting Value'])
        settings = psp.GetAttributesToSave()
        settings = sortify(settings, ['vendor', 'product', 'version'])
        for (key, val) in settings:
            pspattr = psp[key]
            lines.append([psp.GetAttributeDisplay(key), pspattr])
        for line in tableify(lines):
            dsz.ui.Echo(line, dsz.WARNING)

def getPSPFromVendor(vendor):
    return GetPreviousConfig(vendor)

def sortify(tosort, order=[]):
    isd = isinstance(tosort, dict)
    ordersorted = []
    elsesorted = []
    for item in tosort:
        val = item
        if isd:
            val = (item, tosort[item])
        if (item in order):
            ordersorted.insert(order.index(item), val)
        else:
            elsesorted.append(val)
    elsesorted.sort()
    ordersorted.extend(elsesorted)
    return ordersorted

def tableify(lines, header=True, topdeco=True, bottomdeco=True):

    def rowline(text, maxlens, alignments=['<', '>']):
        outline = ''
        for (ndx, length) in enumerate(maxlens):
            align = (alignments[ndx] if (ndx < len(alignments)) else alignments[(-1)])
            if ((text[ndx] is not None) and (len(unicode(text[ndx])) > TABLE_MAX_LENGTH)):
                text[ndx] = u'{0}...{1}'.format(unicode(text[ndx])[:((TABLE_MAX_LENGTH / 2) - 3)], unicode(text[ndx])[((- (TABLE_MAX_LENGTH / 2)) + 3):])
            outline += u'| {0: {1}{2}} '.format((unicode(text[ndx]) or u''), align, (length - 3))
        outline += u'|'
        return outline.encode('UTF-8')

    def sepline(maxlens):
        outline = ''
        for length in maxlens:
            outline += '{0:-<{1}}'.format('+', length)
        outline += '+'
        return outline
    if header:
        if ((len(lines) > 1) and (len(lines[0]) < len(lines[1]))):
            lines[0].insert(0, '')
    maxlens = map((lambda col: (len(unicode(col)) + 3)), lines[0])
    for line in lines:
        for (ndx, col) in enumerate(line):
            maxlens[ndx] = max(maxlens[ndx], (len(unicode(col)) + 3))
    for ndx in range(len(maxlens)):
        if (maxlens[ndx] > TABLE_MAX_LENGTH):
            maxlens[ndx] = TABLE_MAX_LENGTH
    outlines = []
    if topdeco:
        outlines.append(sepline(maxlens))
    if header:
        outlines.append(rowline(lines.pop(0), maxlens, ['^']))
        outlines.append(sepline(maxlens))
    for line in lines:
        outlines.append(rowline(line, maxlens))
    if bottomdeco:
        outlines.append(sepline(maxlens))
    return outlines

def boxify(lines, border='='):
    maxlen = 0
    for line in lines:
        maxlen = max((maxlen, len(line)))
    maxlen += (2 + 2)
    output = []
    output.append('{0:{1}<{2}}'.format('', border[0], maxlen))
    for line in lines:
        line = '{0} {1: <{2}} {0}'.format(border, line, (maxlen - 4))
        output.append(line)
    output.append('{0:{1}<{2}}'.format('', border[0], maxlen))
    return output

def DSZPrint(lines, echocode):
    for line in lines:
        dsz.ui.Echo(line, echocode)

def CreateList(toCreate):
    if (len(toCreate) > 0):
        dsz.ui.Echo('I noticed these possible PSPs running, but there are no scripts implemented:', dsz.WARNING)
    psps = []
    for create in toCreate:
        psp = UNFINISHEDPSP(os.path.splitext(create)[0])
        dsz.ui.Echo(create, dsz.WARNING)
        psps.append(psp)
    dsz.ui.Echo('\n', dsz.WARNING)
    return psps

def WriteMetaData(psps):
    if (not (type(psps) == list)):
        psps = [psps]
    with ops.db.get_tdb() as db:
        c = db.cursor()
        try:
            c.execute('DELETE FROM {0}'.format(DB_PSP_TABLE_NAME))
            c.execute('DELETE FROM {0}'.format(DB_PSP_ATTRIBUTES_TABLE_NAME))
        except:
            psplog.error('Error deleting PSP data from database.', exc_info=True)
            return False
    for psp in psps:
        datatowrite = psp.GetAttributesToSave()
        datatowrite.update(psp.GetConfigAttributes())
        for attr in datatowrite.keys()[:]:
            if (datatowrite[attr] is None):
                del datatowrite[attr]
        cols = []
        vals = []
        for attr in _dbinfoToPSPMap.keys():
            if (attr in datatowrite.keys()):
                cols.append(u"'{0}'".format(attr))
                vals.append(u"'{0}'".format(unicode(datatowrite.pop(_dbinfoToPSPMap[attr]))))
        sqlCmd = u'INSERT OR REPLACE INTO {0} ({1}) VALUES ({2})'.format(DB_PSP_TABLE_NAME, ','.join(cols), ','.join(vals)).encode('UTF-8')
        with ops.db.get_tdb() as db:
            c = db.cursor()
            try:
                c.execute(sqlCmd)
            except:
                psplog.error('Error writing PSP data to database!', exc_info=True)
                return False
            pspid = c.lastrowid
        cols = []
        vals = []
        config = psp.GetConfigAttributes().keys()
        with ops.db.get_tdb() as db:
            c = db.cursor()
            for attr in datatowrite.keys():
                sqlCmd = "INSERT OR REPLACE INTO {0} (pspid,\n                                                        attribName,\n                                                        attribValue,\n                                                        config,\n                                                        displayas)\n                            VALUES ({1},\n                                    '{2}',\n                                    '{3}',\n                                    {4},\n                                    '{5}')".format(DB_PSP_ATTRIBUTES_TABLE_NAME, pspid, attr, datatowrite[attr], int((attr in config)), psp.GetAttributeDisplay(attr))
                try:
                    c.execute(sqlCmd)
                except:
                    psplog.error('Error writing PSP data to database!', exc_info=True)
                    return False
    return True