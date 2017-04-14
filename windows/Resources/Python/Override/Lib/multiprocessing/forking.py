## @package multiprocessing.forking
# DSZ compatible implementation of forking using tricks

import os
import platform
import sys

import dsz.cmd
import dsz.control
import dsz.script

# Can't use relative trick since we invoke this script as a main script
# to mimic Win32 Popen spawning.
from multiprocessing import process

def assert_spawning(self):
    if not Popen.thread_is_spawning():
        raise RuntimeError('%s objects should only be shared between processes through inheritance' % type(self).__name__)

# =====================================================================
# Utility stuff
# =====================================================================

from _multiprocessing import win32, Connection, PipeConnection
from multiprocessing.util import Finalize

import _subprocess
import msvcrt

close = win32.CloseHandle
def duplicate(handle, target_process=None, inheritable=False):
    if target_process is None:
        target_process = _subprocess.GetCurrentProcess()
    return _subprocess.DuplicateHandle(
        _subprocess.GetCurrentProcess(), handle, target_process,
        0, inheritable, _subprocess.DUPLICATE_SAME_ACCESS
        ).Detach()

from pickle import Pickler, HIGHEST_PROTOCOL, load

class ForkingPickler(Pickler):
    
    dispatch = Pickler.dispatch.copy()
    
    @classmethod
    def register(cls, type, reduce):
        def dispatcher(self, obj):
            rv = reduce(obj)
            self.save_reduce(obj=obj, *rv)
        cls.dispatch[type] = dispatcher

def _reduce_method(m):
    if m.im_self is None:
        return getattr, (m.im_class, m.im_func.func_name)
    else:
        return getattr, (m.im_self, m.im_func.func_name)
ForkingPickler.register(type(ForkingPickler.save), _reduce_method)

def _reduce_method_descriptor(m):
    return getattr, (m.__objclass__, m.__name__)

ForkingPickler.register(type(list.append), _reduce_method_descriptor)
ForkingPickler.register(type(int.__add__), _reduce_method_descriptor)

try:
    from functools import partial
except ImportError:
    pass
else:
    def _reduce_partial(p):
        return _rebuild_partial, (p.fun, p.args, p.keywords or {})
    def _rebuild_partial(fun, args, keywords):
        return partial(fun, *args, **keywords)
    ForkingPickler.register(partial, _reduce_partial)

try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO

def dump(obj, file, protocol):
    ForkingPickler(file, protocol).dump(obj)
    
# =====================================================================
# Popen implementation
# =====================================================================

class Popen(object):

    __isspawning = False

    ## Creates the new "thread"
    #
    # Mimics the implementation for Win32 from the Python core by invoking
    # a new python command, running this script with some parameters and
    # pickled information to setup the new environment.
    def __init__(self, process_obj):
        Popen.__isspawning = True
        
        rfd, wfd = os.pipe()
        rhandle = duplicate(msvcrt.get_osfhandle(rfd), inheritable=True)
        os.close(rfd)
        
        # Construct command line.
        args = [
            '-multiprocessingfork',
            '-pipe', rhandle
            ]
        cmd = get_command_line() % ' '.join(str(i) for i in args)
    
        # Execute new 'process'
        # Change to use context manager in next version that supports it.
        flags = dsz.control.Method()
        dsz.control.echo.Off()
        (ret, self.pid) = dsz.cmd.RunEx(cmd)
        del flags
        
        self.returncode = None
        
        prep_data = get_preparation_data(process_obj._name)
        to_child = os.fdopen(wfd, 'wb')
        try:
            dump(prep_data, to_child, HIGHEST_PROTOCOL)
            dump(process_obj, to_child, HIGHEST_PROTOCOL)
        finally:
            # In case something goes horribly wrong, let's make sure to clear this state.
            Popen.__isspawning = False
    
    ## Wait for process to exit (or timeout)
    #
    # Emulates waiting by doing little sleeps (currently 1000 ms). Too much? Too little?
    # Like many time related functions (including sleep), but especially because of this
    # emulation, do not attempt to use it for timing purposes beyond simple "check is running,
    # wait a bit" style checks.
    #
    # A timeout less than this default 'little sleep' will be used in place of the normal
    # sleep interval.
    #
    # \param timeout
    #   timeout to wait, in ms, or None for 'infinite' wait
    #
    # \return Boolean return state of script, or None if still running.
    def wait(self, timeout=None):
        if self.returncode is None:
    
            isrunning = bool(dsz.cmd.data.Get("commandmetadata::isrunning", dsz.TYPE_BOOL, self.pid)[0])
            # Time to sleep for a bit... too little? too much?
            if timeout is None:
                sleep_interval = 1000
            else:
                sleep_interval = 1000 if timeout > 1000 else timeout
            
            while isrunning and sleep_interval > 0:
                dsz.Sleep(sleep_interval)
                isrunning = dsz.cmd.data.Get("commandmetadata::isrunning", dsz.TYPE_BOOL, self.pid)[0]
                if timeout is not None:
                    timeout -= sleep_interval
                    if timeout <= 0:
                        break
            
            # if still running, then timeout exceeded
            if not isrunning:
                # Coerce to boolean; assume failure if there's a query problem.
                try:
                    self.returncode = (dsz.cmd.data.Get("commandmetadata::status", dsz.TYPE_INT, self.pid)[0] == 0)
                except RuntimeError:
                    self.returncode = False
                
        return self.returncode
    
    ## Check if process is still running
    def poll(self):
        return self.wait(timeout=0)
    
    ## Terminate process
    def terminate(self):
        if self.poll() is None:
            dsz.cmd.Run('stop %d' % self.pid)
    
    @staticmethod
    def thread_is_spawning():
        return Popen.__isspawning
    
    @staticmethod
    def duplicate_for_child(handle):
        return duplicate(handle) 

