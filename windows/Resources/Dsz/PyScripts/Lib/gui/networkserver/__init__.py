import sys
import xml.dom.minidom
import time

import client
import response

#----------------------------------------------------------------
# This is a sample function, providing a demonstration of how
# certain attributes should be called
#----------------------------------------------------------------
def main(args):
    # I know these two already - you'll have to do some work
    ns = client.Client("127.0.0.1", 4638)
    # request a few commands
    #   A command isn't considered added until there is a response.NewRequest object for it
    #ns.RequestRawCommand("dir")
    #ns.RequestFileRetrieval(fullpath="c:/DszTestDir/perm")
    #ns.RequestFileRetrieval(name="*.dll", path="C:/windows", recursive=True, max=10)
    #ns.RequestFileListing(name="*.dll", path="C:/windows")
    #ns.RequestDriveListing()
    for t in range(274, 999999):
        #ns.RetrieveData("7a6d6f4c-ef7f-7140-9f955f3637335105", t, True)
        #ns.RetrieveData(t, includeChildren=False)
        pass

    # in my case, I know for a fact that 92 is a 'dir' that I did
    ns.RetrieveData(92, includeChildren=False)    

    # here's my message receive loop - reads all responses, giving a 10
    # second maximum delay between bits
    # gives a ten second delay to make sure there aren't pending messages
    waited = False    
    while (True):
        #print "About to read response"
        ret = ns.ReadResponse()
        # I think this one is done
        if (ret == None and waited):
            break
        elif (ret == None):
            time.sleep(10)
            waited = True
        else:
            waited = False
            #print ">%s" % (ret)
            try:
                message = ret.message
            except:
                print ">>%s" % ret
                continue
            try:
                # this is a breakdown of getting task data
                if (type(message) == response.TaskData):
                    print "Task data"
                    try:
                        # same pattern as used in dsz scripting
                        items = message["diritem[0]::fileitem"]
                    except:
                        # expect this to come up - as you're likely to get
                        # multiple messages with part of the data
                        #   for instance, a commandmetadata node (or 12),
                        #   and multiple 'diritem' nodes
                        # so you have to handle missing variable exceptions
                        # cleanly
                        print "Coudln't find variable"
                        continue

                    for i in items:
                        # if you want to use the returned value as a data
                        # object and the continued path references, you need
                        # to wrap each item returned in a response.DataObject
                        dataObj = response.DataObject(i)
                        print "File = %s" % (i["name"])
                else:
                    print ">>%s" % message
            except:
                raise
                

#------------------------------------------------------------------------------------------
if __name__ == '__main__':
	if (main(sys.argv) != True):
		sys.exit(-1)
		