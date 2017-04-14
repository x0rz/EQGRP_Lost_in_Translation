"""

Platform dependent plugin execution helper functions.

"""

import os
import sys
import uuid


__all__ = ["generate_pipename",
           "create_pipe",
           "validate_plugin",
           "launch_plugin",
           "connect_pipe",
           "write_outconfig",
           "close_pipe",
           "PipeError"]


CONNECT_TIMEOUT_SECS = 45

class PipeError(Exception):
    pass

mswindows = (sys.platform == "win32")

if mswindows:
    import win32pipe
    import win32file
    import pywintypes
    import win32event
    import subprocess

    ERROR_PIPE_CONNECTED = 535
    ERROR_IO_PENDING = 997

    PIPE_PREFIX = "\\\\.\\pipe\\fb-pipe"

else:
    import signal
    import subprocess

    PIPE_PREFIX = "/tmp/fb-pipe-"


#
# Cross platform functions
#
def generate_pipename():
    return PIPE_PREFIX + str(uuid.uuid4())

#
# MS Windows
#
if mswindows:

    def create_pipe(pipeName):
        # XXX - We should validate here and return None on fail
        pipe = win32pipe.CreateNamedPipe(pipeName,
                                         win32pipe.PIPE_ACCESS_INBOUND | win32file.FILE_FLAG_OVERLAPPED,
                                         0x0,
                                         1,
                                         1024,
                                         1024,
                                         0,
                                         None)
        return pipe

    def validate_plugin(binName, inName, io):
        cmdLine = []
        if binName.endswith(".py"):
            cmdLine.append("python.exe")
        cmdLine.append("\"%s\"" % binName)
        cmdLine.append("--InConfig \"%s\"" % inName)
        cmdLine.append("--ValidateOnly true")
        try:
            retcode = subprocess.call(" ".join(cmdLine),
                                    stdout=io.stdout, 
                                    stderr=io.stdout,
                                    stdin=io.stdin,
                                    env=os.environ)
        except OSError, e:
            io.print_error("Failed to execute: %s" % str(e))
            retcode = 1

        return retcode

    def launch_plugin(binName, inName, pipeName, logFile, io, newconsole):
        """Execute the process with the passed in parameters.  Note that the
        output parameter is not a file name, but rather a named pipe!"""
        if newconsole:
            cmdLine = []
            cmdLine.append("start \"%s\" cmd /T:9F /K " % binName)
            if binName.endswith(".py"):
                cmdLine.append("\"python.exe \"%s\"" % binName)
            else:
                cmdLine.append("\"\"%s\"" % binName)
            cmdLine.append("--InConfig \"%s\"" % inName)
            cmdLine.append("--OutConfig \"%s\"" % pipeName)
            cmdLine.append("--LogFile \"%s\"\"" % logFile)
            p = subprocess.Popen(" ".join(cmdLine), shell=True, env=os.environ)
        else:
            cmdLine = []
            if binName.endswith(".py"):
                cmdLine.append("python.exe")
            cmdLine.append("\"%s\"" %  binName)
            cmdLine.append("--InConfig \"%s\"" % inName)
            cmdLine.append("--OutConfig \"%s\"" % pipeName)
            cmdLine.append("--LogFile \"%s\"" % logFile)
            p = subprocess.Popen(" ".join(cmdLine), 
                             shell=False, 
                             stdout=io.stdout, 
                             stderr=io.stderr,
                             stdin=io.stdin,
                             env=os.environ)
        return p
            

    def connect_pipe(pipe, pipeName):
        overLap = pywintypes.OVERLAPPED()
        overLap.hEvent = win32event.CreateEvent(None, 1, 0, None)
        if overLap.hEvent == 0:
            raise PipeError('Could not create hEvent')

        try:
            # Wait for a pipe client connection
            ret = win32pipe.ConnectNamedPipe(pipe, overLap)
            if not ret in (0, ERROR_PIPE_CONNECTED):
                if ret == ERROR_IO_PENDING:
                    ret = win32event.WaitForSingleObject(overLap.hEvent, 
                                                         1000 * CONNECT_TIMEOUT_SECS)
                    if ret != win32event.WAIT_OBJECT_0:
                        # Timeout error
                        raise PipeError('Timeout error')
                else:
                    # API error
                    raise PipeError('API error')

                ret = win32pipe.GetOverlappedResult(pipe, overLap, True)
            if not ret in (0, ERROR_PIPE_CONNECTED):
                # API Error
                raise PipeError('API error 2')
        except PipeError:
            # Named pipe exception
            win32file.CancelIo(pipe)
            pipe.close()
            raise
        except BaseException, err:
            win32file.CancelIo(pipe)
            pipe.close()
            pipe = None
            raise PipeError('BaseException : ' + str(err))

        return pipe 


    def write_outconfig(fileName, pipe):
        tmpFile = open(fileName, "w")
        while 1:
            try:
                (ret, line) = win32file.ReadFile(pipe, 4096, None)
                if ret != 0 or line == "":
                    break
                else:
                    tmpFile.write(line)
            except:
                break
        tmpFile.close()


    def close_pipe(pipe):
        win32file.CancelIo(pipe)
        pipe.close()

