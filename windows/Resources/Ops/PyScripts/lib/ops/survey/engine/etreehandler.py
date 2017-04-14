
import datetime
import re
import sys
from xml.etree.ElementTree import ElementTree
import dsz
import ops.survey
from ops.survey.engine.xmlhandler import ConfigProcessor, enforce

class ElementTreeProcessor(ConfigProcessor, ):

    def __init__(self, namespace, forcemenu=False, **kwargs):
        self.__namespace = namespace
        self.__path = []
        self.__tree = None
        self.forcemenu = forcemenu
        self.__interval = re.compile('((\\d+)\\s*w){0,1}\\s*((\\d+)\\s*d){0,1}\\s*((\\d+)\\s*h){0,1}\\s*((\\d+)\\s*m){0,1}\\s*((\\d+)\\s*s){0,1}')
        ConfigProcessor.__init__(self, **kwargs)

    @property
    def namespace(self):
        return self.__namespace

    def process(self):
        enforce((self.__tree is None), 'Cannot execute processing while another processing or validation routine is still active.')
        self.validate_only = False
        self.__tree = ElementTree(file=self.file)
        self.__path = []
        self._process_child_elements(self.__tree.getroot())
        self.__tree = None

    def validate(self):
        enforce((self.__tree is None), 'Cannot execute validation while another processing or validation routine is still active.')
        self.__tree = ElementTree(file=self.file)
        self.validate_only = True
        self.__path = []
        self._process_child_elements(self.__tree.getroot())
        self.__tree = None
        return True

    def _process_child_elements(self, element, ignore=[]):
        self.__path.append(None)
        for e in element:
            self.__path.pop()
            dsz.script.CheckStop()
            if (e.tag in ignore):
                continue
            self.__path.append(e.tag)
            modname = '.'.join(([self.namespace] + self.__path))
            try:
                __import__(modname)
            except ImportError as exc:
                enforce(False, (lambda : ("Tag handler '%s' not found for element '<%s>'; reason: %s." % (modname, e.tag, exc))))
            handler = sys.modules[modname]
            marker = e.get('marker')
            display = e.get('name')
            generic_display = ('"%s": ["attribs": %s, "text": %s]' % (e.tag, e.attrib, repr(e.text)))
            if (display is None):
                display = generic_display
            error_marker = (marker if (marker is not None) else ((('__generic_error_marker__::' + self.file) + '::') + generic_display))
            period = e.get('period')
            if (period is not None):
                period = self.__interval.match(period)
                enforce((period is not None), (lambda : ('%s -- error in period time delta format string.' % display)))
                qc = (lambda x: (int(x) if (x is not None) else 0))
                period = datetime.timedelta(weeks=qc(period.group(2)), days=qc(period.group(4)), hours=qc(period.group(6)), minutes=qc(period.group(8)), seconds=qc(period.group(10)))
            taghandler = eval((('handler.' + e.tag.title()) + 'TagHandler(element=e, _processor=self, _marker=marker, _period=period, _display=display, _error_marker=error_marker)'))
            if self.validate_only:
                enforce(taghandler.validate(), (lambda : ("Validation error for tag '<%s>'; text='%s'; attributes=%s" % (e.tag, repr(e.text), e.attrib))))
            else:
                if (not taghandler.marker_check()):
                    continue
                try:
                    ret = taghandler.process()
                    if (ret == True):
                        if ((marker is not None) or (marker != 'None')):
                            ops.survey.complete(marker)
                        else:
                            ops.survey.complete(error_marker)
                    elif (ret == False):
                        if ((marker is not None) and (marker != 'None')):
                            ops.survey.error(marker)
                        else:
                            ops.survey.error(error_marker)
                except:
                    if ((marker is not None) and (marker != 'None')):
                        ops.survey.error(marker)
                    else:
                        ops.survey.error(error_marker)
                    raise 
        self.__path.pop()
        return True

class EtreeTagHandler(object, ):

    def __init__(self, element, _processor=None, _marker=None, _period=None, _display=None, _error_marker=None):
        enforce((_processor is not None), 'Tag handler does not have all the required information.')
        enforce((element is not None), 'Tag handler does not have its element to process.')
        enforce((_display is not None), 'Display for error print out required.')
        enforce((_error_marker is not None), 'Error marker must be provided for error flow control.')
        self.__period = _period
        self.__marker = _marker
        self.__error_marker = _error_marker
        self.__display = _display
        self.element = element
        self.__processor = _processor

    @property
    def flags(self):
        return self.__processor.flags

    @property
    def forcemenu(self):
        return self.__processor.forcemenu

    def continue_processing(self, ignore=[]):
        return self.__processor._process_child_elements(self.element, ignore)

    def marker_check(self):
        if ((self.__marker is not None) and (self.__marker != 'None')):
            if ops.survey.isDone(self.__marker, self.__period):
                ops.info(('%s already completed, skipping.' % self.__display))
                return False
            if ops.survey.isError(self.__marker):
                ops.warn('Warning: The following task encountered an error last time it was executed.')
                print ('\t%s' % self.__display)
                ops.warn('You may not want to run this task unless you know it is safe to do so.')
                if dsz.ui.Prompt('Skip this task?'):
                    return False
            if ops.survey.isRedo(self.__marker):
                ops.info('The following task has been marked for re-do.')
                print ('\t%s' % self.__display)
                if (not dsz.ui.Prompt('Do you wish to re-do this task?')):
                    return True
        elif ops.survey.isError(self.__error_marker):
            ops.warn('Warning: The following task encountered an error last time it was executed.')
            print ('\t%s' % self.__display)
            ops.warn('You may not want to run this task unless you know it is safe to do so.')
            if dsz.ui.Prompt('Skip this task?'):
                return False
        return True

    def process(self):
        enforce(False, (lambda : ("XML element handler 'process' not implemented for %s" % self.__class__)))

    def validate(self):
        enforce(False, (lambda : ("XML element handeler 'validate' not implemented for %s" % self.__class__)))

    def getbool(self, attrib, default=None):
        value = self.element.get(attrib, default=default)
        if ((value is not None) and (type(value) is not bool)):
            value = (value.lower() == 'true')
        return value