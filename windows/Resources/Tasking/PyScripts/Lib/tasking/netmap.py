
import dsz
import os
import re
from task import *

class Netmap(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'Netmap')

    def CreateCommandLine(self):
        return ['netmap -minimal']
TaskingOptions['_netmapTasking'] = Netmap