
import fnmatch
import logging as log
import os
import sys
import traceback
import win32file
import win32con
from optparse import OptionParser
import host_list
import dsz_rename
import scansweep_assist
HOST_LIST_PATTERNS = {'*/Data/*arp*xml': host_list.handle_arp, '*/Data/*config*xml': host_list.handle_config, '*/Data/*netbios*xml': host_list.handle_netbios, '*/Data/*netmap*xml': host_list.handle_netmap, '*/Data/*netconnections*xml': host_list.handle_netconnections, '*/Data/*ping*xml': host_list.handle_ping}
DSZ_RENAME_PATTERNS = {'*/Data/*-get*.xml': dsz_rename.main}
SCANSWEEP_PATTERNS = {'*/Logs/scansweep_*_alert.bat': scansweep_assist.main}
PATTERN_HANDLERS = {}

def main(arguments):
    (op, args) = parse_arguments(arguments)
    if ((not op.get_files) and (not op.host_table) and (not op.scansweep)):
        log.error('You must specify at least one type of monitor to run (--get-files, --host-table, --scansweep)')
        return
    if op.get_files:
        PATTERN_HANDLERS.update(DSZ_RENAME_PATTERNS)
    if op.host_table:
        PATTERN_HANDLERS.update(HOST_LIST_PATTERNS)
    if op.scansweep:
        PATTERN_HANDLERS.update(SCANSWEEP_PATTERNS)
    if (len(args) < 1):
        path = os.curdir
    else:
        path = args[0]
    abspath = os.path.abspath(path)
    log.debug(('options:   %s' % op))
    log.debug(('arguments: %s' % args))
    log.debug(('abspath:   %s' % abspath))
    if op.fresh:
        for (root, dirs, files) in os.walk(abspath):
            for name in files:
                event_handler(os.path.join(root, name), op.output_dir)
    while True:
        try:
            win32watcher(abspath, op.output_dir)
        except KeyboardInterrupt:
            print 'got a keyboard interrupt... continuing...'
            continue

def parse_arguments(arguments):
    usage = '%prog [options] path \n    \n    This program monitors file system changes on a given path and \n    fires plug-ins based on matching changed files against certain file masks. \n    '
    parser = OptionParser(usage=usage)
    parser.add_option('-l', '--log-level', dest='log_level', default='info', help='Logging level {debug, info, warning, error, critical}')
    parser.add_option('-f', '--fresh', dest='fresh', action='store_true', default=False, help='Run all plugins against a fresh listing of the files')
    parser.add_option('-g', '--get-files', action='store_true', default=False, help='Run the automatic get_files renamer')
    parser.add_option('-t', '--host-table', action='store_true', default=False, help='Generate a table that aggregates all host information')
    parser.add_option('-s', '--scansweep', action='store_true', default=False, help='Replays any alerts that scansweep generates')
    parser.add_option('-o', '--output-dir', default='D:/', help='Where to write any output files that may be created')
    (op, args) = parser.parse_args()
    LEVELS = {'debug': log.DEBUG, 'info': log.INFO, 'warning': log.WARNING, 'error': log.ERROR, 'critical': log.CRITICAL}
    level = LEVELS.get(op.log_level, log.NOTSET)
    log.basicConfig(level=level)
    return (op, args)

def event_handler(file_changed, output_dir):
    for pattern in PATTERN_HANDLERS:
        if (not (fnmatch.fnmatch(file_changed, pattern) and os.path.exists(file_changed))):
            continue
        log.debug(('%s\n' % file_changed))
        pattern_handler = PATTERN_HANDLERS[pattern]
        try:
            pattern_handler(file_changed, output_dir)
        except:
            log.error(('Error running handler for pattern: %s' % pattern))

def win32watcher(abspath, output_dir):
    FILE_LIST_DIRECTORY = 1
    dir_handle = win32file.CreateFile(abspath, FILE_LIST_DIRECTORY, (win32con.FILE_SHARE_READ | win32con.FILE_SHARE_WRITE), None, win32con.OPEN_EXISTING, win32con.FILE_FLAG_BACKUP_SEMANTICS, None)
    events_to_watch = (((((win32con.FILE_NOTIFY_CHANGE_FILE_NAME | win32con.FILE_NOTIFY_CHANGE_DIR_NAME) | win32con.FILE_NOTIFY_CHANGE_ATTRIBUTES) | win32con.FILE_NOTIFY_CHANGE_SIZE) | win32con.FILE_NOTIFY_CHANGE_LAST_WRITE) | win32con.FILE_NOTIFY_CHANGE_SECURITY)
    while True:
        results = win32file.ReadDirectoryChangesW(dir_handle, 4096, True, events_to_watch, None, None)
        for (action, file) in results:
            full_filename = os.path.join(abspath, file)
            if (os.path.isdir(full_filename) and (action == 3)):
                continue
            event_handler(full_filename, output_dir)
if (__name__ == '__main__'):
    main(sys.argv)