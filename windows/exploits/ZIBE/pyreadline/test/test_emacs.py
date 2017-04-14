# -*- coding: utf-8 -*-
#*****************************************************************************
#       Copyright (C) 2006  Michael Graz. <mgraz@plan10.com>
#       Copyright (C) 2006  Michael Graz. <mgraz@plan10.com>
#
#  Distributed under the terms of the BSD License.  The full license is in
#  the file COPYING, distributed as part of this software.
#*****************************************************************************

import sys, unittest
import pdb
sys.path.append (u'../..')
from pyreadline.modes.emacs import *
from pyreadline import keysyms
from pyreadline.lineeditor import lineobj

from common import *
from pyreadline.logger import log
import pyreadline.logger as logger
logger.sock_silent=True
logger.show_event=[u"debug"]

#----------------------------------------------------------------------


class EmacsModeTest (EmacsMode):
    tested_commands={}
    def __init__ (self):
        EmacsMode.__init__ (self, MockReadline())
        self.mock_console = MockConsole ()
        self.init_editing_mode (None)
        self.lst_completions = []
        self.completer = self.mock_completer
        self.completer_delims = u' u'
        self.tabstop = 4
        self.mark_directories=False
        self.show_all_if_ambiguous=False
        
    def get_mock_console (self):
        return self.mock_console
    console = property (get_mock_console)

    def _set_line (self, text):
        self.l_buffer.set_line (text)

    def get_line (self):
        return self.l_buffer.get_line_text ()
    line = property (get_line)

    def get_line_cursor (self):
        return self.l_buffer.point
    line_cursor = property (get_line_cursor)

    def input (self, keytext):
        if keytext[0:1] == u'"' and keytext[-1:] == u'"':
            lst_key = [u'"%s"' % c for c in keytext[1:-1]]
        else:
            lst_key = [keytext]
        for key in lst_key:
            keyinfo, event = keytext_to_keyinfo_and_event (key)
            dispatch_func = self.key_dispatch.get(keyinfo.tuple(),self.self_insert)
            self.tested_commands[dispatch_func.__name__]=dispatch_func
            log(u"keydisp: %s %s"%( key,dispatch_func.__name__))
            dispatch_func (event)
            self.previous_func=dispatch_func

    def accept_line (self, e):
        if EmacsMode.accept_line (self, e):
            # simulate return
            # self.add_history (self.line)
            self.l_buffer.reset_line ()

    def mock_completer (self, text, state):
        return self.lst_completions [state]

#----------------------------------------------------------------------

class TestsKeyinfo (unittest.TestCase):

    def test_keyinfo (self):
        keyinfo, event = keytext_to_keyinfo_and_event (u'"d"')
        self.assertEqual (u'd', event.char)
        keyinfo, event = keytext_to_keyinfo_and_event (u'"D"')
        self.assertEqual (u'D', event.char)
        keyinfo, event = keytext_to_keyinfo_and_event (u'"$"')
        self.assertEqual (u'$', event.char)
        keyinfo, event = keytext_to_keyinfo_and_event (u'Escape')
        self.assertEqual (u'\x1b', event.char)


class TestsMovement (unittest.TestCase):
    def test_cursor (self):
        r = EmacsModeTest ()
        self.assertEqual (r.line, u'')
        r.input(u'"First Second Third"')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 18)
        r.input(u'Control-a')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 0)
        r.input(u'Control-e')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 18)
        r.input(u'Home')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 0)
        r.input(u'Right')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 1)
        r.input(u'Ctrl-f')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 2)
        r.input(u'Ctrl-Right')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 5)
        r.input(u'Ctrl-Right')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 12)
        r.input(u'Ctrl-Right')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 18)
        r.input(u'Ctrl-Right')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 18)
        r.input(u'Ctrl-Left')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 13)
        r.input(u'Ctrl-Left')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 6)
        r.input(u'Ctrl-Left')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 0)
        r.input(u'Ctrl-Left')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 0)


