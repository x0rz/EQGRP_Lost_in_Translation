
import datetime
from optparse import OptionParser
import ops
import ops.cmd
import ops.db
import ops.survey
import ops.processes.processlist
from ops.pprint import pprint
import dsz
import dsz.ui

def main():
    parser = OptionParser()
    parser.add_option('--start-monitor', dest='startmonitor', action='store_true', default=False, help='Start the process monitor in addition to getting a process list.')
    parser.add_option('--full-list', dest='fulllist', action='store_true', default=False, help='Do a full process list (no -minimal).')
    (options, args) = parser.parse_args()
    proc_cmd = ops.cmd.getDszCommand('processes -list')
    (result, messages) = proc_cmd.safetyCheck()
    minimal_flag = (not result)
    if options.fulllist:
        ops.survey.print_header('Process list')
        cachelist = ops.processes.processlist.get_processlist(minimal=minimal_flag, maxage=datetime.timedelta.max)
        curlist = ops.processes.processlist.get_processlist(minimal=minimal_flag, maxage=datetime.timedelta(seconds=30))
        ops.survey.print_agestring(curlist[0].dszobjage)
        try:
            if (cachelist.cache_timestamp != curlist.cache_timestamp):
                do_diff = True
        except:
            pass
        proctree = ops.processes.processlist.build_process_tree(curlist)
        displays = treecurse(proctree, 0)
        if (len(displays) != len(curlist)):
            ops.warn('The below tree is not a tree!  There must be a loop in the process tree!  Falling back to non-tree display')
            displays = map((lambda x: prettyproc(x, 0)), curlist)
        codes = list()
        for displayproc in displays:
            proc = displayproc['procobj']
            code = dsz.DEFAULT
            if (proc.proctype == 'MALICIOUS_SOFTWARE'):
                code = dsz.ERROR
            elif (proc.proctype == 'SECURITY_PRODUCT'):
                code = dsz.WARNING
            elif (proc.proctype == 'SAFE'):
                code = dsz.GOOD
            elif (proc.friendlyname == ''):
                code = dsz.WARNING
            codes.append(code)
        fullpathheader = 'Full Path'
        if minimal_flag:
            fullpathheader = 'Image Name'
        pprint(displays, header=['PID', 'PPID', fullpathheader, 'User', 'Comment'], dictorder=['id', 'parentid', 'fullpath', 'user', 'friendlyname'], echocodes=codes)
    if options.startmonitor:
        ops.processes.processlist.start_monitor()

def prettyproc(proc, depth):
    retval = dict()
    for key in ['id', 'parentid', 'fullpath', 'name', 'user', 'friendlyname', 'proctype']:
        exec ('retval[key] = proc.%s' % key)
    retval['procobj'] = proc
    retval['fullpath'] = ('%s%s' % (('---' * depth), retval['fullpath']))
    return retval

def treecurse(proctree, depth):
    retval = list()
    for rootproc in proctree:
        retval.append(prettyproc(rootproc[0], depth))
        retval.extend(treecurse(rootproc[1], (depth + 1)))
    return retval
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()