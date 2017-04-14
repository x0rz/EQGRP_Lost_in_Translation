
import os
import dsz
from generic import GenericDatabase

class SQLite(GenericDatabase, ):
    NAME = 'SQLite'

    def connection_string_wizard(self):
        db_file_path = None
        while True:
            print ''
            db_file_path = dsz.ui.GetString('Enter the path to a SQLite File (usually .db or .sqlite)')
            if dsz.file.Exists(db_file_path):
                break
            dsz.ui.Echo('Path does not exist...', dsz.ERROR)
        return db_file_path

    def top_ten_query(self, handle_id):
        table_file = os.path.join(os.path.dirname(__file__), '..', '..', 'Data', 'database_plans', 'SQLite', 'table_names.sql')
        top_ten_query = 'select * from %s limit 10'
        GenericDatabase.top_ten_query(self, handle_id, table_file, top_ten_query)