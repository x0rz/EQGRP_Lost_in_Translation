
import util.DSZPyLogger as logging
import re
import xml.etree.ElementTree
from Queue import Queue
acfwlog = logging.getLogger('ActionFramework')
acfwlog.setFileLogLevel(logging.WARNING)

class Forest(object, ):

    def __init__(self, trees=None):
        self.trees = (trees or [])

    def __len__(self):
        return len(self.trees)

    def addTree(self, tree):
        self.trees.append(tree)
        acfwlog.debug('added new tree, trees: {0}'.format(self.trees))

    def printTrees(self):
        map(self.__printNodes, self.trees)

    def __printNodes(self, node, level=1):
        print '{0:-<{1}} {2}'.format(' ', level, node)
        for child in node.children:
            self.__printNodes(child, (level + 1))

    def getiterator(self):
        allnodes = []
        for tree in self.trees:
            allnodes.extend(tree.getiterator())
        return allnodes

class TreeItem(object, ):

    def __init__(self, parent=None, children=set([])):
        acfwlog.debug('New Treeitem: s:{2},p:{0},c:{1}'.format(parent, children, self))
        self.parent = parent
        self.children = set([])
        self.addChildren(children)
        if parent:
            parent.addChild(self)

    def addChildren(self, children):
        for child in children:
            self.addChild(child)

    def addChild(self, child):
        acfwlog.debug('Adding a child: p:{0},c:{1}'.format(self, child))
        child.parent = self
        self.children.add(child)

    def getiterator(self):
        allnodes = []
        allnodes.append(self)
        for child in self.children:
            allnodes.extend(child.getiterator())
        return allnodes

class ValidationFailure(object, ):

    def __init__(self, act, msg):
        assert isinstance(act, Action)
        self.act = act
        self.msg = msg
        self.at = None

    def AddAttribute(self, at):
        self.at = at

    def __repr__(self, *args, **kwargs):
        repout = 'Attribute: {0}\nAction: {1}\nMessage: {2}'.format(self.at, self.act, self.msg)
        return repout

class AttributePackage(TreeItem, ):

    def __init__(self, attribname, attribval=None, actmgr=None, attribconfig=False, attribdisplay=None, attribdefault=None, **kwargs):
        self.attribname = attribname
        self.attribval = attribval
        self.attribconfig = attribconfig
        self.attribdisplay = (attribdisplay or self.attribname)
        self.attribdefault = attribdefault
        self.actmgr = actmgr
        self.valid = False
        TreeItem.__init__(self, **kwargs)

    def Validate(self):
        validationfailures = []
        validationfailures.extend(self.actmgr.Validate())
        for fail in validationfailures:
            fail.AddAttribute(self)
        for child in self.children:
            validationfailures.extend(child.Validate())
        return validationfailures

    def Execute(self):
        self.valid = self.actmgr.Execute()
        if ((not self.valid) and (self.attribdefault is not None)):
            self.attribval = self.attribdefault
            self.valid = True
        if self.valid:
            if ('%' in self.attribval):
                self.attribval = re.sub('%(.+)%', (lambda m: ('%%{0}%%'.format(m.group(1)) if (self.actmgr.GetActionVar(m.group(1)) is None) else self.actmgr.GetActionVar(m.group(1)))), self.attribval)
            for child in self.children:
                child.Execute()
        return self.valid

    def __str__(self, *args, **kwargs):
        return '<Attribute Package -- Name: {0} Value: {1} Config: {2} Display: {3}>'.format(str(self.attribname), str(self.attribval), str(self.attribconfig), str(self.attribdisplay))

    def __unicode__(self, *args, **kwargs):
        return u'<Attribute Package -- Name: {0} Value: {1} Config: {2} Display: {3}>'.format(self.attribname, self.attribval, self.attribconfig, self.attribdisplay)

    def __repr__(self, *args, **kwargs):
        return '<Attribute Package -- Name: {0} Value: {1} Config: {2} Display: {3}>'.format(repr(self.attribname), repr(self.attribval), repr(self.attribconfig), repr(self.attribdisplay))

