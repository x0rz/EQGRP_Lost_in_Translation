
import glob
import os
import shutil
import sys

args = ""
i = 1
while (i < len(sys.argv)):
	if (len(args)):
		args = "%s %s" % (args, sys.argv[i])
	else:
		args = sys.argv[1]
	i = i + 1


os.system("java -Djava.endorsed.dirs=lib -jar FelonyCrowbarQuery.jar %s" % (args))

sys.exit(0)