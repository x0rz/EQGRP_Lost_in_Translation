#!/usr/bin/env python
# -*- Coding: UTF-8 -*-

import sys
import binascii
import logging
from ZIBE import logs, zbutil
from ZIBE.context_mgr import ContextManager, ZIBEException
from ZIBE.shell import ZIBEShell
from optparse import OptionParser
import os

if os.name == "nt":
    sep = ';'
else:
    sep = ":"
for v in os.environ['PATH'].split(sep):
    sys.path.append(v)

__logo__ = '''
                           .sssssssss.
                      .ssssssssssssssssss
                    sssssssssssssssssssssss
                   sssssssssssssssssssssssssss
                    @@sssssssssssssssssssssss@ss
                    |s@@@@sssssssssssssss@@@@s|s
               _____|sssss@@@@@sssss@@@@@sssss|s
             /       sssssssss@sssss@sssssssss|s
            /  .----+.ssssssss@sssss@ssssssss.|
           /  /     |...sssssss@sss@sssssss...|
          |  |      |.......sss@sss@ssss......|
          |  |      |..........s@ss@sss.......|
          |  |      |...........@ss@..........|
           \  \     |............ss@..........|
            \  ,    +...........ss@...........|
             \______ .........................|
                    | ........................|
                   /...........................\\
                  |.............................|
                     |.......................|
                         |...............|

'''


class ZIBEOptionParser(OptionParser):
    def __init__(self):
        OptionParser.__init__(self)
        self.add_option('--TargetIp', help='IP Address of Target Machine', dest="TargetIp")
        self.add_option('--TargetPort', help='Port of Target Machine', dest="TargetPort", default=445, type='int')
        self.add_option('--NetworkTimeout', help='Timeout for networking calls', dest="NetworkTimeout", default=60, type='int')
        self.add_option('--TargetEPMPort', help='Port of Target Machine', dest="TargetEPMPort", default=135, type='int')
        self.add_option('--CredentialType', help='Type of credential provided', dest="CredentialType", default="UsernamePassword")
        self.add_option('--Username', help='Account Username', dest="Username")
        self.add_option('--Credential', help='Account Password', dest="Credential")
        self.add_option('--Domain', help='Account Domain', dest="Domain", default=None)
        
        # Kerberos options
        self.add_option("--UseESRO", action="store_true", dest="UseESRO")
        self.add_option('--KerbCredentialType', help="The type of credential to use when performing the kerberos authentication", dest='KerbCredentialType')
        self.add_option('--TargetNetbiosName', help="NETBIOS name of the target computer", dest='TargetNetbiosName')
        self.add_option('--TargetDcIp', help="Domain Controller's IP address", dest='TargetDcIp')
        self.add_option('--TargetDcKerberosPort', help="Port used by the Kerberos service", dest='TargetDcKerberosPort', default=88, type='int')
        self.add_option('--TargetDcSMBPort', help="Port used by the Kerberos service", dest='TargetDcSMBPort', default=445, type='int')
        
        # DAPU Options
        self.add_option('--PrivateKey', help='DAPU Private Key', dest="PrivateKey")
        
        # Usability options
        self.add_option('--TabCompletion', help='Disable tab completion, which uses more network traffic, and may be painful over slow networks', 
                        dest="TabCompletion")
                        
try:
    sys.path.append(os.path.abspath(os.path.join(os.environ['FBDIR'], "fuzzbunch")))
    from coli import CommandlineWrapper
except Exception as e:
    print "Fuzzbunch directory not registered.  Using command line arguments"
    class CommandlineWrapper(object):
        def __call__(self, args):
            print "Called local commandlinewrapper"
            d = {}
            context = {}
            self.processParams(args, None, d, context, logs.get_logger('debug.log'))

