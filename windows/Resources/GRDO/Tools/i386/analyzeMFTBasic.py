#!/usr/bin/env python

noGUI = True								
unicodeHack = True						  

import struct, sys, ctypes, re, time, unicodedata, csv, binascii, os, platform
from datetime import date, datetime, timedelta
from optparse import OptionParser

# Globals

SIAttributeSizeXP = 72
SIAttributeSizeNT = 48


if noGUI == False:
	if platform.system() == "Windows":
		  import win32gui

	from Tkinter import *
	import Tkinter as tk
	import tkCommonDialog
	import tkFileDialog

class WindowsTime:
	"Convert the Windows time in 100 nanosecond intervals since Jan 1, 1601 to time in seconds since Jan 1, 1970"
	
	def __init__(self, low, high):
		self.low = long(low)
		self.high = long(high)
		
		if (low == 0) and (high == 0):
			self.dt = 0
			self.dtstr = "Not defined"
			self.unixtime = 0
			return
		
		# Windows NT time is specified as the number of 100 nanosecond intervals since January 1, 1601.
		# UNIX time is specified as the number of seconds since January 1, 1970. 
		# There are 134,774 days (or 11,644,473,600 seconds) between these dates.
		self.unixtime = self.GetUnixTime()
		
		try:  
			self.dt = datetime.fromtimestamp(self.unixtime)

		  # Pass isoformat a delimiter if you don't like the default "T".
			self.dtstr = self.dt.isoformat(' ')
		  
		except:
			self.dt = 0
			self.dtstr = "Invalid timestamp"
			self.unixtime = 0
		  
		
	def GetUnixTime(self):
		t=float(self.high)*2**32 + self.low
		return (t*1e-7 - 11644473600)

def decodeMFTmagic(s):
	if s == 0x454c4946:
		return "Good"
	elif s == 0x44414142:
		return 'Bad'
	elif s == 0x00000000:
		return 'Zero'
	else:
		return 'Unknown'

# decodeMFTisactive and decodeMFTrecordtype both look at the flags field in the MFT header.
# The first bit indicates if the record is active or inactive. The second bit indicates if it
# is a file or a folder.
#
# I had this coded incorrectly initially. Spencer Lynch identified and fixed the code. Many thanks!

def decodeMFTisactive(s):
	if s & 0x0001:
		return 'Active'
	else:
		return 'Inactive'
	
def decodeMFTrecordtype(s):
	tmpBuffer = s
	if s & 0x0002:
		tmpBuffer = 'Folder'
	else:
		tmpBuffer = 'File'
	if s & 0x0004:
		tmpBuffer = "%s %s" % (tmpBuffer, '+ Unknown1')
	if s & 0x0008:
		tmpBuffer = "%s %s" % (tmpBuffer, '+ Unknown2')

	return tmpBuffer

def addNote(s):
	
	if 'notes' in MFTR:
#		MFTR['notes'] = "%s | %s |" % (MFTR['notes'], s)
		MFTR['notes'] = "%s | %s |" % (MFTR['notes'], s)
	else:
		MFTR['notes'] = "%s" % s
		

def decodeMFTHeader(s):

	d = {}

	d['magic'] = struct.unpack("<I", s[:4])[0]
	d['upd_off'] = struct.unpack("<H",s[4:6])[0]
	d['upd_cnt'] = struct.unpack("<H",s[6:8])[0]
	d['lsn'] = struct.unpack("<d",s[8:16])[0]	
	d['seq'] = struct.unpack("<H",s[16:18])[0]
	d['link'] = struct.unpack("<H",s[18:20])[0]
	d['attr_off'] = struct.unpack("<H",s[20:22])[0]
	d['flags'] = struct.unpack("<H", s[22:24])[0]
	d['size'] = struct.unpack("<I",s[24:28])[0]
	d['alloc_sizef'] = struct.unpack("<I",s[28:32])[0]
	d['base_ref'] = struct.unpack("<Lxx",s[32:38])[0]
	d['base_seq'] = struct.unpack("<H",s[38:40])[0]
	d['next_attrid'] = struct.unpack("<H",s[40:42])[0]
	d['f1'] = s[42:44]
	d['entry'] = s[44:48]
	d['fncnt'] = 0							# Counter for number of FN attributes
	d['si'] = -1
	d['file_size'] = 0
	return d

