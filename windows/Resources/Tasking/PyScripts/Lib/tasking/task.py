
import dsz
import os
import re
import shutil
import xml.dom.minidom
from util.DSZPyLogger import DSZPyLogger
TaskingOptions = dict()

class Task(object, ):

    def __init__(self, file, name):
        self.file = file
        self.name = name
        f = open(file, 'r')
        self.Priority = 10
        try:
            for line in f:
                line = line.strip()
                item = line.split(None, 1)
                self.__dict__[item[0]] = item[1]
        except:
            DSZPyLogger = DSZPyLogger()
            taskingLog = DSZPyLogger.getLogger('TaskingLog')
            taskingLog.warning(('Tasking.py failed to parse: %s' % file))
            shutil.copy(file, os.path.join(DSZPyLogger.LOG_FILE_DIR, '..'))

    def Preprocessing(self):
        pass

    def IsSkip(self):
        return False

    def IsVerify(self):
        return False

    def CreateCommandLine(self):
        raise Exception(('This task is incomplete:  %s' % self.name))

    def Display(self):
        dsz.ui.Echo(('Task:  %s' % self.name))
        pass