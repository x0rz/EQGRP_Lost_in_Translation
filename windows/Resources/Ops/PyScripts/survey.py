
from __future__ import print_function
import json
import os
import sys
from ops.parseargs import ArgumentParser
import dsz
import ops, ops.env, ops.survey, ops.cmd
import ops.survey.engines
import ops.override.commands
from ops.survey.engine.bugcatcher import bugcatcher, wasCaught, userQuitScript

def execute(config, sections=None, quiet=False):
    if (not os.path.exists(config)):
        raise RuntimeError, ('%s not found.' % config)
    if (sections is None):
        sections = ops.survey.DEFAULT_SECTIONS
    ops.env.set('OPS_SIMPLE', False)
    ops.survey.setupEnv()
    success = True
    try:
        for i in sections:
            bugcatcher((lambda : ops.survey.engines.run(fullpath=config, sections=[i])), bug_critical=True)
    except Exception as e:
        if wasCaught(e):
            success = False
        elif userQuitScript(e):
            ops.error('User quit script.')
            success = False
        else:
            raise 
    print()
    ops.env.set('OPS_SIMPLE', True)
    if (not quiet):
        ops.info('Commands currently running in the background:')
        ops.override.commands.main()
    if (not success):
        sys.exit((-1))

def main():
    parser = ArgumentParser(prog='survey')
    actiongrp = parser.add_mutually_exclusive_group(required=True)
    actiongrp.add_argument('--run', dest='run', const=ops.survey.DEFAULT_CONFIG, nargs='?', metavar='SURVEY', help='Run specified survey. Uses default if none specified. (%(const)s)')
    actiongrp.add_argument('--modify', dest='modify', action='store_true', default=False, help='Manipulate the settings for default survey.')
    parser.add_argument('--sections', dest='sections', default=ops.survey.DEFAULT_SECTIONS, metavar='SECTION', nargs='+', help='Sections for --run or --override.')
    modgrp = parser.add_argument_group(title='--modify options', description='These options are only used with the --modify option.')
    modgrp.add_argument('--override', dest='override', help='Change the default survey file for all targets.')
    modgrp.add_argument('--exclude', dest='exclude', nargs='+', metavar='GROUP', help='Adds the specified groups to the list of tasks to exclude when running survey configurations.')
    modgrp.add_argument('--include', dest='include', nargs='+', metavar='GROUP', help='Removes the specified groups from the list of tasks to exclude when running survey configurations.')
    modgrp.add_argument('--exclusions', dest='printex', action='store_true', default=False, help='Print out a list of excluded survey groups.')
    parser.add_argument('--quiet', dest='quiet', action='store_true', default=False, help='Suppress some framework messages, including the running commands list at the end.')
    options = parser.parse_args()
    if ((not options.modify) and ((options.override is not None) or (options.exclude is not None) or (options.include is not None) or options.printex)):
        parser.error('-modify is required for these options')
    if options.modify:
        if options.override:
            ops.survey.override(options.override, options.sections)
        if options.exclude:
            if ops.survey.exclude(options.exclude):
                ops.info(('%s added to exclusion list.' % options.exclude))
                ops.survey.print_exclusion_list()
            else:
                ops.info(('%s already in exclusion list.' % options.exclude))
        if options.include:
            if ops.survey.include(options.include):
                ops.info(('%s removed from exclusion list.' % options.include))
                ops.survey.print_exclusion_list()
            else:
                ops.info(('%s not in exclusion list.' % options.include))
        if options.printex:
            ops.survey.print_exclusion_list()
    else:
        execute(options.run, options.sections, options.quiet)
if (__name__ == '__main__'):
    main()