
import dsz
import os
import re
from task import *

class SystemInfo(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'SystemInfo')

    def CreateCommandLine(self):
        return ['systemversion', 'packages']
TaskingOptions['_systemInfoTasking'] = SystemInfo