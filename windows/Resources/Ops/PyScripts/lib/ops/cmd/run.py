
import ops.cmd
import ops
import ops.env
import ops.cmd.safetychecks
from ops.cmd import getBoolOption, setBoolOption, getValueOption, setListOption, setStringOption
OpsCommandException = ops.cmd.OpsCommandException
VALID_OPTIONS = ['command', 'redirect', 'noinput', 'wait', 'input', 'output', 'directory', 'allowdsz', 'background']

class RunCommand(ops.cmd.DszCommand, ):

    def __init__(self, plugin='run', command=None, **optdict):
        ops.cmd.DszCommand.__init__(self, plugin, **optdict)
        self.command = command

    def validateInput(self):
        for opt in self.optdict:
            if (opt not in VALID_OPTIONS):
                return False
            if (opt == 'command'):
                cmdstr = self.optdict['command']
                cmdstr = cmdstr.strip()
                if (cmdstr[0] != '"'):
                    cmdstr = ('"' + cmdstr)
                if (cmdstr[(-1)] != '"'):
                    cmdstr += '"'
                if (cmdstr[(-2)] == '"'):
                    cmdstr = (cmdstr[:(-1)] + ' "')
                lastquote = cmdstr.find('"', 1)
                while (lastquote < (len(cmdstr) - 1)):
                    if (cmdstr[(lastquote - 1)] != '\\'):
                        cmdstr = ((cmdstr[:lastquote] + '\\') + cmdstr[lastquote:])
                    lastquote = cmdstr.find('"', (lastquote + 1))
                self.optdict['command'] = cmdstr
        return True
    noinput = property((lambda x: getBoolOption(x, 'noinput')), (lambda x, y: setBoolOption(x, y, 'noinput')))
    wait = property((lambda x: getBoolOption(x, 'wait')), (lambda x, y: setBoolOption(x, y, 'wait')))
    redirect = property((lambda x: getBoolOption(x, 'redirect')), (lambda x, y: setBoolOption(x, y, 'redirect')))
    allowdsz = property((lambda x: getBoolOption(x, 'allowdsz')), (lambda x, y: setBoolOption(x, y, 'allowdsz')))
    background = property((lambda x: getBoolOption(x, 'background')), (lambda x, y: setBoolOption(x, y, 'background')))
    input = property((lambda x: getValueOption(x, 'input')), (lambda x, y: setListOption(x, y, 'input', ['ascii', 'oem', 'unicode', 'utf8'])))
    output = property((lambda x: getValueOption(x, 'output')), (lambda x, y: setListOption(x, y, 'output', ['ascii', 'auto', 'oem', 'unicode', 'utf8'])))
    command = property((lambda x: getValueOption(x, 'command')), (lambda x, y: setStringOption(x, y, 'command')))
    directory = property((lambda x: getValueOption(x, 'directory')), (lambda x, y: setStringOption(x, y, 'directory')))
ops.cmd.command_classes['run'] = RunCommand
ops.cmd.aliasoptions['run'] = VALID_OPTIONS