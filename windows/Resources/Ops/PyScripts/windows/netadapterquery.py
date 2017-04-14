
import dsz
import dsz.windows
import sys
import re
import ops.cmd
import codecs
from binascii import unhexlify
from ops.pprint import pprint
from datetime import datetime

def main():
    hive = 'L'
    classkey = 'system\\currentcontrolset\\control\\class'
    intkey = 'system\\currentcontrolset\\services\\tcpip\\parameters\\interfaces'
    config_dict = getadapterkeys(hive, classkey)
    key_list = ['Enabled', 'Name', 'IPAddress', 'SubnetMask', 'DefaultGateway', 'EnableDHCP', 'DhcpIPAddress', 'DhcpServer', 'DhcpSubnetMask', 'DriverDesc', 'ProviderName', 'DriverVersion']
    (interface_list, key_list) = gettcpipconfigs(hive, intkey, config_dict, key_list)
    key_remove = ['DhcpSubnetMaskOpt', 'DhcpInterfaceOptions', 'RawIPAllowedProtocols', 'UDPAllowedPorts', 'TCPAllowedPorts', 'IPAutoconfigurationSeed', 'DefaultGatewayMetric', 'UseZeroBroadcast', 'RegisterAdapterName', 'NTEContextList', 'CksOffload', 'Support8021p', 'SuperSwitch', 'Jumboframe', 'Largesend', 'DuplexMode', 'ITR', 'NicCoPlugins', 'QtagSwControlled', 'DmaFairness', 'CoInstallFlag', 'AdaptiveIFS', 'ChecksumTxTcp', 'SavePowerNowEnabled', 'DhcpClassIdBin', 'SPDEnabled', 'MaxFrameSize', 'TaggingMode', 'ChecksumTxIp', 'MulticastFilterType', 'ReduceSpeedOnPowerDown', 'TxIntDelay', 'MasterSlave', 'WakeOn', 'AutoPowerSaveModeEnabled', 'VlanFiltering', 'CoInstallers32', 'LogLinkStateEvent', 'NumRxDescriptors', 'SpeedDuplex', 'WaitAutoNegComplete', 'MWIEnable', 'Lease', 'AddressType', 'EnablePME', 'ChecksumRxIp', 'FlowControl', 'FirstTime', 'CustomMessages', 'ChecksumRxTcp', 'NumTxDescriptors', 'AutoNegAdvertised', 'Characteristics', 'InfSectionExt', 'MTU', 'MaxTsoSegSize', 'MinTsoSegCount', 'TsoEnable', 'RegistrationEnabled', 'EnableDeadGWDetect', 'BusType', 'ComponentId', 'PciScanMethod', 'DriverDateData', 'MatchingDeviceId', 'DeviceInstance', '*MediaType', 'DhcpGatewayHardwareCount', '*TCPChecksumOffloadIPv4', 'TransmitMode', 'DhcpConnForceBroadcastFlag', '*PriorityVLANTag', '*FlowControl', 'NetLuidIndex', 'MaxNumReceivePackets', 'MaxDpcLoopCount', '*LsoV1IPv4', 'MaxTxDpcLoopCount', 'NumCoalesceBuffers', '*SpeedDuplex', 'DefaultNameIndex', 'NewDeviceInstall', '*UDPChecksumOffloadIPv4', '*IfType', '*PhysicalMediaType', '*JumboPacket', 'DhcpGatewayHardware', '*TransmitBuffers', 'DefaultNameResourceId', '*ReceiveBuffers', 'IsServerNapAware', '*IPChecksumOffloadIPv4', '*InterruptModeration']
    time_keys = ['T2', 'T1', 'LeaseObtainedTime', 'LeaseTerminatesTime']
    ip_keys = ['DhcpDefaultGateway', 'DefaultGateway', 'SubnetMask', 'IPAddress']
    for key in key_remove:
        if (key in key_list):
            key_list.remove(key)
    devicelist = getdeviceclass()
    color_list = []
    interface_list.sort(key=(lambda x: x['NetCfgInstanceId']))
    for item in interface_list:
        for key in key_list:
            if (not (key in item.keys())):
                item[key] = ''
            if (key in ip_keys):
                item[key] = hex_to_ascii(item[key])
            if ((key in time_keys) and (item[key] != '')):
                item[key] = gettime(item[key])
        if (item['NetCfgInstanceId'] in devicelist.keys()):
            item['Enabled'] = devicelist[item['NetCfgInstanceId']][0]
            item['DeviceInstance'] = devicelist[item['NetCfgInstanceId']][1]
            if (item['Enabled'] == '1'):
                color_list.append(dsz.GOOD)
            else:
                color_list.append(dsz.ERROR)
        else:
            item['Enabled'] = ''
            item['DeviceInstance'] = ''
            color_list.append(dsz.DEFAULT)
    pprint(interface_list, header=key_list, dictorder=key_list, echocodes=color_list)
    return True

