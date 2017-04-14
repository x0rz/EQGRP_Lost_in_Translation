"""
Utility classes and functions

- iDict : Case insensitive dictionary
- 
"""
import datetime
import re
import string

from operator import itemgetter

GVAR_CHAR = '$'

__all__ = ['charconvert', 
           'superTuple', 
           'Param', 
           'oParam', 
           'iDict', 
           'validateip', 
           'convert_consolemode', 
           'consolemode_map',
           'CONSOLE_REUSE', 
           'CONSOLE_NEW', 
           'CONSOLE_DEFAULT',
           'formattime', 
           'parseinput', 
           'variable_replace',
           'has_nonprintable',
           'parse_param_list',
           'scalar_to_list',
           ]
"""
string converters
"""
def convert_hexstring(input):
    return input

def convert_wstring(input):
    import binascii
    return binascii.hexlify(input.encode('utf-16le') + '\x00\x00')

def convert_ascii(input):
    import binascii
    return binascii.hexlify(input + '\x00')

def convert_filename(input):
    """Treat input as a filename; return the raw bytes from that file [in hex]."""
    import binascii
    try:
        with open(input, 'rb') as fd:
            return binascii.hexlify(fd.read())
    except IOError:
        raise TypeError


"""
Decorators

"""
def charconvert(f):
    conv = iDict([('L:', convert_wstring),
                  ('A:', convert_ascii),
                  ('H:', convert_hexstring),
                  ('F:', convert_filename)])
    def wrap(self, input):
        inputList = input.strip().split()
        if len(inputList) > 1:
            arg = ' '.join(inputList[1:])
            try:
                arg = conv[arg[:2]](arg[2:])
            except (KeyError, TypeError):
                pass
            else:
                input = ''.join(inputList[:1]) + ' ' + arg
        return f(self, input)
    wrap.__doc__ = f.__doc__
    return wrap


def superTuple(typename, *attribute_names):
    """
    Create and return a subclass of tuple with named attributes.
    From O'Reilly Python Cookbook.

    """
    nargs = len(attribute_names)
    class supertup(tuple):
        __slots__ = ()
        def __new__(cls, *args):
            if len(args) != nargs:
                raise TypeError, '%s takes %d args (%d given)' % (typename, nargs, len(args))
            return tuple.__new__(cls, args)
        def __repr__(self):
            return '%s(%s)' % (typename, ', '.join(map(repr, self)))
        def __eq__(self, other):
            if hasattr(self, 'name') and hasattr(other, 'name'):
                if self.name.upper() == other.name.upper():
                    return True
                else:
                    return False
            else:
                return tuple.__eq__(self, other)

    for index, attr_name in enumerate(attribute_names):
        setattr(supertup, attr_name, property(itemgetter(index)))
    supertup.__name__ = typename
    return supertup


Param = superTuple('Param', 'name', 'value')
oParam = superTuple('Param', 'name', 'value', 'type', 'format')

class iDict(dict):
    """
    Extension of the standard Python dictionary to support case insensitive
    keys.  Still tries to store the keys in their original case but allows
    accesses and lookups to be case insensitive.

    """
    def real_key(self, val):
        for k in self.keys():
            if k.lower() == val.lower():
                return k
        return val

    def __contains__(self, i):
        return dict.__contains__(self, self.real_key(i))

    def __delitem__(self, i):
        return dict.__delitem__(self, self.real_key(i))

    def __getitem__(self, i):
        return dict.__getitem__(self, self.real_key(i))

    def __setitem__(self, i, value):
        return dict.__setitem__(self, self.real_key(i), value)

    def get(self, k, defval):
        return dict.get(self, self.real_key(k), defval)

    def has_key(self, val):
        return dict.has_key(self, self.real_key(val))

    def items(self):
        return [Param(key,val) for key,val in dict.items(self)]


"""
IP Address Validation

"""
import socket

def validateip(ip):
    
    if ip == '':
        # This is here because Windows getaddrinfo() thinks '' is a valid IP
        return None

    try:
        # Figure out whether we have a valid IP.  This should not throw an exception
        socket.getaddrinfo(ip, None)
    except Exception as e:
        print "Address %s not valid: %s" % (ip, e)
        return None
    return ip


"""
Console mode constants and functions

"""
CONSOLE_REUSE = 1
CONSOLE_NEW   = 2
CONSOLE_DEFAULT = CONSOLE_REUSE

consolemode_map = {"new"     : CONSOLE_NEW,
                   "reuse"   : CONSOLE_REUSE,
                   "default" : CONSOLE_DEFAULT}


def convert_consolemode(str):
    try:
        return consolemode_map[str.lower()]
    except:
        return consolemode_map["default"]


"""
Time formatting

"""
def formattime(timestamp=None):
    if timestamp is None:
        timestamp = datetime.datetime.now()
    timestamp = str(timestamp)
    timestamp = timestamp.replace(' ', '.')
    return timestamp.replace(':', '.')

"""
Arg line parsing

"""
def parseinput(line, count):
    _list = line.strip().split()
    params = []
    for i in range(0, count):
        try:
            params.append(_list[i])
        except IndexError:
            params.append(None)
    return (len(params) - params.count(None), params)

def variable_replace(line, gvars):
    patterns = ["(\$[A-Za-z0-9_]+)", "(\$\{[A-Za-z0-9_]+\})"]
    newline = line.strip()
    for p in patterns:
        group = re.split(p, newline)
        linelist = []
        for g in group:
            try:
                if g[0] == GVAR_CHAR and g[1:] in gvars:
                    linelist.append(gvars[g[1:]])
                elif g[0] == GVAR_CHAR and g[2:-1] in gvars:
                    linelist.append(gvars[g[2:-1]])
                else:
                    linelist.append(g)
            except IndexError:
                pass
        newline = "".join(linelist)
    return newline

    
"""
Misc functions

"""
def has_nonprintable(line):
    for i in line:
        if i not in string.printable:
            return True
    return False


def parse_param_list(l, ltype):
    # Verify [ .. ] and remove
    if not l:
        return None
    if l[0] != '[' or l[-1] != ']':
        return None
    l = l[1:-1]


    tokens = []
    if ltype in ('IPv4', 'IPv6', 'LocalFile', 'String', 'UString', 'Buffer'):
        # tokens are 'token',  "token", ...
        # quoted strings with comma and (optional) whitespace delimiters
        while l:
            if l[0] not in "'\"":
                if l[0] in (' ', ','):
                    l = l[1:]
                    continue
                else:
                    return None
            else:
                delim = l[0]
                l = l[1:]
            try:
                pos = l.index(delim)
            except ValueError:
                return None
            tokens.append(l[:pos])
            l = l[pos+1:]
    else:
        tokens = [t.strip() for t in l.split(',')]

    return tokens

def scalar_to_list(param):
    if param.type in ('IPv4', 'IPv6', 'LocalFile', 'String', 'UString', 'Buffer'):
        return "['" + param.value + "']"
    else:
        return "[" + param.value + "]"

