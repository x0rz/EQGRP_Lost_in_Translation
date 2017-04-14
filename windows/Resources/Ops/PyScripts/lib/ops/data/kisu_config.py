
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('kisu_config' not in cmd_definitions):
    module_flags = OpsClass('flags', {'encrypted': OpsField('encrypted', dsz.TYPE_BOOL), 'compressed': OpsField('compressed', dsz.TYPE_BOOL), 'demand_load': OpsField('demand_load', dsz.TYPE_BOOL), 'service_key': OpsField('service_key', dsz.TYPE_BOOL), 'user_mode': OpsField('user_mode', dsz.TYPE_BOOL), 'kernel_driver': OpsField('kernel_driver', dsz.TYPE_BOOL), 'boot_start': OpsField('boot_start', dsz.TYPE_BOOL), 'auto_start_once': OpsField('auto_start_once', dsz.TYPE_BOOL), 'system_start': OpsField('system_start', dsz.TYPE_BOOL), 'auto_start': OpsField('auto_start', dsz.TYPE_BOOL), 'system_mode': OpsField('system_mode', dsz.TYPE_BOOL), 'value': OpsField('value', dsz.TYPE_INT)}, DszObject)
    module_hash = OpsClass('hash', {'sha1': OpsField('sha1', dsz.TYPE_STRING), 'md5': OpsField('md5', dsz.TYPE_STRING)}, DszObject)
    module_data = OpsClass('module', {'id': OpsField('id', dsz.TYPE_INT), 'order': OpsField('order', dsz.TYPE_INT), 'size': OpsField('size', dsz.TYPE_INT), 'processname': OpsField('processname', dsz.TYPE_STRING), 'modulename': OpsField('modulename', dsz.TYPE_STRING), 'flags': module_flags, 'hash': module_hash}, DszObject, single=False)
    regstoragefields = {'registryvalue': OpsField('registryvalue', dsz.TYPE_STRING), 'servicename': OpsField('servicename', dsz.TYPE_STRING)}
    launcher_data = OpsClass('launcher', regstoragefields, DszObject)
    kernloader_data = OpsClass('kernelmoduleloader', regstoragefields, DszObject)
    userloader_data = OpsClass('usermoduleloader', regstoragefields, DszObject)
    modstore_data = OpsClass('modulestoredirectory', regstoragefields, DszObject)
    persistence_data = OpsClass('persistence', {'method': OpsField('method', dsz.TYPE_STRING)}, DszObject)
    kisu_config_data = OpsClass('configuration', {'launcher': launcher_data, 'kernelmoduleloader': kernloader_data, 'modulestoredirectory': modstore_data, 'usermoduleloader': userloader_data, 'persistence': persistence_data, 'module': module_data}, DszObject)
    kisu_config_command = OpsClass('configuration', {'configuration': kisu_config_data}, DszCommandObject)
    cmd_definitions['kisu_config'] = kisu_config_command