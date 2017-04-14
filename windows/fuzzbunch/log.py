version = '0.4.2'

import json
import os
import platform
import shutil
import sys
from uuid import uuid1
from copy import deepcopy
from datetime import datetime
from traceback import print_exception
is_windows = platform.uname()[0].lower() == 'windows'

def uuid(): return str(uuid1())
    
class log(object):
    def __init__(self, tool_name, tool_version, options={}, **params):
        # record parent if child, otherwise do following setup only if parent log
        self.parent = options.get('parent') # None == root, instance_parent
        self.uuid = uuid() # instance_uuid
        if not self.parent:
            # user-controllable options
            for option in ['debug', 'enabled', 'verbose']:
                value = options.get(option) if isinstance(options.get(option), bool) else True 
                self.__setattr__(option, value)
            
            # dispatcher depends on a common prefix being used across output files
            # dispatcher will look for files dropped in directories under the log_root
            self.prefix = 'concernedparent'
            self.log_root = 'c:\\temp' if is_windows else '/tmp'
            
            # create log_dir from log_root/prefix, otherwise use cwd/prefix
            self.log_dir = os.path.join(self.log_root, self.prefix)
            if self.enabled:
                try:
                    if not os.path.exists(self.log_dir):
                        os.makedirs(self.log_dir)
                except:
                    try:
                        self.log_dir = os.path.join(os.getcwd(), self.prefix)
                        if not os.path.exists(self.log_dir):
                            os.makedirs(self.log_dir)
                    except:
                        self.enabled = False
                        self.notify_of_error('Could not open a log output directory.  Logging will be disabled.')
                finally:
                    if self.verbose and self.enabled: print "Logging to " + self.log_dir
        # setup a queue of parameters to write once next log entry
        self.__queue = {}
        
        # register the tool name, version, and extra params with the log
        self._register(tool_name, tool_version, **params)

    def queue(self, **params):
        ''' Queue any number of params for next call.  Returns log. '''
        try:
            for key in params: self.__queue[key] = deepcopy(params[key])
        except:
            self.notify_of_error("Could not set queue by dictionary.  Parameters were:\n"+str(params))
        return self
    
    def get(self, key, default=None):
        ''' Get the value of key from the params, return default if not found. '''
        return self.__params.get(key, default)
    
    def set(self, **params):
        ''' Set the value of params for all future calls.  Returns log. '''
        try:
            for key in params: self.__params[key] = deepcopy(params[key])
        except:
            self.notify_of_error("Could not set params.  Parameters were:\n"+str(params))
        return self
    
    def set_machine_info(self, hostname=None, os_name=None, os_version=None, os_arch=None, hw_processor=None, **params):
        ''' Set various attributes about the machine from which the log is being produced.  Returns log. '''
        return self.set(local_hostname=hostname, local_os_name=os_name, local_os_version=os_version, local_os_arch=os_arch, local_hw_processor=hw_processor, **params)
        
    def make_child(self, tool_name, tool_version, parent_uuid=None, **params):
        try:
            child = deepcopy(self)
            child.__init__(tool_name, tool_version, dict(parent=self), **params)
            if parent_uuid: child.queue(event_parent_uuid=parent_uuid)
            return child
        except:
            self.notify_of_error('Creating child log for ' + str(tool_name) + ' ' + str(tool_version))
            return None
    
    ''' Tool-related helper methods. '''
    def open(self, command_line=None, **params):
        ''' Reports this tool was opened, pass in command line if known.  Returns log. '''
        self('tool opened', command_line=command_line, **params)
        return self
    def close(self, command_line=None, results=None, status=None, success=None, **params):
        ''' Reports this tool was closed. '''
        self.running = False
        self('tool closed', command_line=command_line, command_results=results, command_status=status, command_success=success, command_uuid=uuid() if command_line else None, **params)
    
    def command(self, name, results=None, status=None, success=None, *args, **params):
        ''' A tool's internal command caused activity on the remote machine.  Returns event_uuid. '''
        return self('command executed', command_name=name, command_args=str(args), command_results=results, command_status=status, command_success=success, command_uuid=uuid(), **params)
    
    def launch_from_command(self, command_name, tool_name, tool_version, **params):
        ''' Reports that a command was run from this tool instance, spawning a child tool.  Returns log. ''' 
        parent_uuid = self.command(command_name, **params)
        child = self.make_child(tool_name, tool_version, parent_uuid)
        return child
    
    def file_from_path(self, full_path, parent_uuid=None, **params):
        ''' Upload a file given its local path.  Returns event_uuid. '''
        try:
            full_path = os.path.realpath(os.path.normpath(full_path))
            (file_path, file_name) = os.path.split(full_path)
            shutil.copyfile(full_path, self.basefilename()+'.'+file_name)
        except: self.notify_of_error('Could not access file ' + full_path)
        else: return self('remote file', parent_uuid, file_origin_name=file_name, file_origin_path=file_path, file_origin_created=datetime.utcfromtimestamp(os.path.getctime(full_path)).isoformat(' '), **params)
        return None
    
    def file_from_content(self, content, storage_name, parent_uuid=None, **params):
        ''' Upload a file given its content.  Returns event_uuid. '''
        try:
            storage_name = storage_name or "%s.txt"%(uuid())
            full_path = self.basefilename()+'.'+storage_name
            with open(full_path, 'wb') as f:
                f.write(content.encode('utf-8'))
        except: self.notify_of_error('Could not write file ' + full_path)
        else: return self('remote file', parent_uuid, file_origin_name=storage_name, file_origin_path=None, file_origin_created=datetime.utcfromtimestamp(os.path.getctime(full_path)).isoformat(' '), **params)
        return None
    
    def file_from_file(self, fd, parent_uuid=None, **params):
        ''' Upload a file given an open file descriptor to a local path.  Returns event_uuid. '''
        try: # if isinstance(fd,file)...
            fd.flush()
            return self.file_from_path(fd.name, parent_uuid, **params)
        except:
            self.notify_of_error('Could not access file descriptor for '+str(fd))
            return None
        
    ''' Execution-related helper methods. '''
    def start(self):
        ''' Queues the start time of execution.  Results in stop time being marked by next log call.  Returns log. '''
        return self.queue(start_time=datetime.utcnow())
    
    def execute_exploit(self, **params):
        ''' Intended for use by other methods (success/fail).  Reports execution of an exploit from within this tool. Returns event_uuid.'''
        return self('exploit executed', **params)
    
    def execute_tool(self, **params): return self(event_type='tool executed', **params)
    def successful_exploit(self, **params): return self.execute_exploit(exploit_success=True, **params)
    def failed_exploit(self, **params): return self.execute_exploit(exploit_success=False, **params)
    
    def execute_tool_from_command_line(self, command_line, **params):
        ''' Reports execution of this tool and the command line that started it. '''
        return self.execute_tool(command_line=command_line, **params)
    def successful_exploit_from_command_line(self, command_line, **params):
        ''' Reports successful exploitation from this tool and the command line that started it. '''
        return self.successful_exploit(command_line=command_line, **params)
    def failed_exploit_from_command_line(self, command_line, **params):
        ''' Reports failed exploitation from this tool and the command line that started it. '''
        return self.failed_exploit(command_line=command_line, **params)
    
    def successful_exploit_from_command(self, command, tool_name, tool_version, **params):
        ''' Ran single-fire local command to exploit with sub-tool name/version.  Report successful exploit.  Return event_uuid. '''
        return self.launch_from_command(command, tool_name, tool_version).successful_exploit(**params)
    def failed_exploit_from_command(self, command, tool_name, tool_version, **params):
        ''' Ran single-file local command to exploit with sub-tool name/version.  Report failed exploit.  Return event_uuid. '''
        return self.launch_from_command(command, tool_name, tool_version).failed_exploit(**params)
    
    ''' Network-related helper methods. '''
   
    def interface_enabled(self, ip, project=None, mac=None, name=None, **params):
        ''' Enable a network interface on the reporting machine. '''
        return self(event_type='interface enabled', interface_ip=ip, interface_project=project, interface_mac=mac, interface_name=name, **params)
    def interface_disabled(self, ip, project=None, mac=None, name=None, **params):
        ''' Disable a network interface on the reporting machine. '''
        return self(event_type='interface disabled', interface_ip=ip, interface_project=project, interface_mac=mac, interface_name=name, **params)
    
    def socket_opened(self, port, ip='0.0.0.0', project=None, is_tcp=None, is_udp=None, is_raw=None, **params):
        ''' Open a local RAW/UDP or TCP LISTENing socket. '''
        if is_raw or is_tcp or is_udp: return self(event_type='socket opened', socket_port=port, socket_ip=ip, socket_project=project, socket_is_raw=is_raw, socket_is_tcp=is_tcp, socket_is_udp=is_udp, **params)
        else: self.notify_of_error('Could not open socket.  No socket type specified.')
    def socket_closed(self, port, ip='0.0.0.0', project=None, is_tcp=None, is_udp=None, is_raw=None, **params):
        ''' Close a local socket and any open connections. '''
        if is_raw or is_tcp or is_udp: return self(event_type='socket closed', socket_port=port, socket_ip=ip, socket_project=project, socket_is_raw=is_raw, socket_is_tcp=is_tcp, socket_is_udp=is_udp, **params)
        else: self.notify_of_error('Could not close socket.  No socket type specified.')
    
    def channel_opened(self, listen_ip, listen_port, redirect_from_ip, forward_to_ip, forward_to_port, is_tcp=None, listen_project=None, redirect_from_project=None, forward_to_project=None,  **params):
        ''' Create a channel from a listening ip:port or [ip,...]:port to a redirector, from which data is forwarded to an ip:port. '''
        return self(event_type='channel opened', channel_listen_ip=listen_ip, channel_listen_port=listen_port, channel_listen_project=listen_project, channel_forward_to_ip=forward_to_ip, channel_forward_to_port=forward_to_port, channel_forward_to_project=forward_to_project, channel_redirect_from_ip=redirect_from_ip, channel_redirect_from_project=redirect_from_project, channel_is_tcp=is_tcp, **params)
    def channel_closed(self, listen_ip, listen_port, listen_project=None, **params):
        ''' Terminate a channel from a listening ip:port or [ip,...]:port to a redirector, from which data is forwarded to an ip:port. '''
        return self(event_type='channel closed', channel_listen_ip=listen_ip, channel_listen_port=listen_port, channel_listen_project=listen_project, **params)
    
    def connection_opened(self, source_ip, source_port, destination_ip, destination_port, is_tcp=None, source_project=None, destination_project=None, **params):
        ''' Open (successfully) a direct connection between source (initiating) and destination (receiving) ip:port pairs. '''
        return self(event_type='connection opened', connection_source_ip=source_ip, connection_source_project=source_project, connection_source_port=source_port, connection_destination_ip=destination_ip, connection_destination_project=destination_project, connection_destination_port=destination_port, connection_is_tcp=is_tcp, **params)
    def connection_closed(self, source_ip, source_port, destination_ip, destination_port, is_tcp=None, source_project=None, destination_project=None, **params):
        ''' Close a direct connection between source (initiating) and destination (receiving) ip:port pairs. '''
        return self(event_type='connection closed', connection_source_ip=source_ip, connection_source_project=source_project, connection_source_port=source_port, connection_destination_ip=destination_ip, connection_destination_project=destination_project, connection_destination_port=destination_port, connection_is_tcp=is_tcp, **params)
    
    
    # UNVETTED
    def connection_refused(self, source_ip, source_port, destination_ip, destination_port, is_tcp=None, source_project=None, destination_project=None, **params):
        ''' Connection from source ip:port to destination (listening) ip:port was refused. ''' 
        return self(event_type='connection refused', connection_source_ip=source_ip, connection_source_project=source_project, connection_source_port=source_port, connection_destination_ip=destination_ip, connection_destination_project=destination_project, connection_destination_port=destination_port, connection_is_tcp=is_tcp, **params)
    def connection_rejected(self, source_ip, source_port, destination_ip, destination_port, is_tcp=None, source_project=None, destination_project=None, **params):
        ''' Connection from source ip:port to destination (listening) ip:port was rejected. ''' 
        return self(event_type='connection rejected', connection_source_ip=source_ip, connection_source_project=source_project, connection_source_port=source_port, connection_destination_ip=destination_ip, connection_destination_project=destination_project, connection_destination_port=destination_port, connection_is_tcp=is_tcp, **params)
    def connection_failed(self, source_ip, source_port, destination_ip, destination_port, is_tcp=None, source_project=None, destination_project=None, **params):
        ''' Connection from source ip:port to destination (listening) ip:port failed. ''' 
        return self(event_type='connection failed', connection_source_ip=source_ip, connection_source_project=source_project, connection_source_port=source_port, connection_destination_ip=destination_ip, connection_destination_project=destination_project, connection_destination_port=destination_port, connection_is_tcp=is_tcp, **params)
    def trigger_sent(self, trigger_type, source_ip, source_port, target_ip, target_port, is_tcp=None, **params):
        ''' Send a trigger from source ip:port at a target (probably locally listening) ip:port. '''
        return self(event_type='trigger sent', trigger_source_ip=source_ip, trigger_source_port=source_port, trigger_target_ip=target_ip, trigger_target_port=target_port, trigger_type=trigger_type, **params)
    

    # Library Functionality
    def basefilename(self):
        return os.path.join(self.log_dir, self.prefix) + '.' + datetime.utcnow().strftime('%Y%m%d%H%M%S') + '.' + self.get('tool_name').lower()

    def notify_of_warning(self,warning_string=''):
        if self.enabled and self.verbose:
            print "Warning:", warning_string
            if self.debug:
                exception_type, exception_value, exception_traceback = sys.exc_info()
                print_exception(exception_type, exception_value, exception_traceback, limit=10, file=sys.stdout)
    
    def notify_of_error(self,error_string=''):
        if self.enabled:
            if self.verbose: print "Error:", error_string
            if self.debug:
                exception_type, exception_value, exception_traceback = sys.exc_info()
                if self.verbose: print_exception(exception_type, exception_value, exception_traceback, limit=10, file=sys.stdout)
                else:
                    try:
                        with open(self.basefilename()+'.error', 'a') as f:
                            f.write('Error: '+str(error_string)+'\n')
                            print_exception(exception_type, exception_value, exception_traceback, limit=10, file=f)
                            self(event_type='error file', file_origin_name=f.name[f.name.rfind(self.get('tool_name').lower()):], file_origin_path=os.path.dirname(f.name), file_origin_created=datetime.utcfromtimestamp(os.path.getctime(f.name)).isoformat(' '))
                    except:
                        print 'Notice: The following is a notification of something gone awry and should not impact you operationally.'
                        print 'Please save the following traceback and inform the developer.\nError:', error_string
                        print_exception(exception_type, exception_value, exception_traceback, limit=10, file=sys.stdout)
                        exception_type, exception_value, exception_traceback = sys.exc_info()
                        print_exception(exception_type, exception_value, exception_traceback, limit=10, file=sys.stdout)

    def _register(self, tool_name, tool_version, **params):
        try:
            def_pars = {'tool_name': str(tool_name) if tool_name else 'Unknown',
                        'tool_version': str(tool_version) if tool_version else None,
                        'instance_uuid': self.uuid,
                        'instance_parent_uuid': self.parent.uuid if self.parent else None,
                        'instance_log_version': version,
                        }
        except:
            def_pars = {'tool_name': 'Unknown', 'tool_version': None, 'instance_uuid': uuid(), 'instance_parent_uuid': None, 'instance_log_version': version}
            self.notify_of_warning('Tool parameters invalid.  Moving on.')
        try:
            self.__params = deepcopy(params)
            for k in def_pars:
                if not self.__params.has_key(k):
                    self.__params[k] = def_pars[k]
        except:
            self.__params = def_pars
            self.notify_of_warning('{params} passed were invalid and have been reset.  Moving on.')
    
    def __contains__(self,element):
        try: return True if self[element] else True
        except AttributeError: return False
    
    def __getitem__(self,key):
        return self.__getattribute__(key) # removed  __getattr__(key) since get/setattr no longer defined
    
    def __setitem__(self,key,value):
        self.__setattr__(key, value)
        
    def __call__(self, event_type='heartbeat', parent_uuid=None, event_time=None, **params):
        ''' Basic log call.  At a minimum, this will write the tool name and version specified during init,
            an event_type (heartbeat if not specified), a parent event (only if specified), and an event_time
            (now if not specified). ''' 
        try:
            # build output dictionary
            d = self._flatten(event_time=event_time if event_time else datetime.utcnow(),
                              event_type=event_type,
                              event_uuid=uuid(),
                              event_parent_uuid=parent_uuid,
                              **params)
            
            # mark stop time and replace event time with start time
            if d.get('start_time'):
                d['stop_time'] = d['event_time']
                d['event_time'] = d['start_time']
            
            # write/append JSON entry to file    
            if self.enabled:            
                try:
                    filename = self.basefilename() + '.json'
                    with open(filename, 'a') as f:
                        f.write(self._dumps(d)+'\n')
                except:
                    self.notify_of_error("Failed to generate output file.  Parameters were:\n"+str(params))
                    try: os.remove(filename)
                    except: pass
                
            return d['event_uuid']
        except:
            self.notify_of_error("Key error.  Parameters were:\n"+str(params))

    def _flatten(self, **params):
        try:
            ret = self.__params.copy()
            for k in self.__queue:
                ret[k] = self.__queue[k]
            self.__queue = {}
            for k in params:
                ret[k] = deepcopy(params[k])
            return ret
        except:
            self.notify_of_error("Problem flattening log.  Parameters so far were:\n"+str(ret)+'\nParameters passed were:\n'+str(params))
            return {}

    def _dumps(self, obj):
        return json.dumps(obj, cls=self._dtencoder)

    class _dtencoder(json.JSONEncoder):
        def default(self, obj):
            if isinstance(obj, datetime): return obj.isoformat(' ')
            return json.JSONEncoder.default(self, obj)
        
    """
    def __getattr__(self,name):
        return object.__getattribute__(self,lower(name))
    
    def __setattr__(self,name,value):
        object.__setattr__(self, lower(name), value)
        if isinstance(self.__getattr__(lower(name)), self.baselogtype):
            self.__getattr__(name).log = self
            self.__getattr__(name).name = lower(name)

    import threading
    def pacemaker(self, timeout=60):
    #   This is a stand-alone heartbeat generator.  To pulse from your own control loop,
    #   call your AbstractLog subclass instance event handler (e.g. AbstractLog['event']()
        def __target(timeout=60):
            if platform.uname()[0].lower() == "windows":
                import win32con
                import win32event
                self.running = True
                kill = win32event.CreateEvent(None, 1, 0, None)
                pulse = win32event.CreateWaitableTimer(None, 0, None)
                win32event.SetWaitableTimer(pulse, 0, timeout*1000, None, None, False)
                while(self.running):
                    try:
                        result = win32event.WaitForMultipleObjects([kill, pulse], False, 1000)
                        
                        # if kill signal received, break loop
                        if(result == win32con.WAIT_OBJECT_0): break
                        # elif timeout has passed, generate a pulse
                        elif(result == win32con.WAIT_OBJECT_0 + 1): self['event']()
                    except:
                        self.notify_of_error("Pacemaker shutdown.  Heartbeats will not be generated.")
                        win32event.SetEvent(kill)
            elif self.verbose: print "Pacemaker only supported in Windows at this time. " 
       
        try:
            self.thread = threading.Thread(target=__target, args=(timeout,) )
            #self.thread.start() NOT READY FOR DEPLOYMENT
        except:
            self.notify_of_error("Pacemaker thread exception.  Heartbeats will not be generated.")
    """