class TestsDelete (unittest.TestCase):
    def test_delete (self):
        r = EmacsModeTest ()
        self.assertEqual (r.line, u'')
        r.input(u'"First Second Third"')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 18)
        r.input(u'Delete')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 18)
        r.input(u'Left')
        r.input(u'Left')
        r.input(u'Delete')
        self.assertEqual (r.line, u'First Second Thid')
        self.assertEqual (r.line_cursor, 16)
        r.input(u'Delete')
        self.assertEqual (r.line, u'First Second Thi')
        self.assertEqual (r.line_cursor, 16)
        r.input(u'Backspace')
        self.assertEqual (r.line, u'First Second Th')
        self.assertEqual (r.line_cursor, 15)
        r.input(u'Home')
        r.input(u'Right')
        r.input(u'Right')
        self.assertEqual (r.line, u'First Second Th')
        self.assertEqual (r.line_cursor, 2)
        r.input(u'Backspace')
        self.assertEqual (r.line, u'Frst Second Th')
        self.assertEqual (r.line_cursor, 1)
        r.input(u'Backspace')
        self.assertEqual (r.line, u'rst Second Th')
        self.assertEqual (r.line_cursor, 0)
        r.input(u'Backspace')
        self.assertEqual (r.line, u'rst Second Th')
        self.assertEqual (r.line_cursor, 0)
        r.input(u'Escape')
        self.assertEqual (r.line, u'')
        self.assertEqual (r.line_cursor, 0)
        
    def test_delete_word (self):
        r = EmacsModeTest ()
        self.assertEqual (r.line, u'')
        r.input(u'"First Second Third"')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 18)
        r.input(u'Control-Backspace')
        self.assertEqual (r.line, u'First Second ')
        self.assertEqual (r.line_cursor, 13)
        r.input(u'Backspace')
        r.input(u'Left')
        r.input(u'Left')
        self.assertEqual (r.line, u'First Second')
        self.assertEqual (r.line_cursor, 10)
        r.input(u'Control-Backspace')
        self.assertEqual (r.line, u'First nd')
        self.assertEqual (r.line_cursor, 6)
        r.input(u'Escape')
        self.assertEqual (r.line, u'')
        self.assertEqual (r.line_cursor, 0)
        r.input(u'"First Second Third"')
        r.input(u'Home')
        r.input(u'Right')
        r.input(u'Right')
        r.input(u'Control-Delete')
        self.assertEqual (r.line, u'FiSecond Third')
        self.assertEqual (r.line_cursor, 2)
        r.input(u'Control-Delete')
        self.assertEqual (r.line, u'FiThird')
        self.assertEqual (r.line_cursor, 2)
        r.input(u'Control-Delete')
        self.assertEqual (r.line, u'Fi')
        self.assertEqual (r.line_cursor, 2)
        r.input(u'Control-Delete')
        self.assertEqual (r.line, u'Fi')
        self.assertEqual (r.line_cursor, 2)
        r.input(u'Escape')
        self.assertEqual (r.line, u'')
        self.assertEqual (r.line_cursor, 0)



class TestsSelectionMovement (unittest.TestCase):
    def test_cursor (self):
        r = EmacsModeTest ()
        self.assertEqual (r.line, u'')
        r.input(u'"First Second Third"')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 18)
        self.assertEqual (r.l_buffer.selection_mark, -1)
        r.input(u'Home')
        r.input(u'Shift-Right')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 1)
        self.assertEqual (r.l_buffer.selection_mark, 0)
        r.input(u'Shift-Control-Right')
        self.assertEqual (r.line, u'First Second Third')
        self.assertEqual (r.line_cursor, 5)
        self.assertEqual (r.l_buffer.selection_mark, 0)
        r.input(u'"a"')
        self.assertEqual (r.line, u'a Second Third')
        self.assertEqual (r.line_cursor, 1)
        self.assertEqual (r.l_buffer.selection_mark, -1)
        r.input(u'Shift-End')
        self.assertEqual (r.line, u'a Second Third')
        self.assertEqual (r.line_cursor, 14)
        self.assertEqual (r.l_buffer.selection_mark, 1)
        r.input(u'Delete')
        self.assertEqual (r.line, u'a')
        self.assertEqual (r.line_cursor, 1)
        self.assertEqual (r.l_buffer.selection_mark, -1)



