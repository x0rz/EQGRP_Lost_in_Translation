
# package pc2_2
import dsz

import pc2_2.payload

import re

#--------------------------------------------------------------------------------------
def IsValidIpAddress(addr):

	# This is a rather inefficient way to find IPv6 addresses in particular...
	
	if ((re.match("^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$", addr) != None) or
		(re.match("^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$", addr) != None) or
		(re.match("^::$", addr) != None) or
		(re.match("^::([a-fA-F0-9]){1,4}(:([a-f]|[A-F]|[0-9]){1,4}){0,6}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}::([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,5}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,1}::([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,4}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,2}::([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,3}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,3}::([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,2}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,4}::([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,1}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,4}::([a-fA-F0-9]){1,4}:([a-fA-F0-9]){1,4}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,5}::([a-fA-F0-9]){1,4}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,6}::$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){5}:[0-9]{1,3}(\.[0-9]{1,3}){3}$", addr) != None) or
		(re.match("^::([0-9]){1,3}(\.[0-9]{1,3}){3}$", addr) != None) or
		(re.match("^::([a-fA-F0-9]){1,4}(:)([0-9]){1,3}(\.[0-9]{1,3}){3}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}::([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,3}:[0-9]{1,3}(\.[0-9]{1,3}){3}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,1}::([a-fA-F0-9]){1,4}(:[a-fA-F0-9]){0,2}:[0-9]{1,3}(\.[0-9]{1,3}){3}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,2}::([a-fA-F0-9]){1,4}(:[a-fA-F0-9]){0,1}:[0-9]{1,3}(\.[0-9]{1,3}){3}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,3}::([a-fA-F0-9]){1,4}:[0-9]{1,3}(\.[0-9]{1,3}){3}$", addr) != None) or
		(re.match("^([a-fA-F0-9]){1,4}(:([a-fA-F0-9]){1,4}){0,4}::[0-9]{1,3}(\.[0-9]{1,3}){3}$", addr) != None)):
		return True
	else:
		dsz.ui.Echo("Invalid IP address", dsz.ERROR)
		return False
