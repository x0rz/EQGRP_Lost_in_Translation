
import codecs
import cStringIO
import csv
import glob
import optparse
import os
import sys
from xml.etree.ElementTree import ElementTree
import dsz
import dsz.lp
from ops.pprint import pprint
DSZ_NS = '{urn:mca:db00db84-8b5b-2141-a632b5980175d3c6}'
DATALOG_TAG = ('%sDataLog' % DSZ_NS)
COMMANDDATA_TAG = ('%sCommandData' % DSZ_NS)
SQL_TAG = ('%sSql' % DSZ_NS)
QUERY_TAG = ('%sQuery' % DSZ_NS)
COLUMNINFO_TAG = ('%sColumnInfo' % DSZ_NS)
COLUMN_TAG = ('%sColumn' % DSZ_NS)
NAME_TAG = ('%sName' % DSZ_NS)
UNCOMPRESSEDDATA_TAG = ('%sUncompressedData' % DSZ_NS)
TABLEROW_TAG = ('%sTableRow' % DSZ_NS)
TABLEDATA_TAG = ('%sTableData' % DSZ_NS)

def main(args):
    (opts, args) = parse_args(args)
    if (not args):
        return
    column_header = header_from_id(args[0])
    all_rows = data_from_id(args[0])
    print ''
    if (not all_rows):
        dsz.ui.Echo('No valid SQL query data found.', dsz.ERROR)
        return
    dsz.ui.Echo(('Found %s columns...' % len(column_header)), dsz.GOOD)
    if (opts.print_data is None):
        print ''
        opts.print_data = dsz.ui.Prompt('Would you like see the results?', False)
    if opts.print_data:
        print ''
        all_rows = list(all_rows)
        pprint(all_rows, column_header)
    if (opts.write_csv is None):
        print ''
        opts.write_csv = dsz.ui.Prompt('Would you like to write to a CSV file?', False)
    if opts.write_csv:
        output_file = os.path.join(opts.output_dir, ('%s.csv' % format_id(args[0])))
        write(all_rows, column_header, output_file)
    return (all_rows, column_header)

def save_blob_from_file(command_id, output_path, column_name=None, column_index=None, row=0):
    if ((column_name is None) and (column_index is None)):
        dsz.ui.Echo('You must either specify a column_name or column_index!', dsz.ERROR)
        return None
    column_header = header_from_id(command_id)
    all_rows = data_from_id(command_id)
    if (not all_rows):
        return
    if column_name:
        row_dict = dict(zip(column_header, all_rows[row]))
        blob = row_dict[column_name]
    else:
        blob = all_rows[row][column_index]
    if (not os.path.exists(os.path.dirname(output_path))):
        os.makedirs(os.path.dirname(output_path))
    oh = open(output_path, 'wb')
    oh.write(blob.decode('hex'))
    oh.close()
    return output_path

def parse_args(arguments):
    USAGE = '%prog [-w/-W] [-p/-P] [-o output_dir] <ID of SQL XML File>\n\nExample: %prog -w -P 240'
    parser = optparse.OptionParser(USAGE)
    parser.disable_interspersed_args()
    parser.add_option('-w', '--write-csv', action='store_true', dest='write_csv', default=None, help='Write a csv file')
    parser.add_option('-W', '--no-write-csv', action='store_false', dest='write_csv', default=None, help="Don't write a csv file")
    parser.add_option('-o', '--output-dir', default=os.path.join(dsz.lp.GetLogsDirectory(), 'GetFiles', 'sql_decrypted'), help='Override the output directory for the CSV file')
    parser.add_option('-p', '--print', action='store_true', dest='print_data', default=None, help='Print the data to the screen')
    parser.add_option('-P', '--no-print', action='store_false', dest='print_data', default=None, help="Don't print the data to the screen")
    (options, args) = parser.parse_args(arguments)
    if (len(args) != 1):
        print ''
        dsz.ui.Echo('You must specify a command ID!', dsz.ERROR)
        print ''
        parser.print_help()
        return (None, None)
    return (options, args)

def format_id(command_id):
    command_id = str(command_id).strip()
    command_id = ('%05d' % int(command_id))
    return command_id

def data_from_id(command_id):
    command_id = format_id(command_id)
    mask = ('%s-sql*' % command_id)
    pattern = os.path.join(dsz.lp.GetLogsDirectory(), 'Data', mask)
    files = glob.glob(pattern)
    if (not files):
        (yield [])
    query_path = '/'.join([COMMANDDATA_TAG, SQL_TAG, QUERY_TAG])
    data_path = '/'.join([COMMANDDATA_TAG, SQL_TAG, QUERY_TAG, UNCOMPRESSEDDATA_TAG, TABLEROW_TAG])
    for input_file in files:
        tree = ElementTree()
        tree.parse(input_file)
        query = tree.find(query_path)
        if (query is None):
            continue
        rows = tree.findall(data_path)
        for row in rows:
            (yield [column.text for column in row.findall(TABLEDATA_TAG)])

def header_from_id(command_id):
    command_id = format_id(command_id)
    mask = ('%s-sql*' % command_id)
    pattern = os.path.join(dsz.lp.GetLogsDirectory(), 'Data', mask)
    files = glob.glob(pattern)
    if (not files):
        return []
    column_header = []
    query_path = '/'.join([COMMANDDATA_TAG, SQL_TAG, QUERY_TAG])
    column_path = '/'.join([COMMANDDATA_TAG, SQL_TAG, QUERY_TAG, COLUMNINFO_TAG, COLUMN_TAG, NAME_TAG])
    for input_file in files:
        tree = ElementTree()
        tree.parse(input_file)
        query = tree.find(query_path)
        if (query is None):
            continue
        columns = tree.findall(column_path)
        column_header = [column.text for column in columns]
        return column_header
    return column_header

def write(data, header, output_file):
    if (not os.path.exists(os.path.dirname(output_file))):
        os.makedirs(os.path.dirname(output_file))
    with open(output_file, 'ab') as oh:
        writer = UnicodeWriter(oh, quoting=csv.QUOTE_ALL)
        if header:
            writer.writerow(header)
        if data:
            writer.writerows(data)
    print ''
    dsz.ui.Echo(('File written to: %s' % output_file), dsz.GOOD)

def safe_encode(val):
    return ('' if (val is None) else val.encode('utf-8'))

class UnicodeWriter:

    def __init__(self, f, dialect='excel', encoding='utf-8', **kwds):
        self.queue = cStringIO.StringIO()
        self.writer = csv.writer(self.queue, dialect=dialect, **kwds)
        self.stream = f
        self.encoder = codecs.getincrementalencoder(encoding)()

    def writerow(self, row):
        self.writer.writerow([safe_encode(col) for col in row])
        data = self.queue.getvalue()
        data = data.decode('utf-8')
        data = self.encoder.encode(data)
        self.stream.write(data)
        self.queue.truncate(0)

    def writerows(self, rows):
        for row in rows:
            if row:
                self.writerow(row)
if (__name__ == '__main__'):
    main(sys.argv[1:])