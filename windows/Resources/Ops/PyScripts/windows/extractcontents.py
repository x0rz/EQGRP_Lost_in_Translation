
import dsz, dsz.path, dsz.lp, dsz.file
import re, os, time
from optparse import OptionParser
results = []
results_dict = {}

def get_files(file_name, file_path):
    try:
        list_files = dsz.file.GetNames(str(file_name), str(file_path))
        return list_files
    except Exception as e:
        dsz.ui.Echo(str(e), dsz.ERROR)

def run_cmd(cmd):
    dsz.ui.Echo('Searching for files')
    dsz.control.echo.Off()
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    try:
        dir_path = dsz.cmd.data.Get('DirItem::path', dsz.TYPE_STRING)
        dsz.ui.Echo('Found {0} archive(s)'.format(str(len(dir_path))))
        return dir_path
    except RuntimeError:
        return False

def files_in_path(path, mask):
    cmd = 'dir -mask {0} -path "{1}"'.format(mask, path.rstrip('\\'))
    dsz.control.echo.Off()
    dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    list_of_files = dsz.cmd.data.Get('DirItem::FileItem::name', dsz.TYPE_STRING)
    return list_of_files

def build_cmd(options):
    cmd = 'dir -mask {0} -path "{1}"'.format(options.file_mask, options.dir_path)
    if (options.recursive == True):
        cmd = (cmd + ' -recursive')
    return cmd

def get_options():
    parser = OptionParser()
    parser.add_option('-f', dest='target_file_path', type='string', default=None, help='The location of 7za.exe on target')
    parser.add_option('-p', dest='dir_path', type='string', default=None, help='The path to run dir against')
    parser.add_option('-m', dest='file_mask', type='string', default=None, help='File mask')
    parser.add_option('-s', dest='search_item', type='string', default=None, help='File string to search for')
    parser.add_option('-r', dest='recursive', action='store_true', default='False', help='Boolean value for recursive tasking, defaults to false')
    (options, args) = parser.parse_args()
    return options

def check_options(options):
    if (options.target_file_path == None):
        return False
    elif (options.dir_path == None):
        return False
    elif (options.file_mask == None):
        return False
    elif (options.search_item == None):
        return False
    else:
        return True

def help():
    str = 'python <script name> -args <file_name/mask> <file_path>'
    return str

def list_size_status(path_list, mask):
    key_size = max((len(k) for k in path_list))
    out_str = 'You have {0} path(s) in your list.\n'.format(len(path_list))
    out_str += '\t{0}\t{1}\n'.format('Path'.ljust(key_size), 'File Count')
    out_str += '\t{0}\t{1}\n'.format('----'.ljust(key_size), '----------')
    for path in path_list:
        out_str += '\t{0}\t{1}\n'.format(path.ljust(key_size), str(len(files_in_path(path, mask))))
    return out_str

def user_prompt():
    state = True
    while state:
        num_to_process = dsz.ui.GetString('How many path(s) would you like to process (0 to quit)?:  ')
        if re.match('^\\d', num_to_process):
            if (int(num_to_process) == 0):
                dsz.ui.Echo('Quiting Script!', dsz.WARNING)
                exit(0)
            user_answer = dsz.ui.GetString('You have chosen {0}, is this correct? ([YES]/NO/QUIT):  '.format(num_to_process), defaultValue='YES')
            if ((user_answer.lower() == 'yes') or (user_answer.lower() == 'y')):
                num_to_process = int(num_to_process)
                state = False
                return num_to_process
            elif (user_answer.lower() == 'quit'):
                dsz.ui.Echo('Quiting Script!', dsz.ERROR)
                exit(0)
            else:
                dsz.ui.Echo('Please choose again.')
                continue
        else:
            dsz.ui.Echo('Please choose an integer.')
            continue

def process(num_to_process, path_list, target_file_path, search_item):
    i = 1
    file_store = []
    while (i <= num_to_process):
        file_list = get_files(options.file_mask, path_list[0])
        for file in file_list:
            file_path = os.path.join(path_list[0], file)
            output = run_7za(file_path, target_file_path)
            parse_return(output, file_path, search_item)
        path_list.pop(0)
        i = (i + 1)
    return path_list

def run_7za(file_path, target_file_path):
    cmd = 'run -command "\\"{0}\\" l \\"{1}\\" -r" -redirect'.format(target_file_path, file_path)
    dsz.ui.Echo(cmd, dsz.WARNING)
    try:
        dsz.control.echo.Off()
        dsz.cmd.Run(cmd, dsz.RUN_FLAG_RECORD)
        dsz.control.echo.On()
        output = dsz.cmd.data.Get('ProcessOutput::Output', dsz.TYPE_STRING)
        return output
    except Exception as e:
        dsz.ui.Echo(str(e), dsz.ERROR)
        dsz.ui.Echo('Did you provide the correct location for 7za.exe?', dsz.ERROR)
        dsz.ui.Echo('Quiting script!', dsz.ERROR)
        exit(0)