def getinfo(guid):
    mainkey = 'system\\currentcontrolset\\control\\network\\{4D36E972-E325-11CE-BFC1-08002BE10318}'
    values_dict = get_values('l', ('%s\\%s\\Connection' % (mainkey, guid)))
    return values_dict

def gettime(timestring):
    return datetime.fromtimestamp(int(timestring)).strftime('%Y-%m-%d %H:%m:%S')

def getdeviceclass():
    mainkey = 'SYSTEM\\CurrentControlSet\\Control\\DeviceClasses\\{ad498944-762f-11d0-8dcb-00c04fc3358c}'
    subkey_list = get_subkeys('l', mainkey)
    devicelist = {}
    for subkey in subkey_list:
        if subkey.startswith('##?#PCI#'):
            values_dict = get_values('l', ('%s\\%s' % (mainkey, subkey)))
            deviceinstance = values_dict['DeviceInstance']
            subkey_list = get_subkeys('l', ('%s\\%s' % (mainkey, subkey)))
            referencecount = None
            guid = None
            for key in subkey_list:
                if (key == 'Control'):
                    control_values = get_values('l', ('%s\\%s\\%s' % (mainkey, subkey, key)))
                    referencecount = control_values['ReferenceCount']
                else:
                    guid = key.strip('#')
            if (not (referencecount is None)):
                devicelist[guid] = [referencecount, deviceinstance]
    return devicelist

def getadapterkeys(hive, classkey):
    subkey_pattern = re.compile('^[0-9]{4}$')
    d_out_str = ''
    num_devices = 0
    config_dict = {}
    dsz.ui.Echo("Grabbing 'Network adapters' class keys...")
    device_class = '\\{4D36E972-E325-11CE-BFC1-08002bE10318}'
    class_vals = get_values(hive, ((classkey + '\\') + device_class))
    for device_subkey in get_subkeys(hive, ((classkey + '\\') + device_class)):
        if subkey_pattern.search(device_subkey):
            device_vals = get_values(hive, ((((classkey + '\\') + device_class) + '\\') + device_subkey))
            if (len(device_vals) > 0):
                num_devices += 1
            if ('NetCfgInstanceId' in device_vals):
                config_dict[((device_class + '/') + device_subkey)] = device_vals
    device_subkeys = []
    dsz.ui.Echo((str(num_devices) + ' network adapters found'))
    return config_dict

def gettcpipconfigs(hive, intkey, config_dict, key_list):
    i_out_str = ''
    db_vals = []
    interface_list = []
    dsz.ui.Echo('Grabbing TCP/IP configurations for network adapters...')
    for device in config_dict:
        device_vals = config_dict[device]
        interface_vals = get_values(hive, ((intkey + '\\') + device_vals['NetCfgInstanceId']))
        if (len(interface_vals) == 0):
            continue
        info_dict = getinfo(device_vals['NetCfgInstanceId'])
        for key in info_dict.keys():
            interface_vals[key] = info_dict[key]
        for key in device_vals.keys():
            interface_vals[key] = device_vals[key]
        interface_vals['NetCfgInstanceId'] = device_vals['NetCfgInstanceId']
        interface_list.append(interface_vals)
        for key in interface_vals.keys():
            if (not (key in key_list)):
                key_list.append(key)
    dsz.ui.Echo((str(len(interface_list)) + ' configurations found'))
    return (interface_list, key_list)

def get_subkeys(hive, key):
    names = []
    cmd = ops.cmd.getDszCommand('registryquery')
    cmd.hive = hive
    cmd.key = key
    obj = cmd.execute()
    if cmd.success:
        for key in obj.key:
            for subkey in key.subkey:
                names.append(subkey.name)
    dsz.control.echo.On()
    return names

def get_values(hive, key):
    vdict = {}
    cmd = ops.cmd.getDszCommand('registryquery')
    cmd.hive = hive
    cmd.key = key
    obj = cmd.execute()
    if cmd.success:
        for key in obj.key:
            for value in key.value:
                vdict[value.name] = value.value
    return vdict

def hex_to_ascii(string):
    string_list = codecs.getdecoder('unicode_internal')(unhexlify(string))[0].split('\x00')
    return_list = []
    for item in string_list:
        item = item.strip('\x00')
        if (not (item == '')):
            return_list.append(item)
    return ','.join(return_list)
if (__name__ == '__main__'):
    if (main() != True):
        sys.exit((-1))