def decodeATRHeader(s):
	
	d = {}
	d['type'] = struct.unpack("<L",s[:4])[0]
	if d['type'] == 0xffffffff:
		return d
	d['len'] = struct.unpack("<L",s[4:8])[0]
	d['res'] = struct.unpack("B",s[8])[0]
	d['nlen'] = struct.unpack("B",s[9])[0]				# This name is the name of the ADS, I think.
	d['name_off'] = struct.unpack("<H",s[10:12])[0]
	d['flags'] = struct.unpack("<H",s[12:14])[0]
	d['id'] = struct.unpack("<H",s[14:16])[0]
	if d['res'] == 0:
		d['ssize'] = struct.unpack("<L",s[16:20])[0]
		d['soff'] = struct.unpack("<H",s[20:22])[0]
		d['idxflag'] = struct.unpack("<H",s[22:24])[0]
	else:
		d['start_vcn'] = struct.unpack("<d",s[16:24])[0]
		d['last_vcn'] = struct.unpack("<d",s[24:32])[0]
		d['run_off'] = struct.unpack("<H",s[32:34])[0]
		d['compusize'] = struct.unpack("<H",s[34:36])[0]
		d['f1'] = struct.unpack("<I",s[36:40])[0]
		d['alen'] = struct.unpack("<d",s[40:48])[0]
		d['ssize'] = struct.unpack("<d",s[48:56])[0]
		d['initsize'] = struct.unpack("<d",s[56:64])[0]

	return d

def decodeSIAttribute(s):
	
	d = {}
	d['crtime'] = WindowsTime(struct.unpack("<L",s[:4])[0],struct.unpack("<L",s[4:8])[0])
	d['mtime'] = WindowsTime(struct.unpack("<L",s[8:12])[0],struct.unpack("<L",s[12:16])[0])
	d['ctime'] = WindowsTime(struct.unpack("<L",s[16:20])[0],struct.unpack("<L",s[20:24])[0])
	d['atime'] = WindowsTime(struct.unpack("<L",s[24:28])[0],struct.unpack("<L",s[28:32])[0])
	d['dos'] = struct.unpack("<I",s[32:36])[0]		# 4
	d['maxver'] = struct.unpack("<I",s[36:40])[0]	 # 4
	d['ver'] = struct.unpack("<I",s[40:44])[0]		# 4
	d['class_id'] = struct.unpack("<I",s[44:48])[0]	 # 4
	d['own_id'] = struct.unpack("<I",s[48:52])[0]	 # 4
	d['sec_id'] = struct.unpack("<I",s[52:56])[0]	 # 4
	d['quota'] = struct.unpack("<d",s[56:64])[0]		# 8
	d['usn'] = struct.unpack("<d",s[64:72])[0]		# 8 - end of date to here is 40
		
	return d

def decodeFNAttribute(s):
	
	hexFlag = False
	# File name attributes can have null dates.
	
	d = {}
	d['par_ref'] = struct.unpack("<Lxx", s[:6])[0]	# Parent reference nummber
	d['par_seq'] = struct.unpack("<H",s[6:8])[0]		# Parent sequence number
	d['crtime'] = WindowsTime(struct.unpack("<L",s[8:12])[0],struct.unpack("<L",s[12:16])[0])
	d['mtime'] = WindowsTime(struct.unpack("<L",s[16:20])[0],struct.unpack("<L",s[20:24])[0])
	d['ctime'] = WindowsTime(struct.unpack("<L",s[24:28])[0],struct.unpack("<L",s[28:32])[0])
	d['atime'] = WindowsTime(struct.unpack("<L",s[32:36])[0],struct.unpack("<L",s[36:40])[0])
	d['alloc_fsize'] = struct.unpack("<q",s[40:48])[0]
	d['real_fsize'] = struct.unpack("<q",s[48:56])[0]
	d['flags'] = struct.unpack("<d",s[56:64])[0]			# 0x01=NTFS, 0x02=DOS
	d['nlen'] = struct.unpack("B",s[64])[0]
	d['nspace'] = struct.unpack("B",s[65])[0]
	
	

	# The $MFT string is stored as \x24\x00\x4D\x00\x46\x00\x54. Ie, the first character is a single
	# byte and the remaining characters are two bytes with the first byte a null.
	# Note: Actually, it can be stored in several ways and the nspace field tells me which way.
	#
	# I found the following:
	# 
	# NTFS allows any sequence of 16-bit values for name encoding (file names, stream names, index names,
	# etc.). This means UTF-16 codepoints are supported, but the file system does not check whether a
	# sequence is valid UTF-16 (it allows any sequence of short values, not restricted to those in the
	# Unicode standard).
	#
	# If true, lovely. But that would explain what I am seeing.
	#
	# I just ran across an example of "any sequence of ..." - filenames with backspaces and newlines
	# in them. Thus, the "isalpha" check. I really need to figure out how to handle Unicode better.
	
	if (unicodeHack):
		d['name'] = ''
		for i in range(66, 66 + d['nlen']*2):	
			if s[i] != '\x00':						 # Just skip over nulls
				if s[i] > '\x1F' and s[i] < '\x80':		  # If it is printable, add it to the string
					d['name'] = d['name'] + s[i]
				else:
					d['name'] = "%s0x%02s" % (d['name'], s[i].encode("hex"))
					hexFlag = True

	# This statement produces a valid unicode string, I just cannot get it to print correctly
	# so I'm temporarily hacking it with the if (unicodeHack) above.
	else:
		d['name'] = s[66:66+d['nlen']*2]
		
