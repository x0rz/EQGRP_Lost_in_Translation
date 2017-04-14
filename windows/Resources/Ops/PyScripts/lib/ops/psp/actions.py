
from ops.ActionFramework import Action, ProcessableAction, ValidationFailure, AttributePackageManager
import ops.survey, ops.data, ops.psp
import ops.system.environment
import ops.files.dirs
from ops.psp import PSP, PSPAttribute, RegistryError
import util.DSZPyLogger as logging
import dsz.cmd
import dsz.version.checks
import dsz.ui
import os
import copy
import re
import parser
from datetime import timedelta, datetime
from ops.cmd.safetychecks import addSafetyHandler
from ops.cmd import OpsCommandException
psplog = logging.getLogger('PSPActions')
psplog.setFileLogLevel(logging.WARNING)
datacache = {}
x86ProgramFiles = []

def _SetCacheData(cmd, uniqid, val):
    datacache['{0}_{1}'.format(cmd, uniqid)] = val

def _GetCacheData(cmd, uniqid):
    return datacache.get('{0}_{1}'.format(cmd, uniqid), None)

def _GetTargetEnvirons():
    env_data = ops.system.environment.get_environment(maxage=timedelta(seconds=600), use_volatile=True)
    retval = dict()
    for env_var in env_data.environment.value:
        retval[env_var.name] = env_var.value
    return retval

def _isProgramFilesPath(path):
    targetenvironmentvars = _GetTargetEnvirons()
    pathsplit = path.split(os.path.sep)
    programfiles = targetenvironmentvars.get('ProgramFiles', None)
    if (programfiles is not None):
        programfiles = os.path.split(programfiles)[1]
    else:
        programfiles = 'Program Files'
    if (pathsplit[1] == programfiles):
        return True
    return False

def GetDirList(mask, path):
    dsz.control.echo.Off()
    try:
        psplog.debug('path: {0}'.format(path))
        targetenvironmentvars = _GetTargetEnvirons()
        path = re.sub('%(.+)%', (lambda m: ('%{0}%'.format(m.group(1)) if (m.group(1) not in targetenvironmentvars) else targetenvironmentvars[m.group(1)])), path)
    except:
        psplog.error('There was an error trying to parse the environment variables on this target. \n ***** PSP DATA MAY NOT BE ACCURATE. *****', exc_info=True)
        return None
    dir_cache_key = ('PSP_%s' % os.path.join(path, mask))
    maxage = timedelta(minutes=5)
    pathsplit = path.split(os.path.sep)
    result = None
    try:
        if ((len(pathsplit) > 2) and _isProgramFilesPath(path) and (pathsplit[2] in x86ProgramFiles)):
            path = os.path.join(pathsplit[0], targetenvironmentvars.get('ProgramFiles(x86)', '{0} {1}'.format(pathsplit[1], '(x86)')), os.path.sep.join(pathsplit[2:]))
    except:
        psplog.debug('Unexpected error trying to convert dirlist to (x86) dirlist.', exc_info=True)
    result = __getdirlist(path, cache_tag=dir_cache_key, maxage=maxage, mask=mask)
    if (result is None):
        pathsplit = path.split(os.path.sep)
        if ((len(pathsplit) > 2) and _isProgramFilesPath(path) and (pathsplit[2] not in x86ProgramFiles) and dsz.version.checks.IsOs64Bit()):
            path = os.path.join(pathsplit[0], targetenvironmentvars.get('ProgramFiles(x86)', '{0} {1}'.format(pathsplit[1], '(x86)')), os.path.sep.join(pathsplit[2:]))
            x86ProgramFiles.append(pathsplit[2])
            dir_cache_key = ('PSP_%s' % os.path.join(path, mask))
            result = __getdirlist(path, cache_tag=dir_cache_key, maxage=maxage, mask=mask)
        else:
            result = None
    dsz.control.echo.On()
    return result

