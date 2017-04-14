
try:
    import dsz.script
    import dsz.env
    import dsz.ui
    HASDSZ = True
except:
    HASDSZ = False
import logging
import os
DEBUG = logging.DEBUG
INFO = logging.INFO
GOOD = (INFO + 5)
logging.addLevelName(GOOD, 'GOOD')
WARNING = logging.WARNING
ERROR = logging.ERROR
CRITICAL = logging.CRITICAL
LOG_FILE_DIR = ''
if HASDSZ:
    LOG_FILE_DIR = os.path.join(dsz.script.Env['log_path'], 'GetFiles', 'NOSEND', 'OPLOGS')
DEFAULT_LOG_FILE = 'DSZPyLogger.log'
_TERM_LOG_FORMAT = '%(asctime)s (%(name)s) - %(message)s'
_FILE_LOG_FORMAT = '%(asctime)s (%(name)s) %(levelname)s - %(message)s'
LOG_EXC_TO_TERM = False

def getLogger(name=None):
    log = logging.getLogger(name)
    return log

def CheckEnvVar(name):
    if HASDSZ:
        dsz.env.Check(name)
    else:
        return None

def GetEnvVar(name):
    if HASDSZ:
        dsz.env.Get(name)
    else:
        return None

def SetEnvVar(name, value):
    if HASDSZ:
        dsz.env.Set(name, value)

class DSZLogger(logging.Logger, ):

    def __init__(self, name, fileloglevel=DEBUG, termloglevel=GOOD, **kwargs):
        logging.Logger.__init__(self, name, **kwargs)
        if (not os.path.exists(LOG_FILE_DIR)):
            os.makedirs(LOG_FILE_DIR)
        logging.basicConfig(filename=os.path.join(LOG_FILE_DIR, DEFAULT_LOG_FILE), format=_FILE_LOG_FORMAT, level=fileloglevel)
        self.propagate = False
        ch = self._getHandler(logging.FileHandler)
        if (ch is None):
            ch = logging.FileHandler(os.path.join(LOG_FILE_DIR, (name + '.log')))
            formatter = logging.Formatter(_FILE_LOG_FORMAT)
            ch.setFormatter(formatter)
            level = fileloglevel
            try:
                rootFH = root._getHandler(logging.FileHandler)
                if (rootFH is not None):
                    level = rootFH.level
            except NameError:
                pass
            ch.setLevel(level)
            self.addHandler(ch)
        ch = self._getHandler(DSZTerminalHandler)
        if (ch is None):
            ch = DSZTerminalHandler()
            formatter = logging.Formatter(_TERM_LOG_FORMAT, '[%H:%M:%S]')
            ch.setFormatter(formatter)
            level = termloglevel
            try:
                rootSH = root._getHandler(DSZTerminalHandler)
                if (rootSH is not None):
                    level = rootSH.level
            except NameError:
                pass
            ch.setLevel(level)
            self.addHandler(ch)
        ch = None
        self.setFileLogLevel(fileloglevel)
        self.setTermLogLevel(termloglevel)
        logging.addLevelName(21, 'USER')

    def logProblem(self, src, details):
        try:
            eLog = logging.getLogger(src)
            eLog.propagate = False
            ch = self._getHandler(logging.FileHandler, eLog)
            if (ch is None):
                ch = logging.FileHandler(os.path.join(LOG_FILE_DIR, 'UserProblems.log'))
                formatter = logging.Formatter(_FILE_LOG_FORMAT)
                ch.setFormatter(formatter)
                ch.setLevel(self.INFO)
                eLog.addHandler(ch)
        except:
            raise TypeError, 'src must be a string [a valid windows filename]'
        eLog.log(21, details)
        eLog = None

    def setFileLogLevel(self, level):
        try:
            level = int(level)
        except:
            raise TypeError, 'level must be one of DSZPyLogger.DEBUG|INFO|WARNING|ERROR|CRITICAL'
        ch = self._getHandler(logging.FileHandler)
        if (ch is not None):
            ch.setLevel(level)
        ch = None

    def setTermLogLevel(self, level):
        try:
            level = int(level)
        except:
            raise TypeError, 'level must be one of DSZPyLogger.DEBUG|INFO|GOOD|WARNING|ERROR|CRITICAL'
        ch = self._getHandler(DSZTerminalHandler)
        if (ch is not None):
            ch.setLevel(level)
        ch = None

    def _getHandler(self, cls):
        for ch in self.handlers:
            if (ch.__class__ == cls):
                return ch
        return None

    def _getEffectiveHandler(self, cls):
        ch = self._getHandler(cls)
        if ((ch is None) and (self.parent is not None)):
            ch = self._getEffectiveHandler(cls, self.parent)
        return ch

    def good(self, msg, *args, **kwargs):
        if self.isEnabledFor(GOOD):
            self._log(GOOD, msg, args, **kwargs)
if HASDSZ:

    class DSZTerminalHandler(logging.Handler, ):

        def __init__(self):
            logging.Handler.__init__(self)

        def emit(self, record):
            try:
                if (not LOG_EXC_TO_TERM):
                    record.exc_info = False
                    record.exc_text = None
                msg = self.format(record)
                if (record.levelno >= ERROR):
                    echocode = dsz.ERROR
                elif (record.levelno >= WARNING):
                    echocode = dsz.WARNING
                elif (record.levelno >= GOOD):
                    echocode = dsz.GOOD
                else:
                    echocode = dsz.DEFAULT
                dsz.ui.Echo(str(msg), echocode)
            except (KeyboardInterrupt, SystemExit):
                raise 
            except:
                self.handleError(record)
else:
    DSZTerminalHandler = logging.StreamHandler
root = DSZLogger('DSZPyLogger', level=DEBUG)
logging.Logger.root = root
logging.setLoggerClass(DSZLogger)

class DSZPyLogger:
    DEBUG = logging.DEBUG
    INFO = logging.INFO
    WARNING = logging.WARNING
    ERROR = logging.ERROR
    CRITICAL = logging.CRITICAL

    def __init__(self):
        pass

    def getLogger(self, name):
        return getLogger(name)

    def setTermLogLevel(self, level, log=None):
        if (log is None):
            getLogger().setTermLogLevel(level)
        else:
            log.setTermLogLevel(level)

    def setFileLogLevel(self, level, log=None):
        if (log is None):
            getLogger().setFileLogLevel(level)
        else:
            log.setFileLogLevel(level)