# This didn't work
#	d['name'] = struct.pack("\u	
#	for i in range(0, d['nlen']*2, 2):
#		d['name']=d['name'] + struct.unpack("<H",s[66+i:66+i+1])
		
# What follows is ugly. I'm trying to deal with the filename in Unicode and not doing well.
# This solution works, though it is printing nulls between the characters. It'll do for now.
#	d['name'] = struct.unpack("<%dH" % (int(d['nlen'])*2),s[66:66+(d['nlen']*2)])
#	d['name'] = s[66:66+(d['nlen']*2)]
#	d['decname'] = unicodedata.normalize('NFKD', d['name']).encode('ASCII','ignore')
#	d['decname'] = unicode(d['name'],'iso-8859-1','ignore')

	if hexFlag:
		addNote('Filename - chars converted to hex')
		
	return d

def decodeAttributeList(s):

	hexFlag = False
	
	d = {}
	d['type'] = struct.unpack("<I",s[:4])[0]				# 4
	d['len'] = struct.unpack("<H",s[4:6])[0]				# 2
	d['nlen'] = struct.unpack("B",s[6])[0]				# 1
	d['f1'] = struct.unpack("B",s[7])[0]					# 1
	d['start_vcn'] = struct.unpack("<d",s[8:16])[0]		 # 8
	d['file_ref'] = struct.unpack("<Lxx",s[16:22])[0]	 # 6
	d['seq'] = struct.unpack("<H",s[22:24])[0]			# 2
	d['id'] = struct.unpack("<H",s[24:26])[0]			 # 4
	if (unicodeHack):
		d['name'] = ''
		for i in range(26, 26 + d['nlen']*2):
			if s[i] != '\x00':						 # Just skip over nulls
				if s[i] > '\x1F' and s[i] < '\x80':		  # If it is printable, add it to the string
					d['name'] = d['name'] + s[i]
				else:
					d['name'] = "%s0x%02s" % (d['name'], s[i].encode("hex"))
					hexFlag = True
	else:
		d['name'] = s[26:26+d['nlen']*2]
 
	if hexFlag:
		addNote('Filename - chars converted to hex')
		  
	return d

def decodeVolumeInfo(s):

	d = {}
	d['f1'] = struct.unpack("<d",s[:8])[0]				  # 8
	d['maj_ver'] = struct.unpack("B",s[8])[0]			   # 1
	d['min_ver'] = struct.unpack("B",s[9])[0]			   # 1
	d['flags'] = struct.unpack("<H",s[10:12])[0]			# 2
	d['f2'] = struct.unpack("<I",s[12:16])[0]			   # 4

	if (options.debug):
		print "+Volume Info"
		print "++F1%d" % d['f1']
		print "++Major Version: %d" % d['maj_ver']
		print "++Minor Version: %d" % d['min_ver']
		print "++Flags: %d" % d['flags']
		print "++F2: %d" % d['f2']
		
	return d

class ObjectID:
	def __init__(self, s):
		self.objid = s
		if s == 0:
			self.objstr = 'Undefined'
		else:
			self.objstr = self.FmtObjectID()

	def FmtObjectID(self):
		string = "%s-%s-%s-%s-%s" % (binascii.hexlify(self.objid[0:4]),binascii.hexlify(self.objid[4:6]),
			binascii.hexlify(self.objid[6:8]),binascii.hexlify(self.objid[8:10]),binascii.hexlify(self.objid[10:16]))
			
		return string

