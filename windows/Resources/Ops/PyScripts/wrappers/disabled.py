
import sys
import dsz
import ops
import ops.parseargs
dsz.control.echo.Off()
parser = ops.parseargs.ArgumentParser()
parser.add_argument('command_id', type=int, help='Command ID of wrapped command.')
parser.add_argument('reason', help='Reason for command to be disabled.')
options = parser.parse_args()
if (options.reason.startswith('"') and options.reason.endswith('"')):
    options.reason = options.reason[1:(-1)]
command = dsz.cmd.data.ObjectGet('CommandMetadata', 'Name', dsz.TYPE_STRING, options.command_id)[0]
ops.error(('%s is disabled. Reason:' % command))
dsz.ui.Echo(('\t%s' % options.reason), dsz.ERROR)
sys.exit((-1))