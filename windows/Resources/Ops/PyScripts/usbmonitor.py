
import ops.cmd
import dsz
import sys
from ops.parseargs import ArgumentParser

def monitor_drives(interval):
    known_drives = []
    drives = ops.cmd.getDszCommand('drives')
    while True:
        results = drives.execute()
        current_drives = []
        for drive in results.driveitem:
            current_drives.append(drive.drive)
            if (drive.type == 'Removable'):
                if (drive.drive not in known_drives):
                    known_drives.append(drive.drive)
                    ops.alert('Removable media decteced on drive {0} on host {1}'.format(drive.drive, ops.project.getTarget().hostname), dsz.GOOD, stamp=None)
        for drive in known_drives:
            if (drive not in current_drives):
                ops.alert('Removable Media removed from drive {0} on host {1}'.format(drive, ops.project.getTarget().hostname), stamp=None)
                known_drives = current_drives
        dsz.Sleep(interval)

def get_parser():
    parser = ArgumentParser(version='1.0.0', description='usb_monitor.py should be run in the background.  It runs the Drives command at a given interval (default = 300) and monitors if removable media is plugged in or removed.  It will run until killed.')
    group_types = parser.add_argument_group('usb_monitor.py Arguments')
    group_types.add_argument('--interval', dest='interval', type=int, action='store', nargs=1, help='The interval in SECONDS at which to run the Drives command.  Default = 300')
    return parser

def parse_usbargs(args):
    parser = get_parser()
    options = parser.parse_args(args)
    return (options, parser.print_help)

def main(arguments):
    interval = 0
    if (len(arguments) == 0):
        interval = 300000
    else:
        (options, help) = parse_usbargs(arguments)
        interval = (options.interval[0] * 1000)
    monitor_drives(interval)
if (__name__ == '__main__'):
    main(sys.argv[1:])