def parse_return(output_list, path, search_item):
    result = []
    dsz.ui.Echo(path, dsz.DEFAULT)
    for line in output_list:
        line = line.split('\n')
        for item in line:
            if (search_item == '*'):
                if re.match('^\\d{4}-\\d*', item):
                    try:
                        result = parse_data(item, path)
                        dsz.ui.Echo(('\t%s %4s %4s %4s %4s' % (result[0], result[1], result[3], result[4], result[5])))
                        results.append(result)
                    except Exception as e:
                        dsz.ui.Echo(str(e), dsz.ERROR)
            elif re.search(search_item, item):
                try:
                    result = parse_data(item, path)
                    dsz.ui.Echo(('\t%s %4s %4s %4s %4s' % (result[0], result[1], result[3], result[4], result[5])))
                    results.append(result)
                except Exception as e:
                    dsz.ui.Echo(str(e), dsz.ERROR)
        if (len(result) == 0):
            dsz.ui.Echo('\tEmpty archive or no matching file')

def parse_data(item, path):
    result = re.compile('\\s*').split(item)
    (date, time, attr, size, compress) = result[0:5]
    name = ' '.join(result[5:len(result)])
    result = [date, time, attr, size, compress, name, path]
    return result

def to_dict(results):
    i = 0
    for result in results:
        i = (i + 1)
        temp_dict = {'date': result[0], 'time': result[1], 'attr': result[2], 'size': result[3], 'compress': result[4], 'name': result[5], 'path': result[6]}
        results_dict[str(i)] = temp_dict

def to_xml(results_dict):
    file_time = time.strftime('%Y%m%d%H%m%S', time.gmtime())
    file_name = (file_time + '_zip_extract.xml')
    log_dir = os.path.join(dsz.lp.GetLogsDirectory(), 'zip_extract')
    dsz.ui.Echo(('Creating Directory: ' + log_dir), dsz.GOOD)
    try:
        os.makedirs(os.path.join(log_dir))
    except Exception:
        pass
    dsz.ui.Echo('Writing files to {0}'.format(os.path.join(log_dir, file_name)), dsz.GOOD)
    file = open(os.path.join(log_dir, file_name), 'w')
    file.write('<zip_extract>\n')
    for (k, v) in results_dict.iteritems():
        file.write('<result>\n')
        file.write((('<path>' + v['path']) + '</path>'))
        file.write((((((((('<file size="' + v['size']) + '" compressed="') + v['compress']) + '" DTG="') + v['date']) + '_') + v['time']) + '">\n'))
        file.write((('\n' + v['name']) + '\n</file>\n'))
        file.write('</result>\n')
    file.write('</zip_extract>')
    file.close

def check_path_list(path_list):
    for path in path_list:
        if re.search('System Volume Information', path):
            path_list.remove(path)
    return path_list

def main(path_list, target_file_path, search_item, mask):
    script_state = True
    while script_state:
        dsz.ui.Echo(list_size_status(path_list, mask), dsz.WARNING)
        num_to_process = user_prompt()
        dsz.ui.Echo('Processing {0} files'.format(num_to_process))
        if (num_to_process > len(path_list)):
            dsz.ui.Echo('Input greater than total paths.', dsz.ERROR)
        elif (num_to_process == 0):
            dsz.ui.Echo('Input is 0, please provide a number greater than 0.', dsz.ERROR)
        else:
            path_list = process(num_to_process, path_list, target_file_path, search_item)
            if (len(path_list) == 0):
                script_state = False
    to_dict(results)
    to_xml(results_dict)
if (__name__ == '__main__'):
    options = get_options()
    options_status = check_options(options)
    if (options_status == True):
        target_file_path = options.target_file_path
        search_item = options.search_item
        dir_cmd = build_cmd(options)
        dsz.ui.Echo(('Running ' + dir_cmd), dsz.WARNING)
        path_list = run_cmd(dir_cmd)
        if (path_list != False):
            path_list = check_path_list(path_list)
            main(path_list, target_file_path, search_item, options.file_mask)
        else:
            dsz.ui.Echo('Search returned no results', dsz.WARNING)
    else:
        dsz.ui.Echo('Warning incomplete arguments', dsz.WARNING)
        dsz.ui.Echo('Use:\n\tpython extractcontents.py -args "-h", for help', dsz.WARNING)