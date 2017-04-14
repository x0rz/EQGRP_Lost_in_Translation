# -*- coding: utf-8 -*-
#*****************************************************************************
#       Copyright (C) 2003-2006 Gary Bishop.
#       Copyright (C) 2006  Jorgen Stenarson. <jorgen.stenarson@bostream.nu>
#
#  Distributed under the terms of the BSD License.  The full license is in
#  the file COPYING, distributed as part of this software.
#*****************************************************************************
u'''Cursor control and color for the .NET console.
'''

#
# Ironpython requires a patch to work do:
#
# In file PythonCommandLine.cs patch line:     
#    class PythonCommandLine
#    {

# to:
#    public class PythonCommandLine
#    {
#
#
#
# primitive debug printing that won't interfere with the screen

import clr,sys
clr.AddReferenceToFileAndPath(sys.executable)
import IronPythonConsole

import sys
import re
import os

import System

from event import Event
from pyreadline.logger import log

from pyreadline.keysyms import \
    make_keysym, make_keyinfo, make_KeyPress, make_KeyPress_from_keydescr
from pyreadline.console.ansi import AnsiState
color = System.ConsoleColor

ansicolor={u"0;30": color.Black,
           u"0;31": color.DarkRed,
           u"0;32": color.DarkGreen,
           u"0;33": color.DarkYellow,
           u"0;34": color.DarkBlue,
           u"0;35": color.DarkMagenta,
           u"0;36": color.DarkCyan,
           u"0;37": color.DarkGray,
           u"1;30": color.Gray,
           u"1;31": color.Red,
           u"1;32": color.Green,
           u"1;33": color.Yellow,
           u"1;34": color.Blue,
           u"1;35": color.Magenta,
           u"1;36": color.Cyan,
           u"1;37": color.White
          }

winattr = {u"black" : 0,        u"darkgray" : 0+8,
           u"darkred" : 4,      u"red" : 4+8,
           u"darkgreen" : 2,    u"green" : 2+8,
           u"darkyellow" : 6,   u"yellow" : 6+8,
           u"darkblue" : 1,     u"blue" : 1+8,
           u"darkmagenta" : 5,  u"magenta" : 5+8,
           u"darkcyan" : 3,     u"cyan" : 3+8,
           u"gray" : 7,         u"white" : 7+8}

class Console(object):
    u'''Console driver for Windows.

    '''

    def __init__(self, newbuffer=0):
        u'''Initialize the Console object.

        newbuffer=1 will allocate a new buffer so the old content will be restored
        on exit.
        '''
        self.serial = 0
        self.attr = System.Console.ForegroundColor
        self.saveattr = winattr[str(System.Console.ForegroundColor).lower()]
        self.savebg = System.Console.BackgroundColor
        log(u'initial attr=%s' % self.attr)

    def _get(self):
        top = System.Console.WindowTop
        log(u"WindowTop:%s"%top)
        return top

    def _set(self, value):
        top = System.Console.WindowTop
        log(u"Set WindowTop:old:%s,new:%s"%(top, value))

    WindowTop = property(_get, _set)
    del _get, _set

    def __del__(self):
        u'''Cleanup the console when finished.'''
        # I don't think this ever gets called
        pass

    def pos(self, x=None, y=None):
        u'''Move or query the window cursor.'''
        if x is not None:
            System.Console.CursorLeft=x
        else:
            x = System.Console.CursorLeft
        if y is not None:
            System.Console.CursorTop=y
        else:
            y = System.Console.CursorTop
        return x, y

    def home(self):
        u'''Move to home.'''
        self.pos(0, 0)

