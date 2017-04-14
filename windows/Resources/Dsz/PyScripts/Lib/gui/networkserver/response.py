import re
#----------------------------------------------------------------
# Holds response objects for the networkserver client.
#----------------------------------------------------------------


#----------------------------------------------------------------
# An unknown response.
#----------------------------------------------------------------
class UnknownResponse(object):
    def __init__(self, xml):
        self.xml = xml
    def __repr__(self):
        return "Unknown response:  %s" % (xml.toprettyxml(indent="  "))

#----------------------------------------------------------------
# The identity of the target you have connected to.  Danderspritz
# returns 'Live Peer', but anything that follows the Danderspritz
# IPC could provide something else
#----------------------------------------------------------------
class RemoteIdentification(object):
    def __init__(self, name):
        self.name = name
    def __repr__(self):
        return "Identification: %s" % (self.name)

#----------------------------------------------------------------
# A ping request from the target.
#----------------------------------------------------------------
class RemotePing(object):
    pass
    def __repr__(self):
        return "Remote Ping"

#----------------------------------------------------------------
# A ping response from the target.
#----------------------------------------------------------------
class RemotePong(object):
    pass
    def __repr__(self):
        return "Remote Pong"

#----------------------------------------------------------------
# A message from the server.  The work-horse message.  Check the
# 'message' field for the wrapped message
#----------------------------------------------------------------
class RemoteMessage(object):
    def __init__(self, msg):
        self.message = msg

    def __repr__(self):
        return "RemoteMessage:  %s" % (self.message)

#----------------------------------------------------------------
# A requested command has been run - but not necessarily finished
# The requestId field is the request id provided when the request
# was registered.
# taskId and operation are the identifiers used to determine
# task data
#----------------------------------------------------------------
class ExecutedRequest(object):
    def __init__(self, reqId, operation, taskId):
        self.requestId = reqId
        self.operation = operation
        self.taskid = taskId

    def __repr__(self):
        return "ExecutedRequest:  %d (%s <=> %d)" % (self.requestId, self.operation, self.taskid)

#----------------------------------------------------------------
# A requested command has been run and completed
# The requestId field is the request id provided when the request
# was registered.
# taskId and operation are the identifiers used to determine
# task data
#----------------------------------------------------------------
class CompletedRequest(object):
    def __init__(self, reqId, operation, taskId, status):
        self.requestId = reqId
        self.operation = operation
        self.taskid = taskId
        self.status = status

    def __repr__(self):
        return "CompletedRequest:  %d (%s <=> %d) == %s" % (self.requestId, self.operation, self.taskid, self.status)

#----------------------------------------------------------------
# A requested command was cancelled
# The requestId field is the request id provided when the request
# was registered.
#----------------------------------------------------------------
class CancelledRequest(object):
    def __init__(self, id):
        self.id = id
    def __repr__(self):
        return "Cancelled Request:  %d" % (self.id)

#----------------------------------------------------------------
# A requested command was denied
# The requestId field is the request id provided when the request
# was registered.
#----------------------------------------------------------------
class DeniedRequest(object):
    def __init__(self, id):
        self.id = id
    def __repr__(self):
        return "Denied Request:  %d" % (self.id)

#----------------------------------------------------------------
# A newly requested operation
#----------------------------------------------------------------
class NewRequest(object):
    def __init__(self, requestId, source, key, data):
        self.requestId = requestId
        self.source = source
        self.key = key
        self.data = data
    def __repr__(self):
        return "New Request:  %d, %s, %s\n\t%s" % (self.requestId, self.source, self.key, self.data)

#----------------------------------------------------------------
# Task Data
# The data is stored in a dictionary, according to the task's
# documentation.
#----------------------------------------------------------------
class TaskData(object):
    def __init__(self, name, operation, id, parentId, data):
        self.data = DataObject(data)
        self.name = name
        self.operation = operation
        self.id = id
        self.parentId = parentId

    def __repr__(self):
        return "TaskData:  %d: %s => %s" % (self.id, self.name, self.data)

    def __getitem__(self, index):
        return self.data[index]


#----------------------------------------------------------------
# Data Object
# Holds data from a command, and provides indexing lookup
#----------------------------------------------------------------
class DataObject(object):
    def __init__(self, data):
        self.data = data
        
    def __getitem__(self, index):
        return _derive([self.data], index.split("::"))























#----------------------------------------------------------------
def _splitStep(step):
    try:
        m = re.match("(.*)\[([0-9+])\]$", step)
        return (m.group(1), int(m.group(2)))
    except:
        return (step, -1)

#----------------------------------------------------------------
def _derive(data, steps):
    if ((data == None) or (len(data) == 0)):
        return None
    newData = []

    for d in data:
        (string, index) = _splitStep(steps[0])
        a = d[string]
        if (index == -1):
            newData += a
        else:
            newData.append(a[index])
            
    if len(steps) == 1:
        return newData
    else:
        return _derive(newData, steps[1:])