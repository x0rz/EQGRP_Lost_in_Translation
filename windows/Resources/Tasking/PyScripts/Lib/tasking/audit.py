
import dsz
import os
import re
from task import *

class Audit(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'Audit')

    def CreateCommandLine(self):
        return ['audit -status']
TaskingOptions['_auditTasking'] = Audit