def decodeObjectID(s):

	d = {}
	d['objid'] = ObjectID(s[0:16])
	d['orig_volid'] = ObjectID(s[16:32])
	d['orig_objid'] = ObjectID(s[32:48])
	d['orig_domid'] = ObjectID(s[48:64])
	
	return d
	



def getfilepath(files,recordNumber):

	if not(files.has_key(recordNumber)):
		return -1

	else:

		
		if(-1 == files[recordNumber]):
			return "No FN Record"
		outstring = "GETFILEPATH" + "_" + str(recordNumber) + "_" + str(files[recordNumber]['par_ref'])
		workingrecordnumber = recordNumber

		path = files[recordNumber]['name']
		if((files[recordNumber]['fileflags'] & 0x2)):
			path += '\\'
		if(not(files[recordNumber]['fileflags'] & 0x1)):
			path += '(deleted)'
		
		i=0
		while (files[workingrecordnumber]['par_ref']<>5 and i<30):
			
			workingrecordnumber = files[workingrecordnumber]['par_ref']
			if(workingrecordnumber>len(files)):
				return "Invalid parent___" + "\\" + path
	
			if(files.has_key(workingrecordnumber)):
			
				if(files[workingrecordnumber]<>-1):
					path = files[workingrecordnumber]['name'] + "\\" + path
				else:
					return "PATHERROR_" + str(workingrecordnumber) + "\\" + path
			else:
				return "PATHERROR2" + "\\" + path
				
			i+=1

		 
		 
		return path
	
		
	 
def anomalyDetect(files,recordNumber):
 
 
	# Check for STD create times that are before the FN create times
	if MFTR['fncnt'] > 0:
		
		
		try:
			if (MFTR['fn', 0]['crtime'].dt == 0) or (MFTR['si']['crtime'].dt < MFTR['fn', 0]['crtime'].dt):
				MFTR['stf-fn-shift'] = True
				if MFTR['fn', 0]['crtime'].dt > searchdate:
					print getfilepath(files,recordNumber)

		except:
			MFTR['stf-fn-shift'] = True
	
	 
		  # Check for STD create times with a nanosecond value of '0'
		if MFTR['fn',0]['crtime'].dt != 0:
			if MFTR['fn',0]['crtime'].dt.microsecond == 0:
				MFTR['usec-zero'] = True
					
		if MFTR['fn',0]['crtime'].dt != 0:
			if MFTR['fn',0]['crtime'].dt == MFTR['fn',0]['mtime'].dt:
				MFTR['FN_cr_mod_match'] = True
					
					
	
