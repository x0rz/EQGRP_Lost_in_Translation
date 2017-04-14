
from __future__ import print_function
import dsz
import ops, ops.survey
import ops.cmd
import ops.system.registry
import time
from datetime import timedelta
from optparse import OptionParser
import ops.system.systemversion
INSTALL_DATE_TAG = 'OS_INSTALL_DATE_TAG'
OS_LANGUAGE_TAG = 'OS_LANGUAGE_TAG'
SYSTEMVERSION_TAG = 'OS_VERSION_TAG'

def main():
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of information to use before re-running commands for this module', type='int')
    (options, args) = parser.parse_args()
    ops.survey.print_header('OS information')
    lang_data = ops.system.systemversion.get_os_language(maxage=timedelta(seconds=options.maxage)).languages
    sysver_data = ops.system.systemversion.get_os_version(maxage=timedelta(seconds=options.maxage)).versioninfo
    install_date = ops.system.systemversion.get_os_install_date(maxage=timedelta(seconds=options.maxage))
    ops.survey.print_agestring(lang_data.dszobjage)
    print()
    dsz.ui.Echo(('OS installed on %s' % install_date), dsz.GOOD)
    print('- System language settings')
    print(('  Locale:    %s' % lang_data.localelanguage.english))
    print(('  Installed: %s' % lang_data.installedlanguage.english))
    print(('  UI:        %s' % lang_data.uilanguage.english))
    print(('  OS:        %s' % ', '.join(map((lambda x: x.english), lang_data.oslanguages.oslanguage))))
    print('- System version information')
    print(('  Version:   %d.%d.%d.%d Build %d %s %s %s' % (sysver_data.major, sysver_data.minor, sysver_data.revisionmajor, sysver_data.revisionminor, sysver_data.build, sysver_data.platform, sysver_data.arch, sysver_data.extrainfo)))
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()