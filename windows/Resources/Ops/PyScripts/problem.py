
from util.DSZPyLogger import DSZPyLogger
import sys, dsz, dsz.ui, dsz.env, ops

def main():
    if (ops.TARGET_ADDR == 'z0.0.0.1'):
        ops.warn('Problems can only be reported from target sessions.  If you have no more target sessions, please complain about the problem through other means')
        sys.exit((-1))
    toolName = sys.argv[1]
    if (not dsz.env.Check('OPS_USERID')):
        idnum = dsz.ui.GetInt('Please enter your ID')
        dsz.env.Set('OPS_USERID', str(idnum), 0, '')
    idnum = dsz.env.Get('OPS_USERID')
    problemText = ' '.join(sys.argv[2:])
    dszLogger = DSZPyLogger()
    toolLog = dszLogger.getLogger(toolName)
    toolLog.log(21, ((idnum + ':') + problemText))
    ops.info('Your problem has been logged and will be reported when you are done')
if (__name__ == '__main__'):
    main()