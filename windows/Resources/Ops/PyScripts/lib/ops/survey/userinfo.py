
import dsz
import ops, ops.survey
import ops.security.principals
import ops.project
import ops.survey
import datetime
from ops.pprint import pprint
from optparse import OptionParser
import traceback

def main():
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of information to use before re-running commands for this module', type='int')
    (options, args) = parser.parse_args()
    maxage = datetime.timedelta(seconds=options.maxage)
    ops.survey.print_header('User and group queries.')
    ops.survey.print_header('Users')
    lusers = ops.security.principals.get_users_local(maxage=datetime.timedelta(seconds=options.maxage))
    ops.survey.print_agestring(lusers.dszobjage)
    pprint(lusers.user, dictorder=['userid', 'name', 'comment', 'privilege', 'usershell', 'passwordlastchanged', 'passwordexpired'], header=['UID', 'Username', 'Comment', 'Privilege', 'Shell', 'Password changed', 'Password expired'])
    ops.survey.print_header('Local groups')
    lgroups = ops.security.principals.get_groups_local(maxage=datetime.timedelta(seconds=options.maxage))
    ops.survey.print_agestring(lgroups.dszobjage)
    pprint(lgroups.group, dictorder=['group', 'comment'], header=['Group', 'Comment'])
    ops.survey.print_header('Network groups')
    ngroups = ops.security.principals.get_groups_network(maxage=datetime.timedelta(seconds=options.maxage))
    ops.survey.print_agestring(ngroups.dszobjage)
    pprint(ngroups.group, dictorder=['group', 'comment'], header=['Group', 'Comment'])
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()