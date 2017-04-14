
import dsz
import ops.data
import ops.parseargs
dsz.control.echo.Off()
dsz.ui.Background()
parser = ops.parseargs.ArgumentParser()
parser.add_argument('command_id', type=int, help='Command ID to monitor.')
args = parser.parse_args()
pr = ops.data.getDszObject(args.command_id)
lasterror = None
while True:
    dsz.script.CheckStop()
    dsz.Sleep(5000)
    pr.update()
    if (not pr.commandmetadata.isrunning):
        break
    errors = pr.commandmetadata.friendlyerrors
    if (not len(errors)):
        continue
    if ((lasterror is None) or (lasterror < errors[(-1)].timestamp)):
        lasterror = errors[(-1)].timestamp
        msg = ('packetredirect failed to send!\n Command %d: %s\n' % (pr.commandmetadata.id, pr.commandmetadata.fullcommand))
        for i in errors[(-1)]:
            if ((i.type == 'OsError') and (i.text == 'The system cannot find the file specified.')):
                msg += (" - %s Do you need '-driver', '-raw' or to toggle FLAV?" % i)
            else:
                msg += (' - %s\n' % i)
        ops.alert(msg)