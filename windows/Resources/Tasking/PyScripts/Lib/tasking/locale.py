
import dsz
import os
import re
from task import *

class Locale(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'Locale')

    def CreateCommandLine(self):
        return ['language']
TaskingOptions['_localeTasking'] = Locale