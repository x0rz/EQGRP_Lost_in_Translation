
import runpy
import sys
import dsz
import ops
import ops.survey
import util
from ops.survey.engine.bugcatcher import bugcatcher

def plugin_launcher(module, name=None, prompt=True, bg=False, resource=None, pyscripts=False, run_name=ops.survey.PLUGIN, args=None, marker=None, nobugs=False):
    if (prompt and (not dsz.ui.Prompt((('Do you want to run "%s"?' % name) if name else module)))):
        return (None, None)
    if bg:
        control_flags = dsz.control.Method()
        dsz.control.echo.Off()
        cmd = ('--module ' + module)
        if name:
            cmd += (' --name "%s"' % name)
        if marker:
            cmd += (' --marker "%s"' % marker)
        if resource:
            cmd += (' --resource "%s"' % resource)
        if pyscripts:
            cmd += ' --pyscripts'
        if (run_name != ops.survey.PLUGIN):
            cmd += (' --run_name "%s"' % run_name)
        if args:
            cmd += (' - ' + args)
        cmd = ('background python survey/launcher.py -project Ops -args "%s"' % cmd.replace('"', '\\"'))
        (ret, cmdid) = dsz.cmd.RunEx(cmd)
        if ret:
            ops.info(('%s started in the background as command ID %d.' % ((name if name else module), cmdid)))
        del control_flags
        return (ret, cmdid)
    saved_argv = sys.argv
    if args:
        sys.argv = util.make_sys_argv(module, args)
    else:
        sys.argv = [module]
    try:
        (success, ret) = bugcatcher((lambda : runpy.run_module(module, run_name=run_name, alter_sys=True)), bug_critical=nobugs)
    finally:
        sys.argv = saved_argv
    return (success, ret)