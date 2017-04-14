
import dsz
import ops.cmd
from ops.pprint import pprint
from datetime import date
from datetime import datetime
from datetime import timedelta
import sys
import dsz.version.checks.windows
from ops.parseargs import ArgumentParser
import ops.timehelper

def getmostrecentrecordnum(eventlog='security'):
    eventcmd = ops.cmd.getDszCommand('eventlogquery', log=eventlog)
    eventobject = eventcmd.execute()
    current_recnum = eventobject.eventlog[0].mostrecentrecordnum
    return current_recnum

def processeventobj(eventobject, summary):
    record_list = []
    if (len(eventobject.record) > 0):
        last_date = eventobject.record[0].datewritten
        date_list = last_date.split('-')
        last_date = date(int(date_list[0]), int(date_list[1]), int(date_list[2]))
        for record in eventobject.record:
            rec_dict = {'number': None, 'id': None, 'datewritten': None, 'timewritten': None, 'computer': None, 'user': None, 'eventtype': None}
            rec_dict['number'] = record.number
            rec_dict['id'] = record.id
            rec_dict['datewritten'] = record.datewritten
            rec_dict['timewritten'] = record.timewritten
            rec_dict['computer'] = record.computer
            rec_dict['user'] = record.user
            rec_dict['eventtype'] = record.eventtype
            if summary:
                string_list = []
                for item in record.string:
                    string_list.append(item.value.strip().replace('\r', '').replace('\n', '').replace('\t', ''))
                rec_dict['summary'] = ';'.join(string_list)
            record_list.append(rec_dict)
    return record_list

def eventlogtime(log='Security', max=100, num=1000, id_list=None, sid=None, string_opt_list=None, startrecord=None, xpath=None, target=None, summary=False, logons=False):
    record_list = []
    color_list = []
    eventcmd = ops.cmd.getDszCommand('eventlogfilter')
    eventcmd.log = log
    eventcmd.max = max
    eventcmd.num = num
    if (id_list is not None):
        id_list = id_list.split(',')
    else:
        id_list = [None]
    if (sid is not None):
        eventcmd.sid = sid
    if (string_opt_list is not None):
        string_opt_list = string_opt_list.split(',')
    else:
        string_opt_list = [None]
    if (startrecord is not None):
        eventcmd.startrecord = startrecord
    if (xpath is not None):
        eventcmd.xpath = xpath
    if (target is not None):
        eventcmd.target = target
    if logons:
        if dsz.version.checks.windows.IsVistaOrGreater():
            id_list = ['4776', '4624', '5140', '4634', '4768', '4769', '4672']
        else:
            id_list = ['680', '540', '538', '672', '673', '576']
    for id in id_list:
        for string_opt in string_opt_list:
            eventcmd.id = None
            eventcmd.string = None
            if (id is not None):
                eventcmd.id = id
            if (string_opt is not None):
                eventcmd.string = string_opt
            eventobject = eventcmd.execute()
            record_list.extend(processeventobj(eventobject, summary))
    if (len(record_list) == 0):
        dsz.ui.Echo('No records returned', dsz.ERROR)
        return False
    record_list.sort(key=(lambda x: x['number']))
    date_list = record_list[0]['datewritten'].split('-')
    last_date = date(int(date_list[0]), int(date_list[1]), int(date_list[2]))
    for record in record_list:
        date_list = record['datewritten'].split('-')
        this_date = date(int(date_list[0]), int(date_list[1]), int(date_list[2]))
        if (this_date != last_date):
            if (last_date == (this_date - timedelta(days=1))):
                color_list.append(dsz.WARNING)
            else:
                color_list.append(dsz.ERROR)
        else:
            color_list.append(dsz.DEFAULT)
        last_date = this_date
    if (not summary):
        pprint(record_list, header=['date', 'time', 'recnum', 'id', 'computer', 'user', 'eventtype'], dictorder=['datewritten', 'timewritten', 'number', 'id', 'computer', 'user', 'eventtype'], echocodes=color_list)
    else:
        pprint(record_list, header=['date', 'time', 'recnum', 'id', 'computer', 'user', 'eventtype', 'summary'], dictorder=['datewritten', 'timewritten', 'number', 'id', 'computer', 'user', 'eventtype', 'summary'], echocodes=color_list)

