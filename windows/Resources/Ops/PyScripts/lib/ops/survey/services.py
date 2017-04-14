
from optparse import OptionParser
import dsz
import ops
import ops.survey
from datetime import datetime, timedelta
import ops.system.services
import ops.pprint

def main():
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of information to use before re-running queries', type='int')
    (options, args) = parser.parse_args()
    ops.survey.print_header('Running services')
    servs = ops.system.services.get_running_services(maxage=timedelta(seconds=options.maxage))
    ops.survey.print_agestring(servs[0].dszobjage)
    ops.pprint.pprint(servs, dictorder=['displayname', 'servicename'], header=['Display name', 'Service name'])
if (__name__ == ops.survey.PLUGIN):
    main()
if (__name__ == '__main__'):
    main()