
import sys
import glob
import os
import shutil
from xml.etree import ElementTree
DSZ_NS = '{urn:mca:db00db84-8b5b-2141-a632b5980175d3c6}'
DATALOG_TAG = ('%sDataLog' % DSZ_NS)
COMMANDDATA_TAG = ('%sCommandData' % DSZ_NS)
TASKRESULT_TAG = ('%sTaskResult' % DSZ_NS)
FILESTART_TAG = ('%sFileStart' % DSZ_NS)
FILELOCALNAME_TAG = ('%sFileLocalName' % DSZ_NS)
LOCAL_NAME_KEY = 'local_name'
REMOTE_NAME_KEY = 'remote_name'
SAFE_EXTS = ['.gif', '.bmp', '.tif', '.tiff', '.jpg', '.jpeg', '.png', '.bmp', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.vsd', '.txt', '.cfg', '.csv', '.pdf', '.rtf', '.log', '.xml', '.rar', '.gz', '.zip', '.bz2', '.tgz']

def main(file_to_read, output_dir):
    if (not is_completed_result(file_to_read)):
        return
    task_id = file_to_read.split('_')[2]
    path_to_glob = os.path.join(os.path.dirname(file_to_read), ('*-get_*_%s_*.xml' % task_id))
    all_gets = glob.glob(path_to_glob)
    if (len(all_gets) <= 0):
        return
    all_files = {}
    for get_file in all_gets:
        base_name = os.path.basename(get_file)
        task_id = base_name.split('-')[0]
        tree = ElementTree.parse(get_file)
        data_log = tree.getiterator(DATALOG_TAG)[0]
        command_data = data_log.find(COMMANDDATA_TAG)
        file_start = command_data.find(FILESTART_TAG)
        file_local_name = command_data.getiterator(FILELOCALNAME_TAG)
        if (file_start is not None):
            file_id = file_start.get('fileId')
            remote_name = file_start.get('remoteName')
            all_files = safe_store_by_ids(all_files, task_id, file_id, REMOTE_NAME_KEY, remote_name)
        elif len(file_local_name):
            file_local_name = file_local_name[0]
            file_id = file_local_name.get('fileId')
            local_name = file_local_name.text
            all_files = safe_store_by_ids(all_files, task_id, file_id, LOCAL_NAME_KEY, local_name)
        else:
            pass
    target_dir = os.path.dirname(os.path.dirname(file_to_read))
    dest_dir = os.path.join(output_dir, 'GetFiles_Renamed')
    if (not os.path.exists(dest_dir)):
        os.makedirs(dest_dir)
    copy_files_from_dict(all_files, target_dir, dest_dir)

def is_completed_result(file_to_parse):
    try:
        tree = ElementTree.parse(file_to_parse)
        data_log = tree.getiterator(DATALOG_TAG)[0]
        command_data = data_log.find(COMMANDDATA_TAG)
        task_result = command_data.find(TASKRESULT_TAG)
        if ((task_result is not None) and (task_result.text == '0x00000000')):
            return True
        else:
            return False
    except:
        return False

def safe_store_by_ids(dictionary, task_id, file_id, key, value):
    if (not dictionary.has_key(task_id)):
        dictionary[task_id] = {file_id: {key: value}}
        return dictionary
    if (not dictionary[task_id].has_key(file_id)):
        dictionary[task_id][file_id] = {key: value}
        return dictionary
    dictionary[task_id][file_id][key] = value
    return dictionary

def copy_files_from_dict(all_files, target_dir, dest_dir):
    for (task_id, files) in all_files.items():
        for (file_id, names) in files.items():
            to_copy = os.path.join(target_dir, 'GetFiles', names[LOCAL_NAME_KEY])
            new_dest_name = os.path.basename(names[REMOTE_NAME_KEY])
            ext = os.path.splitext(new_dest_name)[1]
            if ((ext.lower() not in SAFE_EXTS) and (ext != '')):
                new_dest_name += '.r'
            dest = os.path.join(dest_dir, ('%s_%s_%s' % (task_id, file_id, new_dest_name)))
            if os.path.exists(dest):
                continue
            try:
                shutil.copyfile(to_copy, dest)
            except IOError as e:
                pass