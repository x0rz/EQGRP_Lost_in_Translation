
import dsz
import os
import re
from task import *

class Arp(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'Arp')

    def CreateCommandLine(self):
        return ['arp -query']
TaskingOptions['_arpTasking'] = Arp