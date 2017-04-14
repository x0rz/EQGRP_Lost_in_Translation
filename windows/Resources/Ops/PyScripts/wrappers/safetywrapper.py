
import sys
import dsz
import ops
import ops.cmd
import ops.parseargs
from ops.cmd.safetychecks import doSafetyHandlers
dsz.control.echo.Off()
parser = ops.parseargs.ArgumentParser()
parser.add_argument('command_id', type=int, help='Command ID of wrapped command.')
options = parser.parse_args()
arguments = dsz.cmd.data.ObjectGet('CommandMetaData', 'Argument', dsz.TYPE_STRING, options.command_id)
(good, msgparts) = doSafetyHandlers(ops.cmd.getDszCommand(' '.join(arguments)))
if (not good):
    ops.error(('%s did not pass safety checks. %s:' % (arguments[0], ('Reasons' if (len(msgparts) > 1) else 'Reason'))))
    for msg in msgparts:
        dsz.ui.Echo(('\t%s' % msg), dsz.ERROR)
    dsz.ui.Echo('Command will *NOT* be run.', dsz.ERROR)
    sys.exit((-1))