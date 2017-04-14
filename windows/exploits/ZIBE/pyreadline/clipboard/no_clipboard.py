# -*- coding: utf-8 -*-
#*****************************************************************************
#       Copyright (C) 2006  Jorgen Stenarson. <jorgen.stenarson@bostream.nu>
#
#  Distributed under the terms of the BSD License.  The full license is in
#  the file COPYING, distributed as part of this software.
#*****************************************************************************


mybuffer = u""

def GetClipboardText():
    return mybuffer

def SetClipboardText(text):
    global mybuffer
    mybuffer = text
    
