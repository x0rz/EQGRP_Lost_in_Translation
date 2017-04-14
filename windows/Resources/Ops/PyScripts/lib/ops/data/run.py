
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz

class RunCommandData(DszCommandObject, ):

    def __init__(self, cmdid=None, cmdname='run', debug=False, **kwargs):
        DszCommandObject.__init__(self, cmdid, cmdname, debug)
        self.update(debug)

    def _getAllOutput(self):
        retval = ''
        for outputline in self.processoutput:
            retval = (retval + outputline.output)
        return retval
    all_output = property(_getAllOutput)
if ('run' not in cmd_definitions):
    dszprocessstarted = OpsClass('processstarted', {'id': OpsField('id', dsz.TYPE_INT)}, DszObject)
    dszprocessoutput = OpsClass('processoutput', {'output': OpsField('output', dsz.TYPE_STRING)}, DszObject, single=False)
    dszprocessstatus = OpsClass('processstatus', {'status': OpsField('status', dsz.TYPE_INT)}, DszObject)
    runcommand = OpsClass('run', {'processstarted': dszprocessstarted, 'processoutput': dszprocessoutput, 'processstatus': dszprocessstatus}, RunCommandData)
    cmd_definitions['run'] = runcommand