# -*- coding: utf-8 -*-
#*****************************************************************************
#       Copyright (C) 2003-2006 Gary Bishop.
#       Copyright (C) 2006  Jorgen Stenarson. <jorgen.stenarson@bostream.nu>
#
#  Distributed under the terms of the BSD License.  The full license is in
#  the file COPYING, distributed as part of this software.
#*****************************************************************************
import System
from common import validkey, KeyPress, make_KeyPress_from_keydescr

c32 = System.ConsoleKey
Shift = System.ConsoleModifiers.Shift
Control = System.ConsoleModifiers.Control
Alt = System.ConsoleModifiers.Alt
# table for translating virtual keys to X windows key symbols
code2sym_map = {#c32.CANCEL:    u'Cancel',
                c32.Backspace:  u'BackSpace',
                c32.Tab:        u'Tab',
                c32.Clear:      u'Clear',
                c32.Enter:      u'Return',
#                c32.Shift:     u'Shift_L',
#                c32.Control:   u'Control_L',
#                c32.Menu:      u'Alt_L',
                c32.Pause:      u'Pause',
#                c32.Capital:   u'Caps_Lock',
                c32.Escape:     u'Escape',
#                c32.Space:     u'space',
                c32.PageUp:     u'Prior',
                c32.PageDown:   u'Next',
                c32.End:        u'End',
                c32.Home:       u'Home',
                c32.LeftArrow:  u'Left',
                c32.UpArrow:    u'Up',
                c32.RightArrow: u'Right',
                c32.DownArrow:  u'Down',
                c32.Select:     u'Select',
                c32.Print:      u'Print',
                c32.Execute:    u'Execute',
#                c32.Snapshot:  u'Snapshot',
                c32.Insert:     u'Insert',
                c32.Delete:     u'Delete',
                c32.Help:       u'Help',
                c32.F1:         u'F1',
                c32.F2:         u'F2',
                c32.F3:         u'F3',
                c32.F4:         u'F4',
                c32.F5:         u'F5',
                c32.F6:         u'F6',
                c32.F7:         u'F7',
                c32.F8:         u'F8',
                c32.F9:         u'F9',
                c32.F10:        u'F10',
                c32.F11:        u'F11',
                c32.F12:        u'F12',
                c32.F13:        u'F13',
                c32.F14:        u'F14',
                c32.F15:        u'F15',
                c32.F16:        u'F16',
                c32.F17:        u'F17',
                c32.F18:        u'F18',
                c32.F19:        u'F19',
                c32.F20:        u'F20',
                c32.F21:        u'F21',
                c32.F22:        u'F22',
                c32.F23:        u'F23',
                c32.F24:        u'F24',
#                c32.Numlock:    u'Num_Lock,',
#                c32.Scroll:     u'Scroll_Lock',
#                c32.Apps:       u'VK_APPS',
#                c32.ProcesskeY: u'VK_PROCESSKEY',
#                c32.Attn:       u'VK_ATTN',
#                c32.Crsel:      u'VK_CRSEL',
#                c32.Exsel:      u'VK_EXSEL',
#                c32.Ereof:      u'VK_EREOF',
#                c32.Play:       u'VK_PLAY',
#                c32.Zoom:       u'VK_ZOOM',
#                c32.Noname:     u'VK_NONAME',
#                c32.Pa1:        u'VK_PA1',
                c32.OemClear:  u'VK_OEM_CLEAR',
                c32.NumPad0:    u'NUMPAD0',
                c32.NumPad1:    u'NUMPAD1',
                c32.NumPad2:    u'NUMPAD2',
                c32.NumPad3:    u'NUMPAD3',
                c32.NumPad4:    u'NUMPAD4',
                c32.NumPad5:    u'NUMPAD5',
                c32.NumPad6:    u'NUMPAD6',
                c32.NumPad7:    u'NUMPAD7',
                c32.NumPad8:    u'NUMPAD8',
                c32.NumPad9:    u'NUMPAD9',
                c32.Divide:     u'Divide',
                c32.Multiply:   u'Multiply',
                c32.Add:        u'Add',
                c32.Subtract:   u'Subtract',
                c32.Decimal:    u'VK_DECIMAL'
               }

# function to handle the mapping
def make_keysym(keycode):
    try:
        sym = code2sym_map[keycode]
    except KeyError:
        sym = u''
    return sym

sym2code_map = {}
for code,sym in code2sym_map.iteritems():
    sym2code_map[sym.lower()] = code

def key_text_to_keyinfo(keytext):
    u'''Convert a GNU readline style textual description of a key to keycode with modifiers'''
    if keytext.startswith('"'): # "
        return keyseq_to_keyinfo(keytext[1:-1])
    else:
        return keyname_to_keyinfo(keytext)


def char_to_keyinfo(char, control=False, meta=False, shift=False):
    vk = (ord(char))
    if vk & 0xffff == 0xffff:
        print u'VkKeyScan("%s") = %x' % (char, vk)
        raise ValueError, u'bad key'
    if vk & 0x100:
        shift = True
    if vk & 0x200:
        control = True
    if vk & 0x400:
        meta = True
    return (control, meta, shift, vk & 0xff)

def keyname_to_keyinfo(keyname):
    control = False
    meta = False
    shift = False

    while 1:
        lkeyname = keyname.lower()
        if lkeyname.startswith(u'control-'):
            control = True
            keyname = keyname[8:]
        elif lkeyname.startswith(u'ctrl-'):
            control = True
            keyname = keyname[5:]
        elif lkeyname.startswith(u'meta-'):
            meta = True
            keyname = keyname[5:]
        elif lkeyname.startswith(u'alt-'):
            meta = True
            keyname = keyname[4:]
        elif lkeyname.startswith(u'shift-'):
            shift = True
            keyname = keyname[6:]
        else:
            if len(keyname) > 1:
                return (control, meta, shift, sym2code_map.get(keyname.lower(),u" "))
            else:
                return char_to_keyinfo(keyname, control, meta, shift)

def keyseq_to_keyinfo(keyseq):
    res = []
    control = False
    meta = False
    shift = False

    while 1:
        if keyseq.startswith(u'\\C-'):
            control = True
            keyseq = keyseq[3:]
        elif keyseq.startswith(u'\\M-'):
            meta = True
            keyseq = keyseq[3:]
        elif keyseq.startswith(u'\\e'):
            res.append(char_to_keyinfo(u'\033', control, meta, shift))
            control = meta = shift = False
            keyseq = keyseq[2:]
        elif len(keyseq) >= 1:
            res.append(char_to_keyinfo(keyseq[0], control, meta, shift))
            control = meta = shift = False
            keyseq = keyseq[1:]
        else:
            return res[0]

def make_keyinfo(keycode, state):
    control = False
    meta  =False
    shift = False
    return (control, meta, shift, keycode)


def make_KeyPress(char, state, keycode):

    shift = bool(int(state) & int(Shift))
    control = bool(int(state) & int(Control))
    meta = bool(int(state) & int(Alt))
    keyname = code2sym_map.get(keycode, u"").lower()
    if control and meta: #equivalent to altgr so clear flags
        control = False
        meta = False    
    elif control:
        char = str(keycode)
    return KeyPress(char, shift, control, meta, keyname)

