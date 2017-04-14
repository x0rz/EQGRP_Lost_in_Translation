"""
Port of the C figlet driver to Python.  Ugly, gross, not fully working, but
does what I need to display a simple banner with a hand selected set of fonts.
"""
import sys
import os
import random

__all__ = ['newbanner']

def newbanner(fontdir, msg):
    """
    Returns msg converted to a random ascii art font from the given
    fontdir.
    """
    try:
        font = get_randfont(fontdir)
        if not font:
            return "", ""
        f = Fig(font)
        f.addline(msg)
    except:
        return "", ""

    return f.getline(),font

def get_randfont(fontdir):
    fonts = get_fontdirlist(fontdir)
    if not fonts:
        return None
    index = random.randint(0, len(fonts) - 1)
    return fonts[index]

def get_fontdirlist(fontdir='fonts'):
    fonts = [fontdir + os.path.sep + item 
             for item in os.listdir(fontdir) 
             if item.endswith(".flf")]
    return fonts

class Fig:
    hdr = {}
    def __init__(self, fontfile=None):
        if fontfile:
            self.init_fonts(fontfile)
        self.clearline()


    """
    Font File parsing
    """
    def init_fonts(self, fontfile=None):
        if fontfile:
            self.fontfile = fontfile
        file = open(self.fontfile)
        self.parse_header(file.readline().split())
        self.parse_comments(file)
        self.parse_chars(file)
        file.close()

    def parse_header(self, header):
        self.hdr['signature']    = header[0][:-1]
        self.hdr['hardblank']    = header[0][-1]
        self.hdr['height']       = int(header[1])
        self.hdr['baseline']     = header[2]
        self.hdr['maxlength']    = int(header[3])
        self.hdr['oldlayout']    = header[4]
        self.hdr['commentlines'] = int(header[5])
        try:
            self.hdr['printdir']     = header[6]
            self.hdr['fulllayout']   = header[7]
            self.hdr['codetagcount'] = header[8]
        except:
            self.hdr['printdir']     = ""
            self.hdr['fulllayout']   = ""
            self.hdr['codetagcount'] = ""
        if self.hdr['signature'] != "flf2a":
            self.hdr = {}
            return False
        return True

    def parse_comments(self, file):
        for i in range(0, self.hdr['commentlines']):
            line = file.readline()
            del line

    def parse_chars(self, file):    
        self.chars = {}
        for c in range(32,127):
            self.chars[chr(c)] = []
            for i in range(0, self.hdr['height']):
                self.chars[chr(c)].append(list(file.readline().rstrip("@#\r\n")))

    def getletter(self, c):
        self.previouscharwidth = self.currcharwidth
        self.currcharwidth = len(self.chars[c][0])
        return self.chars[c]

    def len_letter(self, letter):
        return len(letter[0])

    """
    Input Handling
    """
    def smushmem(self, ch1, ch2):
        special = "|/\\[]{}()<>"
        if ch1 == ' ':
            return ch2
        if ch2 == ' ':
            return ch1
        if self.previouscharwidth < 2 or self.currcharwidth < 2:
            return '\0'
        if ch1 == self.hdr['hardblank'] or ch2 == self.hdr['hardblank']:
            return '\0'
        if ch1 == ch2:
            return ch1
        if ch1 == '_' and ch2 in special:
            return ch2
        if ch2 == '_' and ch1 in special:
            return ch1
        if ch1 == "|" and ch2 in special[1:]:
            return ch2
        if ch2 == "|" and ch1 in special[1:]:
            return ch1
        if ch1 in "/\\" and ch2 in special[3:]:
            return ch2
        if ch2 in "/\\" and ch1 in special[3:]:
            return ch1
        if ch1 in "[]" and ch2 in special[5:]:
            return ch2
        if ch2 in "[]" and ch1 in special[5:]:
            return ch1
        if ch1 in "{}" and ch2 in special[7:]:
            return ch2
        if ch2 in "{}" and ch1 in special[7:]:
            return ch1
        if ch1 in "()" and ch2 in special[9:]:
            return ch2
        if ch2 in "()" and ch1 in special[9:]:
            return ch1
        if ch1 == '[' and ch2 == ']':
            return '|'
        if ch1 == ']' and ch2 == '[':
            return '|'
        if ch1 == '{' and ch2 == '}':
            return '|'
        if ch1 == '}' and ch2 == '{':
            return '|'
        if ch1 == '(' and ch2 == ')':
            return '|'
        if ch1 == ')' and ch2 == '(':
            return '|'

        return '\0'

    def get_smushamount(self, l):
        max_smush = self.currcharwidth
        for row in range(0, self.hdr['height']):
            linebd = len(self.line[row])
            ch1 = ' '
            while linebd > 0 and ch1 == ' ':
                try:
                    ch1 = self.line[row][linebd]
                except IndexError:
                    ch1 = ' '
                if ch1 != ' ':
                    break
                linebd = linebd - 1

            try:
                charbd = 0
                ch2 = ' '
                while ch2 == ' ':
                    ch2 = l[row][charbd]
                    if ch2 != ' ':
                        break
                    charbd = charbd + 1
            except IndexError:
                ch2 = None

            amt = charbd + self.outlinelen - 1 - linebd
            if ch1 == None or ch1 == ' ':
                amt = amt + 1
            elif ch2 != None:
                if self.smushmem(ch1, ch2) != '\0':
                    amt = amt + 1
            if amt < max_smush:
                max_smush = amt
        return max_smush                

    def addchar(self, c):
        letter = self.getletter(c)
        smush_amount = self.get_smushamount(letter)
        for row in range(0, self.hdr['height']):
            for k in range(0, smush_amount):
                if self.outlinelen - smush_amount + k >= 0:
                    ch1 = self.line[row][self.outlinelen-smush_amount+k]
                    ch2 = letter[row][k]
                    self.line[row][self.outlinelen-smush_amount+k] = self.smushmem(ch1, ch2)
            self.line[row] += letter[row][smush_amount:]
        self.outlinelen = len(self.line[0])

    def addline(self, line):
        for c in line: self.addchar(c)

    """
    Output handling

    """
    def clearline(self):
        self.line = []
        for i in range(0,self.hdr['height']):
            self.line.append([])
        self.previouscharwidth = 0
        self.currcharwidth = 0
        self.outlinelen = 0
            

    def getstring(self, i):
        return ''.join(self.line[i]).replace(self.hdr['hardblank'], ' ')

    def getline(self):
        lines = []
        for i in range(0, self.hdr['height']):
            lines.append(self.getstring(i))
        self.clearline()
        return '\n'.join(lines)

    def putstring(self, i):
        print ''.join(self.line[i]).replace(self.hdr['hardblank'], ' ')

    def printline(self):
        for i in range(0, self.hdr['height']):
            self.putstring(i)
        self.clearline()
        

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print "usage: %s [phrase] [fontdir]" % sys.argv[0]
        sys.exit(-1)

    fontdir = sys.argv[2]
    fonts = get_fontdirlist(fontdir)
    index = random.randint(0, len(fonts) - 1)
    for font in fonts:
        print "FONT: ", font
        f = Fig(font)
        f.addline(sys.argv[1])
        f.printline()

