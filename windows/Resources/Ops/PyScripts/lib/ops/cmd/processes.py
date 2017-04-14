
import ops.cmd
import util.ip

class ProcessesCommand(ops.cmd.DszCommand, ):

    def __init__(self, plugin='processes', list=False, monitor=False, minimal=False, ignore=None, target=None, **optdict):
        if (ignore == None):
            ignore = []
        self.list = list
        self.monitor = monitor
        self.minimal = minimal
        self.ignore = ignore
        self.target = target
        ops.cmd.DszCommand.__init__(self, plugin, **optdict)

    def _getList(self):
        return self._opt_list

    def _setList(self, list):
        assert (type(list) is bool), 'List option must be Boolean.'
        self._opt_list = list
    list = property(_getList, _setList)

    def _getMonitor(self):
        return self._opt_monitor

    def _setMonitor(self, monitor):
        assert ((type(monitor) is bool) or ((type(monitor) is int) and (monitor > 0))), 'Monitor option must be Boolean or a positive non-zero integer.'
        self._opt_monitor = monitor
    monitor = property(_getMonitor, _setMonitor)

    def _getMinimal(self):
        return self._opt_minimal

    def _setMinimal(self, minimal):
        assert (type(minimal) is bool), 'Minimal option must be Boolean.'
        self._opt_minimal = minimal
    minimal = property(_getMinimal, _setMinimal)

    def _getIgnore(self):
        return self._opt_ignore

    def _setIgnore(self, ignore):
        assert (type(ignore) is type([])), 'Ignore must be a list.'
        assert (len(ignore) <= 9), 'Ignore list cannont exceed 9 items.'
        self._opt_ignore = ignore
    ignore = property(_getIgnore, _setIgnore)

    def _getTarget(self):
        return self._opt_target

    def _setTarget(self, target):
        assert ((type(target) is str) or (type(target) is unicode) or (target is None)), 'Target must be a string representation or None to clear.'
        assert ((target is None) or util.ip.validate(target)), 'Target address must be a valid IPv4 or IPv6 address.'
        self._opt_target = target
    target = property(_getTarget, _setTarget)

    def validateInput(self):
        return (self.list ^ bool(self.monitor))

    def __str__(self):
        cmdstr = u''
        for prefix in self.prefixes:
            cmdstr += ('%s ' % prefix)
        cmdstr += (self.plugin + ' ')
        if self.list:
            cmdstr += '-list '
        if self.monitor:
            cmdstr += (('-monitor %d' % self.monitor) if (type(self.monitor) is int) else '-monitor ')
        if self.minimal:
            cmdstr += '-minimal '
        if (self.ignore and (len(self.ignore) > 0)):
            cmdstr += '-ignore '
            for i in self.ignore:
                cmdstr += (i + ' ')
        if self.target:
            cmdstr += ('-target %s ' % self.target)
        return ops.utf8(cmdstr)
ops.cmd.command_classes['processes'] = ProcessesCommand