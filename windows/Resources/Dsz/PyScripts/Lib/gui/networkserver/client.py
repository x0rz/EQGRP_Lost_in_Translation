import sys
from socket import *
import xml.dom.minidom

import response


#----------------------------------------------------------------
# Client class
#   Interacts with the NetworkServer in a Danderspritz window
#   The NetworkServer listens on a TCP port for XML messages.
#   This client connects to the server and wraps the generation
#   of the XML messages.
#----------------------------------------------------------------
class Client(object):
    def __init__(self, addr, port, name="Python Client"):
        # connect!
        self.sock = socket(AF_INET, SOCK_STREAM)
        self.sock.connect((addr, port))
        self.sock.setblocking(0)

        self.pending = bytearray(0)

        # consider setting another thread going to recieve?        

        doc = xml.dom.minidom.Document()
        msg = doc.createElement("RemoteIdentification")
        doc.appendChild(msg)
        txt = doc.createTextNode(name)
        msg.appendChild(txt)

        _sendXml(self.sock, doc)

    #-------------------------------------------------------
    # Requests a file be retrieved.
    # This is the preferred manner to retrieve files from a
    # target.  Name and Path must be provided together, or
    # Fullpath must be provided.  Do not provide Fullpath and either
    # Name or Path.
    #-------------------------------------------------------
    def RequestFileRetrieval(self, name=None, path=None, fullpath=None, recursive=None, max=None):
        data = dict()
        if name != None:
            data["name"] = name
        if path != None:
            data["path"] = path
        if fullpath != None:
            data["fullpath"] = fullpath
        if recursive:
            data["recursive"] = "True"
        if max != None:
            data["max"] = "%d" % (max)
        return _sendNewRequest(self.sock, "get", data)            

    #-------------------------------------------------------
    # Requests a file listing
    # This is the preferred manner to list files on a
    # target.  
    #-------------------------------------------------------
    def RequestFileListing(self, path=None, name=None, recursive=False):
        data = dict()
        if name != None:
            data["name"] = name
        if path != None:
            data["path"] = path
        if recursive:
            data["recursive"] = "True"
        return _sendNewRequest(self.sock, "dir", data)

    #-------------------------------------------------------
    # Requests a strings on a file
    # This is the preferred manner to do a strings dump on a file
    # Name and Path must be provided together, or Fullpath must
    # be provided.  Do not provide Fullpath and either
    # Name or Path.
    #-------------------------------------------------------
    def RequestStrings(self, name=None, path=None, fullpath=None, recursive=None, max=None):
        data = dict()
        if name != None:
            data["name"] = name
        if path != None:
            data["path"] = path
        if fullpath != None:
            data["fullpath"] = fullpath
        if recursive:
            data["recursive"] = "True"
        if max != None:
            data["max"] = "%d" % (max)
        return _sendNewRequest(self.sock, "strings", data)
        
    #-------------------------------------------------------
    # Requests a drive listing
    #-------------------------------------------------------
    def RequestDriveListing(self):
        return _sendNewRequest(self.sock, "drives", dict())

    #-------------------------------------------------------
    # Requests process information
    #-------------------------------------------------------
    def RequestProcessInfo(self, id, elevate=False):
        data = dict({"id" : id})
        if elevate:
            data["elevate"] = "True"
        return _sendNewRequest(self.sock, "processinfo", data)

    #-------------------------------------------------------
    # Requests process options
    #-------------------------------------------------------
    def RequestProcessOptions(self, id):
        return _sendNewRequest(self.sock, "processoptions", dict({"id" : id}))

    #-------------------------------------------------------
    # Requests process information
    #-------------------------------------------------------
    def RequestProcessKill(self, id, force=False):
        data = dict({"id" : id})
        if elevate:
            data["force"] = "True"
        return _sendNewRequest(self.sock, "kill", data)

    #-------------------------------------------------------
    # Requests process information
    #-------------------------------------------------------
    def RequestProcessKill(self, name, type, comment=None):
        data = dict({"name" : name, "type" : type})
        if (comment != None):
            data["comment"] = comment
        return _sendNewRequest(self.sock, "markProcess", data)


    #-------------------------------------------------------
    # Sends a directly formed command to the target.
    # This should be used rarely as command syntax could
    # mutate subtly.
    #-------------------------------------------------------
    def RequestRawCommand(self, command):
        return _sendNewRequest(self.sock, "raw", { "command" : command })


    #-------------------------------------------------------
    # Requests data variables from the target for a specific
    # command, and all it's children.  It's generally a good
    # idea to leave includeChildren == True, unless you ran
    # a 'raw' command, because all commands other than 'raw'
    # call a script that calls the appropriate command after
    # formatting it.  So, you'll get the task id of the script,
    # but not the command you actually care about.
    # Leaving operation == None means it will work on only the
    # current operation.  If you provide it, it will be used to
    # which command you meant.
    #-------------------------------------------------------
    def RetrieveData(self, taskId, operation=None, includeChildren=True):
        doc = xml.dom.minidom.Document()
        req = doc.createElement("Request")
        doc.appendChild(req)

        dataReq = doc.createElement("TaskDataRequest")
        req.appendChild(dataReq)
        if (operation != None):
            dataReq.setAttribute("operation", "%s" % (operation))
        dataReq.setAttribute("taskId", "%s" % (taskId))
        if (includeChildren):
            dataReq.setAttribute("includeChildren", "true")
        else:
            dataReq.setAttribute("includeChildren", "false")
        return _sendMessage(self.sock, req)
        
    #-------------------------------------------------------
    # Retrieves a response from the wire
    # This function returns an object from gui.networkserver.response
    # which contains the message from the NetworkServer
    #-------------------------------------------------------
    def ReadResponse(self):
        len = None
        # first, let's get any pending data
        while True:
            # break if we already have the IPC record mark
            try:
                len = self.pending.index(b'\x01')
                break
            except ValueError:
                pass
            # read a blob (let's call it 1K for now)
            try:
                input = self.sock.recv(1024)
                self.pending.extend(input)
            except:
                break

        if len == None:
            return None
            
        (msgStr, ret) = (self.pending[:len],self.pending[len+1:])
        self.pending[:] = ret
                
        msgXml = xml.dom.minidom.parseString(msgStr.decode("UTF-8"))

        msgXml.normalize()
        root = msgXml.documentElement
        if root.nodeName == "RemoteIdentification":
            return response.RemoteIdentification(_getStringFromNode(root))
        elif root.nodeName == "RemoteMessage":
            return response.RemoteMessage(_parseMessage(_getStringFromNode(root.getElementsByTagName("Message")[0])))
        elif root.nodeName == "RemotePing":
            return response.RemotePing()
        elif root.nodeName == "RemotePong":
            return response.RemotePong()

        print "Msg = %s" % (msgStr)
        
        return UnknownResponse(msgXml)

