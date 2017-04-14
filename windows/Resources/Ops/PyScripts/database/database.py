
import optparse
import sys
import dsz
import ops.menu
from ops.pprint import pprint
import sql_utils
import sql_server
import oracle
import sqlite
import generic
__version__ = 2.0
CLASS_MAP = [sql_server.SQLServer, oracle.Oracle, sqlite.SQLite, generic.GenericDatabase]
SETTING_CSV = 'Output to CSV'
SETTING_MAX_SIZE = 'Max Column Size'

def main():
    (opts, args) = get_option_parser().parse_args()
    database_menu = ops.menu.Menu()
    database_menu.set_heading('Database Type')
    for db_class in CLASS_MAP:
        database_menu.add_option(db_class.NAME, callback=database_main, db_class=db_class, options=opts)
    database_menu.execute()
    print ''
    dsz.ui.Echo('Exiting...')
    return True

def get_option_parser():
    usage = 'usage: database.py [options]'
    description = 'Connect to a database using SCOFFRETAIL'
    parser = optparse.OptionParser(usage=usage, version=__version__, description=description)
    parser.disable_interspersed_args()
    parser.add_option('-n', '--no-audit-checks', action='store_false', dest='run_audit_check', default=True, help="Don't run any of the audit checks")
    return parser

def database_main(db_class, options):
    db_module = db_class()
    if (not db_module):
        return
    print ''
    dsz.ui.Echo('Loading SCOFFRETAIL and retrieving handle list...\n', dsz.GOOD)
    handle_list = sql_utils.handle_list()
    if handle_list:
        pprint(handle_list, ['Handle ID', 'Connection String'])
    else:
        dsz.ui.Echo('No existing connections found.', dsz.GOOD)
    if options.run_audit_check:
        print ''
        dsz.ui.Echo(('Running audit checks for %s...' % db_module.NAME), dsz.GOOD)
        db_module.audit_check()
    handle = connection_string_menu(db_module)
    if (not handle):
        db_module.cleanup(None)
        return
    try:
        query_menu(db_module, handle)
    except Exception as details:
        dsz.ui.Echo('Caught an exception querying:', dsz.ERROR)
        print ''
        print details
        print ''
        dsz.ui.Echo('Cleaning up and starting over.', dsz.ERROR)
    print ''
    dsz.ui.Echo('Done with this database, cleaning up...', dsz.GOOD)
    print ''
    db_module.cleanup(handle)

def connection_string_menu(db_module):
    database_menu = ops.menu.Menu()
    database_menu.set_heading('Create a connection string by:')
    database_menu.add_option('Running the connection string wizard', callback=wizard_callback, db_module=db_module, menu=database_menu)
    cs_prompt = 'Please enter your connection string: '
    database_menu.add_option('Manually supplying a connection string', callback=string_return_callback, prompt=cs_prompt, menu=database_menu)
    handle_prompt = 'Please enter the handle ID: '
    database_menu.add_option('Using an existing handle', callback=int_return_callback, prompt=handle_prompt, menu=database_menu)
    while True:
        result = database_menu.execute(exit='Back...', menuloop=False)
        handle = result['option_state']
        if handle:
            return handle
        if (result['selection'] == 0):
            break

def wizard_callback(db_module, menu):
    connection_string = db_module.connection_string_wizard()
    if (not connection_string):
        return
    handle = sql_utils.connect_to_database(connection_string)
    menu.set_current_state(handle)

def string_return_callback(prompt, menu):
    connection_string = dsz.ui.GetString(prompt)
    handle = sql_utils.connect_to_database(connection_string)
    menu.set_current_state(handle)

def int_return_callback(prompt, menu):
    handle = dsz.ui.GetInt(prompt)
    menu.set_current_state(handle)

def query_menu(db_module, handle_id):
    menu = ops.menu.Menu()
    menu.set_heading('Database Query Menu')
    menu.add_toggle_option(SETTING_CSV, section='Settings', state='False', enabled='True', disabled='False')
    menu.add_int_option(SETTING_MAX_SIZE, section='Settings', state=64000, default=64000)
    menu.add_option('Run a standard query plan', section='Query Commands', callback=read_args_callback, db_module=db_module, menu=menu, function=db_module.canned_plan_menu, handle_id=handle_id)
    menu.add_option('Read the top 10 rows from every table', section='Query Commands', callback=read_args_callback, db_module=db_module, menu=menu, function=db_module.top_ten_query, handle_id=handle_id)
    menu.add_option('Run a folder of queries', section='Query Commands', callback=read_args_callback, db_module=db_module, menu=menu, function=db_module.prompt_for_query_folder, handle_id=handle_id)
    menu.execute(exit='Disconnect')
    return True

def read_args_callback(db_module, menu, function, handle_id):
    (csv_output, max_col_size) = read_settings(menu)
    db_module.csv_output = csv_output
    db_module.max_col_size = max_col_size
    function(handle_id)

def read_settings(menu):
    settings = menu.all_states()['Settings']
    csv_output = (settings[SETTING_CSV] == 'True')
    max_col_size = int(settings[SETTING_MAX_SIZE])
    return (csv_output, max_col_size)
if (__name__ == '__main__'):
    main()