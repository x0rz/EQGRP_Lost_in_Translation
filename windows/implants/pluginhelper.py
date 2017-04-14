import sys
import os
import getopt
import tempfile
import subprocess

__all__ = ['PythonPlugin', 'PluginFiles', 'parseargs']

SUPPORTED_ARCH = {'win32':   'x86-Windows',
                  'linux2-i686':  'i686-Linux',
                  'linux2-x86_64':  'x86_64-Linux',
                  'solaris': 'sparc-SunOS'}
try:
    platform = sys.platform
    if sys.platform == 'linux2':
        platform = sys.platform + "-" + os.uname()[4]
    arch = SUPPORTED_ARCH[sys.platform]
except KeyError:
    print "You are running on an unsuported architecture!"
    sys.exit(-1)

FB_FILE = os.path.realpath(__file__)
FB_DIR  = os.path.join(os.path.dirname(FB_FILE), os.path.pardir)
EDFLIB_DIR = os.path.join(FB_DIR, "lib", arch)
#print "FBFILE: ", FB_FILE
#print "FBDIR : ", FB_DIR
#print "EDFLIB: ", EDFLIB_DIR

os.environ['PATH'] += os.pathsep + EDFLIB_DIR
sys.path.append(os.path.join(FB_DIR, "fuzzbunch"))
sys.path.append(EDFLIB_DIR)

import util
from plugin import *
import iohandler


PluginFiles = util.superTuple('PluginFiles', 'input', 'output', 'log')

class PythonPlugin(Plugin):
    def __init__(self, files):
        Plugin.__init__(self, files[:1], iohandler.IOhandler())
        self.io.setlogfile(files.log)
        if files.log:
            self.logdir  = os.path.dirname(files.log)
        else:
            self.logdir = ""
        self.basedir = FB_DIR
        self.files = files
        if files.output:
            self.outfd = open(files.output, "wb")
        else:
            self.outfd = None

    def validateParams(self):
        pass

    def processParams(self):
        pass

    def gentempfile(self):
        hndl, file = tempfile.mkstemp(dir=self.logdir)
        os.close(hndl)
        return file

    def setfilenames(self, oldout):
        infile = oldout
        tmpfile = self.gentempfile()
        return infile, tmpfile

    def execcommand(self, cmd):
        cmd = "cmd.exe /C \"" + cmd + "\""
        try:
            subprocess.Popen(cmd, shell=False)
        except OSError, err:
            self.io.print_error("%s" % str(err))
            return False
        return True

    def callcommand(self, cmd):
        # XXX - Unix
        cmd = "cmd.exe /C \"" + cmd + "\""
        #print "EXEC : ", cmd

        try:
            retcode = subprocess.check_call(cmd, shell=False)
        except (subprocess.CalledProcessError, OSError), err:
            self.io.print_error("%s" % str(err))
            return False
        return True

    def write_outparams(self):
        pass

def parseargs(args):
    longopt = ['InConfig=', 'OutConfig=', 'LogFile=', 'ValidateOnly=']

    try:
        opts, args = getopt.getopt(args[1:], '', longopt)
    except getopt.GetoptError, err:
        #print str(err)
        return None

    opts = util.iDict(opts)

    try:
        inxml = opts['--inconfig']
    except KeyError, err:
        print "Missing command argument %s" % str(err)
        return None

    try:
        val = opts['--validateonly']
        if val.lower() == 'false':
            validate = False
        else:
            validate = True
    except KeyError, err:
        validate = False

    try:
        outxml = opts['--outconfig']
        logfile = opts['--logfile']
    except KeyError, err:
        outxml = None
        logfile = None

    return (PluginFiles(inxml, outxml, logfile),validate)