class TestsHistory (unittest.TestCase):
    def test_history_1 (self):
        r = EmacsModeTest ()
        r.add_history (u'aa')
        r.add_history (u'bbb')
        self.assertEqual (r.line, u'')
        r.input (u'Up')
        self.assertEqual (r.line, u'bbb')
        self.assertEqual (r.line_cursor, 3)
        r.input (u'Up')
        self.assertEqual (r.line, u'aa')
        self.assertEqual (r.line_cursor, 2)
        r.input (u'Up')
        self.assertEqual (r.line, u'aa')
        self.assertEqual (r.line_cursor, 2)
        r.input (u'Down')
        self.assertEqual (r.line, u'bbb')
        self.assertEqual (r.line_cursor, 3)
        r.input (u'Down')
        self.assertEqual (r.line, u'')
        self.assertEqual (r.line_cursor, 0)

    def test_history_2 (self):
        r = EmacsModeTest ()
        r.add_history (u'aaaa')
        r.add_history (u'aaba')
        r.add_history (u'aaca')
        r.add_history (u'akca')
        r.add_history (u'bbb')
        r.add_history (u'ako')
        self.assert_line(r,'',0)
        r.input (u'"a"')
        r.input (u'Up')
        self.assert_line(r,'ako',1)
        r.input (u'Up')
        self.assert_line(r,'akca',1)
        r.input (u'Up')
        self.assert_line(r,'aaca',1)
        r.input (u'Up')
        self.assert_line(r,'aaba',1)
        r.input (u'Up')
        self.assert_line(r,'aaaa',1)
        r.input (u'Right')
        self.assert_line(r,'aaaa',2)
        r.input (u'Down')
        self.assert_line(r,'aaba',2)
        r.input (u'Down')
        self.assert_line(r,'aaca',2)
        r.input (u'Down')
        self.assert_line(r,'aaca',2)
        r.input (u'Left')
        r.input (u'Left')
        r.input (u'Down')
        r.input (u'Down')
        self.assert_line(r,'bbb',3)
        r.input (u'Left')
        self.assert_line(r,'bbb',2)
        r.input (u'Down')
        self.assert_line(r,'bbb',2)
        r.input (u'Up')
        self.assert_line(r,'bbb',2)


    def test_history_3 (self):
        r = EmacsModeTest ()
        r.add_history (u'aaaa')
        r.add_history (u'aaba')
        r.add_history (u'aaca')
        r.add_history (u'akca')
        r.add_history (u'bbb')
        r.add_history (u'ako')
        self.assert_line(r,'',0)
        r.input (u'')
        r.input (u'Up')
        self.assert_line(r,'ako',3)
        r.input (u'Down')
        self.assert_line(r,'',0)
        r.input (u'Up')
        self.assert_line(r,'ako',3)

    def test_history_3 (self):
        r = EmacsModeTest ()
        r.add_history (u'aaaa')
        r.add_history (u'aaba')
        r.add_history (u'aaca')
        r.add_history (u'akca')
        r.add_history (u'bbb')
        r.add_history (u'ako')
        self.assert_line(r,'',0)
        r.input (u'k')
        r.input (u'Up')
        self.assert_line(r,'k',1)

    def test_complete (self):
        import rlcompleter
        logger.sock_silent = False

        log("-" * 50)
        r = EmacsModeTest()
        completerobj = rlcompleter.Completer()
        def _nop(val, word):
            return word
        completerobj._callable_postfix = _nop
        r.completer = completerobj.complete
        r._bind_key("tab", r.complete)
        r.input(u'"exi(ksdjksjd)"')
        r.input(u'Control-a')
        r.input(u'Right')
        r.input(u'Right')
        r.input(u'Right')
        r.input(u'Tab')
        self.assert_line(r, u"exit(ksdjksjd)", 4)

        r.input(u'Escape')
        r.input(u'"exi"')
        r.input(u'Control-a')
        r.input(u'Right')
        r.input(u'Right')
        r.input(u'Right')
        r.input(u'Tab')
        self.assert_line(r, u"exit", 4)

        
        
    def assert_line(self,r,line,cursor):
        self.assertEqual (r.line, line)
        self.assertEqual (r.line_cursor, cursor)
        
#----------------------------------------------------------------------
# utility functions

#----------------------------------------------------------------------

if __name__ == u'__main__':
    Tester()
    tested=EmacsModeTest.tested_commands.keys()    
    tested.sort()
#    print " Tested functions ".center(60,"-")
#    print "\n".join(tested)
#    print
    
    all_funcs=dict([(x.__name__,x) for x in EmacsModeTest().key_dispatch.values()])
    all_funcs=all_funcs.keys()
    not_tested=[x for x in all_funcs if x not in tested]
    not_tested.sort()
    print " Not tested functions ".center(60,"-")
    print "\n".join(not_tested)
    
    
