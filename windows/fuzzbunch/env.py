"""
Support routines for intelligently determining Fuzzbunch's operating environment
and setting some global variables
"""

import sys
import os

__all__ = ['setup_core_paths', 'setup_lib_paths']

SUPPORTED_ARCH = {
    'win32':            'x86-Windows',
    'linux2-i686':      'i686-Linux',
    'linux2-x86_64':    'x86_64-Linux',
    'solaris':          'sparc-SunOS'
}

try:
    platform = sys.platform
    if sys.platform == 'linux2':
        platform = sys.platform + "-" + os.uname()[4]
    arch = SUPPORTED_ARCH[platform]
except KeyError:
    print "You are running on an unsuported architecture!"
    sys.exit(-1)

"""
Set up core paths

"""
def setup_core_paths( fbdir ):
    global FB_FILE
    global FB_DIR
    global EDFLIB_DIR
    FB_FILE = os.path.realpath(fbdir)
    FB_DIR  = os.path.dirname(FB_FILE)
    EDFLIB_DIR = os.path.join(FB_DIR, "lib", arch)
    os.environ['PATH'] = EDFLIB_DIR + os.pathsep + os.environ['PATH']   # The EDF libs should always come FIRST in the system PATH...
    os.environ['FBDIR'] = FB_DIR
    sys.path.append(os.path.join(FB_DIR, 'fuzzbunch'))
    sys.path.append(EDFLIB_DIR)
    return (FB_FILE, FB_DIR, EDFLIB_DIR)

def setup_lib_paths(fbdir, libdir):
    """This is a little bit of a hack, but it should work. If we detect that the EDFLIB_DIR is 
    not in LD_LIBRARY_PATH, restart after adding it.  
    """
    try:
        libpath = os.environ['LD_LIBRARY_PATH']
    except KeyError:
        libpath = ""
    if not (sys.platform == "win32") and (libdir not in libpath):
        # To get the Fuzzbunch environment setup properly, we need to modify LD_LIBRARY_PATH.
        # To do that, we need to rerun Fuzzbunch so that it picks up the new LD_LIBRARY_PATH
        os.environ['LD_LIBRARY_PATH'] = "%s:%s" % (libdir,libpath)
        #path = os.path.abspath(fbdir)
        #args = ['"' + path + '"'] + sys.argv[1:]
        #os.execvpe( 'python', ['python']+sys.argv, os.environ)
 
