
import glob
import os
import shutil
import sys
import xml.dom.minidom

#------------------------------------------------------------------------------------------
# DOM helper functions
#------------------------------------------------------------------------------------------
def getMatchingChildNodes(node, name):
	l = list()
	for item in node.childNodes:
		if (item.nodeType == node.ELEMENT_NODE) and (item.nodeName == name):
			l.append(item)
	return l
	
def getText(nodelist):
    rc = ""
    for node in nodelist:
        if node.nodeType == node.TEXT_NODE:
            rc = rc + node.data
    return rc

#------------------------------------------------------------------------------------------
def copyFiles(files):

	for item in files:
		src = item[0]
		dst = item[1]
		#print "%s -> %s" % (src, dst)
		try:
			os.makedirs(os.path.dirname(dst))
		except:
			pass
		
		shutil.copy2(src, dst)
	
	return True

#------------------------------------------------------------------------------------------
def handleDir(dirName, dstDir, root, recursive=False):

	#print "handleDir: ENTER (%s)" % dirName
	fileList = list()
	fileNodes = getMatchingChildNodes(root, "File")
	for fileNode in fileNodes:
		name = getText(fileNode.childNodes)			
		if (fileNode.getAttribute("name")):
			newName = fileNode.getAttribute("name")
		else:
			newName = None
		
		files = glob.glob("%s/%s" % (dirName, name))
		for item in files:
			item = os.path.basename(item)
			dstName = newName
			if (dstName == None):
				dstName = item
			if (len(dirName) > 0):
				if (os.path.isfile("%s/%s" % (dirName, item))):
					fileList.append(("%s/%s" % (dirName, item), "%s/%s/%s" % (dstDir, dirName, dstName)))
			else:
				if (os.path.isfile(item)):
					fileList.append((item, "%s/%s" % (dstDir, dstName)))
		
	# handle any sub-dirs
	if (recursive):
		dirNodes = [root]
	else:
		dirNodes = getMatchingChildNodes(root, "Dir")
	for dirNode in dirNodes:
		if (recursive):
			ignoreNodes = list()
			if (len(dirName) > 0):
				subDirName = "%s/*" % dirName
			else:
				subDirName = "*"
		else:
			ignoreNodes = getMatchingChildNodes(dirNode, "Ignore")
			if (len(dirName) > 0):
				subDirName = "%s/%s" % (dirName, dirNode.getAttribute("name"))
			else:
				subDirName = dirNode.getAttribute("name")
		
		subRecursive = recursive
		if (not subRecursive):
			rStr = dirNode.getAttribute("recursive")
			if ((rStr != None) and (rStr == "true")):
				subRecursive = True
				#print "RECURSIVE (%s)" % subDirName
					
		#print "Checking for '%s'" % subDirName
		names = glob.glob("%s" % subDirName)
		for name in names:
			if (os.path.basename(name) == ".svn"):
				continue
				
			# make sure it's not ignored
			ignore = False
			for ignoreNode in ignoreNodes:
				ignoreName = getText(ignoreNode.childNodes)
				#print "<----------------Checking '%s' for ignored '%s'" % (os.path.basename(name), ignoreName)
				if (ignoreName == os.path.basename(name)):
					ignore = True
			
			if (ignore):
				#print "IGNORING %s" % name
				continue
			
			if (os.path.isdir(name)):
				dirList = handleDir(os.path.normpath(name), dstDir, dirNode, subRecursive)
				for item in dirList:
					fileList.append(item)
			
	return fileList
		
#------------------------------------------------------------------------------------------
def main(argv):

#	rootDir = os.path.dirname(argv[0])
#	if (len(rootDir) == 0):
#		rootDir = "."
#	xmlName = "%s/replay.xml" % rootDir
	
	rootDir = "."
	xmlName = "%s/replay.xml" % rootDir
	
	dom1 = xml.dom.minidom.parse(xmlName)
	root = dom1.getElementsByTagName("ReplayFiles")
	
	dstDir = None
	while (dstDir == None):
		dstDir = os.path.normpath("%s/../ReplayDisk" % rootDir)
		sys.stdout.write("Enter the replay destination directory [%s]:" % dstDir)
		dir = sys.stdin.readline().rstrip('\r\n')
		if (len(dir) > 0):
			dstDir = dir
	
	fileCopyList = list()
	
	rootList = handleDir(rootDir, dstDir, root[0])
	for item in rootList:
		fileCopyList.append(item)
	
	if (not copyFiles(fileCopyList)):
		return False
	
	print "\n-----------------------------"
	print "Replay disk creation complete"
	print "-----------------------------"
	return True
	
#------------------------------------------------------------------------------------------
	
if __name__ == '__main__':
	if (main(sys.argv) != True):
		sys.exit(-1);