class ActionDataSource(object, ):

    def __init__(self, rootActions=[], **kwargs):
        self.rootActs = rootActions

    def GetRootActions(self):
        return self.rootActs

class XMLAttributeActionDataSource(ActionDataSource, ):

    def __init__(self, xmlactions, xmltoattributemap):
        self.xmlacts = xmlactions
        acfwlog.debug('XMLActions: {0}'.format(xmlactions))
        self.actionmap = xmltoattributemap
        self.atpkg = self._buildActPkgs(xmlactions)
        ActionDataSource.__init__(self, [self.atpkg])

    def __getActionsAttributes(self, act, attriblist):
        params = act.mandatoryparams[:]
        params.extend(act.optionalparams)
        strippedattribs = {}
        for param in params:
            try:
                if (param in attriblist):
                    acfwlog.debug('Removing this attribute: {0}'.format(param))
                    strippedattribs[param] = attriblist.pop(param)
            except:
                acfwlog.debug('Removing attrib failed.', exc_info=True)
        return strippedattribs

    def _buildActPkgs(self, element, parent=None):
        acfwlog.debug('Building AttributePackage for element: {0}'.format(element))
        actions = []
        try:
            attriblist = element.attrib.copy()
            attribvalue = attriblist.pop('value')
            attribconfig = (attriblist.pop('config', 'false').lower() == 'true')
            attribdisplay = attriblist.pop('display', None)
            attribdefault = attriblist.pop('default', None)
            for param in element.attrib:
                if (not (param in attriblist)):
                    continue
                try:
                    actklass = self.actionmap[param.lower()]
                    actparams = self.__getActionsAttributes(actklass, attriblist)
                except:
                    acfwlog.debug('no map for param {0}'.format(param))
                    continue
                currentact = actklass(actparams, parent=None)
                actions.append(currentact)
        except:
            acfwlog.error('Error while processing element. See OPLOGS for more info.', exc_info=True)
            acfwlog.debug(xml.etree.ElementTree.dump(element))
            return None
        actmgr = ActionManager(actions)
        atpkg = AttributePackage(attribname=element.tag, attribval=attribvalue, attribconfig=attribconfig, attribdisplay=attribdisplay, attribdefault=attribdefault, actmgr=actmgr, parent=parent)
        for childelem in element.getchildren():
            child = self._buildActPkgs(childelem, atpkg)
            if (child is not None):
                atpkg.addChild(child)
        return atpkg

class XMLActionDataSource(ActionDataSource, ):

    def __init__(self, xmlactions, xmltoattributemap, **kwargs):
        self.xmlacts = xmlactions
        acfwlog.debug('XMLActions: {0}'.format(xmlactions))
        self.actionmap = xmltoattributemap
        actTree = self.buildActionTree(xmlactions, **kwargs)
        ActionDataSource.__init__(self, actTree, **kwargs)

    def buildActionTree(self, element, parent=None, **kwargs):
        acfwlog.debug('Building Action tree.')
        try:
            actklass = self.actionmap[element.tag.lower()]
        except:
            return []
        acttree = []
        actparams = element.attrib
        currentact = actklass(actparams, parent)
        acttree.append(currentact)
        for subactel in element.getchildren():
            acttree.append(self.__buildActionTree(subactel, currentact))
        return acttree

