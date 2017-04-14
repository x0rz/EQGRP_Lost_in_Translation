
import sys
import ops.cmd
import ops.env
import ops.db
import ops
from util.DSZPyLogger import getLogger
logger = getLogger('SAFETY')
unhookables = ['dir', 'registryquery', 'registryadd', 'get', 'put', 'run', 'dll_u', 'injectdll', 'cd', 'copy', 'move', 'delete']
warnhookables = ['eventlogedit']

def ensureTable(dbHandle=None):
    if (dbHandle is None):
        dbHandle = ops.db.Database(db=ops.db.TARGET_DB, isolation_level=None)
        curs = dbHandle.connection.cursor()
    else:
        curs = dbHandle.connection.cursor()
    try:
        curs.execute('CREATE TABLE safetyhandlers (plugin, handlerfunc)')
    except:
        pass
    return curs

def cmdenv(plugin):
    return ops.env.get(('OPS_SAFE_%s' % plugin))

def getSafetyHandlerNames(plugin):
    retval = []
    if (cmdenv(plugin) is not None):
        handlerstr = cmdenv(plugin)
        handlernames = handlerstr.split(',')
        retval = []
        for handlername in handlernames:
            lastdot = handlername.rindex('.')
            modname = handlername[0:lastdot]
            funcname = handlername[(lastdot + 1):]
            retval.append((modname, funcname))
    return retval

def getSafetyHandlerFuncs(plugin):
    funcnames = getSafetyHandlerNames(plugin)
    retval = []
    for funcname in funcnames:
        try:
            stepimport(funcname[0])
            retval.append(sys.modules[funcname[0]].__dict__[funcname[1]])
        except ImportError as ex:
            logger.log(10, ('Could not find module %s' % funcname[0]))
            raise ex
        except KeyError as ex:
            logger.log(10, ('Could not find function %s in module %s' % (funcname[1], funcname[0])))
            raise ex
    return retval

def addSafetyHandler(plugin, fullfunc):
    current = getSafetyHandlerNames(plugin)
    lastdot = fullfunc.rindex('.')
    modname = fullfunc[0:lastdot]
    funcname = fullfunc[(lastdot + 1):]
    splitfunc = (modname, funcname)
    if (splitfunc not in current):
        current.append(splitfunc)
        writeSafetyHandlers(plugin, current)

def clearSafetyHandler(plugin):
    writeSafetyHandlers(plugin, None)

def removeSafetyHandler(plugin, fullfunc):
    current = getSafetyHandlerNames(plugin)
    lastdot = fullfunc.rindex('.')
    modname = fullfunc[0:lastdot]
    funcname = fullfunc[(lastdot + 1):]
    splitfunc = (modname, funcname)
    for handler in current:
        if (handler == splitfunc):
            current.remove(handler)
            writeSafetyHandlers(plugin, current)
GENERIC_WRAPPER_SCRIPT = 'wrappers/safetywrapper.py'

def writeSafetyHandlers(plugin, handlers):
    if ((handlers is None) or (len(handlers) == 0)):
        ops.env.delete(('OPS_SAFE_%s' % plugin))
        ops.cmd.getDszCommand('wrappers', unregister=plugin, script=GENERIC_WRAPPER_SCRIPT, project='Ops', pre=True).execute()
        return
    else:
        strval = ('%s.%s' % handlers[0])
        for handler in handlers[1:]:
            strval += (',%s.%s' % handler)
        ops.env.set(('OPS_SAFE_%s' % plugin), strval)
        if (len(handlers) == 1):
            ops.cmd.getDszCommand('wrappers', register=plugin, script=GENERIC_WRAPPER_SCRIPT, project='Ops', pre=True).execute()
        ops.warn(('%d safety %s registered for %s' % (len(handlers), ('handler' if (len(handlers) == 1) else 'handlers'), plugin)))

def loadHandlers():
    tdb = ops.db.get_tdb()
    ensureTable(tdb)
    curs = tdb.connection.execute('SELECT * FROM safetyhandlers')
    for row in curs:
        for handler in row['handlerfunc'].split(','):
            addSafetyHandler(row['plugin'], handler)

def saveHandlers():
    tdb = ops.db.get_tdb()
    ensureTable(tdb)
    tdb.connection.execute('DELETE FROM safetyhandlers')
    env = ops.cmd.quickrun('lpgetenv')
    for var in env.envitem:
        if (var.option[0:9] == 'OPS_SAFE_'):
            tdb.connection.execute('INSERT INTO safetyhandlers(plugin, handlerfunc) VALUES(?, ?)', (var.option[9:], var.value))

def listSafetyHandlers():
    pass

def stepimport(modname):
    packs = modname.split('.')
    curpack = packs[0]
    __import__(curpack)
    for pack in packs[1:]:
        curpack += ('.' + pack)
        __import__(curpack)

def doSafetyHandlers(commandobj):
    if (not isinstance(commandobj, ops.cmd.DszCommand)):
        raise RuntimeError, ('Script did not provide an ops.cmd.DszCommand instance; instead it gave me a %s' % type(commandobj))
    good = True
    msgparts = []
    if (not commandobj.validateInput()):
        good = False
        msgparts.append('Input validation failed')
    handlers = getSafetyHandlerFuncs(commandobj.plugin)
    for handler in handlers:
        try:
            (isgood, msg) = handler(commandobj)
        except AttributeError:
            (isgood, msg) = (True, '')
        if (not isgood):
            good = False
        if (msg != ''):
            msgparts.append(msg)
    return (good, msgparts)

def _usage():
    return 'Usage: \n\tsafetychecks.py <load|save|list>\n\tsafetychecks.py clear <name of plugin>\n\tsafetychecks.py <add|delete> <name of safety check>\n\n\tNote: name of safety check is not required for clear'
if ((__name__ == '__main__') or (__name__ == '__ops_survey_plugin__')):
    good = False
    if (len(sys.argv) == 2):
        action = sys.argv[1]
        if (action == 'load'):
            loadHandlers()
            ops.info('Loaded safety handlers from previous op(s)')
            good = True
        elif (action == 'save'):
            saveHandlers()
            ops.info('Saved safety handlers for future op(s)')
            good = True
        elif (action == 'list'):
            listSafetyHandlers()
            good = True
    elif (len(sys.argv) == 3):
        action = sys.argv[1]
        plugin = sys.argv[2]
        if (action == 'clear'):
            clearSafetyHandler(plugin)
            good = True
    elif (len(sys.argv) == 4):
        action = sys.argv[1]
        plugin = sys.argv[2]
        handler = sys.argv[3]
        if (action == 'add'):
            addSafetyHandler(plugin, handler)
            good = True
        elif (action == 'delete'):
            removeSafetyHandler(plugin, handler)
            good = True
    if (not good):
        ops.warn('You called this wrong!  Are you sure you should be doing this?')
        ops.info(_usage())