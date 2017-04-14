
import dsz
import os
import re
from task import *

class Route(Task, ):

    def __init__(self, file):
        Task.__init__(self, file, 'Route')

    def CreateCommandLine(self):
        return ['route -query']
TaskingOptions['_routeTasking'] = Route