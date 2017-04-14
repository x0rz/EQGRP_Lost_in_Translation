# Copyright (C) 2006  Michael Graz. <mgraz@plan10.com>

import sys, unittest
sys.path.append (u'../..')
#from pyreadline.modes.vi import *
#from pyreadline import keysyms
from pyreadline.lineeditor import lineobj

#----------------------------------------------------------------------


#----------------------------------------------------------------------

class Test_copy (unittest.TestCase):
    def test_copy1 (self):
        l=lineobj.ReadLineTextBuffer(u"first second")
        q=l.copy()
        self.assertEqual(q.get_line_text(),l.get_line_text())
        self.assertEqual(q.point,l.point)
        self.assertEqual(q.mark,l.mark)
        
    def test_copy2 (self):
        l=lineobj.ReadLineTextBuffer(u"first second",point=5)
        q=l.copy()
        self.assertEqual(q.get_line_text(),l.get_line_text())
        self.assertEqual(q.point,l.point)
        self.assertEqual(q.mark,l.mark)
        

class Test_linepos (unittest.TestCase):
    t="test text"
    def test_NextChar (self):
        t=self.t
        l=lineobj.ReadLineTextBuffer(t)
        for i in range(len(t)):
            self.assertEqual(i,l.point)
            l.point=lineobj.NextChar
        #advance past end of buffer            
        l.point=lineobj.NextChar
        self.assertEqual(len(t),l.point)

    def test_PrevChar (self):
        t=self.t
        l=lineobj.ReadLineTextBuffer(t,point=len(t))
        for i in range(len(t)):
            self.assertEqual(len(t)-i,l.point)
            l.point=lineobj.PrevChar
        #advance past beginning of buffer            
        l.point=lineobj.PrevChar
        self.assertEqual(0,l.point)

    def test_EndOfLine (self):
        t=self.t
        l=lineobj.ReadLineTextBuffer(t,point=len(t))
        for i in range(len(t)):
            l.point=i
            l.point=lineobj.EndOfLine
            self.assertEqual(len(t),l.point)
                        
    def test_StartOfLine (self):
        t=self.t
        l=lineobj.ReadLineTextBuffer(t,point=len(t))
        for i in range(len(t)):
            l.point=i
            l.point=lineobj.StartOfLine
            self.assertEqual(0,l.point)
                        

class Tests_linepos2(Test_linepos):
    t="kajkj"
            
class Tests_linepos3(Test_linepos):
    t=""


