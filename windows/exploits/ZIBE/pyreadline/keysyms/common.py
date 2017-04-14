# -*- coding: utf-8 -*-
#*****************************************************************************
#       Copyright (C) 2003-2006 Gary Bishop.
#       Copyright (C) 2006  Jorgen Stenarson. <jorgen.stenarson@bostream.nu>
#
#  Distributed under the terms of the BSD License.  The full license is in
#  the file COPYING, distributed as part of this software.
#*****************************************************************************
# table for translating virtual keys to X windows key symbols

try:
    set
except NameError:
    from sets import Set as set
    
from pyreadline.unicode_helper import ensure_unicode

validkey =set([u'cancel',      u'backspace',    u'tab',          u'clear',
               u'return',      u'shift_l',      u'control_l',    u'alt_l',
               u'pause',       u'caps_lock',    u'escape',       u'space',
               u'prior',       u'next',         u'end',          u'home',
               u'left',        u'up',           u'right',        u'down',
               u'select',      u'print',        u'execute',      u'snapshot',
               u'insert',      u'delete',       u'help',         u'f1',
               u'f2',          u'f3',           u'f4',           u'f5',
               u'f6',          u'f7',           u'f8',           u'f9',
               u'f10',         u'f11',          u'f12',          u'f13',
               u'f14',         u'f15',          u'f16',          u'f17',
               u'f18',         u'f19',          u'f20',          u'f21',
               u'f22',         u'f23',          u'f24',          u'num_lock',
               u'scroll_lock', u'vk_apps',      u'vk_processkey',u'vk_attn',
               u'vk_crsel',    u'vk_exsel',     u'vk_ereof',     u'vk_play',
               u'vk_zoom',     u'vk_noname',    u'vk_pa1',       u'vk_oem_clear',
               u'numpad0',     u'numpad1',      u'numpad2',      u'numpad3',
               u'numpad4',     u'numpad5',      u'numpad6',      u'numpad7',
               u'numpad8',     u'numpad9',      u'divide',       u'multiply',
               u'add',         u'subtract',     u'vk_decimal'])

escape_sequence_to_special_key = {u"\\e[a" : u"up", u"\\e[b" : u"down", u"del" : u"delete"}

class KeyPress(object):
    def __init__(self, char=u"", shift=False, control=False, meta=False, keyname=u""):
        if control or meta or shift:
            char = char.upper()
        self.info = dict(char=char,
                         shift=shift,
                         control=control,
                         meta=meta,
                         keyname=keyname)
        
    def create(name):
        def get(self):
            return self.info[name]

        def set(self, value):
            self.info[name] = value
        return property(get, set)
    char = create(u"char")
    shift = create(u"shift")
    control = create(u"control")
    meta = create(u"meta")
    keyname = create(u"keyname")
        
    def __repr__(self):
        return u"(%s,%s,%s,%s)"%tuple(map(ensure_unicode, self.tuple()))

    def tuple(self):
        if self.keyname:
            return (self.control, self.meta, self.shift, self.keyname)
        else:
            if self.control or self.meta or self.shift:
                return (self.control, self.meta, self.shift, self.char.upper())
            else:
                return (self.control, self.meta, self.shift, self.char)

    def __eq__(self, other):
        if isinstance(other, KeyPress):
            s = self.tuple()
            o = other.tuple()
            return s == o
        else:
            return False

def make_KeyPress_from_keydescr(keydescr):
    keyinfo = KeyPress()
    if len(keydescr) > 2 and keydescr[:1] == u'"' and keydescr[-1:] == u'"':
        keydescr = keydescr[1:-1]
        
    while 1:
        lkeyname = keydescr.lower()
        if lkeyname.startswith(u'control-'):
            keyinfo.control = True
            keydescr = keydescr[8:]
        elif lkeyname.startswith(u'ctrl-'):
            keyinfo.control = True
            keydescr = keydescr[5:]
        elif keydescr.lower().startswith(u'\\c-'):
            keyinfo.control = True
            keydescr = keydescr[3:]
        elif keydescr.lower().startswith(u'\\m-'):
            keyinfo.meta = True
            keydescr = keydescr[3:]
        elif keydescr in escape_sequence_to_special_key:
            keydescr = escape_sequence_to_special_key[keydescr]
        elif lkeyname.startswith(u'meta-'):
            keyinfo.meta = True
            keydescr = keydescr[5:]
        elif lkeyname.startswith(u'alt-'):
            keyinfo.meta = True
            keydescr = keydescr[4:]
        elif lkeyname.startswith(u'shift-'):
            keyinfo.shift = True
            keydescr = keydescr[6:]
        else:
            if len(keydescr) > 1:
                if keydescr.strip().lower() in validkey:
                    keyinfo.keyname = keydescr.strip().lower()
                    keyinfo.char = ""
                else:
                    raise IndexError(u"Not a valid key: '%s'"%keydescr)
            else:
                keyinfo.char = keydescr
            return keyinfo

if __name__ == u"__main__":
    import startup
    