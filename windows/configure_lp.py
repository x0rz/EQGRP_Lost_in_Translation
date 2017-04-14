#!/usr/bin/python

import os
import re
import sys
import time
import random

# determine the absolute path to the disk
scriptDir = os.path.dirname(os.path.realpath(sys.argv[0]))

if (re.search("\s", scriptDir)):
    print "Path to disk CANNOT contain any spaces";
    time.sleep(10)
    sys.exit(-1)

# change to the location of this script
os.chdir(scriptDir)

if (os.name == "nt"):
	# windows requires "start" prior to command
	javaExe = "start javaw"
	eol = ""
else:
	# unix
	javaExe = "java"
	eol = " &"

args = ""
i = 1
while (i < len(sys.argv)):
	if (len(args)):
		args = "%s %s" % (args, sys.argv[i])
	else:
		args = sys.argv[1]
	i = i + 1
	
port = int(random.randrange(25000, 55000))

##my $debug = "-agentlib:jdwp=transport=dt_shmem,address=jdbconn,server=y,suspend=n";
debug = "-Dcom.sun.management.jmxremote.port=%d -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false" % (port)
#debug = ""
cmd = "%s -Xms20m -Xmx1024m %s -Djava.endorsed.dirs=%s/Resources/Dsz/Gui/Lib/endorsed -jar %s/Start.jar %s %s" % (javaExe, debug, scriptDir, scriptDir, args, eol) 

#print "cmd: %s" % cmd
os.system(cmd)

sys.exit(0)
