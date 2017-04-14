
import dsz, dsz.version.checks.windows
import ops, ops.cmd
import os.path

def getregvalue(hive, key, value):
    cmd = ops.cmd.getDszCommand('registryquery')
    cmd.hive = hive
    cmd.key = key
    if (value != ''):
        cmd.value = value
    obj = cmd.execute()
    if cmd.success:
        if (value == ''):
            for key in obj.key:
                for value in key.value:
                    if (value.name == ''):
                        return (key.updatedate, key.updatetime, value.value)
        else:
            return (obj.key[0].updatedate, obj.key[0].updatetime, obj.key[0].value[0].value)
    else:
        return (None, None, None)

def getdirinfo(pathtocheck):
    cmd = ops.cmd.getDszCommand('dir', path=('"%s"' % os.path.dirname(pathtocheck)), mask=('"%s"' % os.path.basename(pathtocheck)))
    obj = cmd.execute()
    if cmd.success:
        try:
            return (obj.diritem[0].fileitem[0].filetimes.accessed.time, obj.diritem[0].fileitem[0].filetimes.created.time, obj.diritem[0].fileitem[0].filetimes.modified.time)
        except:
            pass
    return (None, None, None)

def checkmvinprocserver():
    (moddate, modtime, value) = getregvalue('l', 'SOFTWARE\\Classes\\CLSID\\{1945f23e-0573-4e7e-9641-37215654bce4}', '')
    if (value == 'Internet Traffic Handler'):
        dsz.ui.Echo(('Internet Traffic Handler key found [%s %s]' % (moddate, modtime)), dsz.GOOD)
    else:
        dsz.ui.Echo('Internet Traffic Handler key not found', dsz.ERROR)
        return
    (moddate, modtime, value) = getregvalue('l', 'SOFTWARE\\Classes\\CLSID\\{1945f23e-0573-4e7e-9641-37215654bce4}\\InprocServer32', '')
    if (value is not None):
        dsz.ui.Echo(('InProcServer32 key found [%s %s]' % (moddate, modtime)), dsz.GOOD)
        (fileaccessed, filecreated, filemodified) = getdirinfo(value)
        if (fileaccessed is not None):
            dsz.ui.Echo(('Found %s [a:%s , c:%s , m:%s]' % (value, fileaccessed, filecreated, filemodified)), dsz.GOOD)
        else:
            dsz.ui.Echo(('Did not find %s' % value), dsz.ERROR)
    else:
        dsz.ui.Echo('InProcServer32 key not found', dsz.ERROR)
    (moddate, modtime, value) = getregvalue('l', 'SOFTWARE\\Classes\\CLSID\\{1945f23e-0573-4e7e-9641-37215654bce4}\\InprocServer32', 'ThreadingModel')
    if (value is not None):
        dsz.ui.Echo(('ThreadingModel key found (%s) [%s %s]' % (value, moddate, modtime)), dsz.GOOD)
    else:
        dsz.ui.Echo('ThreadingModel key not found', dsz.ERROR)
    (moddate, modtime, value) = getregvalue('l', 'SOFTWARE\\Classes\\Protocols\\Filter\\text/html', 'CLSID')
    if (value is not None):
        dsz.ui.Echo(('text/html key found (%s) [%s %s]' % (value, moddate, modtime)), dsz.GOOD)
    else:
        dsz.ui.Echo('text/html key not found', dsz.ERROR)

def checkvalinprocserver():
    if dsz.version.checks.windows.IsVistaOrGreater():
        (moddate, modtime, value) = getregvalue('l', 'SOFTWARE\\Classes\\CLSID\\{C90250F3-4D7D-4991-9B69-A5C5BC1C2AE6}\\InProcServer32', '')
        pass
    else:
        (moddate, modtime, value) = getregvalue('l', 'SOFTWARE\\Classes\\CLSID\\{B8DA6310-E19B-11D0-933C-00A0C90DCAA9}\\InProcServer32', '')
        pass
    if (value is not None):
        dsz.ui.Echo(('InProcServer32 key found [%s %s]' % (moddate, modtime)), dsz.GOOD)
        (fileaccessed, filecreated, filemodified) = getdirinfo(value)
        if (fileaccessed is not None):
            dsz.ui.Echo(('Found %s [a:%s , c:%s , m:%s]' % (value, fileaccessed, filecreated, filemodified)), dsz.GOOD)
        else:
            dsz.ui.Echo(('Did not find %s' % value), dsz.ERROR)
    else:
        dsz.ui.Echo('InProcServer32 key not found', dsz.ERROR)

