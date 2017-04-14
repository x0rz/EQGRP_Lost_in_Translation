
import ops
import ops.cmd
import ops.data
import sys
import dsz
from optparse import OptionParser
if (__name__ == '__main__'):
    parser = OptionParser()
    parser.add_option('-t', '--tag', action='store', type='string', default='', dest='tag', help='Cache-tag to save this under')
    parser.add_option('-s', '--save-to-target', action='store_true', default=False, dest='savetotarget', help='Save this to target.db in addition to voldb')
    parser.add_option('-i', '--interval', action='store', default=5, type='int', dest='interval', help='Update interval (in seconds)')
    parser.add_option('-o', '--override', action='store_true', default=False, dest='override', help='Override the safety check')
    parser.add_option('-g', '--guimonitor', action='store_true', default=False, dest='guimonitor', help='Send to the DSZ monitor')
    (options, args) = parser.parse_args()
    comstr = ''.join(args)
    cmd = ops.cmd.getDszCommand(comstr, dszquiet=True, norecord=False)
    cmd.dszmonitor = options.guimonitor
    (safe, safetymsg) = cmd.safetyCheck()
    if (not safe):
        ops.error('Command safety check failed!')
        ops.error(('Failure: %s' % safetymsg))
        if options.override:
            ops.warn('Someone chose to override this safety check, so this monitor will still be run.  I hope they knew what they were doing')
        else:
            sys.exit((-1))
    mondata = cmd.execute()
    voldb = ops.db.get_voldb()
    targetID = ops.project.getTargetID()
    if options.savetotarget:
        tdb = ops.db.get_tdb()
    if (mondata is not None):
        vol_cache_id = voldb.save_ops_object(mondata, tag=options.tag, targetID=targetID)
        if options.savetotarget:
            tdb_cache_id = tdb.save_ops_object(mondata, tag=options.tag)
        while mondata.commandmetadata.isrunning:
            try:
                dsz.Sleep((options.interval * 1000))
                mondata.update()
                voldb.save_ops_object(mondata, cache_id=vol_cache_id, tag=options.tag, targetID=targetID)
                if options.savetotarget:
                    tdb.save_ops_object(mondata, cache_id=tdb_cache_id, tag=options.tag)
            except KeyboardInterrupt:
                ops.error('User killed channel!')
                sys.exit((-1))
        mondata.update()
        voldb.save_ops_object(mondata, cache_id=vol_cache_id, tag=options.tag)
        tdb.save_ops_object(mondata, cache_id=tdb_cache_id, tag=options.tag)
        ops.info('Updated and saved')