# Map ANSI color escape sequences into Windows Console Attributes

    terminal_escape = re.compile(u'(\001?\033\\[[0-9;]*m\002?)')
    escape_parts = re.compile(u'\001?\033\\[([0-9;]*)m\002?')

    # This pattern should match all characters that change the cursor position differently
    # than a normal character.
    motion_char_re = re.compile(u'([\n\r\t\010\007])')

    def write_scrolling(self, text, attr=None):
        u'''write text at current cursor position while watching for scrolling.

        If the window scrolls because you are at the bottom of the screen
        buffer, all positions that you are storing will be shifted by the
        scroll amount. For example, I remember the cursor position of the
        prompt so that I can redraw the line but if the window scrolls,
        the remembered position is off.

        This variant of write tries to keep track of the cursor position
        so that it will know when the screen buffer is scrolled. It
        returns the number of lines that the buffer scrolled.

        '''
        x, y = self.pos()
        w, h = self.size()
        scroll = 0 # the result

        # split the string into ordinary characters and funny characters
        chunks = self.motion_char_re.split(text)
        for chunk in chunks:
            n = self.write_color(chunk, attr)
            if len(chunk) == 1: # the funny characters will be alone
                if chunk[0] == u'\n': # newline
                    x = 0
                    y += 1
                elif chunk[0] == u'\r': # carriage return
                    x = 0
                elif chunk[0] == u'\t': # tab
                    x = 8 * (int(x / 8) + 1)
                    if x > w: # newline
                        x -= w
                        y += 1
                elif chunk[0] == u'\007': # bell
                    pass
                elif chunk[0] == u'\010':
                    x -= 1
                    if x < 0:
                        y -= 1 # backed up 1 line
                else: # ordinary character
                    x += 1
                if x == w: # wrap
                    x = 0
                    y += 1
                if y == h: # scroll
                    scroll += 1
                    y = h - 1
            else: # chunk of ordinary characters
                x += n
                l = int(x / w) # lines we advanced
                x = x % w # new x value
                y += l
                if y >= h: # scroll
                    scroll += y - h + 1
                    y = h - 1
        return scroll

    trtable = {0 : color.Black,      4 : color.DarkRed,  2 : color.DarkGreen,
               6 : color.DarkYellow, 1 : color.DarkBlue, 5 : color.DarkMagenta,  
               3 : color.DarkCyan,   7 : color.Gray,     8 : color.DarkGray,   
               4+8 : color.Red,      2+8 : color.Green,  6+8 : color.Yellow,
               1+8 : color.Blue,     5+8 : color.Magenta,3+8 : color.Cyan,
               7+8 : color.White}

    def write_color(self, text, attr=None):
        '''write text at current cursor position and interpret color escapes.

        return the number of characters written.
        '''
        log(u'write_color("%s", %s)' % (text, attr))
        chunks = self.terminal_escape.split(text)
        log(u'chunks=%s' % repr(chunks))
        bg = self.savebg
        n = 0 # count the characters we actually write, omitting the escapes
        if attr is None:#use attribute from initial console
            attr = self.attr
        try:
            fg = self.trtable[(0x000f&attr)]
            bg = self.trtable[(0x00f0&attr)>>4]
        except TypeError:
            fg = attr
            
        for chunk in chunks:
            m = self.escape_parts.match(chunk)
            if m:
                log(m.group(1))
                attr = ansicolor.get(m.group(1), self.attr)
            n += len(chunk)
            System.Console.ForegroundColor = fg
            System.Console.BackgroundColor = bg
            System.Console.Write(chunk)
        return n

    def write_plain(self, text, attr=None):
        u'''write text at current cursor position.'''
        log(u'write("%s", %s)' %(text, attr))
        if attr is None:
            attr = self.attr
        n = c_int(0)
        self.SetConsoleTextAttribute(self.hout, attr)
        self.WriteConsoleA(self.hout, text, len(text), byref(n), None)
        return len(text)
        
    if os.environ.has_key(u"EMACS"):
        def write_color(self, text, attr=None):
            junk = c_int(0)
            self.WriteFile(self.hout, text, len(text), byref(junk), None)
            return len(text)
        write_plain = write_color

    # make this class look like a file object
    def write(self, text):
        log(u'write("%s")' % text)
        return self.write_color(text)

    #write = write_scrolling

    def isatty(self):
        return True

    def flush(self):
        pass

    def page(self, attr=None, fill=u' '):
        u'''Fill the entire screen.'''
        System.Console.Clear()

    def text(self, x, y, text, attr=None):
        u'''Write text at the given position.'''
        self.pos(x, y)
        self.write_color(text, attr)

    def clear_to_end_of_window(self):
        oldtop = self.WindowTop
        lastline = self.WindowTop+System.Console.WindowHeight
        pos = self.pos()
        w, h = self.size()
        length = w - pos[0] + min((lastline - pos[1] - 1), 5) * w - 1
        self.write_color(length * u" ")
        self.pos(*pos)
        self.WindowTop = oldtop
        
    def rectangle(self, rect, attr=None, fill=u' '):
        u'''Fill Rectangle.'''
        oldtop = self.WindowTop
        oldpos = self.pos()
        #raise NotImplementedError
        x0, y0, x1, y1 = rect
        if attr is None:
            attr = self.attr
        if fill:
            rowfill = fill[:1] * abs(x1 - x0)
        else:
            rowfill = u' ' * abs(x1 - x0)
        for y in range(y0, y1):
                System.Console.SetCursorPosition(x0, y)
                self.write_color(rowfill, attr)
        self.pos(*oldpos)

    def scroll(self, rect, dx, dy, attr=None, fill=' '):
        u'''Scroll a rectangle.'''
        raise NotImplementedError

    def scroll_window(self, lines):
        u'''Scroll the window by the indicated number of lines.'''
        top = self.WindowTop + lines
        if top < 0:
            top = 0
        if top + System.Console.WindowHeight > System.Console.BufferHeight:
            top = System.Console.BufferHeight
        self.WindowTop = top

    def getkeypress(self):
        u'''Return next key press event from the queue, ignoring others.'''
        ck = System.ConsoleKey
        while 1:
            e = System.Console.ReadKey(True)
            if e.Key == System.ConsoleKey.PageDown: #PageDown
                self.scroll_window(12)
            elif e.Key == System.ConsoleKey.PageUp:#PageUp
                self.scroll_window(-12)
            elif str(e.KeyChar) == u"\000":#Drop deadkeys
                log(u"Deadkey: %s"%e)
                return event(self, e)
            else:
                return event(self, e)

    def title(self, txt=None):
        u'''Set/get title.'''
        if txt:
            System.Console.Title = txt
        else:
            return System.Console.Title

    def size(self, width=None, height=None):
        u'''Set/get window size.'''
        sc = System.Console
        if width is not None and height is not None:
            sc.BufferWidth, sc.BufferHeight = width,height
        else:
            return sc.BufferWidth, sc.BufferHeight

        if width is not None and height is not None:
            sc.WindowWidth, sc.WindowHeight = width,height
        else:
            return sc.WindowWidth - 1, sc.WindowHeight - 1
    
    def cursor(self, visible=True, size=None):
        u'''Set cursor on or off.'''
        System.Console.CursorVisible = visible

    def bell(self):
        System.Console.Beep()

    def next_serial(self):
        u'''Get next event serial number.'''
        self.serial += 1
        return self.serial