def checkstate(guid):
    (moddate, modtime, value) = getregvalue('l', ('SOFTWARE\\Classes\\CLSID\\{%s}\\TypeLib' % guid), 'DigitalProductId')
    if (value is not None):
        dsz.ui.Echo(('State information found (DigitalProductId) [%s %s]' % (moddate, modtime)), dsz.GOOD)
        dsz.ui.Echo(('State information is %s bytes in length' % (len(value) / 2)), dsz.GOOD)
    else:
        dsz.ui.Echo(('State information not found in %s' % guid), dsz.ERROR)

def checkclientid(guid):
    (moddate, modtime, value) = getregvalue('l', ('SOFTWARE\\Classes\\CLSID\\{%s}\\TypeLib' % guid), '')
    if (value is not None):
        dsz.ui.Echo(('Client ID found (%s) [%s %s]' % (value, moddate, modtime)), dsz.GOOD)
        dsz.ui.Echo(('Client ID: %s' % int(decodeguid(value, '8C936AF9243D11D08ED400C04FC2C17B'), 16)), dsz.GOOD)
    else:
        dsz.ui.Echo(('Client ID not found in %s' % guid), dsz.ERROR)

def checkversion(guid):
    (moddate, modtime, value) = getregvalue('l', ('SOFTWARE\\Classes\\CLSID\\{%s}\\Version' % guid), '')
    if (value is not None):
        dsz.ui.Echo(('Version found (%s) [%s %s]' % (value, moddate, modtime)), dsz.GOOD)
    else:
        dsz.ui.Echo(('Version not found in %s' % guid), dsz.ERROR)

def checkselfdelete(guid):
    (moddate, modtime, value) = getregvalue('l', ('SOFTWARE\\Classes\\CLSID\\{%s}\\MiscStatus' % guid), '')
    if (value is not None):
        dsz.ui.Echo(('Self-delete found (%s) [%s %s]' % (value, moddate, modtime)), dsz.GOOD)
        if (value == '0'):
            dsz.ui.Echo('Self-delete reports 0x0', dsz.GOOD)
        else:
            dsz.ui.Echo(('Self-delete reports 0x%s' % decodeguid(value, 'ce0f73870bb5e60b8b4e25c48cebf039')), dsz.ERROR)
    else:
        dsz.ui.Echo(('Self-delete not found in %s' % guid), dsz.ERROR)

def decodeguid(guid, key):
    guid = guid.replace('-', '').replace('{', '').replace('}', '')
    decryptleft = int(guid[0:16], 16)
    decryptright = int(guid[16:32], 16)
    leftkey = int(key[0:16], 16)
    rightkey = int(key[16:32], 16)
    return ('%016X%016X' % ((decryptleft ^ leftkey), (decryptright ^ rightkey)))

def main():
    dsz.ui.Echo('==================================')
    dsz.ui.Echo('=============== VAL ==============')
    dsz.ui.Echo('==================================')
    dsz.ui.Echo('Checking for location on disk')
    checkvalinprocserver()
    dsz.ui.Echo('')
    dsz.ui.Echo('Checking state information')
    checkstate('6AF33D21-9BC5-4F65-8654-B8059B822D91')
    dsz.ui.Echo('')
    dsz.ui.Echo('Checking client ID')
    checkclientid('77032DAA-B7F2-101B-A1F0-01C29183BCA1')
    dsz.ui.Echo('')
    dsz.ui.Echo('Checking version')
    checkversion('77032DAA-B7F2-101B-A1F0-01C29183BCA1')
    dsz.ui.Echo('')
    dsz.ui.Echo('Checking self-deletion')
    checkselfdelete('77032DAA-B7F2-101B-A1F0-01C29183BCA1')
    dsz.ui.Echo('')
    dsz.ui.Echo('==================================')
    dsz.ui.Echo('=============== MV ===============')
    dsz.ui.Echo('==================================')
    dsz.ui.Echo('Checking for location on disk')
    checkmvinprocserver()
    dsz.ui.Echo('')
    dsz.ui.Echo('Checking state information')
    checkstate('B812789D-6FDF-97AB-834B-9F4376B2C8E1')
    dsz.ui.Echo('')
    dsz.ui.Echo('Checking client ID')
    checkclientid('B812789D-6FDF-97AB-834B-9F4376B2C8E1')
    dsz.ui.Echo('')
    dsz.ui.Echo('Checking version')
    checkversion('B812789D-6FDF-97AB-834B-9F4376B2C8E1')
    dsz.ui.Echo('')
    dsz.ui.Echo('Checking self-deletion')
    checkselfdelete('B812789D-6FDF-97AB-834B-9F4376B2C8E1')
    dsz.ui.Echo('')
if (__name__ == '__main__'):
    try:
        main()
    except RuntimeError as e:
        dsz.ui.Echo(('\nCaught RuntimeError: %s' % e), dsz.ERROR)