#
# Linux
#
else:
    def SIGALRM_handler(sigNum, frame):
        return

    def create_pipe(pipename):
        os.mkfifo(pipename, 0666)
        return None

    def launch_plugin(binName, inName, pipeName, logFile, io, newconsole):
        """Execute the process with the passed in parameters.  Note that the
        output parameter is not a file name, but rather a named pipe!"""
        if newconsole:
            cmdLine = []
            cmdLine.append("/usr/bin/xterm -hold -T \"%s\" -e " % binName)
            cmdLine.append("\"%s\"" % binName)
            cmdLine.append("--InConfig \"%s\"" % inName)        # Contains the input parameters
            cmdLine.append("--OutConfig \"%s\"" % pipeName)
            cmdLine.append("--LogFile \"%s\"" % logFile)
            p = subprocess.Popen(" ".join(cmdLine), shell=True, env=os.environ)
        else:
            cmdLine = []
            if binName.endswith(".py"):
                cmdLine.append("/usr/bin/python2.6")
            cmdLine.append("\"%s\"" % binName)
            cmdLine.append("--InConfig \"%s\"" % inName)        # Contains the input parameters
            cmdLine.append("--OutConfig \"%s\"" % pipeName)
            cmdLine.append("--LogFile \"%s\"" % logFile)
            p = subprocess.Popen(" ".join(cmdLine), shell=True, 
                                 stdout=io.stdout, 
                                 stderr=io.stderr, 
                                 stdin=io.stdin,
                                 env=os.environ)
        return p

    def validate_plugin(binName, inName, io):
        cmdLine = []
        if binName.endswith(".py"):
            cmdLine.append("/usr/bin/python2.6")
        cmdLine.append("\"%s\"" % binName)
        cmdLine.append("--InConfig \"%s\"" % inName)
        cmdLine.append("--ValidateOnly true")
        try:
            retcode = subprocess.call(" ".join(cmdLine),
                                    stdout=io.stdout, 
                                    stderr=io.stdout, 
                                    stdin=io.stdin,
                                    shell=True,
                                    env=os.environ)
        except OSError, e:
            io.print_error("Failed to execute: %s" % str(e))
            retcode = 1
        return retcode

    def connect_pipe(pipe, pipeName):
        """
        """
        oldHandler = signal.getsignal(signal.SIGALRM)
        try:
            signal.signal(signal.SIGALRM, SIGALRM_handler)
            signal.alarm(CONNECT_TIMEOUT_SECS + 1)
            retval = os.open(pipeName, os.O_RDONLY)
            signal.alarm(0)
        except OSError:
            # Alarm Timeout
            retval = None
        except BaseException:
            # Keyboard interrupt
            retval = None

        # cancel the alarm and restore prev handler
        signal.signal(signal.SIGALRM, oldHandler)

        return retval


    def write_outconfig(fileName, pipe):
        tmpFile = open(fileName, "w")
        while 1:
            line = os.read(pipe, 4096)
            if len(line) == 0:
                break
            else:
                tmpFile.write(line)
        tmpFile.close()

    def close_pipe(pipe):
        os.close(pipe)


