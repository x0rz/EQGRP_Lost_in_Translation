
import dsz, dsz.control, dsz.cmd, dsz.lp
import sys, random, time
from math import floor
import ops.data
from ops.pprint import pprint

def main(arguments):
    params = dsz.lp.cmdline.ParseCommandLine(sys.argv, 'processconnections.txt')
    searchpid = None
    if params.has_key('pid'):
        searchpid = int(params['pid'][0])
    dsz.control.echo.Off()
    cmd = 'processes -list'
    (succ, proccmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    procobject = None
    try:
        procobject = ops.data.getDszObject(cmdid=proccmdid, cmdname='processes')
    except:
        dsz.ui.Echo('There was an issue with the ops.data.getDszObject.', dsz.ERROR)
        return 0
    proclist = {}
    for process in procobject.initialprocesslistitem.processitem:
        if (searchpid is None):
            proclist[process.id] = {'name': process.name, 'path': process.path, 'user': process.user}
        elif (searchpid == process.id):
            proclist[process.id] = {'name': process.name, 'path': process.path, 'user': process.user}
            break
        else:
            continue
    if (not (len(proclist) > 0)):
        dsz.ui.Echo('Could not find any processes.', dsz.ERROR)
        return 0
    dsz.control.echo.Off()
    cmd = 'netconnections -list'
    (succ, netccmdid) = dsz.cmd.RunEx(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    netconobject = None
    try:
        netconobject = ops.data.getDszObject(cmdid=netccmdid, cmdname='netconnections')
    except:
        dsz.ui.Echo('There was an issue with the ops.data.getDszObject.', dsz.ERROR)
        return 0
    connectionlist = []
    for connection in netconobject.initialconnectionlistitem.connectionitem:
        if ((searchpid is not None) and (not (searchpid == connection.pid))):
            continue
        try:
            thisproc = proclist[connection.pid]
        except:
            thisproc = {'path': None, 'name': ('***PID NOT FOUND (PROCESSES CMDID: %s)***' % proccmdid), 'user': None}
        path = ''
        remote = ''
        if ((thisproc['path'] is not None) and (not (thisproc['path'] == ''))):
            path = ('%s\\%s' % (thisproc['path'], thisproc['name']))
        else:
            path = ('%s' % thisproc['name'])
        if (connection.remote.address is not None):
            remote = ('%s:%s' % (connection.remote.address, connection.remote.port))
        connectionlist.append({'state': connection.state, 'type': connection.type, 'pid': connection.pid, 'local': ('%s:%s' % (connection.local.address, connection.local.port)), 'remote': remote, 'path': path, 'user': thisproc['user']})
    if (not (len(connectionlist) > 0)):
        dsz.ui.Echo('Could not find any netconnections.', dsz.ERROR)
        return 0
    pprint(connectionlist, ['TYPE', 'PID', 'LOCAL', 'REMOTE', 'STATE', 'PATH', 'USER'], ['type', 'pid', 'local', 'remote', 'state', 'path', 'user'])
if (__name__ == '__main__'):
    try:
        main(sys.argv[1:])
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)