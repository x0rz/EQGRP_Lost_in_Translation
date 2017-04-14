
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
	
	return demi.windows.module.Uninstall("Pc", demi.registry.PC.Name, demi.registry.PC.Id, ask=False)

#------------------------------------------------------------------------------------------
if __name__ == '__main__':
	if (main(sys.argv) != True):
		sys.exit(-1);