
from __future__ import print_function
import os
import pickle
from xml.etree.ElementTree import ElementTree
import dsz.lp

class XMLConfigError(Exception, ):
    pass

def enforce(condition, msg=None):
    if (not condition):
        if msg:
            raise XMLConfigError, (msg if (type(msg) is not type((lambda : None))) else msg())
        else:
            raise XMLConfigError

class ConfigProcessor(object, ):

    def __init__(self, file, flags):
        self.flags = flags
        self.file = file

    def process(self):
        enforce(False, (lambda : ('XML config processor not implemented for %s' % self.__class__)))

    def validate(self):
        enforce(False, (lambda : ('XML config validation not implemented for %s' % self.__class__)))

class Config(object, ):

    def __init__(self, file, flags={}, **kwargs):
        self.__file = file
        self.flags = flags
        self.kwargs = kwargs

    @property
    def file(self):
        return self.__file

    def validate(self):
        return self.__process(validate_only=True)

    def process(self):
        self.__process(validate_only=False)

    def __process(self, validate_only):
        ver = version(self.file)
        initargs = _processors[ver]['init']
        processor = _processors[ver]['processor']
        for i in self.kwargs:
            if (i not in initargs):
                initargs[i] = self.kwargs[i]
        config = processor(file=self.file, flags=self.flags, **initargs)
        if validate_only:
            return config.validate()
        else:
            config.process()
_HANDLER_CACHE = os.path.normpath(os.path.join(dsz.lp.GetResourcesDirectory(), '..', 'tmp', 'survey', 'engines.pickle'))

def _loadhandlers():
    if (not os.path.exists(_HANDLER_CACHE)):
        return {}
    with open(_HANDLER_CACHE, 'r') as input:
        return pickle.load(input)
_processors = _loadhandlers()

def _savehandlers():
    if (not os.path.exists(os.path.split(_HANDLER_CACHE)[0])):
        os.makedirs(os.path.split(_HANDLER_CACHE)[0])
    with open(_HANDLER_CACHE, 'w') as output:
        pickle.dump(_processors, output)

def version(file):
    tree = ElementTree(file=file)
    version = tree.getroot().get('version', default=None)
    enforce((version in _processors), (lambda : ("Unsupported XML configuration version '%s' read from file." % version)))
    return version

def register_handler(version, processor, **initargs):
    if (version in _processors):
        return False
    _processors[version] = {'processor': processor, 'init': initargs}
    _savehandlers()
    return True