def writeCSVFile():
	
	mftBuffer = ''
	tmpBuffer = ''
	filenameBuffer = ''
	
	if recordNumber == -1:
		# Write headers
		csvOutFile.writerow(['Record Number', 'Good', 'Active', 'Record type',
						'$Logfile Seq. Num.',
						 'Sequence Number', 'Parent File Rec. #', 'Parent File Rec. Seq. #','Size',
						 'Filename #1', 'Std Info Creation date', 'Std Info Modification date',
						 'Std Info Access date', 'Std Info Entry date', 'FN Info Creation date',
						 'FN Info Modification date','FN Info Access date', 'FN Info Entry date',
						 'Object ID', 'Birth Volume ID', 'Birth Object ID', 'Birth Domain ID',
						 'Standard Information', 'Attribute List', 'Filename',
						 'Object ID', 'Volume Name', 'Volume Info', 'Data', 'Sec_Desc', 'Index Root',
						 'Index Allocation', 'Bitmap', 'Reparse Point', 'EA Information', 'EA',
						 'Property Set', 'Logged Utility Stream', 'Log/Notes', 'STF FN Shift', 'uSec Zero', 'uniq_st_entry'])
	elif 'baad' in MFTR:
		csvOutFile.writerow(["%s" % recordNumber,"BAAD MFT Record"])
	else:
		mftBuffer = [recordNumber, decodeMFTmagic(MFTR['magic']), decodeMFTisactive(MFTR['flags']),
						  decodeMFTrecordtype(int(MFTR['flags']))]


		tmpBuffer = ["%d" % MFTR['seq']]
		mftBuffer.extend(tmpBuffer)
		
		if MFTR['fncnt'] > 0:
			mftBuffer.extend([str(MFTR['fn',0]['par_ref']), str(MFTR['fn',0]['par_seq'])])
		else:
			mftBuffer.extend(['NoParent', 'NoParent'])

		mftBuffer.extend([MFTR['file_size']])
		
			
		if MFTR['fncnt'] > 0:
			filenameBuffer = [FNrecord['name'], "'"+str(SIrecord['crtime'].dtstr),
						"'"+SIrecord['mtime'].dtstr, "'"+SIrecord['atime'].dtstr, "'"+SIrecord['ctime'].dtstr,
						"'"+MFTR['fn',0]['crtime'].dtstr, "'"+MFTR['fn',0]['mtime'].dtstr,
						"'"+MFTR['fn',0]['atime'].dtstr, "'"+MFTR['fn',0]['ctime'].dtstr]
		elif 'si' in MFTR:
			# Should replace SIrecord with MFTR['si']
			filenameBuffer = ['NoFNRecord', "'"+str(SIrecord['crtime'].dtstr),
						"'"+SIrecord['mtime'].dtstr, "'"+SIrecord['atime'].dtstr, "'"+SIrecord['ctime'].dtstr,
						'NoFNRecord', 'NoFNRecord', 'NoFNRecord','NoFNRecord']
		else:
			filenameBuffer = ['NoFNRecord', 'NoSIRecord', 
						'NoSIRecord', 'NoSIRecord', 'NoSIRecord',
						'NoFNRecord', 'NoFNRecord', 'NoFNRecord','NoFNRecord']

		mftBuffer.extend(filenameBuffer)
		
		if 'objid' in MFTR:
			objidBuffer = [MFTR['objid']['objid'].objstr, MFTR['objid']['orig_volid'].objstr,
						 MFTR['objid']['orig_objid'].objstr, MFTR['objid']['orig_domid'].objstr]
		else:
			objidBuffer = ['','','','']

		mftBuffer.extend(objidBuffer)						 


		mftBuffer.append('True') if 'si' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'al' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if MFTR['fncnt'] > 0 else mftBuffer.append('False')
		mftBuffer.append('True') if 'objid' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'volname' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'volinfo' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'data' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'sd' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'indexroot' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'indexallocation' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'bitmap' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'reparse' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'eainfo' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'ea' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'propertyset' in MFTR else mftBuffer.append('False')
		mftBuffer.append('True') if 'loggedutility' in MFTR else mftBuffer.append('False')			
		
		if 'notes' in MFTR:						# Log of abnormal activity related to this record
			mftBuffer.append(MFTR['notes'])
		else:
			mftBuffer.append('None')
		
		if 'stf-fn-shift' in MFTR:
			mftBuffer.append('Y')
		else:
			mftBuffer.append('N')

		if 'usec-zero' in MFTR:
			mftBuffer.append('Y')
		else:
			mftBuffer.append('N')
			 
		if 'uniq_st_entry' in MFTR:
			mftBuffer.append(MFTR['uniq_st_entry'])
			
		else:
			mftBuffer.append('N')
			 
		if 'FN_cr_mod_match' in MFTR:
			mftBuffer.append('Y')
		else:
			mftBuffer.append('N')
			 


		csvOutFile.writerow(mftBuffer)
		
		
# Get command line options

parser = OptionParser()
parser.set_defaults(debug=False,UseLocalTimezone=False,UseGUI=False)

parser.add_option("-f", "--file", dest="filename",
				help="read MFT from FILE", metavar="FILE")

parser.add_option("-o", "--output", dest="output",
				help="write results to FILE", metavar="FILE")
				
parser.add_option("-t", "--time", dest="time",
				help="time to search back", metavar="FILE")				

parser.add_option("-a", "--anomaly",
				action="store_true", dest="anomaly",
				help="turn on anomaly detection")

parser.add_option("-m", "--mactimes", dest="mactimes",
				help="write sorted MAC times to file", metavar="FILE")
				
				

if noGUI == False:
	parser.add_option("-g", "--gui",
					 action="store_true", dest="UseGUI",
					 help="Use GUI for file selection")
parser.add_option("-d", "--debug",
				action="store_true", dest="debug",
				help="turn on debugging output")

(options, args) = parser.parse_args()

# Start reading file

if (options.time):
	searchdate = datetime.now()-timedelta(days=int(options.time))
else:
	searchdate = datetime.now()-timedelta(days=7)


if (options.UseGUI):
	
	# Hide root tK window
	root = tk.Tk()
	root.withdraw()
	options.filename = tkFileDialog.askopenfilename(title='MFT file to open',filetypes=[("all files", "*")])

	options.output = tkFileDialog.asksaveasfilename(title='Output file')


	
	if options.mactimes != None:
		options.mactimes = tkFileDialog.asksaveasfilename(title='mactimes file')

