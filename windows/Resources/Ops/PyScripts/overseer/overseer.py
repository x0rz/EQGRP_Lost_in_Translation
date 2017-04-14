
import glob
import imp
import os
import sys
import dsz
import dsz.file
import dsz.path
import ops.menu

def main():
    modules = load_plugins(os.path.join(os.path.dirname(__file__), 'plugins'))
    module_map = dict([(module.MENU_TEXT, module.main) for module in modules])
    heading = 'Overseer Survey Options'
    menu = ops.menu.Menu()
    menu.set_heading(heading)
    for module in modules:
        menu.add_toggle_option(module.MENU_TEXT, state='Enabled')
    result_set = menu.execute(exit='Run Plugins...')['all_states']['']
    for (text, enabled) in result_set.items():
        if (not (enabled == 'Enabled')):
            continue
        try:
            print '\n'
            dsz.ui.Echo(('-' * 80), dsz.GOOD)
            module_map[text]()
        except:
            dsz.ui.Echo(('\nError running command: %s' % item[0]), dsz.ERROR)
    print '\n'
    dsz.ui.Echo(('-' * 80), dsz.GOOD)
    dsz.ui.Echo('All tasks have been queued or run.\n\nGo check your log files for the information!', dsz.GOOD)

def load_plugins(plugin_path):
    sys.path.append(plugin_path)
    path_to_glob = os.path.join(plugin_path, '*.py')
    all_python_files = glob.glob(path_to_glob)
    modules = []
    for module in all_python_files:
        if ('__init__' in module):
            continue
        name = os.path.basename(module).replace('.py', '')
        module = import_by_name(name)
        if (not module):
            continue
        if (not hasattr(module, 'MENU_TEXT')):
            continue
        if (not hasattr(module, 'main')):
            continue
        modules.append(module)
    return modules

def import_by_name(name):
    try:
        return sys.modules[name]
    except KeyError as e:
        pass
    (fp, pathname, description) = imp.find_module(name)
    try:
        module = imp.load_module(name, fp, pathname, description)
        return module
    except Exception as e:
        print ('Exception on import_by_name: %s' % e)
        return None
    finally:
        if fp:
            fp.close()
if (__name__ == '__main__'):
    main()