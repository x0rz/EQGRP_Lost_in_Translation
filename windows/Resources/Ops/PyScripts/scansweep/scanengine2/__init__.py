
import ops.networking.redirect
import ops, ops.project
import os.path
import glob
import sys
import imp
import re
import util.ip

def _whats_your_name():
    return 'scan'

class scan(object, ):

    def __init__(self, job, timeout=None):
        for field in self.get_data_fields():
            setattr(self, field, '')
        setattr(self, 'success', False)
        self.job = job[0]
        if (len(job) > 1):
            self.target = job[1]
        self.scan_type = _whats_your_name()
        self.multiple_responses = False

    def recall_data(self, old_data_dict):
        for key in old_data_dict.keys():
            setattr(self, key, old_data_dict[key])

    def execute_scan(self, target, verbose):
        pass

    def return_data(self):
        data_dict = {}
        for field in self.get_raw_fields():
            data_dict[field] = getattr(self, field, '')
        try:
            data_dict['sort_field'] = util.ip.get_int_from_ip(self.target)
        except:
            data_dict['sort_field'] = self.target
        return data_dict

    def get_data_fields(self):
        return []

    def get_raw_fields(self):
        return []

    def gettunnel(self, target, protocol, target_port):
        if (not protocol.startswith('-')):
            protocol = ('-' + protocol)
        redir_cmd = None
        success = False
        max_attempts = 5
        for i in range(0, max_attempts):
            redir_cmd = ops.networking.redirect.generate_tunnel_cmd(arg_list=[protocol, '-target', target, target_port, '-lplisten'], random=True)
            redir_output = ops.networking.redirect.start_tunnel(dsz_cmd=redir_cmd)
            if ((redir_output is not False) and (type(redir_output) is int)):
                return redir_cmd
        return False

    def find_newest_touch(self, touch_name, touch_ext, touch_type='touches'):
        list_files = glob.glob(os.path.join(ops.DSZDISKSDIR, touch_type, ('%s-*.%s' % (touch_name, touch_ext))))
        newest_file = ('%s-0.0.0.%s' % (touch_name, touch_ext))
        for this_file in list_files:
            this_split = os.path.basename(this_file).split('-')[1].split('.')[:(-1)]
            newest_split = os.path.basename(newest_file).split('-')[1].split('.')[:(-1)]
            for i in range(0, len(this_split)):
                if (int(this_split[i]) > int(newest_split[i])):
                    newest_file = this_file
                    break
        return newest_file

    def search_project_data(self, macs=None, hostname=None):
        candidate = None
        macslist = []
        if (macs is not None):
            for mac in macs:
                macslist.append(mac.lower())
        if (hostname is not None):
            hostname = hostname.lower()
        try:
            candidate = ops.project.matchTarget(macs=macslist, hostname=hostname)
        except ops.project.MultipleTargetIDException:
            return 'Multiple possible'
        if (candidate is None):
            return ''
        if ((type(candidate) == type([])) and (len(candidate) > 1)):
            return 'Multiple possible'
        if ((type(candidate) == type([])) and (len(candidate) == 0)):
            return ''
        return candidate[(-1)]['target'].crypto_guid

    def min_time(self):
        return 5

    def min_range(self):
        return 5

def get_scanengine(job, timeout=None):
    job_type = job[0]
    for import_job in scan_job_description.keys():
        if (re.search(import_job, job_type) is not None):
            name = scan_job_description[import_job]._whats_your_name()
            if (timeout is None):
                return scan_job_description[import_job].__dict__[name](job)
            else:
                return scan_job_description[import_job].__dict__[name](job, timeout)
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
        scan_job_description[module._whats_your_job()] = module

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
scan_job_description = {}
load_plugins()