#--------------------------------------------------------
# Internal function
#--------------------------------------------------------
def _parseMessage(message):
    msgXml = xml.dom.minidom.parseString(message)
    root = msgXml.documentElement
    try:
        if root.nodeName == "Response":
            if (len(root.getElementsByTagName("CancelledRequest")) > 0):
                cancel = root.getElementsByTagName("CancelledRequest")[0]
                requestId = int(cancel.attributes["reqId"].nodeValue)
                return response.CancelledRequest(requestId)
            
            if (len(root.getElementsByTagName("NewRequest")) > 0):
                newReq = root.getElementsByTagName("NewRequest")[0]
                requestId = int(newReq.attributes["reqId"].nodeValue)
                try:
                    source = _getStringFromNode(newReq.getElementsByTagName("Source")[0])
                except:
                    source = None
                key = _getStringFromNode(newReq.getElementsByTagName("Key")[0])
                data = _parseKeyValuePairs(newReq.getElementsByTagName("Data"))
                return response.NewRequest(requestId, source, key, data)
            
            if (len(root.getElementsByTagName("ExecutedRequest")) > 0):
                executed = root.getElementsByTagName("ExecutedRequest")[0]
                requestId = int(executed.attributes["reqId"].nodeValue)
                operation = executed.attributes["operation"].nodeValue
                taskId = int(executed.attributes["taskId"].nodeValue)
                return response.ExecutedRequest(requestId, operation, taskId)                
            
            if (len(root.getElementsByTagName("RequestCompleted")) > 0):
                completed = root.getElementsByTagName("RequestCompleted")[0]
                requestId = int(completed.attributes["reqId"].nodeValue)
                operation = completed.attributes["operation"].nodeValue
                taskId = int(completed.attributes["taskId"].nodeValue)
                status = completed.attributes["status"].nodeValue
                return response.CompletedRequest(requestId, operation, taskId, status)
            
            if (len(root.getElementsByTagName("TaskData")) > 0):
                taskData = root.getElementsByTagName("TaskData")[0]
                op = taskData.attributes["operation"].nodeValue
                taskId = int(taskData.attributes["taskId"].nodeValue)

                try:
                    parent = taskData.getElementsByTagName("Parent")[0]
                    parentId = int(parent.attributes["taskId"].nodeValue)
                except:
                    parentId = -1
                
                dataObj = taskData.getElementsByTagName("Data")[0]
                name = dataObj.attributes["name"].nodeValue
                data = dict()

                return response.TaskData(name, op, taskId, parentId, _parseDataValues(dataObj.childNodes))

            raise RuntimeError("Unparsed:  %s" % (msgXml.toprettyxml(indent="  ")))
        elif root.nodeName == "Request":
            pass
        elif root.nodeName == "Cancel":
            pass
        elif root.nodeName == "Close":
            pass
    except:
        print root.toprettyxml(indent="  ")
        raise

    return message

