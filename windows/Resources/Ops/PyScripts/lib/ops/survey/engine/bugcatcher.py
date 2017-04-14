
from __future__ import print_function
import traceback
import dsz
import ops
from util.DSZPyLogger import DSZPyLogger
DEFAULT_LOG = 'OPS'
_debug_enabled = False
_pass_through = {}

def register_passthrough(extype, content):
    if (extype not in _pass_through):
        _pass_through[extype] = []
    tcontent = (content if (type(content) is tuple) else (content,))
    if (tcontent not in _pass_through[extype]):
        _pass_through[extype].append(tcontent)

class CriticalError(Exception, ):
    pass
CRITICAL_ERROR_TEXT = 'Critical error. Script should terminate.'
BUGCATCHER_CAUGHT = '::caught by bugcatcher::'
USER_QUIT_SCRIPT_TEXT = 'User QUIT script'
register_passthrough(RuntimeError, USER_QUIT_SCRIPT_TEXT)
register_passthrough(CriticalError, CRITICAL_ERROR_TEXT)

def error(s, log=DEFAULT_LOG):
    logger = DSZPyLogger().getLogger(log)
    logger.error(s)

def warn(s, log=DEFAULT_LOG):
    logger = DSZPyLogger().getLogger(log)
    logger.warn(s)

def debug(s, log=DEFAULT_LOG):
    if _debug_enabled:
        logger = DSZPyLogger().getLogger(log)
        logger.debug(s)
    return _debug_enabled

def bugcatcher(bug_func, bug_log=DEFAULT_LOG, bug_critical=True, **kwargs):
    ret = None
    try:
        return (True, bug_func(**kwargs))
    except Exception as e:
        dsz.script.CheckStop()
        if (type(e) in _pass_through):
            for i in _pass_through[type(e)]:
                if (e.args == i):
                    raise 
        print()
        if bug_critical:
            error((((((str(type(e)) + ' : ') + ''.join([(i.encode('utf8') if (type(i) is unicode) else str(i)) for i in e.args])) + '\n--\n') + traceback.format_exc()) + '--\n'), bug_log)
            print('This is considered a critical functionality error. Script will not continue.')
        else:
            warn((((((str(type(e)) + ' : ') + ''.join([(i.encode('utf8') if (type(i) is unicode) else str(i)) for i in e.args])) + '\n--\n') + traceback.format_exc()) + '--\n'), bug_log)
            print('This is considered a non-critical functionality error.')
        print(("An error report for this problem as been automatically generated in OPLOGS '%s'" % bug_log))
        if (not bug_critical):
            print('Verify it is safe to continue. The default response here is to assume it is not and quit.')
        else:
            print('Assuming it is not safe to continue under these conditions.')
        if (bug_critical or (not dsz.ui.Prompt('Is it safe to continue running this script?', False))):
            raise CriticalError(CRITICAL_ERROR_TEXT, BUGCATCHER_CAUGHT)
        return (False, e)

def wasCaught(e):
    return (e.args == (CRITICAL_ERROR_TEXT, BUGCATCHER_CAUGHT))

def userQuitScript(e):
    return (e.args == (USER_QUIT_SCRIPT_TEXT,))
if (__name__ == '__main__'):

    def testfunc():
        raise RuntimeError, 'foo'
    try:
        print(bugcatcher((lambda : dsz.ui.Prompt('Yes/No/Quit?')), 'TEST'))
        print(bugcatcher(testfunc, 'TEST'))
    except Exception as e:
        if (not wasCaught(e)):
            raise 