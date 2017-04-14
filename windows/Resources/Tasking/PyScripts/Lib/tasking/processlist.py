
import dsz
import os
import re
from task import *

class ProcessList(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'ProcessList')

    def CreateCommandLine(self):
        return ['processes -list']
TaskingOptions['_processlistTasking'] = ProcessList