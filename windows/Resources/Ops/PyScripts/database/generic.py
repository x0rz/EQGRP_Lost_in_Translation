
import os
import dsz
import ops.menu
from ops.pprint import pprint
import sql_utils
import sql_xml_parser

class GenericDatabase(object, ):
    NAME = 'Generic Database'

    def __init__(self):
        self.csv_output = False
        self.max_col_size = 64000

    def audit_check(self):
        print ''
        message = 'No audit-check implementation found, sorry.\n'
        dsz.ui.Echo(message, dsz.WARNING)
        return None

    def connection_string_wizard(self):
        print ''
        message = 'No connection-string wizard implementation found, sorry.\n'
        dsz.ui.Echo(message, dsz.WARNING)
        return None

    def top_ten_query(self, handle_id, table_query_file=None, top_ten_query_template=None):
        print ''
        dsz.ui.Echo('Running query to find all user tables...', dsz.GOOD)
        while (not table_query_file):
            prompt = 'Please provide a query file that will pull the list of tables'
            table_query_file = dsz.ui.GetString(prompt)
            if (not os.path.exists(table_query_file)):
                dsz.ui.Echo(('%s does not exist... try again.' % table_query_file), dsz.ERROR)
                table_query_file = None
        (status, command_id) = sql_utils.run_query_from_file(handle_id, table_query_file, echo=False)
        if (not status):
            print ''
            dsz.ui.Echo("Couldn't get the table list, try reconnecting.", dsz.ERROR)
            return None
        header = sql_xml_parser.header_from_id(command_id)
        data = [row for row in sql_xml_parser.data_from_id(command_id)]
        if (not data):
            print ''
            dsz.ui.Echo("Couldn't read the XML list of tables. There may be an error in sql_xml_parser. Go find a script dev!", dsz.ERROR)
            return None
        print ''
        if dsz.ui.Prompt(('Found %s tables, would you like to see the names?' % len(data))):
            print ''
            pprint(data, header)
        print ''
        if (not dsz.ui.Prompt('Would you like to pull the first 10 rows of each table?')):
            return None
        print ''
        for row in data:
            table_name = row[0]
            if (not top_ten_query_template):
                top_ten_query_text = ('select top 10 * from %s' % table_name)
            else:
                top_ten_query_text = (top_ten_query_template % table_name)
            (status, command_id) = sql_utils.run_query(handle_id, top_ten_query_text, echo=True, max_col_size=self.max_col_size)
            dsz.ui.Echo(('ID: %s Status: %s' % (command_id, status)))
            if (not status):
                if (not dsz.ui.Prompt('Looks like a query failed, would you like to continue?')):
                    return None
            if (self.csv_output and status):
                sql_utils.write_csv_output(command_id, 'TopTenSurvey', table_name)
        return None

    def canned_plan_menu(self, handle_id):
        menu = ops.menu.Menu()
        menu.set_heading(('%s Canned Query Plans' % self.NAME))
        plan_path = os.path.join(os.path.dirname(__file__), '..', '..', 'Data', 'database_plans', self.NAME)
        plan_path = os.path.normpath(plan_path)
        if (not os.path.isdir(plan_path)):
            print ''
            dsz.ui.Echo(('No directory of database plans found at: %s' % plan_path), dsz.ERROR)
            return
        for folder in os.listdir(plan_path):
            query_folder = os.path.join(plan_path, folder)
            if (not os.path.isdir(query_folder)):
                continue
            menu.add_option(folder, callback=sql_utils.run_folder_of_queries, handle_id=handle_id, query_folder=query_folder, csv_output=self.csv_output, max_col_size=self.max_col_size)
        menu.execute(exit='Back')

    def prompt_for_query_folder(self, handle_id):
        prompt = 'Where is the folder of queries to run'
        default_path = os.path.join(dsz.lp.GetLogsDirectory(), 'queries')
        query_folder = dsz.ui.GetString(prompt, default_path)
        sql_utils.run_folder_of_queries(handle_id, query_folder, csv_output=self.csv_output, max_col_size=self.max_col_size)

    def cleanup(self, handle_id):
        sql_utils.disconnect(handle_id)