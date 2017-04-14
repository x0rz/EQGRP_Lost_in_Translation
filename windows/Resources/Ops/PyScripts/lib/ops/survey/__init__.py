
from __future__ import print_function
from __future__ import division
import codecs
import json
import ntpath
import os
import re
import runpy
import datetime
import sys
import traceback
from xml.etree.ElementTree import ElementTree
import dsz
import ops, ops.db, ops.env, ops.marker
import util
from ops.pprint import pprint
from util.DSZPyLogger import DSZPyLogger
PLUGIN = '__ops_survey_plugin__'
LOGFILE = 'OPS-SURVEY'
OVERRIDE = 'OPS_SURVEY_OVERRIDE'
EXCLUDE = 'OPS_SURVEY_EXCLUDE_GROUPS'
DEFAULT_CONFIG = os.path.join(ops.DATA, 'survey.xml')
DEFAULT_SECTIONS = ['pre-danger', 'danger-checks', 'informational']
DB = os.path.join(ops.LOGDIR, 'survey.db')
STARTED = 'STARTED'
DONE = 'DONE'
REDO = 'REDO'
ERROR = 'ERROR'
MARKER_PREFIX = 'ops::survey::marker::%s'
EXCLUDED_GROUPS = (json.loads(ops.env.get(EXCLUDE)) if (ops.env.get(EXCLUDE) is not None) else [])
FLAGS_LIST = os.path.join(ops.RESDIR, 'Ops', 'Data', 'surveyflags.json')

def __initdb():
    pass

def mark(name, comment):
    if ((name is None) or (name == 'None')):
        return None
    name = (MARKER_PREFIX % name)
    __initdb()
    ops.marker.set_volatile(name, comment)

def complete(value):
    mark(value, DONE)

def start(value):
    mark(value, STARTED)

def redo(value):
    mark(value, REDO)

def error(value):
    mark(value, ERROR)

def state(name):
    if (name is None):
        return None
    __initdb()
    name = ('ops::survey::marker::%s' % name)
    r = ops.marker.get_volatile(name)
    return (r['extra'], r['last_date'])

def isDone(value, age):
    s = state(value)
    if (s is None):
        return False
    if (s == (DONE, None)):
        return True
    elif ((s[0] == DONE) and (age is not None)):
        return ((datetime.today() - s[1]) < age)
    else:
        return False

def isStarted(value):
    s = state(value)
    if (s is None):
        return False
    elif (s == (STARTED, None)):
        return True
    else:
        return False

def isError(value):
    s = state(value)
    if (s is None):
        return False
    elif (s[0] == ERROR):
        return True
    else:
        return False

def isRedo(value):
    s = state(value)
    if (s is None):
        return False
    elif (s[0] == REDO):
        return True
    else:
        return False

def locate_files(file, subdir=None):
    if (subdir is None):
        subdir = '.'
    resdirs = util.listdir(ops.RESDIR, includeFiles=False)
    files = []
    for resdir in resdirs:
        if ((resdir.lower() == 'ops') or (resdir.lower() == 'dsz')):
            continue
        fullpath = os.path.normpath(os.path.join(ops.RESDIR, resdir, subdir, file))
        if os.path.exists(fullpath):
            files.append((resdir, fullpath))
    files.sort(cmp=(lambda x, y: cmp(x[0].lower(), y[0].lower())))
    return files

def flags():
    with open(FLAGS_LIST, 'r') as input:
        return json.load(input)

def setupEnv(reinitialize=False):
    dsz.env.Set('OPS_TIME', ops.timestamp())
    dsz.env.Set('OPS_DATE', ops.datestamp())
    for i in flags():
        if ((not dsz.env.Check(i)) or reinitialize):
            ops.env.set(i, False)
    dszflags = dsz.control.Method()
    dsz.control.echo.Off()
    if (not dsz.cmd.Run('systempaths', dsz.RUN_FLAG_RECORD)):
        ops.error("Could not get system paths. I'm confused. This means your OPS_TEMPDIR, OPS_WINDOWSDIR, and OPS_SYSTEMDIR environment variables are not set.")
    else:
        dsz.env.Set('OPS_TEMPDIR', ntpath.normpath(dsz.cmd.data.Get('TempDir::Location', dsz.TYPE_STRING)[0]))
        dsz.env.Set('OPS_WINDOWSDIR', ntpath.normpath(dsz.cmd.data.Get('WindowsDir::Location', dsz.TYPE_STRING)[0]))
        dsz.env.Set('OPS_SYSTEMDIR', ntpath.normpath(dsz.cmd.data.Get('SystemDir::Location', dsz.TYPE_STRING)[0]))
    del dszflags

def override(path, sections=DEFAULT_SECTIONS):
    realpath = os.path.join(ops.RESDIR, os.path.normpath(path))
    if (not os.path.exists(realpath)):
        ops.error(('"%s" does not exist; override not enabled.' % realpath))
        return False
    before = ops.env.get(ops.survey.OVERRIDE, addr='')
    if sections:
        new = ('%s:%s' % (path, sections))
    else:
        new = path
    ops.env.set(ops.survey.OVERRIDE, new, addr='')
    ops.info('Override set.')
    print(('Before: %s' % before))
    print(('After : %s' % new))
    return True

def exclude(group):
    assert (group is not None)
    current = ops.env.get(ops.survey.EXCLUDE, addr='')
    if (current is None):
        current = []
    else:
        current = json.loads(current)
    if (str is type(group)):
        group = codecs.utf_8_decode(group)[0]
    if (group not in current):
        current.append(group)
        ops.env.set(ops.survey.EXCLUDE, json.dumps(current, ensure_ascii=False), addr='')
        EXCLUDED_GROUPS = current
        return True
    else:
        return False

def include(group):
    assert (group is not None)
    current = ops.env.get(ops.survey.EXCLUDE, addr='')
    if (current is None):
        current = []
    else:
        current = json.loads(current)
    if (str is type(group)):
        group = codecs.utf_8_decode(group)[0]
    if (group in current):
        current.remove(group)
        ops.env.set(ops.survey.EXCLUDE, json.dumps(current, ensure_ascii=False), addr='')
        EXCLUDED_GROUPS = current
        return True
    else:
        return False

def print_exclusion_list():
    current = ops.env.get(ops.survey.EXCLUDE, addr='')
    if (current is not None):
        current = json.loads(current)
        if (len(current[0]) == 0):
            disp = None
        else:
            disp = []
            for i in current:
                disp.append([i])
    if (current is not None):
        pprint(disp, header=['Survey Exclusions'])
    else:
        print('No exclusions.')

def print_header(header):
    print()
    padding = (72 - (len(header) // 2))
    ops.info(((((('=' * ((padding - len(ops.targetdatetimestamp())) - 3)) + ' ') + header) + ' ') + ('=' * padding)))

def print_sub_header(header):
    padding = (72 - (len(header) // 2))
    print()
    dsz.ui.Echo(((((('-' * padding) + ' ') + header) + ' ') + ('-' * padding)), dsz.GOOD)

def print_agestring(data_age):
    if (data_age > datetime.timedelta(seconds=5)):
        ops.warn(('Data age: %s (from local cache, re-run manually if you need to)' % ops.agestring(data_age)))
    else:
        ops.warn(('Data age: %s - data is fresh' % ops.agestring(data_age)))