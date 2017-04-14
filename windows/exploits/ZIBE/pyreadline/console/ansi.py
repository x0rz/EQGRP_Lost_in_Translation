# -*- coding: ISO-8859-1 -*-
import re,sys,os

terminal_escape = re.compile(u'(\001?\033\\[[0-9;]*m\002?)')
escape_parts = re.compile(u'\001?\033\\[([0-9;]*)m\002?')


class AnsiState(object):
    def __init__(self,bold=False,inverse=False,color=u"white",background=u"black",backgroundbold=False):
        self.bold = bold
        self.inverse = inverse
        self.color = color
        self.background = background
        self.backgroundbold = backgroundbold

    trtable = {u"black":0, u"red":4,      u"green":2,  u"yellow":6,
               u"blue":1,  u"magenta":5,  u"cyan":3,  u"white":7}
    revtable = dict(zip(trtable.values(),trtable.keys()))
    def get_winattr(self):
        attr = 0
        if self.bold:
            attr |= 0x0008
        if self.backgroundbold:
            attr |= 0x0080
        if self.inverse:
            attr |= 0x4000
        attr |= self.trtable[self.color]
        attr |= (self.trtable[self.background] << 4)
        return attr

    def set_winattr(self, attr):
        self.bold = bool(attr & 0x0008)
        self.backgroundbold = bool(attr & 0x0080)
        self.inverse = bool(attr & 0x4000)
        self.color = self.revtable[attr & 0x0007]
        self.background = self.revtable[(attr & 0x0070) >> 4]
        
    winattr=property(get_winattr,set_winattr)
    def __repr__(self):
        return u'AnsiState(bold=%s,inverse=%s,color=%9s,'    \
               u'background=%9s,backgroundbold=%s)# 0x%x'%   \
                (self.bold, self.inverse, '"%s"'%self.color,  
                 '"%s"'%self.background, self.backgroundbold,
                 self.winattr)

    def copy(self):
        x = AnsiState()
        x.bold = self.bold
        x.inverse = self.inverse
        x.color = self.color
        x.background = self.background
        x.backgroundbold = self.backgroundbold
        return x

defaultstate = AnsiState(False,False,u"white")

trtable = {0:u"black",  1:u"red",       2:u"green", 3:u"yellow",
           4:u"blue",   5:u"magenta",   6:u"cyan",  7:u"white"}

class AnsiWriter(object):
    def __init__(self, default=defaultstate):
        if isinstance(defaultstate, AnsiState):
            self.defaultstate = default
        else:
            self.defaultstate=AnsiState()
            self.defaultstate.winattr = defaultstate
            
            
    def write_color(self,text, attr=None):
        u'''write text at current cursor position and interpret color escapes.

        return the number of characters written.
        '''
        if isinstance(attr,AnsiState):
            defaultstate = attr
        elif attr is None:  #use attribute form initial console
            attr = self.defaultstate.copy()
        else:
            defaultstate = AnsiState()
            defaultstate.winattr = attr
            attr = defaultstate
        chunks = terminal_escape.split(text)
        n = 0 # count the characters we actually write, omitting the escapes
        res=[]
        for chunk in chunks:
            m = escape_parts.match(chunk)
            if m:
                parts = m.group(1).split(u";")
                if len(parts) == 1 and parts[0] == u"0":
                    attr = self.defaultstate.copy()
                    continue
                for part in parts:
                    if part == u"0": # No text attribute
                        attr = self.defaultstate.copy()
                        attr.bold=False
                    elif part == u"7": # switch on reverse
                        attr.inverse=True
                    elif part == u"1": # switch on bold (i.e. intensify foreground color)
                        attr.bold=True 
                    elif len(part) == 2 and u"30" <= part <= u"37": # set foreground color
                        attr.color = trtable[int(part) - 30]
                    elif len(part) == 2 and u"40" <= part <= u"47": # set background color
                        attr.backgroundcolor = trtable[int(part) - 40]
                continue
            n += len(chunk)
            if True:
                res.append((attr.copy(), chunk))
        return n,res

    def parse_color(self,text, attr=None):
        n,res=self.write_color(text, attr)
        return n, [attr.winattr for attr, text in res]

def write_color(text, attr=None):
    a = AnsiWriter(defaultstate)
    return a.write_color(text, attr)

def write_color_old( text, attr=None):
    u'''write text at current cursor position and interpret color escapes.

    return the number of characters written.
    '''
    res = []
    chunks = terminal_escape.split(text)
    n = 0 # count the characters we actually write, omitting the escapes
    if attr is None:#use attribute from initial console
        attr = 15
    for chunk in chunks:
        m = escape_parts.match(chunk)
        if m:
            for part in m.group(1).split(u";"):
                if part == u"0": # No text attribute
                    attr = 0
                elif part == u"7": # switch on reverse
                    attr |= 0x4000
                if part == u"1": # switch on bold (i.e. intensify foreground color)
                    attr |= 0x08
                elif len(part) == 2 and u"30" <= part <= u"37": # set foreground color
                    part = int(part)-30
                    # we have to mirror bits
                    attr = (attr & ~0x07) | ((part & 0x1) << 2) | (part & 0x2) | ((part & 0x4) >> 2)
                elif len(part) == 2 and u"40" <= part <= u"47": # set background color
                    part = int(part) - 40
                    # we have to mirror bits
                    attr = (attr & ~0x70) | ((part & 0x1) << 6) | ((part & 0x2) << 4) | ((part & 0x4) << 2)
                # ignore blink, underline and anything we don't understand
            continue
        n += len(chunk)
        if chunk:
            res.append((u"0x%x"%attr, chunk))
    return res


#trtable={0:"black",1:"red",2:"green",3:"yellow",4:"blue",5:"magenta",6:"cyan",7:"white"}

if __name__==u"__main__x":
    import pprint
    pprint=pprint.pprint

    s=u"\033[0;31mred\033[0;32mgreen\033[0;33myellow\033[0;34mblue\033[0;35mmagenta\033[0;36mcyan\033[0;37mwhite\033[0m"
    pprint (write_color(s))    
    pprint (write_color_old(s))
    s=u"\033[1;31mred\033[1;32mgreen\033[1;33myellow\033[1;34mblue\033[1;35mmagenta\033[1;36mcyan\033[1;37mwhite\033[0m"
    pprint (write_color(s))    
    pprint (write_color_old(s))    

    s=u"\033[0;7;31mred\033[0;7;32mgreen\033[0;7;33myellow\033[0;7;34mblue\033[0;7;35mmagenta\033[0;7;36mcyan\033[0;7;37mwhite\033[0m"
    pprint (write_color(s))    
    pprint (write_color_old(s))
    s=u"\033[1;7;31mred\033[1;7;32mgreen\033[1;7;33myellow\033[1;7;34mblue\033[1;7;35mmagenta\033[1;7;36mcyan\033[1;7;37mwhite\033[0m"
    pprint (write_color(s))    
    pprint (write_color_old(s))    

    
if __name__==u"__main__":
    import console
    import pprint
    pprint=pprint.pprint
    
    c=console.Console()
    c.write_color(u"dhsjdhs")
    c.write_color(u"\033[0;32mIn [\033[1;32m1\033[0;32m]:")
    print
    pprint (write_color(u"\033[0;32mIn [\033[1;32m1\033[0;32m]:"))    
    
if __name__==u"__main__x":
    import pprint
    pprint=pprint.pprint
    s=u"\033[0;31mred\033[0;32mgreen\033[0;33myellow\033[0;34mblue\033[0;35mmagenta\033[0;36mcyan\033[0;37mwhite\033[0m"
    pprint (write_color(s))    
