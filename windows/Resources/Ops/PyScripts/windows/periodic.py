
import optparse
import random
import sys
from datetime import datetime
import dsz
HEADING = 'Starting the periodic command runner...\n'
COMMAND_PROMPT = 'What command would you like to run'
DEFAULT_COMMAND = 'ping localhost'
DEFAULT_PERIOD_MINUTES = '10-15'
CONFIRM_PERIOD_MSG = "Going to run the command '%s' every %s to %s seconds. Are you sure you want to do that???"
CHANGE_COMMAND_ERROR = "There was a problem running the periodic command: '%s'. Would you like to change your command?"
NEW_COMMAND_MSG = 'Type the new command to run'
SLEEPING_MSG = 'Sleeping for %s seconds...'
USAGE = "periodic [-h] [-f] [-i] [-n] [-c <count>] [-t <time>] [-p <period>] [ command to run ]\n\n--period is the time between each command run (default in minutes).\n  Time ranges (e.g. 5-25) will be randomized. Decimals are allowed.\n  You can specify the period as: 5, 5-10, 5-10m, 30s, 30-60s, 4h, 1-2h, etc.\n  \n--ignore-errors to not stop on an error from the child command, \n  i.e. when a ping fails\n  \n--foreground is useful for allowing you to see the output in your terminal\n\n--count is the maximum number of times periodic should run your command\n\n--max-runtime is the maximum amount of time the periodic script will run \n\nBy default, periodic waits for each command to finish before starting the \n  sleep timer. Use --no-wait for long running commands when you want to ensure \n  they spawn at the specified period, no matter how long each command takes. \n  Be careful when using this, you could really bog down the host or DSZ! \n\nExamples -  \n    run: periodic windows -screenshot  \n    result: take a screenshot every 10-15 minutes (the default period)\n    \n    run: periodic -p 30-120s log drives    \n    result: check for new thumbdrives plugged in every 30-120 seconds\n    \n    run: periodic -p 5 -i log ping 1.2.3.4\n    result: ping for 1.2.3.4 every 5 minutes to check if it comes up, \n            ignoring errors from the ping command\n    \n    run: periodic -p 1 log dir 'C:\\Documents and Settings\\joe\\Desktop\\*'\n    result: look for new files once per minute on Joe's desktop\n"

def __main__(arguments):
    dsz.ui.Echo(HEADING, dsz.GOOD)
    parser = optparse.OptionParser(USAGE)
    parser.disable_interspersed_args()
    parser.add_option('-p', '--period', default=DEFAULT_PERIOD_MINUTES, help='Period at which to run the command')
    parser.add_option('-n', '--no-wait', dest='wait', action='store_false', default=True, help="Don't wait for the command to finish, run each command asynchronously")
    parser.add_option('-f', '--foreground', action='store_true', default=False, help="Don't background the main periodic command, keep output on the screen")
    parser.add_option('-i', '--ignore-errors', action='store_true', default=False, help="Don't stop on an error from the child command")
    parser.add_option('-c', '--count', type='int', default=None, help='Max number of times the command should run')
    parser.add_option('-t', '--max-runtime', default=None, help='Max runtime of the periodic command')
    (options, args) = parser.parse_args(arguments)
    if (not args):
        command_string = dsz.ui.GetString(COMMAND_PROMPT, DEFAULT_COMMAND)
    else:
        command_string = ' '.join(args)
    command_string = command_string.replace("'", '"')
    (min_seconds, max_seconds) = _parse_interval_string_(options.period)
    max_runtime = None
    if options.max_runtime:
        max_runtime = _parse_interval_string_(options.max_runtime)[0]
    periodic(command_string, min_seconds, max_seconds, options.foreground, options.ignore_errors, options.wait, options.count, max_runtime)