class event(Event):
    u'''Represent events from the console.'''
    def __init__(self, console, input):
        u'''Initialize an event from the Windows input structure.'''
        self.type = u'??'
        self.serial = console.next_serial()
        self.width = 0
        self.height = 0
        self.x = 0
        self.y = 0
        self.char = str(input.KeyChar)
        self.keycode = input.Key
        self.state = input.Modifiers
        log(u"%s,%s,%s"%(input.Modifiers, input.Key, input.KeyChar))
        self.type = "KeyRelease"
        self.keysym = make_keysym(self.keycode)
        self.keyinfo = make_KeyPress(self.char, self.state, self.keycode)

def make_event_from_keydescr(keydescr):
    def input():
        return 1
    input.KeyChar = u"a"
    input.Key = System.ConsoleKey.A
    input.Modifiers = System.ConsoleModifiers.Shift
    input.next_serial = input
    e = event(input,input)
    del input.next_serial
    keyinfo = make_KeyPress_from_keydescr(keydescr)
    e.keyinfo = keyinfo
    return e

CTRL_C_EVENT=make_event_from_keydescr(u"Control-c")

def install_readline(hook):
    def hook_wrap():
        try:
            res = hook()
        except KeyboardInterrupt,x:   #this exception does not seem to be caught
            res = u""
        except EOFError:
            return None
        if res[-1:] == u"\n":
            return res[:-1]
        else:
            return res
    class IronPythonWrapper(IronPythonConsole.IConsole):
        def ReadLine(self, autoIndentSize): 
            return hook_wrap()
        def Write(self, text, style):
            System.Console.Write(text)
        def WriteLine(self, text, style): 
            System.Console.WriteLine(text)
    IronPythonConsole.PythonCommandLine.MyConsole = IronPythonWrapper()



if __name__ == u'__main__':
    import time, sys
    c = Console(0)
    sys.stdout = c
    sys.stderr = c
    c.page()
    c.pos(5, 10)
    c.write(u'hi there')
    c.title(u"Testing console")
#    c.bell()
    print
    print u"size", c.size()
    print u'  some printed output'
    for i in range(10):
        e = c.getkeypress()
        print e.Key, chr(e.KeyChar), ord(e.KeyChar), e.Modifiers
    del c

    System.Console.Clear()
