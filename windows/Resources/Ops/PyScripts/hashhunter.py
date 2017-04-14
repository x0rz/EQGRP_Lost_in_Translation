
import ops.cmd, ops.db, ops
import os.path
import dsz
from ops.pprint import pprint
import sys
from util.DSZPyLogger import DSZPyLogger
from datetime import timedelta
import optparse
dzlogger = DSZPyLogger()
drvlog = dzlogger.getLogger('DRIVERLIST')

def main(argv=None):
    parser = optparse.OptionParser()
    parser.add_option('-a', dest='maxage', action='store', type='int', default=3600, help='The maximum age for any particular dir')
    options = parser.parse_args(argv)[0]
    maxage = options.maxage
    voldb = ops.db.get_voldb()
    conn = voldb.connection
    with conn:
        curs = conn.execute('SELECT mask,path FROM hashhunter WHERE cpaddr=?', [ops.TARGET_ADDR])
    dir_list = []
    for row in curs:
        dir_list.append([row['mask'], row['path']])
    completed = []
    for item in dir_list:
        if (item in completed):
            continue
        dircmd = ops.cmd.getDszCommand('dir -hash sha1 -max 0')
        dircmd.mask = item[0]
        dircmd.path = item[1]
        cache_tag = ('DRIVERLIST_DIRS_%s' % item[0].upper().split('.')[0])
        dirobj = ops.project.generic_cache_get(dircmd, cache_tag=cache_tag, cache_size=1, maxage=timedelta(seconds=maxage), targetID=None, use_volatile=True)
        completed.append(item)
    ops.alert(('Hashhunter completed on %s!' % ops.project.getTarget().hostname), type=dsz.GOOD, stamp=None)
    with conn:
        curs = conn.execute('DELETE FROM hashhunter WHERE cpaddr=?', [ops.TARGET_ADDR])
    return True
if (__name__ == '__main__'):
    main(sys.argv)