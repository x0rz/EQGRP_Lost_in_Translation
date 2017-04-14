
from __future__ import division
import dsz
import ops, ops.cmd, ops.db
import ops.project
import ops.survey
import datetime
from optparse import OptionParser

def main():
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of information to use before re-running commands for this module', type='int')
    (options, args) = parser.parse_args()
    ops.survey.print_header('Memory usage information')
    mem_cmd = ops.cmd.getDszCommand('memory')
    try:
        mem_data = ops.project.generic_cache_get(mem_cmd, cache_tag='MEMORY_USAGE_TAG', maxage=datetime.timedelta(seconds=options.maxage))
    except ops.cmd.OpsCommandException as ex:
        ops.error(ex.message)
        return
    avail = (mem_data.memoryitem.physicalavail // (1024 * 1024))
    total = (mem_data.memoryitem.physicaltotal // (1024 * 1024))
    load = mem_data.memoryitem.physicalload
    ops.survey.print_agestring(mem_data.dszobjage)
    code = dsz.DEFAULT
    if (load > 90):
        code = dsz.ERROR
    elif (load > 50):
        code = dsz.WARNING
    dsz.ui.Echo(('Memory Load       : %d%%' % load), code)
    dsz.ui.Echo(('Physical Available: %d M' % avail))
    dsz.ui.Echo(('Physical Total    : %d M' % total))
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()