class Test_movement (unittest.TestCase):
    def test_NextChar (self):
        cmd=lineobj.NextChar
        tests=[
        # u"First"
         (cmd,
          u"First",
          u"#     u",
          u" #    u"),
         (cmd,
          u"First",
          u"    # u",
          u"     #"),
         (cmd,
          u"First",
          u"     #",
          u"     #"),
          ]
        for cmd,text,init_point,expected_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            l.point=cmd
            self.assertEqual(get_point_pos(expected_point),l.point)
        
    def test_PrevChar (self):
        cmd=lineobj.PrevChar
        tests=[
        # u"First"
         (cmd,
          u"First",
          u"     #",
          u"    # u"),
         (cmd,
          u"First",
          u" #   u",
          u"#    u"),
         (cmd,
          u"First",
          u"#     u",
          u"#     u"),
          ]
        for cmd,text,init_point,expected_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            l.point=cmd
            self.assertEqual(get_point_pos(expected_point),l.point)
        
        
        
    def test_PrevWordStart (self):
        cmd=lineobj.PrevWordStart
        tests=[
        # u"First Second Third"
         (cmd,
          u"First Second Third",
          u"                  #",
          u"             #     u"),
         (cmd,
          u"First Second Third",
          u"             #     u",
          u"      #            u"),
         (cmd,
          u"First Second Third",
          u"     #             u",
          u"#                  u"),
         (cmd,
          u"First Second Third",
          u"#                  u",
          u"#                  u"),
          ]
        for cmd,text,init_point,expected_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            l.point=cmd
            self.assertEqual(get_point_pos(expected_point),l.point)
        
    def test_NextWordStart (self):
        cmd=lineobj.NextWordStart
        tests=[
        # u"First Second Third"
         (cmd,
          u"First Second Third",
          u"#                 u",
          u"      #           u"),
         (cmd,
          u"First Second Third",
          u"    #             u",
          u"      #           u"),
         (cmd,
          u"First Second Third",
          u"      #            u",
          u"             #     u"),
         (cmd,
          u"First Second Third",
          u"              #    u",
          u"                  #"),
          ]
        for cmd,text,init_point,expected_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            l.point=cmd
            self.assertEqual(get_point_pos(expected_point),l.point)
        
    def test_NextWordEnd (self):
        cmd=lineobj.NextWordEnd
        tests=[
        # u"First Second Third"
         (cmd,
          u"First Second Third",
          u"#                 u",
          u"     #            u"),
         (cmd,
          u"First Second Third",
          u"    #             u",
          u"     #            u"),
         (cmd,
          u"First Second Third",
          u"      #            u",
          u"            #      u"),
         (cmd,
          u"First Second Third",
          u"              #    u",
          u"                  #"),
          ]
        for cmd,text,init_point,expected_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            l.point=cmd
            self.assertEqual(get_point_pos(expected_point),l.point)
        
    def test_PrevWordEnd (self):
        cmd=lineobj.PrevWordEnd
        tests=[
        # u"First Second Third"
         (cmd,
          u"First Second Third",
          u"                  #",
          u"            #      u"),
         (cmd,
          u"First Second Third",
          u"            #      u",
          u"     #             u"),
         (cmd,
          u"First Second Third",
          u"     #             u",
          u"#                  u"),
         (cmd,
          u"First Second Third",
          u"#                  u",
          u"#                  u"),          
          ]
        for cmd,text,init_point,expected_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            l.point=cmd
            self.assertEqual(get_point_pos(expected_point),l.point)
        
    def test_WordEnd_1 (self):
        cmd=lineobj.WordEnd
        tests=[
        # u"First Second Third"
         (cmd,
          u"First Second Third",
          u"#                  u",
          u"     #             u"),
         (cmd,
          u"First Second Third",
          u" #                 u",
          u"     #             u"),
         (cmd,
          u"First Second Third",
          u"             #     u",
          u"                  #"),
          ]
        for cmd,text,init_point,expected_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            l.point=cmd
            self.assertEqual(get_point_pos(expected_point),l.point)

    def test_WordEnd_2 (self):
        cmd=lineobj.WordEnd
        tests=[
        # u"First Second Third"
         (cmd,
          u"First Second Third",
          u"     #             u"),
         (cmd,
          u"First Second Third",
          u"            #      u"),
         (cmd,
          u"First Second Third",
          u"                  #"),
          ]

        for cmd,text,init_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            self.assertRaises(lineobj.NotAWordError,cmd,l)
        
        
    def test_WordStart_1 (self):
        cmd=lineobj.WordStart
        tests=[
        # u"First Second Third"
         (cmd,
          u"First Second Third",
          u"#                  u",
          u"#                  u"),
         (cmd,
          u"First Second Third",
          u" #                 u",
          u"#                  u"),
         (cmd,
          u"First Second Third",
          u"               #   u",
          u"             #     u"),
          ]
        for cmd,text,init_point,expected_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            l.point=cmd
            self.assertEqual(get_point_pos(expected_point),l.point)
        
    def test_WordStart_2 (self):
        cmd=lineobj.WordStart
        tests=[
        # u"First Second Third"
         (cmd,
          u"First Second Third",
          u"     #             u"),
         (cmd,
          u"First Second Third",
          u"            #      u"),
         (cmd,
          u"First Second Third",
          u"                  #"),
          ]

        for cmd,text,init_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            self.assertRaises(lineobj.NotAWordError,cmd,l)
        

    def test_StartOfLine (self):
        cmd=lineobj.StartOfLine
        tests=[
        # u"First Second Third"
         (cmd,
          u"First Second Third",
          u"#                 u",
          u"#                 u"),
         (cmd,
          u"First Second Third",
          u"         #         u",
          u"#                  u"),
         (cmd,
          u"First Second Third",
          u"                  #",
          u"#                  u"),
          ]
        for cmd,text,init_point,expected_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            l.point=cmd
            self.assertEqual(get_point_pos(expected_point),l.point)
        
    def test_EndOfLine (self):
        cmd=lineobj.EndOfLine
        tests=[
        # u"First Second Third"
         (cmd,
          u"First Second Third",
          u"#                 u",
          u"                  #"),
         (cmd,
          u"First Second Third",
          u"         #         u",
          u"                  #"),
         (cmd,
          u"First Second Third",
          u"                  #",
          u"                  #"),
          ]
        for cmd,text,init_point,expected_point in tests:
            l=lineobj.ReadLineTextBuffer(text,get_point_pos(init_point))
            l.point=cmd
            self.assertEqual(get_point_pos(expected_point),l.point)

    def test_Point(self):
        cmd=lineobj.Point
        tests=[
        # u"First Second Third"
         (cmd,
          u"First Second Third",
          0),
         (cmd,
          u"First Second Third",
          12),
         (cmd,
          u"First Second Third",
          18),
          ]
        for cmd,text,p in tests:
            l=lineobj.ReadLineTextBuffer(text,p)
            self.assertEqual(p,cmd(l))


#----------------------------------------------------------------------
# utility functions

def get_point_pos(pstr):
    return pstr.index(u"#")

def get_mark_pos(mstr):
    try:
        return mstr.index(u"#")
    except ValueError:
        return -1
#----------------------------------------------------------------------

if __name__ == u'__main__':
    unittest.main()

    l=lineobj.ReadLineTextBuffer(u"First Second Third")