def periodic(command_string, min_seconds, max_seconds, foreground=False, ignore_errors=False, wait=True, max_count=None, max_runtime_seconds=None):
    if (max_seconds < min_seconds):
        (min_seconds, max_seconds) = (max_seconds, min_seconds)
    if (not dsz.ui.Prompt((CONFIRM_PERIOD_MSG % (command_string, min_seconds, max_seconds)))):
        return
    if (not foreground):
        dsz.ui.Background()
    count = 1
    start_time = datetime.now()
    while True:
        if wait:
            result = dsz.cmd.Run(('foreground ' + command_string), dsz.RUN_FLAG_RECORD)
        else:
            result = dsz.cmd.Run(('background ' + command_string), dsz.RUN_FLAG_RECORD)
        if ((not ignore_errors) and (not result)):
            change_command = dsz.ui.Prompt((CHANGE_COMMAND_ERROR % command_string))
            if (not change_command):
                return (-1)
            command_string = dsz.ui.GetString(NEW_COMMAND_MSG)
            continue
        if (max_count and (count >= max_count)):
            print ''
            dsz.ui.Echo('Max count reached. Exiting.')
            break
        time_delta = (datetime.now() - start_time)
        if (max_runtime_seconds and (_total_seconds(time_delta) >= max_runtime_seconds)):
            print ''
            dsz.ui.Echo('Max runtime exceeded. Exiting.')
            break
        sleep_duration = random.randint(min_seconds, max_seconds)
        print ''
        dsz.ui.Echo((SLEEPING_MSG % sleep_duration), dsz.GOOD)
        dsz.Sleep((sleep_duration * 1000))
        count += 1

def _parse_interval_string_(interval, delimiter='-'):
    min_max_tuple = interval.strip().split(delimiter)
    if (len(min_max_tuple) > 1):
        max_interval = min_max_tuple[1]
    else:
        max_interval = min_max_tuple[0]
    min_interval = min_max_tuple[0]
    (min_value, min_unit) = _split_value_(min_interval)
    (max_value, max_unit) = _split_value_(max_interval)
    if ((min_unit is None) and (max_unit is not None)):
        min_unit = max_unit
    elif ((max_unit is None) and (min_unit is not None)):
        max_unit = min_unit
    min_seconds = _to_seconds_(min_value, min_unit)
    max_seconds = _to_seconds_(max_value, max_unit)
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

def _to_seconds_(value_string, unit_string):
    multiplier_map = {'s': 1, 'm': 60, 'h': (60 * 60), None: 60}
    if (unit_string not in multiplier_map.keys()):
        unit_string = 'm'
    multiplier = multiplier_map[unit_string]
    seconds = int((float(value_string) * multiplier))
    return seconds

def _total_seconds(timedelta_value):
    return ((((timedelta_value.days * 24) * 60) * 60) + timedelta_value.seconds)

def __test_parse_interval_string__():
    correct = (300, 300)
    assert (_parse_interval_string_('5') == correct)
    correct = (300, 600)
    assert (_parse_interval_string_('5-10') == correct)
    correct = (300, 600)
    assert (_parse_interval_string_('5-10m') == correct)
    correct = (30, 30)
    assert (_parse_interval_string_('30s') == correct)
    correct = (30, 60)
    assert (_parse_interval_string_('30-60s') == correct)
    correct = (14400, 14400)
    assert (_parse_interval_string_('4h') == correct)
    correct = (3600, 7200)
    assert (_parse_interval_string_('1-2h') == correct)
    correct = (30, 60)
    assert (_parse_interval_string_('30s-60s') == correct)
    correct = (30, 60)
    assert (_parse_interval_string_('30s-1m') == correct)
    correct = (1800, 5400)
    assert (_parse_interval_string_('30m-1.5h') == correct)
    correct = (90, 150)
    assert (_parse_interval_string_('1.5m-2.5m') == correct)
    correct = (30, 90)
    assert (_parse_interval_string_('30s-90') == correct)
    correct = (90, 30)
    assert (_parse_interval_string_('90s-30') == correct)
    print 'All tests passed.'
if (__name__ == '__main__'):
    try:
        __main__(sys.argv[1:])
    except RuntimeError as e:
        print ('\nCaught RuntimeError: %s' % e)