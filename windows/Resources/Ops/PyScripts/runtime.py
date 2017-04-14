
import datetime
import time
import sys
import dsz
import ops

def main():
    if (len(sys.argv) < 2):
        return ops.error('You need to supply a command to run.')
    cmd = ''
    for i in sys.argv[1:]:
        cmd += (i + ' ')
    ops.info(('Timing the run time of "%s" (Note: no preloading occurs by the timer)' % cmd))
    start = time.clock()
    if (not dsz.cmd.Run(cmd)):
        ops.warn('Command did not execute correctly. Your run time may be useless.')
    end = time.clock()
    ops.info(('Run time: %s' % datetime.timedelta(seconds=int((end - start)))))
if (__name__ == '__main__'):
    main()