else:
	if options.filename == None:
		print "-f <filename> required."
		sys.exit()
	
	if options.output == None:
		print "-o <filename> required."
		sys.exit()
	

try:
	F = open(options.filename, 'rb')
except:
	print "Unable to open file: %s" % options.filename
	sys.exit()

try:
	outFile = open(options.output, 'wb')
	csvOutFile = csv.writer(outFile, dialect=csv.excel,quoting=1)
except (IOError, TypeError):
	print "Unable to open file: %s" % options.output
	sys.exit()
	
if options.mactimes != None:
	try:
		mactimesfile = open(options.mactimes, 'w')
	except:
		print "Unable to open file: %s" % options.mactimes
		sys.exit()
	
# Write the headers to the output file
recordNumber = -1
MFTR = -1
writeCSVFile()
recordNumber = 0

print "Processing MFT data and writing csv data"


file_std_ctimes = {}
files = {}
file_times = {}


recordnum = 0

offsetString = F.read(4)
offsetToNextRecord = struct.unpack("<I", offsetString)[0]
recordData = F.read(offsetToNextRecord-4)

if options.debug: print "Record " + str(recordNumber) + " - Offset to next record " + str(offsetToNextRecord)



while offsetToNextRecord>0:
	MFT_index = struct.unpack("<I",recordData[0:4])[0]
	MFTR = decodeMFTHeader(recordData[4:52]);
	
	FNrecord = -1
	
	if options.debug:	print '-->Record number: %d\n\tMagic: %s Attribute offset: %d Flags: %s Size:%d' %  (recordNumber, MFTR['magic'], MFTR['attr_off'], hex(int(MFTR['flags'])), MFTR['size'])
	
	if MFTR['magic'] == 0x44414142:
		if options.debug: print "BAAD MFT Record "  + str(recordNumber)
		MFTR['baad'] = True
	elif MFTR['magic'] == 0:
		if options.debug: print "ZERO Record " + str(recordNumber)
		MFTR['zero'] = True
	
	else:
		attributes = struct.unpack("<I",recordData[124:128])[0]
		
		if (attributes & 0x1): MFTR['sd'] = True
		if (attributes & 0x2): MFTR['volname'] = True
		if (attributes & 0x4): MFTR['data'] = True
		if (attributes & 0x8): MFTR['indexroot'] = True
		if (attributes & 0x10): MFTR['bitmap'] = True
		if (attributes & 0x20): MFTR['ea'] = True
		if (attributes & 0x40): MFTR['eainfo'] = True
		if (attributes & 0x80): MFTR['loggedutility'] = True
		if (attributes & 0x100): MFTR['indexallocation'] = True
		if (attributes & 0x200): MFTR['propertyset'] = True
		if (attributes & 0x400): MFTR['reparsepoint'] = True
		if (attributes & 0x800): MFTR['fncnt'] = 1
		if (attributes & 0x1000): MFTR['nonresattriblist'] = True
		if (attributes & 0x2000): MFTR['unamed_data'] = True
		
		if options.debug: print "Attributes " + str(attributes)
		
		SIrecord = decodeSIAttribute(recordData[52:124])
		MFTR['si']=SIrecord
		if options.debug: print "++CRTime: %s\n++MTime: %s\n++ATime: %s\n++EntryTime: %s" % (SIrecord['crtime'].dtstr, SIrecord['mtime'].dtstr, SIrecord['atime'].dtstr, SIrecord['ctime'].dtstr)

		if(MFTR['fncnt']>0):
			if options.debug: print "File name record"
			FNrecord = decodeFNAttribute(recordData[128:])
			MFTR['fn',0] = FNrecord
			MFTR['file_size']=FNrecord['real_fsize']
			
			if options.debug: print "Name: %s" % (FNrecord['name'])
			if FNrecord['crtime'] != 0:
				if options.debug: print "\tCRTime: %s MTime: %s ATime: %s EntryTime: %s" % (FNrecord['crtime'].dtstr, FNrecord['mtime'].dtstr, FNrecord['atime'].dtstr, FNrecord['ctime'].dtstr)
		
	if(FNrecord<>-1):
		FNrecord['fileflags'] = MFTR['flags']
	if(1==MFTR['fncnt']):
		files[recordNumber]=FNrecord
	
	offsetString = F.read(4)
	if(offsetString==''): 
		#hit end of file
		break
	offsetToNextRecord = struct.unpack("<I", offsetString)[0]
	recordData = F.read(offsetToNextRecord-4)

	if options.debug: print "Record " + str(recordNumber) + " - Offset to next record " + str(offsetToNextRecord)
	writeCSVFile()

	recordNumber = recordNumber + 1
	
	if(recordNumber % 100000 == 0):
		print "processing recordNumber - " + str(recordNumber)
		
