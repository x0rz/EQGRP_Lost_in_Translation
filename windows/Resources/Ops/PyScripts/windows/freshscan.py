
import sys, os
import os.path
from globalconfig import config
import dsz
import getutils, sendfile
import shutil
password = 'ops_submit'
prefix = 'samplesubmit'
winzipexe = config['exes']['winzip']
if (len(sys.argv) > 1):
    filename = sys.argv[1]
else:
    remoteget = dsz.ui.Prompt('Do you need me to get the file from target?')
if remoteget:
    filename = dsz.ui.GetString('What is the full name of the file (on target) you wish to send?')
    getresult = getutils.wrapget(filename, warnsize=10000000)
    if ((getresult == None) or (not getresult.successful)):
        dsz.ui.Echo('Unable to get file automatically, if you get it for me, I can still send it', dsz.WARNING)
        answer = dsz.ui.Prompt('Do you want to do that?')
        if (not answer):
            sys.exit((-1))
        dsz.ui.Echo('Go to another tab and get the file, please')
        remoteget = False
    else:
        dsz.ui.Echo('Got your file...')
        localpath = os.path.normpath(os.path.join(dsz.env.Get('_LOGPATH'), getresult.localpath))
        if (not os.path.exists(os.path.join(localpath, 'NOSEND'))):
            os.mkdir(os.path.join(localpath, 'NOSEND'))
        localfilename = os.path.normpath(((localpath + os.sep) + getresult.localname))
        shutil.move(localfilename, os.path.join(localpath, 'NOSEND', getresult.localname))
        localfilename = os.path.normpath(os.path.join(localpath, 'NOSEND', getresult.localname))
if (not remoteget):
    localfilename = dsz.ui.GetString('What is the full name of the local file you wish to send?')
userid = dsz.ui.GetInt('Please enter your ID')
if (not dsz.env.Check('OPS_PROJECTNAME')):
    projname = dsz.ui.GetString("Couldn't find project name, what is your project name?")
    dsz.env.Set('OPS_PROJECTNAME', projname)
else:
    projname = dsz.env.Get('OPS_PROJECTNAME')
if (not os.path.exists(localfilename)):
    localfilename = ((dsz.env.Get('_LOGPATH') + os.sep) + localfilename)
    dsz.ui.Echo('Your file does not seem to exist locally, bailing...')
    sys.exit((-1))
standardname = ('%s_%s_%d_W' % (prefix, projname, userid))
tempzipname = ('%s\\%s.zip' % (config['paths']['tmp'], standardname))
if os.path.exists(tempzipname):
    os.remove(tempzipname)
os.system(('%s -s%s -a %s %s' % (winzipexe, password, tempzipname, localfilename)))
sendfile.ftpfile(tempzipname, 'fast')
dsz.ui.Echo('File sent to fastmonkey...await results')