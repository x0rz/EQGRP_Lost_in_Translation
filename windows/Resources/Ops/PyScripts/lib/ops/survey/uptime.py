
from __future__ import print_function
import dsz
import ops
import ops.system
import ops.survey

def main():
    ops.survey.print_header('Uptime')
    uptime = ops.system.get_uptime()
    if (uptime is None):
        dsz.Sleep(5000)
        uptime = ops.system.get_uptime()
    if (uptime is None):
        ops.error('Could not properly find process list to calculate uptime, you might have to do the math on your own')
        return
    print(('Uptime: %d days, %d:%02d:%02d' % (uptime.days, (uptime.seconds / 3600), ((uptime.seconds / 60) % 60), (uptime.seconds % 60))))
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()