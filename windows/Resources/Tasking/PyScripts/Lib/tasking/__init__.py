
import re
from tasking import *
from task import *
from arp import *
from audit import *
from dir import *
from get import *
from ip import *
from locale import *
from netmap import *
from netstat import *
from processlist import *
from regquery import *
from regwalk import *
from route import *
from systeminfo import *
from traceroute import *
AutomaticallyProceed = 'AutomaticallyProceedWithTasking'

def GenerateTasking(filename, path):
    for key in TaskingOptions.keys():
        if (key.lower() in filename.lower()):
            t = TaskingOptions[key]
            return t(('%s/%s' % (path, filename)))
    return None