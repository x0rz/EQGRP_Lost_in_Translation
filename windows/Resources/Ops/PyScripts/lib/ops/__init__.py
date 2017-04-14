
import os
import time
import dsz, dsz.lp

def _ensuretargettempdir():
    retval = os.path.join(LOGDIR, 'tmp')
    if (not os.path.exists(retval)):
        os.mkdir(retval)
    return retval
TARGET_ADDR = dsz.script.Env['target_address']
TARGET_IP = TARGET_ADDR[1:]
PID = dsz.env.Get('_PID')
LOGDIR = dsz.lp.GetLogsDirectory()
PROJECTLOGDIR = os.path.normpath(os.path.join(LOGDIR, '..'))
BASELOGDIR = os.path.normpath(os.path.join(LOGDIR, '..', '..'))
RESDIR = dsz.lp.GetResourcesDirectory()
PROJECT = (dsz.env.Get('OPS_PROJECTNAME') if dsz.env.Check('OPS_PROJECTNAME') else None)
PREPS = os.path.normpath(os.path.join(RESDIR, '..', 'Preps'))
PROJECT_PREPS = (os.path.join(PREPS, PROJECT) if (PROJECT is not None) else None)
TARGET_PREPS = (os.path.join(PROJECT_PREPS, (TARGET_IP + 'w')) if (PROJECT_PREPS is not None) else None)
DSZDISKSDIR = os.path.normpath(os.path.join(RESDIR, '..'))
OPSDIR = os.path.join(RESDIR, 'Ops')
DATA = os.path.join(OPSDIR, 'Data')
TOOLS = os.path.join(OPSDIR, 'Tools')
TARGET_TEMP = _ensuretargettempdir()
TARGET_ID = (dsz.env.Get('OPS_TARGET_ID') if dsz.env.Check('OPS_TARGET_ID') else None)
INSTANCE_NUM = (dsz.env.Get('OPS_DSZ_INSTANCE_NUM') if dsz.env.Check('OPS_DSZ_INSTANCE_NUM') else None)

def timestamp():
    return time.strftime('%H:%M:%S')

def datestamp():
    return time.strftime('%Y-%m-%d')

def datetimestamp():
    return ((datestamp() + ' ') + timestamp())

def targetdatetimestamp():
    return ((datetimestamp() + ' ') + TARGET_ADDR)

def agestring(delta):
    retval = ''
    if (delta.days > 0):
        retval += ('%d days, ' % delta.days)
    total_seconds = ((delta.microseconds + ((delta.seconds + ((delta.days * 24) * 3600)) * (10 ** 6))) / (10 ** 6))
    if (total_seconds > 3600):
        retval += ('%02d:' % (delta.seconds / 3600))
    if (total_seconds > 60):
        retval += ('%02d:' % ((delta.seconds % 3600) / 60))
    retval += ('%02d' % ((delta.seconds % 60),))
    if (total_seconds < 60):
        retval += ' seconds'
    return retval

def utf8(msg):
    return (msg.encode('utf8') if (type(msg) is unicode) else msg)

def info(msg, type=dsz.GOOD, stamp=None):
    dsz.ui.Echo(('[%s] %s' % ((stamp if stamp else targetdatetimestamp()), utf8(msg))), type)

def warn(msg, stamp=None):
    info(msg, type=dsz.WARNING, stamp=stamp)

def error(msg, stamp=None):
    info(msg, type=dsz.ERROR, stamp=stamp)

def pause(msg=None):
    dsz.ui.Pause((msg if (msg is not None) else 'Press enter to continue.'))

def alert(msg, type=dsz.WARNING, stamp=None):
    msg = msg.replace('"', '\\"')
    cmdline = ('warn "[%s] %s"' % ((stamp if stamp else datetimestamp()), utf8(msg)))
    if (type == dsz.DEFAULT):
        cmdline += ' -default'
    elif (type == dsz.ERROR):
        cmdline += ' -error'
    elif (type == dsz.GOOD):
        cmdline += ' -good'
    dsz.cmd.Run(cmdline)

def preload(cmd):
    flags = dsz.control.Method()
    dsz.control.echo.Off()
    ret = dsz.cmd.Run(('available -command %s -load' % cmd))
    del flags
    return ret