F.seek(0)	 
recordNumber = 0;
	
print "Starting run 2 for anamoly detection and MAC times"


offsetString = F.read(4)
offsetToNextRecord = struct.unpack("<I", offsetString)[0]
recordData = F.read(offsetToNextRecord-4)

if options.debug: print "Record " + str(recordNumber) + " - Offset to next record " + str(offsetToNextRecord)



while offsetToNextRecord>0:
	MFT_index = struct.unpack("<I",recordData[0:4])[0]
	MFTR = decodeMFTHeader(recordData[4:52]);
	
	FNrecord = -1
	
	if options.debug:	print '-->Record number: %d\n\tMagic: %s Attribute offset: %d Flags: %s Size:%d' %  (recordNumber, MFTR['magic'], MFTR['attr_off'], hex(int(MFTR['flags'])), MFTR['size'])
	
	if MFTR['magic'] == 0x44414142:
		if options.debug: print "BAAD MFT Record "  + str(recordNumber)
		MFTR['baad'] = True
	elif MFTR['magic'] == 0:
		if options.debug: print "ZERO Record " + str(recordNumber)
		MFTR['zero'] = True
	
	else:
		
		attributes = struct.unpack("<I",recordData[124:128])[0]
		
		if (attributes & 0x1): MFTR['sd'] = True
		if (attributes & 0x2): MFTR['volname'] = True
		if (attributes & 0x4): MFTR['data'] = True
		if (attributes & 0x8): MFTR['indexroot'] = True
		if (attributes & 0x10): MFTR['bitmap'] = True
		if (attributes & 0x20): MFTR['ea'] = True
		if (attributes & 0x40): MFTR['eainfo'] = True
		if (attributes & 0x80): MFTR['loggedutility'] = True
		if (attributes & 0x100): MFTR['indexallocation'] = True
		if (attributes & 0x200): MFTR['propertyset'] = True
		if (attributes & 0x400): MFTR['reparsepoint'] = True
		if (attributes & 0x800): MFTR['fncnt'] = 1
		if (attributes & 0x1000): MFTR['nonresattriblist'] = True
		if (attributes & 0x2000): MFTR['unamed_data'] = True
		
		if options.debug: print "Attributes " + str(attributes)
		
		SIrecord = decodeSIAttribute(recordData[52:124])
		MFTR['si']=SIrecord
		if options.debug: print "++CRTime: %s\n++MTime: %s\n++ATime: %s\n++EntryTime: %s" % (SIrecord['crtime'].dtstr, SIrecord['mtime'].dtstr, SIrecord['atime'].dtstr, SIrecord['ctime'].dtstr)
		
		if(MFTR['fncnt']>0):
			if options.debug: print "File name record"
			FNrecord = decodeFNAttribute(recordData[128:])
			MFTR['fn',0] = FNrecord
			MFTR['file_size']=FNrecord['real_fsize']
			
			if options.debug: print "Name: %s" % (FNrecord['name'])
			if FNrecord['crtime'] != 0:
				if options.debug: print "\tCRTime: %s MTime: %s ATime: %s EntryTime: %s" % (FNrecord['crtime'].dtstr, FNrecord['mtime'].dtstr, FNrecord['atime'].dtstr, FNrecord['ctime'].dtstr)
		

		
	if(FNrecord<>-1):
		FNrecord['fileflags'] = MFTR['flags']

	offsetString = F.read(4)
	if(offsetString==''): 
		#hit end of file
		print "Hit end of file at record - " + str(recordNumber)
		break
	offsetToNextRecord = struct.unpack("<I", offsetString)[0]
	recordData = F.read(offsetToNextRecord-4)

	if options.debug: print "Record " + str(recordNumber) + " - Offset to next record " + str(offsetToNextRecord)
	writeCSVFile()

	
	
	if(recordNumber % 100000 == 0):
		print "Run2 processing recordNumber - " + str(recordNumber)
		
	if(MFTR<>-1):
		
		filename_with_path = getfilepath(files,recordNumber)

		
		if(filename_with_path<>-1):
			
			entry = [filename_with_path,str(MFTR['file_size'])]

			if(MFTR['si']<>-1):
				
				entry.extend([MFTR['si']['mtime'].dtstr,MFTR['si']['atime'].dtstr,MFTR['si']['crtime'].dtstr,MFTR['si']['ctime'].dtstr])
				if(MFTR['fncnt']>0):
					entry.extend([MFTR['fn',0]['mtime'].dtstr,MFTR['fn',0]['atime'].dtstr,MFTR['fn',0]['crtime'].dtstr,MFTR['fn',0]['ctime'].dtstr])
				else:
					entry.extend(['','','',''])
					
				entry.extend([recordNumber])
					
				
				timeIndex = MFTR['si']['mtime'].dtstr
				file_times[timeIndex + ' ' + filename_with_path] = [timeIndex]
				file_times[timeIndex + ' ' + filename_with_path].extend(entry)

				timeIndex = MFTR['si']['atime'].dtstr
				file_times[timeIndex + ' ' + filename_with_path] = [timeIndex]
				file_times[timeIndex + ' ' + filename_with_path].extend(entry)

				timeIndex = MFTR['si']['ctime'].dtstr
				file_times[timeIndex + ' ' + filename_with_path] = [timeIndex]
				file_times[timeIndex + ' ' + filename_with_path].extend(entry)

				timeIndex = MFTR['si']['crtime'].dtstr
				file_times[timeIndex + ' ' + filename_with_path] = [timeIndex]
				file_times[timeIndex + ' ' + filename_with_path].extend(entry)
				if(MFTR['fncnt']>0):

					timeIndex = MFTR['fn',0]['mtime'].dtstr
					file_times[timeIndex + ' ' + filename_with_path] = [timeIndex]
					file_times[timeIndex + ' ' + filename_with_path].extend(entry)
					
					timeIndex = MFTR['fn',0]['atime'].dtstr
					file_times[timeIndex + ' ' + filename_with_path] = [timeIndex]
					file_times[timeIndex + ' ' + filename_with_path].extend(entry)

					timeIndex = MFTR['fn',0]['ctime'].dtstr
					file_times[timeIndex + ' ' + filename_with_path] = [timeIndex]
					file_times[timeIndex + ' ' + filename_with_path].extend(entry)

					timeIndex = MFTR['fn',0]['crtime'].dtstr
					file_times[timeIndex + ' ' + filename_with_path] = [timeIndex]
					file_times[timeIndex + ' ' + filename_with_path].extend(entry)
					

	if(recordNumber % 100000 == 0):
		print "processesing recordNumber - " + str(recordNumber)
		#break;

	if options.anomaly and 'baad' not in MFTR:
		anomalyDetect(files,recordNumber)
	recordNumber = recordNumber + 1