def main(args):
    parser = ArgumentParser()
    group_target = parser.add_argument_group('Target', 'Options that describe the event log to query')
    group_target.add_argument('--log', action='store', dest='log', default='security', help='The event log to search. Default = Security')
    group_target.add_argument('--target', action='store', dest='target', help='Remote machine to query')
    group_limiters = parser.add_argument_group('Limiters', 'Options that limit the range over which we are searching')
    group_limiters.add_argument('--num', action='store', dest='num', default=1000, type=int, help="The number of entries to parse. A value of zero will result in all entries being parsed. Parsing will cease once the first 1000 records are found unless the 'max' keyword is used.")
    group_limiters.add_argument('--max', action='store', dest='max', default=100, type=int, help='Maximum entries returned from the target. Default=1000. A value of 0 will result in all possible entries returned. It is recommended that a value of 0 not be used due to the fact that a large database could result in an excessive number of entries being parsed and cause a slowdown in the speed and memory usage of the LP.')
    group_limiters.add_argument('--startrecord', action='store', dest='startrecord', help='Record with which to begin filtering. Default = Most recent record.')
    group_filters = parser.add_argument_group('Filters', 'Options that describe what we are looking for')
    group_filters.add_argument('--id', action='store', dest='id', help='The Event ID on which to filter. Default = No filtering.')
    group_filters.add_argument('--logons', action='store_true', dest='logons', default=False, help='Eventlogfilter for common authentication logs')
    group_filters.add_argument('--string', action='store', dest='string_opt', help='String in entry on which to filter.  Default = No filtering.')
    group_filters.add_argument('--sid', action='store', dest='sid', help='Username on which to filter.  Default = No filtering.')
    group_filters.add_argument('--xpath', action='store', dest='xpath', help='XPath expression for search.')
    group_output = parser.add_argument_group('Output', 'Options that change the output')
    group_output.add_argument('--summary', action='store_true', dest='summary', default=False, help='Display a list of the strings associated with each event record')
    group_monitor = parser.add_argument_group('Monitor', 'Options that deal with monitoring')
    group_monitor.add_argument('--monitor', action='store_true', dest='monitor', default=False, help='Execute the eventlogfilter command at a given interval and display any new results')
    group_monitor.add_argument('--interval', action='store', dest='interval', default='5m', type=ops.timehelper.get_seconds_from_age, help='Interval at which to monitor')
    options = parser.parse_args()
    last_record = 0
    newest_record = 0
    querymax = options.max
    querynum = options.num
    startrecord = options.startrecord
    while True:
        if options.monitor:
            newest_record = getmostrecentrecordnum(eventlog=options.log)
            if (not (last_record == 0)):
                querynum = (newest_record - last_record)
                startrecord = newest_record
            querymax = querynum
            if (querymax == 0):
                dsz.ui.Echo(('[%s] No new records' % ops.timestamp()), dsz.WARNING)
                dsz.Sleep((options.interval * 1000))
                continue
        dsz.ui.Echo(('=' * 80), dsz.GOOD)
        eventlogtime(log=options.log, max=querymax, num=querynum, id_list=options.id, sid=options.sid, string_opt_list=options.string_opt, startrecord=startrecord, xpath=options.xpath, target=options.target, summary=options.summary, logons=options.logons)
        last_record = newest_record
        if (not options.monitor):
            return
        dsz.Sleep((options.interval * 1000))
if (__name__ == '__main__'):
    try:
        main(sys.argv[1:])
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)