## Returns whether command line indicates we are in the process of forking.
def is_forking(argv):
    if len(argv) >= 2 and argv[1] == '-multiprocessingfork':
        assert len(argv) == 3
        return True
    else:
        return False

## Probably unused in the DSZ model; implemented for completedness and because it's easy.
#
# I think this is only used on Windows implementations where the Python script is being
# compiled to a standalone exe format.
def freeze_support():
    if is_forking(sys.argv):
        main()
        # may produce artificial "command failures". not sure if I care, but
        # an exit method is required for this implementation to work like
        # the API does.
        sys.exit()

## Returns command line template used for spawning children.
def get_command_line():
    if process.current_process()._identity == () and is_forking(sys.argv):
        raise RuntimeError, 'Attempt to start a new process before the current process has finished its bootstrapping process.'
    
    return 'background python ../Override/Lib/multiprocessing/forking.py -project Python -args "%s"'

## Return info about parent needed by child
#
# Some steps from core are skipped completely.
def get_preparation_data(name):
    d = dict(
        name=name,
        sys_path=sys.path,
        sys_argv=sys.argv,
        authkey=process.current_process().authkey,
        main_path=getattr(sys.modules['__main__'], '__file__', None)
        )
    return d

## Make Connection and PipeConnection objects picklable
def reduce_connection(conn):
    if not Popen.thread_is_spawning():
        raise RuntimeError, 'By default %s objects can only be shared between processes using inheritance' % type(conn).__name__
    return type(conn), (Popen.duplicate_for_child(conn.fileno()), conn.readable, conn.writable)

ForkingPickler.register(Connection, reduce_connection)
ForkingPickler.register(PipeConnection, reduce_connection)

## Save old main modules
old_main_modules = []

## Try to get current process ready to unpickle process object
def prepare(data):
    old_main_modules.append(sys.modules['__main__'])
    
    if 'name' in data:
        process.current_process().name = data['name']
    
    if 'authkey' in data:
        process.current_process()._authkey = data['authkey']
        
    if 'sys_path' in data:
        sys.path = data['sys_path']
    
    if 'sys_argv' in data:
        sys.argv = data['sys_argv']
    
    if 'main_path' in data:
        main_path = data['main_path']
        
        main_name = os.path.splitext(os.path.basename(main_path))[0]
        if main_name == '__init__':
            main_name = os.path.basename(os.path.dirname(mainpath))
        
        import imp
        
        if main_path is None:
            dirs = None
        elif os.path.basename(main_path).startswith('__init__.py'):
            dirs = [os.path.dirname(os.path.dirname(main_path))]
        else:
            dirs = [os.path.dirname(main_path)]
        
        assert main_name not in sys.modules, main_name
        
        file, path_name, etc = imp.find_module(main_name, dirs)
        
        PARENTS_MAIN = '__parents_main__'
        
        # Import the module we need
        main_module = imp.load_module(PARENTS_MAIN, file, path_name, etc)
        
        sys.modules['__main__'] = main_module
        main_module.__name__ = '__main__'
        
        # Hackery from the core: try to make things think they're in main.
        for obj in main_module.__dict__.values():
            try:
                if obj.__module__ == PARENTS_MAIN:
                    obj.__module__ = '__main__'
            except Exception:
                pass
    
## Run code specific by data received over pickled hand off
def main():
    assert is_forking(sys.argv), "This is only called as the bootstrapper for a child script process"
    
    # This is where we'll do the hackery
    # we'll have to get ops.parseargs integrated into the core as well... for now this'll do.
    # it's just like Python's ArgumentParser (in fact, it's a very tiny sub class), but enables consistency
    # with the DSZ interface while providing the same API and features.
    from ops.parseargs import ArgumentParser
    
    parser = ArgumentParser()
    parser.add_argument('--pipe', dest='pipe', type=int, required=True, help='Name of LP environment variable used to pass pickled data structures.')
    parser.add_argument('--multiprocessingfork', dest='multiproc', action='store_true', default=False, help='Used to flag and detect forks for internal logic purposes.')
    
    options = parser.parse_args()
    
    fd = msvcrt.open_osfhandle(options.pipe, os.O_RDONLY)
    from_parent = os.fdopen(fd, 'rb')
    
    process.current_process()._inheriting = True
    preparation_data = load(from_parent)
    prepare(preparation_data)
    self = load(from_parent)
    process.current_process()._inheriting = False
    
    from_parent.close()
    
    if self._bootstrap() != 0:
        sys.exit()

if __name__ == '__main__':
    main()
