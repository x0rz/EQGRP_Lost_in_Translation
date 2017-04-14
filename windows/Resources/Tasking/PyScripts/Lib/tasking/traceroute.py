
import dsz
import os
import re
from task import *

class Traceroute(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'Traceroute')

    def CreateCommandLine(self):
        cmd = 'traceroute'
        if ('Hostname' in self.__dict__):
            cmd = ('%s %s' % (cmd, self.Hostname))
        if ('IpAddress' in self.__dict__):
            cmd = ('%s %s' % (cmd, self.IpAddress))
        if ('use_tcp_tracert' in self.__dict__):
            if bool(self.use_tcp_tracert):
                cmd = ('%s -tcp' % cmd)
        if ('maximum_hops' in self.__dict__):
            cmd = ('%s -maxhops %s' % (cmd, self.maximum_hops))
        if ('timeout' in self.__dict__):
            cmd = ('%s -maxhops %s' % (cmd, self.timeout))
        return [cmd]
TaskingOptions['_tracerouteTasking'] = Traceroute