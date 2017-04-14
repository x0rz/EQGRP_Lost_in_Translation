
import datetime
import dsz
import dsz.ui
import ops
import ops.cmd
import ops.db
import ops.pprint
import ops.survey
import ops.files.drives
from optparse import OptionParser

def main():
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of information to use before re-running commands for this module', type='int')
    (options, args) = parser.parse_args()
    ops.survey.print_header('Disk list and space info')
    last_drives = ops.files.drives.get_drivelist(maxage=datetime.timedelta.max)
    cur_drives = ops.files.drives.get_drivelist(maxage=datetime.timedelta(seconds=options.maxage))
    last_drivespaces = dict()
    cur_drivespaces = dict()
    for drive in filter((lambda x: (x.type == 'Fixed')), cur_drives.driveitem):
        try:
            last_drivespaces[drive.drive[0].upper()] = ops.files.drives.get_diskspace(drive.drive[0].upper(), maxage=datetime.timedelta.max)
            cur_drivespaces[drive.drive[0].upper()] = ops.files.drives.get_diskspace(drive.drive[0].upper(), maxage=datetime.timedelta(seconds=options.maxage))
        except ops.cmd.OpsCommandException as ex:
            ops.warn(('Had a problem when trying to get disk space on drive %s.' % drive.drive[0].upper()))
            ops.warn('It might be a memory card reader or something similar that only pretends to be fixed')
    drive_remove = list()
    drive_add = list()
    for old_drive in last_drives.driveitem:
        match_drive = filter((lambda x: ((x.drive[0].upper() == old_drive.drive[0].upper()) and (x.type == old_drive.type) and (x.serialnumber == old_drive.serialnumber))), cur_drives.driveitem)
        if (len(match_drive) == 0):
            drive_remove.append(old_drive)
    for new_drive in cur_drives.driveitem:
        match_drive = filter((lambda x: ((x.drive[0].upper() == new_drive.drive[0].upper()) and (x.type == new_drive.type) and (x.serialnumber == new_drive.serialnumber))), last_drives.driveitem)
        if (len(match_drive) == 0):
            drive_add.append(new_drive)
    ops.survey.print_agestring(cur_drives.dszobjage)
    results = list()
    for drive in cur_drives.driveitem:
        driveletter = drive.drive[0].upper()
        if (driveletter in cur_drivespaces):
            drivespace = cur_drivespaces[driveletter]
            if (driveletter in last_drivespaces):
                drivespace_diff = (drivespace.free - last_drivespaces[driveletter].free)
            else:
                drivespace_diff = 'NEW'
            results.append({'drive': driveletter, 'serial': drive.serialnumber, 'type': drive.type, 'free': (drivespace.free / (1024 * 1024)), 'total': (drivespace.total / (1024 * 1024)), 'available': (drivespace.available / (1024 * 1024)), 'islow': drivespace.low_diskspace, 'change': (drivespace_diff / (1024 * 1024)), 'inuse': ('%s/%s (%d%%)' % (((drivespace.total - drivespace.free) / (1024 * 1024)), (drivespace.total / (1024 * 1024)), (100 - (100 * (float(drivespace.free) / drivespace.total)))))})
        else:
            results.append({'drive': driveletter, 'serial': drive.serialnumber, 'type': drive.type, 'free': '', 'total': '', 'available': '', 'islow': '', 'change': '', 'inuse': ''})
    ops.pprint.pprint(results, header=['Drive', 'Serial', 'Type', 'In use (MB)', 'Change (MB)'], dictorder=['drive', 'serial', 'type', 'inuse', 'change'])
    pass
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()