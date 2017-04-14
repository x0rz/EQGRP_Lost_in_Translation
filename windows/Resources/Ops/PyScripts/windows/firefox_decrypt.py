
from ctypes import *
from pprint import pprint
import base64
import os
import sqlite3
import struct
import sys

class SECItem(Structure, ):
    _fields_ = [('type', c_uint), ('data', c_void_p), ('len', c_uint)]

class secuPWData(Structure, ):
    _fields_ = [('source', c_ubyte), ('data', c_char_p)]
(SECWouldBlock, SECFailure, SECSuccess) = ((-2), (-1), 0)
(PW_NONE, PW_FROMFILE, PW_PLAINTEXT, PW_EXTERNAL) = (0, 1, 2, 3)

def main(args):
    if (len(args) <= 1):
        print 'ERROR: You must pass a profile folder as the first argument.'
        return
    else:
        profile_path = args[1]
    results = read_passwords_from_profile(profile_path)
    if results:
        pprint(results)
    print 'Done.'

def read_passwords_from_profile(profile_path):
    print ('Reading passwords from profile folder: %s' % profile_path)
    db_file = os.path.join(profile_path, 'signons.sqlite')
    if (not os.path.exists(db_file)):
        print ("Error locating signons.sqlite in folder '%s'. Exiting." % profile_path)
        return
    libnss = load_libnss(profile_path)
    if (not libnss):
        return
    con = sqlite3.connect(db_file)
    c = con.cursor()
    c.execute('SELECT * FROM moz_logins;')
    entries = []
    for row in c:
        site = row[1]
        username = decrypt(row[6], libnss)
        password = decrypt(row[7], libnss)
        entries.append({'site': site, 'user': username, 'pass': password})
    c.close()
    con.close()
    libnss.NSS_Shutdown()
    return entries

def load_libnss(profile_path):
    library_name = ('nss3.dll' if (os.name == 'nt') else 'libnss3.so')
    if (os.name == 'nt'):
        firefox_dir = 'C:\\Program Files\\Mozilla Firefox'
        if (not os.path.exists(os.path.join(firefox_dir, library_name))):
            firefox_dir = 'C:\\Program Files (x86)\\Mozilla Firefox'
            if (not os.path.exists(os.path.join(firefox_dir, library_name))):
                print ("\nERROR: Can't find %s at %s, won't be able to decrypt. Fix the path to firefox in the code and retry." % (library_name, firefox_dir))
                return None
        os.environ['PATH'] = ((firefox_dir + ';') + os.environ['PATH'])
    libnss = CDLL(library_name)
    if (libnss.NSS_Init(profile_path) != 0):
        print 'ERROR: Could not initialize libnss.'
        return None
    return libnss

def decrypt(b64_data, libnss):
    pwdata = secuPWData()
    pwdata.source = PW_NONE
    pwdata.data = 0
    encrypted = SECItem()
    decrypted = SECItem()
    decoded = base64.b64decode(b64_data)
    encrypted.data = cast(c_char_p(decoded), c_void_p)
    encrypted.len = len(decoded)
    if (libnss.PK11SDR_Decrypt(byref(encrypted), byref(decrypted), byref(pwdata)) == SECFailure):
        print ('Error %s when decrypting data %s\n' % (libnss.PORT_GetError(), b64_data))
    text_data = string_at(decrypted.data, decrypted.len)
    return text_data
if (__name__ == '__main__'):
    main(sys.argv)