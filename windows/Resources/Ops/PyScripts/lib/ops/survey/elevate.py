
import dsz, dsz.version, dsz.process
import ops

def main():
    flags = dsz.control.Method()
    dsz.control.echo.Off()
    if dsz.process.windows.IsSystem():
        ops.info('Current user: System')
        dsz.env.Set('OPS_ALREADYPRIV', 'TRUE')
        return None
    if dsz.process.windows.IsInAdminGroup():
        ops.info('Your process has Administrator rights.')
        dsz.env.Set('OPS_ALREADYPRIV', 'TRUE')
        return None
    dsz.env.Set('OPS_ALREADYPRIV', 'FALSE')
    ops.warn('You are not System and do not have Administrator privileges.')
    if (not dsz.ui.Prompt('Use JUMPUP to elevate?')):
        ops.warn('Did not elevate, probably for a good reason.')
    else:
        (success, id) = dsz.cmd.RunEx('getadmin')
        if success:
            ops.info(('Successfully elevated. Do not stop command ID %d or you will lose your blessing.' % id))
        else:
            ops.error(('Could not elevate! See log for command ID %d for more information.' % id))
            ops.error('Be sure you know what you can and cannot do.')
if (__name__ == '__main__'):
    main()