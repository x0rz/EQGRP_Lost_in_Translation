
import ops
import os.path
import imp
import re
import glob
import os
import sys
import dsz
import ops.cmd

def _whats_your_name():
    return 'monitor'
DSZ_NS = '{urn:mca:db00db84-8b5b-2141-a632b5980175d3c6}'
COMMANDDATA_TAG = ('%sCommandData' % DSZ_NS)

class monitor(object, ):

    def __init__(self, job, pattern):
        self.log_path = os.path.abspath(dsz.lp.GetLogsDirectory())
        self.glob_path = os.path.join(self.log_path, pattern)
        self.previously_read_files = set()
        self.previously_read_files = self.previously_read_files.union(self.find_files())

    def execute_monitor(self):
        current_files = self.find_files()
        list_of_files = (current_files - self.previously_read_files)
        current_targets = []
        for input_file in list_of_files:
            (successful, target_list) = self.parse_data(input_file)
            if (not successful):
                continue
            self.previously_read_files = self.previously_read_files.union([input_file])
            current_targets.extend(target_list)
        return current_targets

    def find_tasking(self, file_in_question):
        cmdnum = os.path.basename(file_in_question).split('-')[0]
        cmdname = os.path.basename(file_in_question).split('-')[1].split('_')[0]
        return set(glob.glob(os.path.join(self.log_path, ('Tasking/%s*%s*.xml' % (cmdnum, cmdname)))))

    def find_files(self):
        return set(glob.glob(self.glob_path))

    def min_time(self):
        return 30

    def min_range(self):
        return 30

def get_monitorengine(job):
    job_type = job[0]
    for import_job in monitor_description.keys():
        if (re.search(import_job, job_type) is not None):
            name = monitor_description[import_job]._whats_your_name()
            return monitor_description[import_job].__dict__[name](job)
    return False

def load_plugins():
    plugin_path = os.path.dirname(__file__)
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
        monitor_description[module._whats_your_job()] = module

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
monitor_description = {}
load_plugins()