
import dsz
import os
import re
from task import *

class Ip(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'Ip')

    def CreateCommandLine(self):
        return ['ifconfig']
TaskingOptions['_ipconfigTasking'] = Ip