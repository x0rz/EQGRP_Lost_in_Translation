
import optparse
import os
import sys
import ops
import ops.survey
import ops.survey.engine.launcher
if (__name__ == '__main__'):
    parser = optparse.OptionParser()
    parser.add_option('--module', dest='module', help='Module to run.')
    parser.add_option('--name', dest='name', help='Module name for friendly printing.')
    parser.add_option('--marker', dest='marker', help='Marker identifier for marking completion/errors.')
    parser.add_option('--resource', dest='resource', help='Resource library to search in; only necessary if the module exists outside of the default import paths.')
    parser.add_option('--pyscripts', dest='pyscripts', default=False, action='store_true', help='Module import path is relative to the PyScripts folder, instead of PyScripts/Lib.')
    parser.add_option('--run_name', dest='run_name', default=ops.survey.PLUGIN, help='__name__ of module during run.')
    dash = (-1)
    for i in range(len(sys.argv)):
        if (sys.argv[i] == '-'):
            dash = i
            break
    args = ''
    if (dash > (-1)):
        args = sys.argv[dash:]
        sys.argv = sys.argv[0:dash]
    (options, extraneous) = parser.parse_args()
    if extraneous:
        ops.survey.error(options.marker)
        parser.error('Not all arguments converted to anything useful.')
    if (options.module is None):
        parser.error('Need a module to event attempt to be useful.')
    if options.resource:
        path = os.path.join(ops.RESDIR, options.resource, 'PyScripts')
        if (not options.pyscripts):
            path = os.path.join(path, 'Lib')
        if (path not in sys.path):
            sys.path.append(path)
    (success, ret) = ops.survey.engine.launcher.plugin_launcher(module=options.module, prompt=False, bg=False, name=options.name, marker=options.marker, run_name=options.run_name, args=args, nobugs=True)
    if (not success):
        ops.survey.error(options.marker)
        ops.error(('Encountered errors executing %s' % options.module))
        sys.exit((-1))