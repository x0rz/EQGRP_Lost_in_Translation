
from ops.psp import getPSPFromVendor
import binascii
import sys
import ops.cmd

def registryadd(cmd):
    psps = getPSPFromVendor('mcafee')
    psps_vse = filter((lambda x: (x.product == 'VirusScan Enterprise')), psps)
    issafe = True
    msg = ''
    setting = ''
    regkey = cmd.optdict['key']
    regvalue = cmd.optdict.get('value', None)
    for psp in psps_vse:
        unhexed = binascii.unhexlify(psp.behaviorblocking)
        if (('CW01b' in unhexed) and regkey.lower().startswith('system\\currentcontrolset\\services')):
            issafe = False
            setting = 'Prevent programs registering as a service'
        elif (('CW01a' in unhexed) and (regvalue.lower() == 'appinit_dlls')):
            issafe = False
            setting = 'Prevent programs registering to autorun'
    if (not issafe):
        msg = ('%s %s %s is on this box and the "%s" setting is on.' % (psp.vendor, psp.product, psp.version, setting))
    return (issafe, msg)