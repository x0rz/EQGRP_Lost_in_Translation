
import sys
import time

def convert_smb_time(long_val):
    TIME_BETWEEN_SMB_AND_UNIX_EPOCH = 11644473600L
    time_since_epoch = ((long_val / 10000000) - TIME_BETWEEN_SMB_AND_UNIX_EPOCH)
    return time.ctime(time_since_epoch)
args = sys.argv[1:]
if (len(args) < 1):
    print '\nUsage: python smb_time_converter.py <SystemTime>'
    print '\tWhere <SystemTime> is returned from an RPC touch, as follows:'
    print '\t\tSystemTime=1cbd8165abb14e2 12c'
    print '\tIgnore anything after the space, the "12c" in this case\n'
    sys.exit()
long_time_val = int(args[0], 16)
time_string = convert_smb_time(long_time_val)
print ('\nTime: %s \n' % time_string)