class XMLConditionalActionDataSource(XMLActionDataSource, ):

    def __init__(self, xmlactions, xmltoattributemap, conditionalobjs):
        self.conditionalobjs = (conditionalobjs if (type(conditionalobjs) is list) else [conditionalobjs])
        XMLActionDataSource.__init__(self, xmlactions, xmltoattributemap, conditionalobjs=self.conditionalobjs)

    def buildActionTree(self, element, parent=None, conditionalobjs=[], **kwargs):
        acfwlog.debug('XMLCond - Building Action tree for element: {0}'.format(element))
        acttree = []
        acfwlog.debug('cond objs: {0}'.format(conditionalobjs))
        applicableconobjs = conditionalobjs[:]
        currentact = None
        try:
            if (element.tag.lower() in self.actionmap):
                actklass = self.actionmap[element.tag.lower()]
                actparams = element.attrib
                currentact = actklass(actparams, parent=parent)
                if (len(conditionalobjs) > 0):
                    currentact.additionaldata = conditionalobjs[0]
                else:
                    currentact.additionaldata = None
                if parent:
                    parent.addChild(currentact)
                acttree.append(currentact)
            else:
                attriblist = element.attrib.copy()
                attribname = element.tag.lower()
                attribvalue = attriblist.pop('value')
                acfwlog.debug('attribname,val: {0},{1}'.format(attribname, attribvalue))
                applicableconobjs = filter((lambda x: (x.__dict__.has_key(attribname) and (x.__dict__[attribname] == attribvalue))), applicableconobjs)
        except:
            acfwlog.error('Error while processing element. See OPLOGS for more info.', exc_info=True)
            acfwlog.debug(xml.etree.ElementTree.dump(element))
            return []
        acfwlog.debug('appcond objs: {0}'.format(applicableconobjs))
        for subactel in element.getchildren():
            acttree.extend(self.buildActionTree(subactel, conditionalobjs=applicableconobjs))
        return acttree

class ProcessableAction(object, ):

    def __init__(self, processparams):
        self.mandatoryprocessparams = processparams

    def process(self):
        raise NotImplementedError('Subclass must implement this.')

    def validateprocess(self, params):
        for mandatoryparam in self.mandatoryprocessparams:
            if (params.get(mandatoryparam) is None):
                return False
        return True

    def isprocparam(self, param):
        return (param in self.mandatoryprocessparams)

class Action(TreeItem, ):
    mandatoryparams = []
    optionalparams = []
    validparamvalues = {}

    def __init__(self, execparams, **kwargs):
        TreeItem.__init__(self, **kwargs)
        self.actmgr = None
        self.execparams = execparams
        self.additionaldata = None
        self.done = False
        if (self.mandatoryparams is None):
            self.mandatoryparams = []
        if (self.optionalparams is None):
            self.optionalparams = []
        for param in self.mandatoryparams:
            setattr(self, param, None)
        for param in self.optionalparams:
            setattr(self, param, None)
        acfwlog.debug('action {0}:'.format(self))

    def RegisterAM(self, actmgr):
        self.actmgr = actmgr

    def Execute(self):
        acfwlog.debug('{0} is executing'.format(self.__class__))
        acfwlog.debug('My execparams: {0}'.format(self.execparams))
        self.done = True

    def Validate(self):
        validfails = []
        acfwlog.debug('Validating {0}'.format(self))
        for manparam in self.mandatoryparams:
            if (not (manparam in self.execparams.keys())):
                validfails.append(ValidationFailure(self, 'Failed Validation! MANDATORY parameter missing: {0}'.format(manparam)))
        for param in self.execparams.keys():
            if ((not (param in self.optionalparams)) and (not (param in self.mandatoryparams))):
                validfails.append(ValidationFailure(self, 'Failed Validation! This parameter is not a mandatory or optional parameter: {0}'.format(param)))
            elif ((param in self.validparamvalues.keys()) and (not (self.execparams[param] in self.validparamvalues[param]))):
                validfails.append(ValidationFailure(self, "Failed Validation! This parameter's value is not a valid value. Please ensure the value is one of the following:\nParam: {0}\nValue: {1}\nValid Values: {2}".format(param, self.execparams[param], self.validparamvalues[param])))
        return validfails

    def GetVariable(self, varname):
        if self.parent:
            return self.parent.GetVariable(varname)
        return None

    def FindParamHandler(self, param):
        if ((param in self.mandatoryparams) or (param in self.optionalparams)):
            return self
        elif (not (self.parent is None)):
            return self.parent.FindParamHandler(param)
        else:
            return None

    def GetLastResult(self):
        if getattr(self, 'result', None):
            return self.result
        elif (not (self.parent is None)):
            return self.parent.GetLastResult()
        else:
            return None

    def __repr__(self):
        return '<{0} {1}>'.format(type(self), [(x, self.__dict__[x]) for x in filter((lambda x: (not (x.startswith('__') or (x == 'parent') or (x == 'children')))), self.__dict__)])

