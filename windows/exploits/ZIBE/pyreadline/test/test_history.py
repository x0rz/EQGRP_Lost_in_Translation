# -*- coding: UTF-8 -*-
# Copyright (C) 2007 Jörgen Stenarson. <>

import sys, unittest
sys.path.append (u'../..')
#from pyreadline.modes.vi import *
#from pyreadline import keysyms
from pyreadline.lineeditor import lineobj
from pyreadline.lineeditor.history import LineHistory
import pyreadline.lineeditor.history as history

import pyreadline.logger
pyreadline.logger.sock_silent=False
from pyreadline.logger import log
#----------------------------------------------------------------------


#----------------------------------------------------------------------
RL=lineobj.ReadLineTextBuffer

class Test_prev_next_history(unittest.TestCase):
    t = u"test text"

    def setUp(self):
        self.q = q = LineHistory()
        for x in [u"aaaa", u"aaba", u"aaca", u"akca", u"bbb", u"ako"]:
            q.add_history(RL(x))

    def test_previous_history (self):
        hist = self.q
        assert hist.history_cursor == 6
        l = RL(u"")
        hist.previous_history(l)
        assert l.get_line_text() == u"ako"
        hist.previous_history(l)
        assert l.get_line_text() == u"bbb"
        hist.previous_history(l)
        assert l.get_line_text() == u"akca"
        hist.previous_history(l)
        assert l.get_line_text() == u"aaca"
        hist.previous_history(l)
        assert l.get_line_text() == u"aaba"
        hist.previous_history(l)
        assert l.get_line_text() == u"aaaa"
        hist.previous_history(l)
        assert l.get_line_text() == u"aaaa"

    def test_next_history (self):
        hist=self.q
        hist.beginning_of_history()
        assert hist.history_cursor==0
        l=RL(u"")
        hist.next_history(l)
        assert l.get_line_text()==u"aaba"
        hist.next_history(l)
        assert l.get_line_text()==u"aaca"
        hist.next_history(l)
        assert l.get_line_text()==u"akca"
        hist.next_history(l)
        assert l.get_line_text()==u"bbb"
        hist.next_history(l)
        assert l.get_line_text()==u"ako"
        hist.next_history(l)
        assert l.get_line_text()==u"ako"

class Test_prev_next_history(unittest.TestCase):
    t = u"test text"

    def setUp(self):
        self.q = q = LineHistory()
        for x in [u"aaaa",u"aaba",u"aaca",u"akca",u"bbb",u"ako"]:
            q.add_history(RL(x))
        
    def test_history_search_backward (self):
        q = LineHistory()
        for x in [u"aaaa",u"aaba",u"aaca",u"    aacax",u"akca",u"bbb",u"ako"]:
            q.add_history(RL(x))
        a=RL(u"aa",point=2)
        for x in [u"aaca",u"aaba",u"aaaa",u"aaaa"]:
            res=q.history_search_backward(a)
            assert res.get_line_text()==x
        
    def test_history_search_forward (self):
        q = LineHistory()
        for x in [u"aaaa",u"aaba",u"aaca",u"    aacax",u"akca",u"bbb",u"ako"]:
            q.add_history(RL(x))
        q.beginning_of_history()
        a=RL(u"aa",point=2)
        for x in [u"aaba",u"aaca",u"aaca"]:
            res=q.history_search_forward(a)
            assert res.get_line_text()==x

class Test_history_search_incr_fwd_backwd(unittest.TestCase):
    def setUp(self):
        self.q = q = LineHistory()
        for x in [u"aaaa",u"aaba",u"aaca",u"akca",u"bbb",u"ako"]:
            q.add_history(RL(x))

    def test_backward_1(self):
        q = self.q
        self.assertEqual(q.reverse_search_history(u"b"), u"bbb") 
        self.assertEqual(q.reverse_search_history(u"b"), u"aaba") 
        self.assertEqual(q.reverse_search_history(u"bb"), u"aaba") 

    def test_backward_2(self):
        q = self.q
        self.assertEqual(q.reverse_search_history(u"a"), u"ako") 
        self.assertEqual(q.reverse_search_history(u"aa"), u"aaca") 
        self.assertEqual(q.reverse_search_history(u"a"), u"aaca") 
        self.assertEqual(q.reverse_search_history(u"ab"), u"aaba") 


    def test_forward_1(self):
        q = self.q
        self.assertEqual(q.forward_search_history(u"a"), u"ako") 

    def test_forward_2(self):
        q = self.q
        q.history_cursor = 0
        self.assertEqual(q.forward_search_history(u"a"), u"aaaa") 
        self.assertEqual(q.forward_search_history(u"a"), u"aaba") 
        self.assertEqual(q.forward_search_history(u"ak"), u"akca") 
        self.assertEqual(q.forward_search_history(u"akl"), u"akca") 
        self.assertEqual(q.forward_search_history(u"ak"), u"akca") 
        self.assertEqual(q.forward_search_history(u"ako"), u"ako") 
        
class Test_empty_history_search_incr_fwd_backwd(unittest.TestCase):
    def setUp(self):
        self.q = q = LineHistory()

    def test_backward_1(self):
        q = self.q
        self.assertEqual(q.reverse_search_history(u"b"), u"") 

    def test_forward_1(self):
        q = self.q
        self.assertEqual(q.forward_search_history(u"a"), u"") 


#----------------------------------------------------------------------
# utility functions

#----------------------------------------------------------------------

if __name__ == u'__main__':
    unittest.main()

    l=lineobj.ReadLineTextBuffer(u"First Second Third")