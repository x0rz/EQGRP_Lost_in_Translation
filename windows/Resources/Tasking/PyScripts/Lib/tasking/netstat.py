
import dsz
import os
import re
from task import *

class Netstat(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'Netstat')

    def CreateCommandLine(self):
        return ['netstat -list']
TaskingOptions['_netstatTasking'] = Netstat