counter = 0


	
if options.mactimes:
	print "Processing MAC times for " + str(len(file_times)) + " entries from " + str(recordNumber) + " files"
	mactimesfile.write("filename,size,MACEmace,datetime,MFTRecIndex"+ "\n")

	for file_entry in sorted(file_times.keys()):

		MAC_string = ""
		if(file_times[file_entry][0]==file_times[file_entry][3]):
			MAC_string += 'M'
		else:
			MAC_string += '_'

		if(file_times[file_entry][0]==file_times[file_entry][4]):
			MAC_string += 'A'
		else:
			MAC_string += '_'

		if(file_times[file_entry][0]==file_times[file_entry][5]):
			MAC_string += 'C'
		else:
			MAC_string += '_'

		if(file_times[file_entry][0]==file_times[file_entry][6]):
			MAC_string += 'E'
		else:
			MAC_string += '_'

		if(file_times[file_entry][0]==file_times[file_entry][7]):
			MAC_string += 'm'
		else:
			MAC_string += '_'

		if(file_times[file_entry][0]==file_times[file_entry][8]):
			MAC_string += 'a'
		else:
			MAC_string += '_'

		if(file_times[file_entry][0]==file_times[file_entry][9]):
			MAC_string += 'c'
		else:
			MAC_string += '_'

		if(file_times[file_entry][0]==file_times[file_entry][10]):
			MAC_string += 'e'
		else:
			MAC_string += '_'


		outline_string = ""
		outline_string = file_times[file_entry][1]+ ',' + file_times[file_entry][2] + ',' + MAC_string+ ',\'' + file_times[file_entry][0]  + ',' + str(file_times[file_entry][11])
		
		if options.mactimes != None:
			mactimesfile.write(outline_string+ "\n")
		
	mactimesfile.close()
outFile.close()
	
	
	


