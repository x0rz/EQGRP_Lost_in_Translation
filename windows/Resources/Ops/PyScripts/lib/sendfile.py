
import ftplib, hashlib, zipfile, binascii
import os, os.path, sys, time, StringIO
from globalconfig import config
ftphost = config['hosts']['ftp']

def zip_file(infilename, outfilename=''):
    if (infilename == outfilename):
        raise Exception('You have tried to zip something into itself, that is a problem, quitting...')
    if (outfilename == ''):
        outfilename = (infilename + '.zip')
    outzip = zipfile.ZipFile(outfilename, 'w', zipfile.ZIP_DEFLATED)
    outzip.write(infilename, os.path.split(infilename)[1])
    outzip.close()

def zippath(dirname, outfilename):
    normdirname = os.path.normpath(dirname).lower()
    normfilename = os.path.normpath(outfilename).lower()
    if os.path.split(normfilename)[0].startswith(normdirname):
        raise Exception('You have tried to zip something into itself, that is a problem, quitting...')
    outzip = zipfile.ZipFile(outfilename, 'w')
    for (root, dirs, files) in os.walk(dirname):
        zippath = root.replace(dirname, '')
        for filename in files:
            outzip.write(((root + os.sep) + filename), ((zippath + os.sep) + filename))
    outzip.close()

def getSuite():
    try:
        f = open('C:\\suite.txt', 'r')
        a = f.read()
        return int(a)
    except:
        return 0

def ftpfile(filename, ftpdir='fast'):
    if (ftpdir not in config):
        raise Exception('No credentials available for directory {0}.'.format(ftpdir))
    elif ('username' not in config[ftpdir]):
        raise Exception('No username available for directory {0}.'.format(ftpdir))
    elif ('password' not in config[ftpdir]):
        raise Exception('No password available for directory {0}.'.format(ftpdir))
    username = config[ftpdir]['username']
    password = config[ftpdir]['password']
    ftpsock = ftplib.FTP(ftphost, username, password)
    remotename = filename.split(os.sep)[(-1)]
    f = open(filename, 'rb')
    ziphash = hashlib.md5()
    ziphash.update(f.read())
    md5stream = StringIO.StringIO((binascii.hexlify(ziphash.digest()) + (' *%s' % remotename)))
    f.seek(0)
    try:
        ftpsock.storbinary(('STOR %s' % remotename), f)
        ftpsock.storbinary(('STOR %s' % (remotename + '.md5')), md5stream)
    except:
        print 'Exception while trying to FTP files'
        print sys.exc_info()[0], sys.exc_info()[1]
    finally:
        f.close()
    ftpsock.quit()

def main(infilename, outdir='', outfilebasename='', destfolder='fast', outfilename=''):
    if (outdir == ''):
        outdir = config['paths']['tmp']
    if (outfilebasename == ''):
        outfilebasename = os.path.split(infilename)[1].replace('.', '_')
    if (outfilename == ''):
        now = time.gmtime()
        outfilename = ('%s-W-%s-%d%s%s-%s%s.zip' % (outfilebasename, str(getSuite()), now.tm_year, str(now.tm_mon).ljust(2, '0'), str(now.tm_mday).ljust(2, '0'), str(now.tm_hour).ljust(2, '0'), str(now.tm_min).ljust(2, '0')))
    print ('Making %s' % ((outdir + os.sep) + outfilename))
    if os.path.isdir(infilename):
        zippath(infilename, ((outdir + os.sep) + outfilename))
    elif os.path.isfile(infilename):
        zip_file(infilename, ((outdir + os.sep) + outfilename))
    else:
        raise Exception('The given path does not exist')
    print ('Sending %s to %s' % (((outdir + os.sep) + outfilename), destfolder))
    ftpfile(((outdir + os.sep) + outfilename), destfolder)
if (__name__ == '__main__'):
    i = 1
    (infile, outfile, dest) = ('', '', 'fast')
    if (len(sys.argv) < 3):
        print ('Usage: %s -Options-\n\n    -i or --infilename [filename]\n        File or directory name to FTP (must be specified)\n\n    -o or --outfilename [filenameprefix]\n        Name to give zip file (defaults to infilename)\n\n    -dd or --destdir [fast|imps|slow|...]\n        Destination directory on FTP server (defaults to fast)\n\n    -di or --destip [FTP_server_IP]\n        IP of FTP server (defaults to that given in C:\\utils\\config.cfg, currently %s)' % (sys.argv[0], ftphost))
    else:
        while (i < len(sys.argv)):
            option = sys.argv[i]
            if ((option == '--outfilename') or (option == '-o')):
                outfile = sys.argv[(i + 1)]
                i += 2
            elif ((option == '--infilename') or (option == '-i')):
                infile = sys.argv[(i + 1)]
                i += 2
            elif ((option == '--destdir') or (option == '-dd')):
                dest = sys.argv[(i + 1)]
                i += 2
            elif ((option == '--destip') or (option == '-di')):
                ftphost = sys.argv[(i + 1)]
                i += 2
            else:
                print ('Invalid option %s' % sys.argv[i])
                raise Exception(('Invalid option %s' % sys.argv[i]))
        main(infile, outfilebasename=outfile, destfolder=dest)
        print 'Sent your file successfully'