# -*- coding: utf-8 -*-
#*****************************************************************************
#       Copyright (C) 2006  Jorgen Stenarson. <jorgen.stenarson@bostream.nu>
#
#  Distributed under the terms of the BSD License.  The full license is in
#  the file COPYING, distributed as part of this software.
#*****************************************************************************
import cPickle
import logging
import logging.handlers
import SocketServer
import struct,socket

try:
    import msvcrt
except ImportError:
    msvcrt = None
    print u"problem"


port = logging.handlers.DEFAULT_TCP_LOGGING_PORT
host = u'localhost'

def check_key():
    if msvcrt is None:
        return False
    else:
        if msvcrt.kbhit() != 0:
            q = msvcrt.getch()
            return q
    return u""


singleline=False

def main():
    print u"Starting TCP logserver on port:", port
    print u"Press q to quit logserver", port
    print u"Press c to clear screen", port
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    s.bind((u"", port))
    s.settimeout(1)
    while 1:
        try:
            data, addr = s.recvfrom(100000)
            print data,
        except socket.timeout:
            key = check_key().lower()
            if u"q" == key:
                print u"Quitting logserver"
                break
            elif u"c" == key:
                print u"\n" * 100            

if __name__ == u"__main__":
    main()