class ProcessAction(Action, ):

    def __init__(self, params, parent):
        Action.__init__(self, execparams=params, parent=parent)

    def Execute(self):
        Action.Execute(self)
        return None

    def Validate(self):
        Action.Validate(self)
        return ValidationFailure(self, 'This action is not implemented')

class AttributePackageManager(Forest, ):

    def __init__(self):
        Forest.__init__(self)
        self.valid = False

    def walkAndCollect(self, procfunc):
        q = Queue()
        repolist = [{}]
        for pkg in self.trees:
            if pkg.valid:
                q.put(pkg)
        while (not q.empty()):
            atpkg = q.get_nowait()
            procfunc(atpkg, repolist)
            for child in atpkg.children:
                if child.valid:
                    q.put_nowait(child)
        return repolist

    def addAttributePackage(self, atpkg):
        try:
            results = atpkg.Validate()
            if (len(results) == 0):
                self.addTree(atpkg)
                valid = True
                self.valid = valid
            else:
                acfwlog.critical('Your attribute package failed validation.  Please review the results and fix as needed.\n{0}'.format(results))
                return False
        except:
            acfwlog.critical('Unhandled exception!', exc_info=True)
        return self.valid

    def GetResults(self):

        def cbfunc(atpkg, repolist):
            if (atpkg.name not in repolist):
                repolist[atpkg.attribname] = atpkg
        dicts = self.walkAndCollect(cbfunc)
        return dicts

    def Execute(self):
        for atpkg in self.trees:
            atpkg.Execute()

class ActionManager(Forest, ):

    def __init__(self, actions):
        Forest.__init__(self, trees=actions)
        for act in self.getiterator():
            act.RegisterAM(self)

    def ParentAction(self, act):
        return act.parent

    def Execute(self):
        return all(map(self.__execute, self.trees))

    def GetActionVar(self, varname):
        varvalue = None
        for act in self.getiterator():
            varvalue = act.GetVariable(varname)
            if varvalue:
                break
        return varvalue

    def GetActionResults(self, actklass=Action):
        acts = filter((lambda x: (isinstance(x, actklass) and x.done)), self.getiterator())
        try:
            return [act.result for act in acts]
        except:
            acfwlog.critical('Unhandled exception in GetActionResults. See log for more informaiton.', exc_info=True)
            return []

    def Validate(self):
        allacts = self.getiterator()
        acfwlog.debug('allacts,trees {0},{1}'.format(allacts, self.trees))
        results = []
        for act in allacts:
            results.extend(act.Validate())
        acfwlog.debug('ActMgr Validate results: {0}'.format(results))
        return results

    def __execute(self, act):
        try:
            suc = act.Execute()
        except:
            acfwlog.critical('Unexpected Error while executing action: {0}'.format(act), exc_info=True)
            suc = False
        if suc:
            acfwlog.debug('This actions children: {0}'.format(act.children))
            for child in act.children:
                suc = self.__execute(child)
        return suc

class ActionParameter(object, ):
    pass

class ActionParamterGroup(ActionParameter, ):

    def __init__(self, grpname):
        self.name = grpname
        self.params = []

    def add(self, actionparam):
        self.params.append(actionparam)