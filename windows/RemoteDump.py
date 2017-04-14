import os
import re
import sys
import time


port = ""
while (port == ""):
	port = raw_input("Please enter the dump port: ")
	try:
		port = int(port)
		break
	except:
		port = ""
		pass

logDir = raw_input("Please enter the target log directory")

logFile = "%s/Dump-%d.txt" % (logDir, port)

cmd = "java -cp Resources/Dsz/Tools/java-j2se_1.5/FullThreadDump.jar FullThreadDump localhost:%d > %s" % (port, logFile)

os.system(cmd)

sys.exit(0)