#--------------------------------------------------------
# Internal function
#--------------------------------------------------------
def _parseDataValues(nodes, dataStore=None):
    if dataStore == None:
        dataStore = dict()
    for n in nodes:
        name = n.attributes["name"].nodeValue
        if n.nodeName == "ObjectValue":
            value = _parseDataValues(n.childNodes)
            
        elif n.nodeName == "StringValue":
            value = unicode(_getStringFromNode(n))

        elif n.nodeName == "IntegerValue":
            value = int(_getStringFromNode(n))

        elif n.nodeName == "BooleanValue":
            value = bool(_getStringFromNode(n))

        else:
            raise RuntimeError("unknown node:  %s" % (n.getNodeName))
        
        try:
            current = dataStore[name]
        except KeyError:
            current = []
            dataStore[name] = current
            
        if len(current) > 0 and type(current[0]) != type(value):
            raise RuntimeError("Same name, different types:  (%s, %s)" % (type(current[0]), type(value)))
        current.append(value)
    return dataStore

def _parseKeyValuePairs(data):
    ret = dict()
    for n in data:
        key = _getStringFromNode(n.getElementsByTagName("Key")[0])
        value = _getStringFromNode(n.getElementsByTagName("Value")[0])
        ret[key] = value
    return ret        

#--------------------------------------------------------
# Internal function
#--------------------------------------------------------
def _getStringFromNode(node):
    if node == None:
        return ""
    ret = []
    for n in node.childNodes:
        ret.append(n.nodeValue)
    return ''.join(ret)

#--------------------------------------------------------
# Internal function
#  forms a new request object
#--------------------------------------------------------
def _sendNewRequest(sock, key, data):
    doc = xml.dom.minidom.Document()
    req = doc.createElement("Request")
    doc.appendChild(req)

    newReq = doc.createElement("NewRequest")
    req.appendChild(newReq)

    k = doc.createElement("Key")
    newReq.appendChild(k)
    keyTxt = doc.createTextNode(key)
    k.appendChild(keyTxt)
    
    for keyValue, value in data.items():
        _addKeyValuePair(doc, newReq, keyValue, value)

    return _sendMessage(sock, req)        
    

#--------------------------------------------------------
# Internal function
#  creates a key/value pair to add to the request
#--------------------------------------------------------
def _addKeyValuePair(doc, parent, key, value):
    data = doc.createElement("Data")
    parent.appendChild(data)
    k = doc.createElement("Key")
    v = doc.createElement("Value")
    data.appendChild(k)
    data.appendChild(v)
    keyStr = doc.createTextNode(key)
    k.appendChild(keyStr)
    valueStr = doc.createTextNode(value)
    v.appendChild(valueStr)
    return True
        

#--------------------------------------------------------
# Internal function
#  wraps an XML message and sends it
#--------------------------------------------------------
def _sendMessage(sock, xmlMessage):
    doc = xml.dom.minidom.Document()
    rmsg = doc.createElement("RemoteMessage")
    msg = doc.createElement("Message")
    txt = doc.createTextNode(xmlMessage.toxml(encoding="UTF-8"))
    doc.appendChild(rmsg)
    rmsg.appendChild(msg)
    msg.appendChild(txt)
    return _sendXml(sock, doc)
        

#--------------------------------------------------------
# Internal function
#  sends xml to the target
#--------------------------------------------------------
def _sendXml(sock, xml):
    str = xml.toxml(encoding="UTF-8")
    sock.send(str)
    sock.send("%c" % (0x01))
    return True