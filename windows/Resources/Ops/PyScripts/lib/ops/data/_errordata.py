
import datetime
import os.path
import subprocess
import time
import xml.etree.ElementTree
import dsz
import ops
XALAN = os.path.join(ops.RESDIR, 'ExternalLibraries', 'java-j2se_1.6-sun', 'xalan.jar')
STYLESHEET = os.path.join(ops.DATA, 'DszErrorExtractor.xsl')

class DszCommandError(list, ):

    def __init__(self, timestamp, cmdid):
        self.timestamp = timestamp
        self.__cmdid = cmdid
        list.__init__(self)

    def __str__(self):
        msg = ('Error running command %d: %s\n' % (self.__cmdid, dsz.cmd.data.Get('commandmetadata::fullcommand', dsz.TYPE_STRING, cmdId=self.__cmdid)[0]))
        if len(self):
            for i in self:
                msg += (' - %s' % i)
        else:
            msg += ' - No additional information available. Try viewing the logs.'
        return msg

class DszCommandErrorData(object, ):

    def __init__(self, type, text, timestamp):
        self.type = type
        self.text = text
        self.timestamp = timestamp

    def __str__(self):
        return ('%s: %s' % (self.type, self.text))

def getLastError():
    return getErrorFromCommandId(cmdid=dsz.cmd.LastId())

def getErrorFromCommandId(cmdid):
    if (cmdid < 1):
        return []
    dataDir = os.path.join(ops.LOGDIR, 'Data')
    files = []
    for file in os.listdir(dataDir):
        fullpath = os.path.join(dataDir, file)
        if (not os.path.isfile(fullpath)):
            continue
        try:
            if (int(file.split('-', 1)[0]) == cmdid):
                files.append(fullpath)
        except ValueError:
            pass
    errorSets = []
    for file in files:
        errorSets.append(_parseXML(file, cmdid))
    return errorSets

def _parseXML(fullpath, cmdid):
    xsltoutput = subprocess.Popen(['javaw', '-jar', XALAN, '-in', fullpath, '-xsl', STYLESHEET], stdout=subprocess.PIPE).communicate()[0]
    tree = xml.etree.ElementTree.fromstring(xsltoutput)
    if (not tree.get('timestamp')):
        return DszCommandError(timestamp='', data=[], cmdid=cmdid)
    timestamp = datetime.datetime(*time.strptime(tree.get('timestamp'), '%Y-%m-%dT%H:%M:%S')[0:6])
    errors = DszCommandError(timestamp=timestamp, cmdid=cmdid)
    for error in tree:
        errors.append(DszCommandErrorData(type=error.get('type'), text=unicode(error.text, 'utf_8'), timestamp=timestamp))
    return errors