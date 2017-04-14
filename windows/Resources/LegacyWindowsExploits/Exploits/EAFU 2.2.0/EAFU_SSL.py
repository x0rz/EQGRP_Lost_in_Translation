import re, socket, string, sys


if __name__ == "__main__":
	if len(sys.argv) < 3:
		sys.exit(2)
	
	target_address = (sys.argv[1])
	target_port = int(sys.argv[2])		

	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect((target_address, target_port))
	
	ssl_sock = socket.ssl(s)
	
	# print the cert info
	#print repr(ssl_sock.server())
	#print repr(ssl_sock.issuer())

	# Set a simple HTTP request -- use httplib in actual code.
	ssl_sock.write("""GET / HTTP/1.1\r\nHost:\r\n\r\n""")
	
	# Read a chunk of data. Will not necessarily
	# read all the data returned by the server.
	data = ssl_sock.read()

	# what did we get back?
	# print data

	# parse the reply for the version number
	# Server: WDaemon/9.5.1
	if re.search('Server: WDaemon/\d\d?\.\d\.\d', data):
		m = re.search('Server: WDaemon\/(\d\d?\.\d\.\d)', data)
		print "\n\n\nWorldClient version is: " + m.group(1)

	elif re.search('Server: Microsoft-IIS\/(\d\d?\.\d).*MDaemon\/WorldClient v(\d\d?\.\d\.\d)', data):
		n = re.search('Server: Microsoft-IIS\/(\d\d?\.\d).*MDaemon\/WorldClient v(\d\d?\.\d\.\d)', data)
		print "\n\n\nWorldClient version and IIS version is: " + n.group(2) + n.group(1)
	
	# Note that you need to close the underlying socket, not the SSL object.
	del ssl_sock
	s.close()
 