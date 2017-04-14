## @package multiprocessing.process
# Emulates and replaces the multiprocessing.process core Python API with a DSZ
# compatible implementation.
#

__all__ = ['Process', 'current_process', 'active_children']

# 'normal' imports
import os
import sys
import signal
import itertools

# DSZ imports
import dsz.script

# No good analog in DSZ land, so just leave it alone.
ORIGINAL_DIR = None

## Generally used as an analog for os.getpid()
_DSZ_COMMAND_ID = int(dsz.script.Env['script_command_id'])

# =====================================================================
# Public Functions
# =====================================================================

## Return process object representing the current process
def current_process():
    return _current_process

## Return list of process objects corresponding to live child processes
def active_children():
    _cleanup()
    return list(_current_process._children)

# =====================================================================
# Private Functions
# =====================================================================

## Check for processes which have finished
def _cleanup():
    for p in list(_current_process._children):
        if p._popen.poll() is not None:
            _current_process._children.discard(p)

# =====================================================================
# Public Classes
# =====================================================================

## Process objects represent actibity that is run in a separate process.
#
# This is emulated in DSZ by different instantiations of the 'python'
# command.
class Process(object):

    def __init__(self, group=None, target=None, name=None, args=(), kwargs={}, _dsz_newterm=None):
        # Assertion from the original code
        assert group is None, 'group argument must be None for now'
        
        count = _current_process._counter.next()
        
        self._identity   = _current_process._identity + (count,)
        self._authkey    = _current_process._authkey
        self._daemonic   = _current_process._daemonic
        self._tempdir    = _current_process._tempdir
        # Analog: parent "pid" is the command ID of the parent script
        self._parent_pid = _DSZ_COMMAND_ID
        self._popen      = None
        self._target     = target
        self._args       = args
        self._kwargs     = kwargs
        self._name       = name or type(self).__name__ + '-' + ':'.join(str(i) for i in self._identity)
    
    ## Method to run in sub-process; can be overridden in sub-class.
    def run(self):
        if self._target:
            self._target(*self._args, **self._kwargs)
    
    ## Start child process
    def start(self):
        assert self._popen is None, 'cannot start a process twice'
        assert self._parent_pid == _DSZ_COMMAND_ID, 'can only start a process object created by current process'
        assert not _current_process._daemonic, 'daemonic processes are not allowed to have children'
        
        _cleanup()
        
        from .forking import Popen
        self._popen = Popen(self)
        
        _current_process._children.add(self)
    
    ## Terminate child process
    def terminate(self):
        self._popen.terminate()
    
    ## Wait until child process terminates
    def join(self, timeout=None):
        assert self._parent_pid == _DSZ_COMMAND_ID, 'can only join a child process'
        assert self._popen is not None, 'can only join a started process'
        
        result = self._popen.wait(timeout)
        if result is not None:
            _current_process._children.discard(self)
    
    ## Query if a process is still running
    def is_alive(self):
        if self is _current_process:
            return True
        assert self._parent_pid == _DSZ_COMMAND_ID, 'can only test a child process'
        if self._popen is None:
            return False
        return self._popen.poll() is None
    
    @property
    def name(self):
        return self._name
    
    @name.setter
    def name(self, name):
        assert isinstance(name, basestring), 'name must be a string'
        self._name = name
    
    @property
    def daemon(self):
        return self._daemonic
    
    @daemon.setter
    def daemon(self, daemonic):
        assert self._popen is None, 'process has already started'
        self._daemonic = daemonic
    
    @property
    def authkey(self):
        return self._authkey
    
    @authkey.setter
    def authkey(self, authkey):
        self._authkey = AuthenticationString(authkey)
    
    @property
    def exitcode(self):
        if self._popen is None:
            return None
        return self._popen.poll()
    
    @property
    def ident(self):
        if self is _current_process:
            return _DSZ_COMMAND_ID
        else:
            return self._popen and self._popen.pid
    
    pid = ident
    
    def __repr__(self):
        if self is _current_process:
            status = 'started'
        elif self._parent_pid != _DSZ_COMMAND_ID:
            status = 'unknown'
        elif self._popen is None:
            status = 'initial'
        else:
            if self_popen.poll() is not None:
                status = self.exitcode
            else:
                status = 'started'
            
        if status == False:
            status = 'stopped'
        elif status == True:
            status = 'started'
        
        return '<%s(%s, %s%s)>' % (type(self).__name__, self._name, status, self._daemonic and ' daemon' or '')
    
    def _bootstrap(self):
        global _current_process
        
        try:
            self._children = set()
            self._counter = itertools.count(1)
            _current_process = self
            try:
                self.run()
                exitcode = 0
            finally:
                # might need to implement atexit handlers here, check back later
                pass
        except SystemExit, e:
            if not e.args:
                exitcode = 1
            elif type(e.args[0]) is int:
                exitcode = e.args[0]
            else:
                exitcode = 1
        except:
            exitcode = 1
            import traceback
            sys.stderr.write('Process %s:\n' % self.name)
            sys.stderr.flush()
            traceback.print_exc()
            
        return exitcode
    
class AuthenticationString(bytes):
    def __reduce__(self):
        from .forking import Popen
        if not Popen.thread_is_spawning():
            raise TypeError('Pickling an AuthenticationString object is disallowed for security reasons.')
        return AuthenticationString, (bytes(self),)
    
class _MainProcess(Process):

    def __init__(self):
        self._identity = ()
        self._daemonic = False
        self._name = 'MainProcess'
        self._parent_pid = None
        self._popen = None
        self._counter = itertools.count(1)
        self._children = set()
        self._authkey = AuthenticationString(os.urandom(32))
        self._tempdir = None
    
_current_process = _MainProcess()
del _MainProcess