def __getdirlist(path, cache_tag, maxage, mask):
    try:
        result = ops.files.dirs.get_dirlisting(path, cache_tag=cache_tag, maxage=maxage, mask=mask)
    except OpsCommandException:
        psplog.debug(('Dir list failed (%s).' % path), exc_info=True)
        result = None
    except:
        psplog.debug(('Unexpected error trying to get dir list (%s).' % path), exc_info=True)
        result = None
    return result

def GetFileGrep(pathnmask, pattern):
    dsz.control.echo.Off()
    cmd = 'grep "{0}" -pattern {1} -max 0'.format(pathnmask, pattern)
    (suc, cmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    lines = []
    if suc:
        grepobj = ops.data.getDszObject(cmdid=cmdid)
        grepfile = grepobj.file[0]
        for line in grepfile.line:
            lines.append(line)
    else:
        lines = None
    return lines

class RegQueryAction(Action, ProcessableAction, ):
    mandatoryparams = ['regkey']
    optionalparams = ['regsubkey', 'regvalue', 'regdata', 'regcompare']
    varexpansion = ['regsubkey', 'regvalue', 'regdata', 'regkey']
    validparamvalues = {'regcompare': ['regex', '>', '<', '=', '<=', '>=']}

    def __init__(self, execparams, parent):
        psplog.debug('New reg query action: exparms: {0} parent: {1}'.format(execparams, parent))
        Action.__init__(self, execparams=execparams, parent=parent)
        hivemap = {'hklm': 'L', 'hkey_local_machine': 'L', 'hku': 'U', 'hkey_users': 'U', 'hkcu': 'C', 'hkey_current_user': 'C', 'hkcc': 'G', 'hkey_current_config': 'G', 'hkcr': 'R', 'hkey_classes_root': 'R'}
        try:
            self.hive = hivemap[self.execparams['regkey'].split('\\', 1)[0].lower()]
        except:
            self.hive = None

    def Validate(self):
        result = Action.Validate(self)
        if (self.hive is None):
            result.append(ValidationFailure(self, 'Invalid Hive: {0}'.format(self.execparams['regkey'].split('\\', 1)[0])))
        if ((self.execparams.get('regvalue') is None) and (self.execparams.get('regdata') is not None)):
            result.append(ValidationFailure(self, 'You cannot have a regdata without a regvalue.'))
        return result

    def Execute(self):
        Action.Execute(self)
        self.result = None
        suc = False
        self.regkey = self.execparams['regkey'].split('\\', 1)[1]
        self.regvalue = self.execparams.get('regvalue', None)
        self.regsubkey = self.execparams.get('regsubkey', None)
        self.regdata = self.execparams.get('regdata', None)
        self.regcompare = self.execparams.get('regcompare', '=')
        searchkeys = (True if ((self.regsubkey is not None) and (self.regvalue is None)) else False)
        searchvalues = (True if (self.regvalue is not None) else False)
        try:
            result = ops.psp.RegQuery(self.hive, self.regkey, self.regvalue, searchvalues, searchkeys, haltonerror=True)
            if ((self.regvalue is None) and (self.regsubkey is None) and (self.regdata is None)):
                self.result = result
                suc = True
            elif ((len(result) > 0) and ((self.regvalue in result) or (self.regvalue is None)) and ((self.regsubkey in result) or (self.regsubkey is None))):
                self.result = result
                suc = True
                if (self.regdata is not None):
                    if ((self.regcompare == 'regex') and (not re.match(self.regdata, result[self.regvalue], re.IGNORECASE))):
                        suc = False
                    elif ((self.regcompare == '>') and (not (result[self.regvalue].lower() > self.regdata.lower()))):
                        suc = False
                    elif ((self.regcompare == '<') and (not (result[self.regvalue].lower() < self.regdata.lower()))):
                        suc = False
                    elif ((self.regcompare == '=') and (not (result[self.regvalue].lower() == self.regdata.lower()))):
                        suc = False
                    elif ((self.regcompare == '>=') and (not (result[self.regvalue].lower() >= self.regdata.lower()))):
                        suc = False
                    elif ((self.regcompare == '<=') and (not (result[self.regvalue].lower() <= self.regdata.lower()))):
                        suc = False
            else:
                suc = False
        except RegistryError:
            suc = False
        except:
            psplog.error('Unknown error while querying registry (See OPLOGS for more info)!', exc_info=True)
            suc = False
        psplog.debug('Registry Query key,result,success?: {2},{0},{1}'.format(self.result, suc, self.regkey))
        return suc

    def GetVariable(self, varname):
        ret = None
        if (varname == 'regvalue'):
            ret = self.regvalue
        elif ((varname == 'regdata') and self.regvalue):
            try:
                ret = self.result[self.regvalue]
            except:
                psplog.debug('Error getting regdata. regval: {0}'.format(self.regvalue), exc_info=True)
                ret = None
        elif (varname == 'regsubkey'):
            ret = self.regsubkey
        elif (varname == 'regkey'):
            ret = self.regkey
        return ret

    def process(self, params):
        psplog.debug('regquery processing parms: {0}'.format(params))
        value = params.get('regvalue', None)
        self.regvalue = value
        subkey = params.get('regsubkey', None)
        self.regsubkey = subkey
        savetype = params.get('savetype', 'Data')
        if ((value is None) and (subkey is None)):
            raise AttributeError("You must specify either 'regvalue' or 'regsubkey'!")
        else:
            if value:
                data = self.result.get(value, None)
            else:
                data = None
                if (self.result.has_key(subkey) and (self.result[subkey] is None)):
                    data = subkey
            psplog.debug('regquery did data match?: {0}'.format(data))
            psplog.debug('regquery my result: {0}'.format(self.result))
            if (data and (savetype == 'Data')):
                result = data
            elif data:
                result = value
            else:
                result = None
        return result

    def validateprocess(self, procparms):
        valid = True
        for parm in procparms:
            if (not (parm in self.processparms)):
                valid = False
        return valid

class DirListAction(Action, ProcessableAction, ):
    mandatoryparams = ['directory']
    optionalparams = ['dirmask']
    varexpansion = ['directory', 'filename']

    def __init__(self, execparams, parent):
        Action.__init__(self, execparams=execparams, parent=parent)

    def Execute(self):
        Action.Execute(self)
        self.path = self.execparams['directory']
        mask = self.execparams.get('dirmask', '*')
        self.result = GetDirList(mask=mask, path=self.path)
        return (self.result is not None)

    def GetVariable(self, varname):
        ret = None
        if (varname == 'filename'):
            ret = os.path.join(self.path, self.result[0])
        elif (varname == 'directory'):
            ret = self.path
        return ret

    def process(self, params):
        filename = params.get('filename', None)
        if (filename is None):
            raise AttributeError("You must specify 'filename='!")
        else:
            data = filter((lambda x: (x == filename)), self.result)
            if (len(data) == 0):
                data = None
            else:
                data = os.path.join(self.execparams['path'], data[0])
            result = data
        return result

class ScriptAction(Action, ):
    mandatoryparams = ['name']
    optionalparams = ['entrypoint', 'args']

    def __init__(self, params, parent):
        self.additionaldata = None
        Action.__init__(self, execparams=params, parent=parent)

    def Execute(self):
        Action.Execute(self)
        self.script = self.execparams['name']
        self.entrypoint = self.execparams.get('entrypoint', 'main')
        self.args = self.execparams.get('args')
        try:
            PSPmodule = __import__('ops.psp.{0}'.format(self.script), fromlist=self.entrypoint)
            PSPmethod = PSPmodule.__dict__[self.entrypoint]
            try:
                if (self.additionaldata and self.args):
                    self.result = PSPmethod(self.additionaldata, self.args)
                elif self.additionaldata:
                    self.result = PSPmethod(self.additionaldata)
                else:
                    self.result = PSPmethod(self.args)
            except SystemExit:
                pass
        except ImportError:
            psplog.critical('[ScriptAction] There was an error importing the script: {0}'.format(self.script), exc_info=True)
            self.result = False
        except:
            psplog.critical('[ScriptAction] There was an error executing the entrypoint: {0}.{1}'.format(self.script, self.entrypoint), exc_info=True)
            self.result = False
        return (self.result or False)

def shallow(myst):
    if (not isinstance(myst, list)):
        return myst
    if (len(myst) == 2):
        return shallow(myst[1])
    return [shallow(a) for a in myst[1:]]

class SafetyCheckAction(Action, ):
    mandatoryparams = ['command', 'handlerfunc']
    optionalparams = []

    def __init__(self, params, parent):
        self.additionaldata = None
        Action.__init__(self, execparams=params, parent=parent)

    def Execute(self):
        Action.Execute(self)
        plugin = self.execparams['command']
        handler = self.execparams['handlerfunc']
        safetychecked = False
        if (not safetychecked):
            try:
                addSafetyHandler(plugin, handler)
            except:
                psplog.critical("Unable to add safetyHandler for '{0}'.  Please use caution!".format(plugin))

    def _parseIt(self, goodif):
        parsed = shallow(parser.st2list(parser.expr(goodif)))[0]
        if (not isinstance(parsed, list)):
            parsed = [parsed]
        return parsed

    def Validate(self):
        valid = Action.Validate(self)
        goodif = self.execparams.get('goodif', None)
        if (goodif is not None):
            try:
                parsed = self._parseIt(goodif)
                for (ndx, item) in enumerate(parsed):
                    if (not (item in self.validstatements)):
                        valid.append(ValidationFailure(self, ('%s is not a valid SafetyCheck Statement' % item)))
                    if (item in self.binaryops):
                        if (((ndx - 1) < 0) or ((ndx + 1) > len(parsed)) or (parsed[(ndx - 1)] not in self.conds) or (parsed[(ndx + 1)] not in self.conds)):
                            valid.append(ValidationFailure(self, 'Invalid use of binary operator!'))
            except SyntaxError:
                psplog.critical('Unable to parse the SafetyCheck line!', exc_info=True)
                valid.append(ValidationFailure(self, 'Unable to parse the SafetyCheck line!'))
        return valid

class PSPManager(AttributePackageManager, ):

    def __init__(self):
        AttributePackageManager.__init__(self)
        self.pspobjs = []

    def addVendor(self, vendorData):
        return self.addAttributePackage(vendorData)

    def GetResults(self):
        return self.GetAllPSPs()

    def GetLastPSP(self):
        return self.GetAllPSPs()[(-1)]

    def GetAllPSPs(self):
        pspdicts = self.walkAndCollect(self._wacCB)
        pspobjs = []
        for psp in pspdicts:
            if ((psp.get('Vendor') is None) and (psp.get('vendor') is None)):
                continue
            psplog.debug('psp dict: {0}'.format(psp))
            attribs = [PSPAttribute(x.lower(), psp[x].attribval, config=psp[x].attribconfig, displayas=psp[x].attribdisplay) for x in psp]
            pspobjs.append(PSP(attribs=attribs))
        return pspobjs

    def _wacCB(self, atpkg, repolist):
        psplog.debug(u'In WAC CB')
        psplog.debug((u'repolist: %s' % repolist))
        psplog.debug((u'atpkg: %s' % atpkg))
        if (atpkg.attribname.lower() in ['vendor', 'product', 'version']):
            existingrepos = []
            for repo in repolist[:]:
                psplog.debug((u'atpkg.parent: %s' % atpkg.parent))
                psplog.debug((u'repo.get(atpkg.parent): %s' % repo.get(atpkg.parent.attribname)))
                if (repo.get(atpkg.parent.attribname).attribval == atpkg.parent.attribval):
                    psplog.debug((u'duplicate attrib: %s' % atpkg.parent.attribval))
                    if repo.has_key(atpkg.attribname):
                        existingrepos.append(repo)
                        continue
                    else:
                        repo[atpkg.attribname] = atpkg
                        existingrepos = []
                        break
            for repo in existingrepos:
                if repo.has_key(atpkg.attribname):
                    psplog.debug((u'creating a copy: %s' % atpkg.attribname))
                    newrepo = repo.copy()
                    newrepo[atpkg.attribname] = atpkg
                    repolist.append(newrepo)
                    break
        else:
            for repo in repolist:
                if atpkg.parent:
                    if (repo.get(atpkg.parent.attribname).attribval == atpkg.parent.attribval):
                        repo[atpkg.attribname] = atpkg
                else:
                    repo[atpkg.attribname] = atpkg

class StaticAction(Action, ):

    def __init__(self, params, parent):
        self.mandatoryparams = ['text']
        Action.__init__(self, params, parent)

    def Execute(self):
        Action.Execute(self)
        self.result = self.execparams['text']
        return True

class FileGrepAction(Action, ProcessableAction, ):

    def __init__(self, execparams, parent):
        mandatoryparams = ['filepath', 'pattern']
        Action.__init__(self, execparams=execparams, manparams=mandatoryparams, parent=parent)
        ProcessableAction.__init__(self, ['matchval'])

    def Execute(self):
        Action.Execute(self)
        pathnmask = self.execparams['filepath']
        pattern = self.execparams['pattern']
        self.result = GetFileGrep(pathnmask=pathnmask, pattern=pattern)
        return (self.result is not None)

    def process(self, params):
        matchval = params.get('matchval', None)
        data = filter((lambda x: (x.find(matchval) >= 0)), self.result)
        if (len(data) == 0):
            data = None
        else:
            data = data[0]
        result = data
        return result

class ConditionAction(Action, ):

    def __init__(self, params, parent):
        self.mandatoryparams = None
        Action.__init__(self, execparams=params, parent=parent)

    def Execute(self):
        Action.Execute(self)
        self.result = self.parent.process(self.execparams)
        return (self.result is not None)

    def Validate(self):
        Action.Validate(self)
        if (self.parent is None):
            raise AttributeError('The Process Action cannot ride the rollercoaster by itself! (It needs a parent)')
        if isinstance(self.parent, ProcessableAction):
            return self.parent.validateprocess(self.execparams)
        else:
            raise AttributeError('The parent action is not processable.')

class SaveDataAction(Action, ):
    mandatoryparams = ['attribute', 'value']
    optionalparams = ['display', 'pspid', 'config']

    def __init__(self, params, **kwargs):
        Action.__init__(self, execparams=params, **kwargs)

    def Execute(self):
        Action.Execute(self)
        attrib = self.execparams['attribute']
        value = self.execparams['value']
        pspid = self.execparams.get('pspid', None)
        config = (self.execparams.get('config', 'false').lower() == 'true')
        if (attrib in ['vendor', 'product', 'version', 'installDate']):
            config = True
        try:
            prevPSPs = self.actmgr.GetPSPsFrom(self.parent.parent)
        except:
            psplog.error('Error getting previous PSP objects. Make sure there is a NewSWAction before you try to save to it.', exc_info=True)
            return False
        if (pspid != None):
            prevPSP = filter((lambda x: (x.pspid == pspid)), prevPSPs)[0]
            if ((prevPSP[attrib] != None) and (prevPSP[attrib] != 'NTR')):
                psplog.debug('before copy: {0}'.format(prevPSP))
                prevPSP = copy.deepcopy(prevPSP)
                psplog.debug('after copy: {0}'.format(prevPSP))
                self.actmgr.addPSP(prevPSP, self.parent)
            prevPSP.SaveAttribute(attrib, value, config)
        else:
            for prevPSP in prevPSPs:
                if ((prevPSP[attrib] != None) and (prevPSP[attrib] != 'NTR')):
                    psplog.debug('prevPSP: {0}'.format(prevPSP))
                    newPSP = copy.deepcopy(prevPSP)
                    psplog.debug('newPSP: {0}'.format(newPSP))
                    self.actmgr.addPSP(newPSP, self.parent)
                    newPSP.SaveAttribute(attrib, value, config)
        return True

class NewSWAction(Action, ):
    optionalparams = ['type']

    def __init__(self, params, parent):
        Action.__init__(self, execparams=params, parent=parent)

    def Execute(self):
        Action.Execute(self)
        swtype = self.execparams.get('type')
        if (swtype == 'PSP'):
            res = PSP()
        else:
            res = None
        self.result = res
        self.actmgr.addPSP(self.result, self)
        return (self.result is not None)

class BWGlistTagHandler(object, ):

    def consume(self, element):
        if (element.tag.lower() == 'blacklist'):
            actklass = BlacklistAction
        elif (element.tag.lower() == 'whitelist'):
            actklass = WhitelistAction
        elif (element.tag.lower() == 'greylist'):
            actklass = GreylistAction
        else:
            return None
        acts = []
        for command in element.getchildren():
            actattribs = {'command': command.tag.lower()}
            actattribs.update(command.attrib)
            for arg in command.getchildren():
                actattribs['arguments'] = arg.text
            acts.append(actklass(actattribs, None))
        return acts

class DoNotAction(Action, ):
    mandatoryparams = ['flag']
    optionalparams = ['unset']
    paramvalues = {'flag': ops.survey.flags()}

    def __init__(self, params, parent):
        Action.__init__(self, execparams=params, parent=parent)

    def Execute(self):
        Action.Execute(self)
        flag = self.execparams['flag']
        val = (True if (self.execparams.get('unset') is None) else False)
        if (flag in self.paramvalues['flag']):
            ops.env.set(flag, val)
            self.result = True
        else:
            self.result = False
        return self.result

class BlacklistAction(Action, ):
    mandatoryparams = ['command']
    optionalparams = ['note', 'arguments']
    varexpansion = []

    def __init__(self, execparams, parent):
        Action.__init__(self, execparams=execparams, parent=parent)

    def Execute(self):
        Action.Execute(self)
        self.result = None
        suc = False
        self.command = self.execparams['command']
        self.note = self.execparams.get('note', None)
        self.arguments = self.execparams.get('arguments', None)
        try:
            suc = True
        except:
            psplog.error('Blacklist failed.', exc_info=True)
            suc = False
        return suc

class WhitelistAction(Action, ):
    mandatoryparams = ['command']
    optionalparams = ['note', 'arguments']
    varexpansion = []

    def __init__(self, execparams, parent):
        Action.__init__(self, execparams=execparams, parent=parent)

    def Execute(self):
        Action.Execute(self)
        self.result = None
        suc = False
        self.command = self.execparams['command']
        self.note = self.execparams.get('note', None)
        self.arguments = self.execparams.get('arguments', None)
        try:
            suc = True
        except:
            psplog.error('Whitelist failed.', exc_info=True)
            suc = False
        return suc

class GreylistAction(Action, ):
    mandatoryparams = ['command']
    optionalparams = ['note', 'arguments']
    varexpansion = []

    def __init__(self, execparams, parent):
        Action.__init__(self, execparams=execparams, parent=parent)

    def Execute(self):
        Action.Execute(self)
        self.result = None
        suc = False
        self.command = self.execparams['command']
        self.note = self.execparams.get('note', None)
        self.arguments = self.execparams.get('arguments', None)
        try:
            suc = True
        except:
            psplog.error('Greylist failed.', exc_info=True)
            suc = False
        return suc