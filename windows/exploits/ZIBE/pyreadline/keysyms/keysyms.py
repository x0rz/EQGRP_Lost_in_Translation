# -*- coding: utf-8 -*-
#*****************************************************************************
#       Copyright (C) 2003-2006 Gary Bishop.
#       Copyright (C) 2006  Jorgen Stenarson. <jorgen.stenarson@bostream.nu>
#
#  Distributed under the terms of the BSD License.  The full license is in
#  the file COPYING, distributed as part of this software.
#*****************************************************************************
import winconstants as c32
from   pyreadline.logger import log
from ctypes import windll
import ctypes
# table for translating virtual keys to X windows key symbols

from common import validkey, KeyPress, make_KeyPress_from_keydescr

code2sym_map = {c32.VK_CANCEL:     u'cancel',
                c32.VK_BACK:       u'backspace',
                c32.VK_TAB:        u'tab',
                c32.VK_CLEAR:      u'clear',
                c32.VK_RETURN:     u'return',
                c32.VK_SHIFT:      u'shift_l',
                c32.VK_CONTROL:    u'control_l',
                c32.VK_MENU:       u'alt_l',
                c32.VK_PAUSE:      u'pause',
                c32.VK_CAPITAL:    u'caps_lock',
                c32.VK_ESCAPE:     u'escape',
                c32.VK_SPACE:      u'space',
                c32.VK_PRIOR:      u'prior',
                c32.VK_NEXT:       u'next',
                c32.VK_END:        u'end',
                c32.VK_HOME:       u'home',
                c32.VK_LEFT:       u'left',
                c32.VK_UP:         u'up',
                c32.VK_RIGHT:      u'right',
                c32.VK_DOWN:       u'down',
                c32.VK_SELECT:     u'select',
                c32.VK_PRINT:      u'print',
                c32.VK_EXECUTE:    u'execute',
                c32.VK_SNAPSHOT:   u'snapshot',
                c32.VK_INSERT:     u'insert',
                c32.VK_DELETE:     u'delete',
                c32.VK_HELP:       u'help',
                c32.VK_F1:         u'f1',
                c32.VK_F2:         u'f2',
                c32.VK_F3:         u'f3',
                c32.VK_F4:         u'f4',
                c32.VK_F5:         u'f5',
                c32.VK_F6:         u'f6',
                c32.VK_F7:         u'f7',
                c32.VK_F8:         u'f8',
                c32.VK_F9:         u'f9',
                c32.VK_F10:        u'f10',
                c32.VK_F11:        u'f11',
                c32.VK_F12:        u'f12',
                c32.VK_F13:        u'f13',
                c32.VK_F14:        u'f14',
                c32.VK_F15:        u'f15',
                c32.VK_F16:        u'f16',
                c32.VK_F17:        u'f17',
                c32.VK_F18:        u'f18',
                c32.VK_F19:        u'f19',
                c32.VK_F20:        u'f20',
                c32.VK_F21:        u'f21',
                c32.VK_F22:        u'f22',
                c32.VK_F23:        u'f23',
                c32.VK_F24:        u'f24',
                c32.VK_NUMLOCK:    u'num_lock,',
                c32.VK_SCROLL:     u'scroll_lock',
                c32.VK_APPS:       u'vk_apps',
                c32.VK_PROCESSKEY: u'vk_processkey',
                c32.VK_ATTN:       u'vk_attn',
                c32.VK_CRSEL:      u'vk_crsel',
                c32.VK_EXSEL:      u'vk_exsel',
                c32.VK_EREOF:      u'vk_ereof',
                c32.VK_PLAY:       u'vk_play',
                c32.VK_ZOOM:       u'vk_zoom',
                c32.VK_NONAME:     u'vk_noname',
                c32.VK_PA1:        u'vk_pa1',
                c32.VK_OEM_CLEAR:  u'vk_oem_clear',
                c32.VK_NUMPAD0:    u'numpad0',
                c32.VK_NUMPAD1:    u'numpad1',
                c32.VK_NUMPAD2:    u'numpad2',
                c32.VK_NUMPAD3:    u'numpad3',
                c32.VK_NUMPAD4:    u'numpad4',
                c32.VK_NUMPAD5:    u'numpad5',
                c32.VK_NUMPAD6:    u'numpad6',
                c32.VK_NUMPAD7:    u'numpad7',
                c32.VK_NUMPAD8:    u'numpad8',
                c32.VK_NUMPAD9:    u'numpad9',
                c32.VK_DIVIDE:     u'divide',
                c32.VK_MULTIPLY:   u'multiply',
                c32.VK_ADD:        u'add',
                c32.VK_SUBTRACT:   u'subtract',
                c32.VK_DECIMAL:    u'vk_decimal'
               }

VkKeyScan = windll.user32.VkKeyScanA

def char_to_keyinfo(char, control=False, meta=False, shift=False):
    k=KeyPress()
    vk = VkKeyScan(ord(char))
    if vk & 0xffff == 0xffff:
        print u'VkKeyScan("%s") = %x' % (char, vk)
        raise ValueError, u'bad key'
    if vk & 0x100:
        k.shift = True
    if vk & 0x200:
        k.control = True
    if vk & 0x400:
        k.meta = True
    k.char=chr(vk & 0xff)
    return k

def make_KeyPress(char, state, keycode):
    control = (state & (4+8)) != 0
    meta = (state & (1+2)) != 0
    shift = (state & 0x10) != 0
    if control and not meta:#Matches ctrl- chords should pass keycode as char
        char = chr(keycode)
    elif control and meta:  #Matches alt gr and should just pass on char
        control = False
        meta = False
    try:
        keyname=code2sym_map[keycode]
    except KeyError:
        keyname = u""
    out = KeyPress(char, shift, control, meta, keyname)
    return out

if __name__==u"__main__":
    import startup
    