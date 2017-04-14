
import dsz

def getLastCommandMeta():
    lastid = dsz.cmd.LastId()
    return DszCommandMetadata(lastid)

class DszCommandMetadata(object, ):

    def __init__(self, cmdid=0):
        if (cmdid == 0):
            cmdid = dsz.cmd.LastId()
        for intfield in ['id', 'ParentId', 'Status', 'BytesSent', 'BytesReceived']:
            try:
                self.__dict__[intfield] = dsz.cmd.data.Get(('CommandMetaData::%s' % intfield), dsz.TYPE_INT, cmdid)[0]
            except:
                pass
        self.ID = self.__dict__['id']
        for strfield in ['Name', 'ScreenLog', 'TaskId', 'Destination', 'Source', 'FullCommand']:
            try:
                self.__dict__[strfield] = dsz.cmd.data.Get(('CommandMetaData::%s' % strfield), dsz.TYPE_STRING, cmdid)[0]
            except:
                pass
        for strarrfield in ['XmlLog', 'Prefix', 'Argument']:
            try:
                self.__dict__[strarrfield] = list()
                for strinst in dsz.cmd.data.ObjectGet('CommandMetaData', strarrfield, dsz.TYPE_OBJECT, cmdid):
                    for stritem in dsz.cmd.data.Get(strinst, dsz.TYPE_STRING, cmdid):
                        self.__dict__[strarrfield].append(stritem)
            except:
                pass