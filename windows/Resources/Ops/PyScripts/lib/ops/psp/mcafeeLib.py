
import dsz.ui, dsz.cmd, dsz.menu, dsz.lp
import sys
import ops.cmd, ops.data, ops.psp
import re
import binascii
import mcafee85To88
from ops.pprint import pprint

def checkInstalled(mcafee, netassoc):
    installed = []
    plugins = _getSubKeys(netassoc, 'software\\Network Associates\\ePolicy Orchestrator\\Application Plugins')
    if (plugins != False):
        for key in plugins:
            plugin = {}
            for value in key.value:
                if (value.name == 'Product Name'):
                    plugin['Name'] = value.value
                if (value.name == 'Version'):
                    plugin['Version'] = value.value
            if (len(plugin) == 2):
                installed.append(plugin)
    if (len(installed) == 0):
        dsz.ui.Echo('No McAfee Products Found!', dsz.WARNING)
        return False
    return installed

def checkInstalledSettings(mcafee, installed):
    for product in installed:
        header = '{0} v{1}'.format(product['Name'], product['Version'])
        print '\n'
        dsz.ui.Echo(('#' * len(header)), dsz.WARNING)
        dsz.ui.Echo('{0}'.format(header), dsz.WARNING)
        dsz.ui.Echo((('#' * len(header)) + '\n'), dsz.WARNING)
        if (product['Name'].lower().find('virusscan enterprise') >= 0):
            if (product['Version'][:3] in ['8.5', '8.6', '8.7', '8.8']):
                checkVSE8588(mcafee, product)
        elif (product['Name'].lower().find('host intrusion prevention') >= 0):
            if product['Version'].startswith('7.'):
                checkHIPS7(mcafee)
            elif product['Version'].startswith('8.'):
                checkHIPS8(mcafee)

def checkVSE8588(mcafee, product):
    psp = ops.psp.PSP()
    psp.version = product['Version']
    psp.product = product['Name']
    bb = _getValue(mcafee, 'Software\\McAfee\\VSCore\\On Access Scanner\\BehaviourBlocking', 'AccessProtectionUserRules')
    if (bb == False):
        psp.SaveAttribute('BehaviorBlocking', _getValue(mcafee, 'Software\\McAfee\\SystemCore\\VSCore\\On Access Scanner\\BehaviourBlocking', 'AccessProtectionUserRules'))
    else:
        psp.SaveAttribute('BehaviorBlocking', bb)
    mcafee85To88.checksettings(psp)
    return

def checkHIPS7(mcafee):
    dsz.ui.Echo('NOTE!! The following settings are the settings provided by the ePO server. If the user/admin has changed any settings from the local UI, this list will be incorrect. Keep this in mind.\n', dsz.WARNING)
    enabled_disabled = {'1': 'Enabled', '0': 'Disabled'}
    rules = []
    rules.append({'Name': 'Host IPS Status', 'Value': enabled_disabled[_getValue(mcafee, 'software\\McAfee\\HIP', 'LastEnabledStateHips')]})
    rules.append({'Name': 'Network IPS Status', 'Value': enabled_disabled[_getValue(mcafee, 'software\\McAfee\\HIP', 'LastEnabledStateNips')]})
    rules.append({'Name': 'Firewall Status', 'Value': enabled_disabled[_getValue(mcafee, 'software\\McAfee\\HIP', 'LastEnabledStateFirewall')]})
    rules.append({'Name': 'Patch Version', 'Value': _getValue(mcafee, 'software\\McAfee\\HIP', 'Patch')})
    rules.append({'Name': 'App Creation Protection', 'Value': enabled_disabled[_getValue(mcafee, 'software\\McAfee\\HIP', 'LastEnabledStateAppCreate')]})
    rules.append({'Name': 'App Hooking Protection', 'Value': enabled_disabled[_getValue(mcafee, 'software\\McAfee\\HIP', 'LastEnabledStateAppHook')]})
    rules.append({'Name': 'Prevent High', 'Value': enabled_disabled[_getValue(mcafee, 'software\\McAfee\\HIP\\CounterMeasures', 'PreventHigh')]})
    rules.append({'Name': 'Prevent Medium', 'Value': enabled_disabled[_getValue(mcafee, 'software\\McAfee\\HIP\\CounterMeasures', 'PreventMedium')]})
    rules.append({'Name': 'Prevent Low', 'Value': enabled_disabled[_getValue(mcafee, 'software\\McAfee\\HIP\\CounterMeasures', 'PreventLow')]})
    pprint(rules)
    return

def checkHIPS8(mcafee):
    rules = []
    enabled_disabled = {'1': 'Enabled', '0': 'Disabled'}
    reaction_levels = {'1': 'Ignore', '2': 'Log', '3': 'Prevent'}
    rules.append({'Name': 'Host IPS Status', 'Value': enabled_disabled[_getValue(mcafee, 'software\\McAfee\\HIP\\Config\\Settings', 'IPS_HipsEnabled')]})
    rules.append({'Name': 'Network IPS Status', 'Value': enabled_disabled[_getValue(mcafee, 'software\\McAfee\\HIP\\Config\\Settings', 'IPS_NipsEnabled')]})
    rules.append({'Name': 'Firewall Status', 'Value': enabled_disabled[_getValue(mcafee, 'software\\McAfee\\HIP\\Config\\Settings', 'FW_Enabled')]})
    rules.append({'Name': 'Reaction High', 'Value': reaction_levels[_getValue(mcafee, 'software\\McAfee\\HIP\\Config\\Settings', 'IPS_ReactionForHigh')]})
    rules.append({'Name': 'Reaction Medium', 'Value': reaction_levels[_getValue(mcafee, 'software\\McAfee\\HIP\\Config\\Settings', 'IPS_ReactionForMedium')]})
    rules.append({'Name': 'Reaction Low', 'Value': reaction_levels[_getValue(mcafee, 'software\\McAfee\\HIP\\Config\\Settings', 'IPS_ReactionForLow')]})
    rules.append({'Name': 'Reaction Info', 'Value': reaction_levels[_getValue(mcafee, 'software\\McAfee\\HIP\\Config\\Settings', 'IPS_ReactionForInfo')]})
    rules.append({'Name': 'IPS Rules', 'Value': _getValue(mcafee, 'software\\McAfee\\HIP\\Config\\Settings', 'Client_PolicyName_IpsRulesList')})
    rules.append({'Name': 'FW Rules', 'Value': _getValue(mcafee, 'software\\McAfee\\HIP\\Config\\Settings', 'Client_PolicyName_FwRules')})
    rules.append({'Name': 'Definitions', 'Value': _getValue(mcafee, 'software\\McAfee\\HIP', 'ContentVersion')})
    rules.append({'Name': 'Definitions Date', 'Value': _getValue(mcafee, 'software\\McAfee\\HIP', 'ContentCreated')})
    rules.append({'Name': 'Patch Level', 'Value': _getValue(mcafee, 'software\\McAfee\\HIP', 'Patch')})
    pprint(rules)
    return

def _getKey(reg, key):
    for k in reg.key:
        if (k.name.lower() == key.lower()):
            return k
    return False

def _getValue(reg, key, value):
    for k in reg.key:
        if (k.name.lower() == key.lower()):
            for v in k.value:
                if (v.name.lower() == value.lower()):
                    return v.value
    return False

def _getSubKeys(reg, key):
    keys = []
    for k in reg.key:
        if ((k.name.lower().find(key.lower()) == 0) and (k.name.lower() != key.lower())):
            keys.append(k)
    if (len(keys) > 0):
        return keys
    return False