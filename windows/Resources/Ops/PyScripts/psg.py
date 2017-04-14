
import dsz
import traceback, sys
from optparse import OptionParser
from collections import defaultdict
import re
import ops.cmd
from ops.pprint import pprint

def main():
    process_list = []
    if (len(sys.argv) > 1):
        pattern = (('.*' + sys.argv[1]) + '.*')
    else:
        pattern = '.*'
    print (('\nFiltering processes with regex:: ' + pattern) + '\n')
    regex = re.compile(pattern, (re.I | re.UNICODE))
    dsz.control.echo.Off()
    cmd = ops.cmd.getDszCommand('processes -list')
    proc_items = cmd.execute()
    if cmd.success:
        for proc_item in proc_items.initialprocesslistitem.processitem:
            pid = str(proc_item.id)
            ppid = str(proc_item.parentid)
            name = str(proc_item.name.encode('utf-8'))
            path = str(proc_item.path.encode('utf-8'))
            user = str(proc_item.user.encode('utf-8'))
            c_time = str(proc_item.created.time)
            c_date = str(proc_item.created.date)
            process = [pid, ppid, path, name, user, c_date, c_time]
            if regex:
                tmp_str = ' '.join(process)
                if re.search(regex, tmp_str):
                    process_list.append(process)
    if (process_list > 1):
        pprint(process_list, header=['PID', 'PPID', 'Path', 'Name', 'User', 'CDate', 'CTime'])
    dsz.control.echo.On()
if (__name__ == '__main__'):
    usage = 'psg [regex]\n\t\t\t'
    try:
        main()
    except RuntimeError as ex:
        dsz.ui.Echo(('\n RuntimeError Occured: %s' % e), dsz.ERROR)