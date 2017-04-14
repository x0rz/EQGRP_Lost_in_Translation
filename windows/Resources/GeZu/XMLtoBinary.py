import sys
import os
import binascii
from xml.dom.minidom import parseString

if __name__ == '__main__':
	
	if(len(sys.argv) < 3):
		print "Error: useage %s <inputfile> <outputfile>" % os.path.basename(sys.argv[0])
		exit(1)
	

	filename = sys.argv[1]

	outfilename = sys.argv[2]
	
file = open(filename)

data = file.read()

file.close()

dom = parseString(data)

xmlDump = dom.getElementsByTagName('MemDump')[0].toxml()

Dump = xmlDump.replace('<MemDump>', '').replace('</MemDump>', '')

binDump = binascii.unhexlify(Dump)

outfile = open(outfilename, 'wb')

outfile.write(binDump)

outfile.close()