
import dsz
import ops
import ops.env
import ops.survey
import ops.system.registry
from ops.pprint import pprint
from optparse import OptionParser
import os.path
import datetime
import traceback
ONE_DAY = 86400

def main():
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default=ONE_DAY, help='Maximum age of scheduler information to use before re-running query commands', type='int')
    (options, args) = parser.parse_args()
    ops.survey.print_header('USB survey info')
    keylist = [('System\\CurrentControlSet\\Control\\DeviceClasses\\{53f56307-b6bf-11d0-94f2-00a0c91efb8b}', 'OPS_USB_RECENT_DEVICES_KEY', options.maxage, True), ('SYSTEM\\CurrentControlSet\\Enum\\USB', 'OPS_USB_USB_KEY', options.maxage, True), ('SYSTEM\\CurrentControlSet\\Enum\\USBSTOR', 'OPS_USB_USBSTOR_KEY', options.maxage, True)]
    results = []
    for pair in keylist:
        try:
            result = ops.system.registry.get_registrykey('L', pair[0], cache_tag=pair[1], cache_size=1, maxage=datetime.timedelta(seconds=pair[2]), dszquiet=True, dszlog=True, recursive=pair[3])
            try:
                if (result.dszobjage < datetime.timedelta(seconds=pair[2])):
                    ops.info(('%s data is only %s old, was not re-run' % (pair[0], result.dszobjage)))
                else:
                    ops.info(('Got new data for %s' % pair[0]))
            except:
                pass
            results.append(result)
        except:
            ops.warn(('%s not found' % pair[0]))
    if (results[0].key[0].name == 'System\\CurrentControlSet\\Control\\DeviceClasses\\{53f56307-b6bf-11d0-94f2-00a0c91efb8b}'):
        ops.info('Showing recent USB devices')
        for v in results[0].key[0].subkey:
            print ('[%s %s] %s' % (v.updatedate, v.updatetime, v.name))
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()