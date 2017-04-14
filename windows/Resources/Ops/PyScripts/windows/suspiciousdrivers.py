
import dsz
import dsz.file
import dsz.lp
import dsz.menu
import dsz.payload
import dsz.version
import glob
import os
import re
import shutil
import sys
import datetime

def parse_date(date_str):
    p1 = re.compile('(....)-(..)-(..)')
    p2 = re.compile('(..)/(..)/(....)')
    m = p1.match(date_str)
    if m:
        return datetime.date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
    if (not m):
        m = p2.match(date_str)
        return datetime.date(int(m.group(3)), int(m.group(1)), int(m.group(2)))

def print_results(keys, after, before):
    for key in keys:
        name = dsz.cmd.data.ObjectGet(key, 'name', dsz.TYPE_STRING)[0]
        date = parse_date(dsz.cmd.data.ObjectGet(key, 'updateDate', dsz.TYPE_STRING)[0])
        if (after and (date < after)):
            continue
        if (before and (date > before)):
            continue
        dsz.ui.Echo(('[%s] %s' % (date, name)))

def clean_up_path(n):
    return n.split('\\')[(-1)].lower()

def clean_up_paths(names):
    return [clean_up_path(n) for n in names]

def check_service_driver(key, drivers, drvlist):
    score = 0
    if dsz.cmd.Run(('registryquery -hive L -key %s' % key), dsz.RUN_FLAG_RECORD):
        values = dsz.cmd.data.Get('Key::Value', dsz.TYPE_OBJECT)
        keyed = {}
        for v in values:
            name = dsz.cmd.data.ObjectGet(v, 'name', dsz.TYPE_STRING)[0]
            value = dsz.cmd.data.ObjectGet(v, 'value', dsz.TYPE_STRING)[0]
            keyed[name] = value
        try:
            cleaned_image = clean_up_path(keyed['ImagePath'])
            start = keyed['Start']
        except:
            return
        if (((start == '0') or (start == '1') or (start == '2')) and (cleaned_image.split('.')[(-1)].lower() == 'sys')):
            code = ''
            if (cleaned_image not in drivers):
                code += 'S'
                score += 1
            if (keyed['ErrorControl'] == '0'):
                code += 'E'
                score += 1
            if (cleaned_image not in drvlist):
                code += 'D'
                score += 1
            print ('[%s] %s: %s %s %s' % (code, key, start, keyed['ErrorControl'], cleaned_image))
    return score

def load_drv_list():
    data_path = 'D:\\DSZOPSDisk\\Resources\\Ops\\Data'
    drvlist = {}
    with open(('%s\\drv_list.txt' % data_path)) as f:
        for line in f:
            parts = line.split(',', 1)
            name = (parts[0].strip('"').lower() + '.sys')
            desc = parts[1].strip('"')
            drvlist[name] = desc
    return drvlist

def main(argv):
    dsz.control.echo.Off()
    drvlist = load_drv_list()
    if (not dsz.cmd.Run('drivers -list', dsz.RUN_FLAG_RECORD)):
        dsz.ui.Echo('* Failed to run drivers -list', dsz.ERROR)
        return False
    drivernames = clean_up_paths(dsz.cmd.data.Get('DriverItem::Name', dsz.TYPE_STRING))
    if (not dsz.cmd.Run('registryquery -hive L -key system\\currentcontrolset\\services', dsz.RUN_FLAG_RECORD)):
        dsz.ui.Echo('* Failed to run registryquery', dsz.ERROR)
        return False
    services = dsz.cmd.data.Get('Key::Subkey::name', dsz.TYPE_STRING)
    print '[S] = Driver set to auto start, but not running'
    print '[E] = Errors will not be reported'
    print '[D] = Driver not described in drv_list'
    suspicious_drivers = []
    for s in services:
        key = ('system\\currentcontrolset\\services\\%s' % s)
        score = check_service_driver(key, drivernames, drvlist)
        if (score > 1):
            suspicious_drivers.append(key)
    for s in suspicious_drivers:
        print ('**** %s is suspicious ****' % s)
    return True
if (__name__ == '__main__'):
    if (main(sys.argv) != True):
        sys.exit((-1))