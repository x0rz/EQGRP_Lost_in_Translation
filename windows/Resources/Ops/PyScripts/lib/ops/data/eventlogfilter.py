
import ops.data
import ops.data.eventlogquery
if ('eventlogfilter' not in ops.data.cmd_definitions):
    ops.data.cmd_definitions['eventlogfilter'] = ops.data.cmd_definitions['eventlogquery']