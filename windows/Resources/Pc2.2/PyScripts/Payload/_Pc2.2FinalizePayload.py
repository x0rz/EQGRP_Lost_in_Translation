
import dsz
import pc

import glob
import os
import re
import shutil
import sys

#------------------------------------------------------------------------------------------
def main(argv):

	if (len(argv) != 2):
		dsz.ui.Echo("Usage: %s <payloadFile>" % argv[0], dsz.ERROR)
		return False
		
	return pc2_2.payload.settings.Finalize(argv[1])

	
#------------------------------------------------------------------------------------------
	
if __name__ == '__main__':
	if (main(sys.argv) != True):
		sys.exit(-1);