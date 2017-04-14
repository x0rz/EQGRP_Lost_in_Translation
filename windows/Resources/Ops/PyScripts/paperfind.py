
import datetime
import ntpath
import sys
import ops, ops.system.handles
from ops.parseargs import ArgumentParser, int10or16
from ops.pprint import pprint
from ops.timehelper import delta

def main():
    parser = ArgumentParser(prog='paperfind', description='\nProvides grep-like functionality for the \'handles\' command.\n\nRelative paths will (probably) never match. Use absolute or partial\npaths as though you are grepping. For full featured pattern matching,\nconsider the --regex option.\n\nIf the pattern you\'re searching for starts with a "-" character, place\na "-" by itself before beginning the pattern.\n\n e.g. %(prog)s -any - -filethatstartswithadash\n  or  %(prog)s - -filethatstartswithadash -any\n')
    parser.add_argument('pattern', help='Pattern or regular expression.')
    parser.add_argument('--regex', dest='regex', action='store_true', help='Treat the input pattern as a user-supplied regular expression instead of a simple string pattern.')
    parser.add_argument('--any', dest='any', action='store_true', default=False, help='Search all handle types instead of only file handles.')
    parser.add_argument('--data', dest='data_age', metavar='AGE', type=delta, default=datetime.timedelta(minutes=10), help='How old cached data can be before re-querying target. Use #d#h#m#s format. (Default 10m if unspecified).')
    handles_group = parser.add_argument_group(title='handles', description='Options that control how the handles command is run.')
    handles_group.add_argument('--id', dest='id', type=int10or16, help='Limit returned handle search to a particular process ID.')
    handles_group.add_argument('--all', dest='all', action='store_true', default=False, help='Search all available handle information. (Not recommended with this script; provides no benefit)')
    handles_group.add_argument('--memory', dest='memory', type=int10or16, help='Number of bytes to use for open handle list (defaults to handles default).')
    options = parser.parse_args()
    if options.regex:
        ops.info(('Searching using regex: %s' % options.pattern))
    else:
        ops.info(('Searching for "%s"...' % options.pattern))
    found = ops.system.handles.grep_handles(pattern=ntpath.normpath(options.pattern), id=options.id, all=options.all, memory=options.memory, regex=options.regex, any=options.any, maxage=options.data_age)
    if (int is type(found)):
        ops.error(('Error running handles command. Check logs for command ID %d.' % found))
        sys.exit((-1))
    elif (found is None):
        ops.error('Error running handles; command may not have been attempted.')
        sys.exit((-1))
    elif (not found):
        ops.warn('No matches.')
        sys.exit((-1))
    elif options.any:
        pprint(found, header=['PID', 'Handle', 'Type', 'Full Path'], dictorder=['process', 'handle', 'type', 'name'])
    else:
        pprint(found, header=['PID', 'Handle', 'Full Path'], dictorder=['process', 'handle', 'name'])
if (__name__ == '__main__'):
    main()