class ZIBE(CommandlineWrapper):

    def __init__(self):
        CommandlineWrapper.__init__(self)
        self.parser = ZIBEOptionParser()
        self.opts = None
        self.args = None
        
    def __del__(self):
        pass
            
    def validateParams(self, params):
        return True
        
    def cleanup(self, flags, context, logConfig):
        return 
        
    def getID(self):
        return "b7bc209584db8d06d97dd5a6fa8b2453a93aa94a" 
        
    def processParams(self, inputs, constants, outputs, context, logConfig):
        # As a bi-product of the way we do things, we need to remove
        # the StreamHandler from the logConfig we receive
        for l in logConfig.handlers:
            if not isinstance(l, logging.FileHandler):
                logConfig.removeHandler(l)
        try:
            options, args = self.parser.parse_args(inputs) 
            
            if options.TargetIp ==  "" or options.TargetPort > 65535:
                print("IP/port are invalid")
                return
            if options.CredentialType not in ['UsernamePassword', 'PasswordHash', 'Kerberos', 'DAPU']:
                print("Invalid credential type. ")
                return
        except:
            self.parser.print_usage()
            return
        print "[+] TargetIp:            %s" % (options.TargetIp)
        print "[+] TargetPort:          %d" % (options.TargetPort)
        
        mgr = ContextManager()
        ctx = mgr.create_context("UselessContextName", options.TargetIp, options.TargetPort, options.TargetEPMPort)
        
        print "[+] CredentialType:      %s" % (options.CredentialType)
        try:
            if options.CredentialType in ['UsernamePassword', 'PasswordHash']:
                domain = options.Domain or '\\' in options.Username
                try:
                    if options.CredentialType == 'UsernamePassword' and domain:
                        ctx.provider( ctx.PROVIDER_NTLM_DOMAIN )
                        if options.Domain:
                            ctx.domain(options.Domain)
                        ctx.username( zbutil.arg_to_utf8(options.Username) )
                        ctx.password( zbutil.arg_to_utf8(options.Credential) )
                        print "[+] Username:            %s" % (zbutil.arg_to_utf8(options.Username))
                        print "[+] Credential:          %s" % (zbutil.arg_to_utf8(options.Credential))
                    elif options.CredentialType == 'UsernamePassword' and not domain:
                        ctx.provider( ctx.PROVIDER_NTLM_PLAINTEXT )
                        ctx.username( zbutil.arg_to_utf8(options.Username) )
                        ctx.password( zbutil.arg_to_utf8(options.Credential) )
                        print "[+] Username:            %s" % (zbutil.arg_to_utf8(options.Username))
                        print "[+] Credential:          %s" % (zbutil.arg_to_utf8(options.Credential))
                    elif options.CredentialType == 'PasswordHash' and domain:
                        ctx.provider( ctx.PROVIDER_NTLM_DOMAIN_HASH )
                        if options.Domain:
                            ctx.domain(options.Domain)
                        ctx.username( zbutil.arg_to_utf8(options.Username) )
                        ctx.password_hash(binascii.unhexlify(options.Credential))
                        print "[+] Username:            %s" % (zbutil.arg_to_utf8(options.Username))
                        print "[+] Password Hash:       %s" % (options.Credential)
                    elif options.CredentialType == 'PasswordHash' and not domain:
                        ctx.provider( ctx.PROVIDER_NTLM_PWHASH )
                        ctx.username( zbutil.arg_to_utf8(options.Username) )
                        ctx.password_hash(binascii.unhexlify(options.Credential))
                        print "[+] Username:            %s" % (zbutil.arg_to_utf8(options.Username))
                        print "[+] Password Hash:       %s" % (options.Credential)
                except Exception as e:
                    print("Unable to parse username or password: %s" % (e))
                    return
            elif options.CredentialType == 'Kerberos':
                if options.KerbCredentialType not in ['Password', 'PasswordHash']:
                    print("Invalid Kerberos credential type (--KerbCredentialType)")
                    return
                
                if not options.TargetDcIp or options.TargetDcIp == "":
                    print("Invalid domain controller IP address")
                    return
                if not options.TargetNetbiosName or options.TargetNetbiosName == "":
                    print("TargetNetbiosName is required")
                    return
                print "[+] TargetDcIp:          %s" % (options.TargetDcIp)
                print "[+] TargetDcPort:        %s" % (options.TargetDcKerberosPort)
                print "[+] TargetDcSMBPort:     %s" % (options.TargetDcSMBPort)
                print "[+] TargetNetbiosName:   %s" % (zbutil.arg_to_utf8(options.TargetNetbiosName))
                print "[+] KerbCredentialType:  %s" % (options.KerbCredentialType)
                print "[+] Username:            %s" % (zbutil.arg_to_utf8(options.Username))
                if options.KerbCredentialType == 'Password':
                    if options.UseESRO:
                        ctx.provider( ctx.PROVIDER_ESRO_PLAINTEXT )
                    else:
                        ctx.provider( ctx.PROVIDER_KERB_PLAINTEXT )
                    
                    ctx.password(zbutil.arg_to_utf8(options.Credential))
                    print "[+] Password:            %s" % (zbutil.arg_to_utf8(options.Credential))
                else: # Password Hash
                    if options.UseESRO:
                        ctx.provider( ctx.PROVIDER_ESRO_HASH )
                    else:
                        ctx.provider( ctx.PROVIDER_KERB_HASH )
                        
                    try:
                        ctx.password_hash(binascii.unhexlify( options.Credential ))
                        print "[+] PasswordHash:        %s" % (options.Credential)
                    except TypeError as e:
                        print("Invalid password hash.  Password must be encoded using binhex representation")
                        print(str(e))
                
                ctx.kdc_location( options.TargetDcIp, options.TargetDcKerberosPort, options.TargetDcSMBPort )
                ctx.target_name( zbutil.arg_to_utf8(options.TargetNetbiosName))
                ctx.username(zbutil.arg_to_utf8(options.Username))
                
            elif options.CredentialType == 'DAPU':
                ctx.provider( ctx.PROVIDER_DAPU )
                ctx.dp_key( binascii.unhexlify( options.PrivateKey))
            else:
                print("Invalid Authentication mechanism")
                return
        except Exception, e:
            print("Error when parsing parameters: " + str(e) )
            import traceback
            print(traceback.format_exc())
            return
            
        try:
            ctx.start_session()
        except ZIBEException, err:
            print("Failed to start ZIBE session: " + str(err) )
            return
        
        print(__logo__)
        if options.TabCompletion:
            shell = ZIBEShell(context=ctx, logger=logConfig)
        else:
            shell = ZIBEShell(context=ctx, completekey=None, logger=logConfig)
        
        shell.cmdloop(intro="ZIBE Interactive Shell")
        mgr.release_context(ctx)
        
if __name__ == "__main__":
    z = ZIBE()
    z(sys.argv[1:])
