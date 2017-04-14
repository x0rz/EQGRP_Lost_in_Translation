"""
Friendly wrapper around the TRUANTCHILD ctypes wrapper.  Provides classes for
the different parameter structures with methods for access.
"""

import binascii
import ctypes
import exma
import hashlib
import os
from util import superTuple, oParam
import pytrch as trch

try:
    from pytrch import TrchError as TrchError
except:
    from pytrch import TrchError

__all__ = ["attribute_convert", "Parameter", 
           "Paramgroup", "Paramchoice",
           "Config", "Params", "Param"]

Param = superTuple('Param', 'name', 'value')

def attribute_convert(val):
    if val in ("1", 1, "TRUE", "true"):
        return "YES"
    else:
        return "NO"

class Parameter:
    def __init__(self, paramStruct):
        self.TypeListFnMap = {
            "Boolean"   : { "getValue" : self.Boolean_List_getValue,
                            "setValue" : self.Boolean_List_setValue },
            "IPv4"      : { "getValue" : self.IPv4_List_getValue,
                            "setValue" : self.IPv4_List_setValue },
            "IPv6"      : { "getValue" : self.IPv6_List_getValue,
                            "setValue" : self.IPv6_List_setValue },
            "LocalFile" : { "getValue" : self.LocalFile_List_getValue,
                            "setValue" : self.LocalFile_List_setValue },
            "TcpPort"   : { "getValue" : self.TcpPort_List_getValue,
                            "setValue" : self.TcpPort_List_setValue },
            "UdpPort"   : { "getValue" : self.UdpPort_List_getValue,
                            "setValue" : self.UdpPort_List_setValue },
            "S16"       : { "getValue" : self.S16_List_getValue,
                            "setValue" : self.S16_List_setValue },
            "S32"       : { "getValue" : self.S32_List_getValue,
                            "setValue" : self.S32_List_setValue },
            "S64"       : { "getValue" : self.S64_List_getValue,
                            "setValue" : self.S64_List_setValue },
            "S8"        : { "getValue" : self.S8_List_getValue,
                            "setValue" : self.S8_List_setValue },
            "Socket"    : { "getValue" : self.Socket_List_getValue,
                            "setValue" : self.Socket_List_setValue },
            "String"    : { "getValue" : self.String_List_getValue,
                            "setValue" : self.String_List_setValue },
            "U16"       : { "getValue" : self.U16_List_getValue,
                            "setValue" : self.U16_List_setValue },
            "U32"       : { "getValue" : self.U32_List_getValue,
                            "setValue" : self.U32_List_setValue },
            "U64"       : { "getValue" : self.U64_List_getValue,
                            "setValue" : self.U64_List_setValue },
            "U8"        : { "getValue" : self.U8_List_getValue,
                            "setValue" : self.U8_List_setValue },
            "UString"   : { "getValue" : self.UString_List_getValue,
                            "setValue" : self.UString_List_setValue },
            "Buffer"    : { "getValue" : self.Buffer_List_getValue,
                            "setValue" : self.Buffer_List_setValue },
            }
        self.TypeFnMap = {
            "Boolean"   : { "getValue" : self.Boolean_getValue,
                            "setValue" : self.Boolean_setValue },
            "IPv4"      : { "getValue" : self.IPv4_getValue,
                            "setValue" : self.IPv4_setValue },
            "IPv6"      : { "getValue" : self.IPv6_getValue,
                            "setValue" : self.IPv6_setValue },
            "LocalFile" : { "getValue" : self.LocalFile_getValue,
                            "setValue" : self.LocalFile_setValue },
            "TcpPort"   : { "getValue" : self.TcpPort_getValue,
                            "setValue" : self.TcpPort_setValue },
            "UdpPort"   : { "getValue" : self.UdpPort_getValue,
                            "setValue" : self.UdpPort_setValue },
            "S16"       : { "getValue" : self.S16_getValue,
                            "setValue" : self.S16_setValue },
            "S32"       : { "getValue" : self.S32_getValue,
                            "setValue" : self.S32_setValue },
            "S64"       : { "getValue" : self.S64_getValue,
                            "setValue" : self.S64_setValue },
            "S8"        : { "getValue" : self.S8_getValue,
                            "setValue" : self.S8_setValue },
            "Socket"    : { "getValue" : self.Socket_getValue,
                            "setValue" : self.Socket_setValue },
            "String"    : { "getValue" : self.String_getValue,
                            "setValue" : self.String_setValue },
            "U16"       : { "getValue" : self.U16_getValue,
                            "setValue" : self.U16_setValue },
            "U32"       : { "getValue" : self.U32_getValue,
                            "setValue" : self.U32_setValue },
            "U64"       : { "getValue" : self.U64_getValue,
                            "setValue" : self.U64_setValue },
            "U8"        : { "getValue" : self.U8_getValue,
                            "setValue" : self.U8_setValue },
            "UString"   : { "getValue" : self.UString_getValue,
                            "setValue" : self.UString_setValue },
            "Buffer"    : { "getValue" : self.Buffer_getValue,
                            "setValue" : self.Buffer_setValue },
            }
        self.param = paramStruct

    def __repr__(self):
        if self.isHidden():
            return ""
        else:
            return "%s : %s\n" % (self.getName(), self.getValue())

    def _tokenize_list(self, l):
        # Verify [ .. ] and remove
        if l[0] != '[' or l[-1] != ']':
            return None
        l = l[1:-1]

        # tokens are 'token',  "token", ...
        # quoted strings with comma and (optional) whitespace delimiters
        tokens = []
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
        return tokens

    def _tokenize_barelist(self, l):
        # Verify [ .. ] and remove
        if l[0] != '[' or l[-1] != ']':
            return None
        l = l[1:-1]

        # tokens are token, token, ..., token
        # Non-quoted strings with comma and (optional) whitespace delimiters
        return [x.strip() for x in l.split(',')]

    def getDescription(self):
        return trch.Parameter_getDescription(self.param)

    def getFormat(self):
        return trch.Parameter_getFormat(self.param)

    def getName(self):
        return trch.Parameter_getName(self.param)

    def getType(self):
        return trch.Parameter_getType(self.param)

    def getMarshalledDefault(self):
        return trch.Parameter_getMarshalledDefault(self.param)

    def getValue(self):
        if self.hasValue():
            if self.getFormat().lower() == "list":
                try:
                    return str(self.TypeListFnMap[self.getType()]['getValue']())
                except KeyError:
                    return ""
            else:
                return str(self.TypeFnMap[self.getType()]['getValue']())
        else:
            return ""

    def hasValue(self):
        return trch.Parameter_hasValue(self.param)

    def hasValidValue(self):
        return trch.Parameter_hasValidValue(self.param)

    def getAttributeList(self):
        if self.getFormat().lower() == "list":
            extendedtype = " List"
        else:
            extendedtype = ""
        alist = [("Name",       self.getName()),
                 ("Value",      self.getValue()),
                 ("Type",       self.getType() + extendedtype),
                 ("Description", self.getDescription()),
                 ("Is Valid",   attribute_convert(self.hasValidValue())),
                 ("Required",   attribute_convert(self.isRequired()))]
        return alist 

    def getAttributeValueList(self):
        return []

    def getParameterList(self):
        #if not self.isHidden():
        #    return [Param(self.getName(), self.getValue())]
        #else:
        #    return []
        return [Param(self.getName(), self.getValue())]

    def getParameterListExt(self):
        #if not self.isHidden():
        return [oParam(self.getName(), self.getValue(), 
                    self.getType(), self.getFormat())]
        #else:
        #    return []

    def isHidden(self):
        return trch.Parameter_isHidden(self.param)

    def isRequired(self):
        return trch.Parameter_isRequired(self.param)

    def isValid(self):
        return trch.Parameter_isValid(self.param)

    def markInvalid(self):
        trch.Parameter_markInvalid(self.param)

    def matchName(self, name):
        return trch.Parameter_matchName(self.param, name)

    def matchType(self, type):
        return trch.Parameter_matchType(self.param, type)

    def setValue(self, value):
        if self.getFormat().lower() == "list":
            try:
                self.TypeListFnMap[self.getType()]['setValue'](value)
            except KeyError:
                pass
        else:
            self.TypeFnMap[self.getType()]['setValue'](value)

    def resetValue(self):
        trch.Parameter_resetValue(self.param)
    
    # Value accessors
    def Boolean_getValue(self):
        b = trch.Parameter_Boolean_getValue(self.param)
        if b:
            return "True"
        else:
            return "False"

    def Boolean_setValue(self, value):
        if value.lower() in ("false", "f", "0", "off"):
            value = 0
        elif value.lower() in ("true", "t", "1", "on"):
            value = 1
        else:
            value = ""
        trch.Parameter_Boolean_setValue(self.param, int(value))

    def IPv4_getValue(self):
        return trch.Parameter_IPv4_getValue(self.param)

    def IPv4_setValue(self, value):
        trch.Parameter_IPv4_setValue(self.param, value)

    def IPv6_getValue(self):
        return trch.Parameter_IPv6_getValue(self.param)

    def IPv6_setValue(self, value):
        trch.Parameter_IPv6_setValue(self.param, value)

    def LocalFile_getValue(self):
        return os.path.normpath(trch.Parameter_LocalFile_getValue(self.param))

    def LocalFile_setValue(self, value):
        trch.Parameter_LocalFile_setValue(self.param, os.path.normpath(value))

    def TcpPort_getValue(self):
        return str(trch.Parameter_Port_getValue(self.param))

    def TcpPort_setValue(self, value):
        trch.Parameter_Port_setValue(self.param, int(value))

    def UdpPort_getValue(self):
        return str(trch.Parameter_Port_getValue(self.param))

    def UdpPort_setValue(self, value):
        trch.Parameter_Port_setValue(self.param, int(value))

    def S16_getValue(self):
        return str(trch.Parameter_S16_getValue(self.param))

    def S16_setValue(self, value):
        trch.Parameter_S16_setValue(self.param, int(value))

    def S32_getValue(self):
        return str(trch.Parameter_S32_getValue(self.param))

    def S32_setValue(self, value):
        trch.Parameter_S32_setValue(self.param, int(value))

    def S64_getValue(self):
        return str(trch.Parameter_S64_getValue(self.param))

    def S64_setValue(self, value):
        trch.Parameter_S64_setValue(self.param, long(value))

    def S8_getValue(self):
        return str(trch.Parameter_S8_getValue(self.param))

    def S8_setValue(self, value):
        trch.Parameter_S8_setValue(self.param, int(value))

    def Socket_getValue(self):
        return str(trch.Parameter_Socket_getValue(self.param))

    def Socket_setValue(self, value):
        trch.Parameter_Socket_setValue(self.param, int(value))

    def String_getValue(self):
        return trch.Parameter_String_getValue(self.param)

    def String_setValue(self, value):
        trch.Parameter_String_setValue(self.param, value)

    def U16_getValue(self):
        return str(trch.Parameter_U16_getValue(self.param))

    def U16_setValue(self, value):
        trch.Parameter_U16_setValue(self.param, int(value))

    def U32_getValue(self):
        return str(trch.Parameter_U32_getValue(self.param))

    def U32_setValue(self, value):
        trch.Parameter_U32_setValue(self.param, int(value))

    def U64_getValue(self):
        return str(trch.Parameter_U64_getValue(self.param))

    def U64_setValue(self, value):
        trch.Parameter_U64_setValue(self.param, long(value))

    def U8_getValue(self):
        return str(trch.Parameter_U8_getValue(self.param))

    def U8_setValue(self, value):
        trch.Parameter_U8_setValue(self.param, int(value))

    def UString_getValue(self):
        bytes = trch.Parameter_UString_getValue(self.param)
        if bytes:
            return binascii.hexlify(bytes)
        else:
            return ""

    def UString_setValue(self, value):
        if value.startswith("\\x"):
            decoded_val = value.decode('string-escape')
        else:
            decoded_val = binascii.unhexlify(value)
        trch.Parameter_UString_setValue(self.param, decoded_val)

    def Buffer_getValue(self):
        bytes = trch.Parameter_Buffer_getValue(self.param)
        if bytes:
            return binascii.hexlify(bytes)
        else:
            return ""

    def Buffer_setValue(self, value):
        if value.startswith("\\x"):
            decoded_val = value.decode('string-escape')
        else:
            decoded_val = binascii.unhexlify(value)
        trch.Parameter_Buffer_setValue(self.param, decoded_val)

    def Boolean_List_setValue(self, value):
        values = []
        for v in self._tokenize_barelist(value):
            if v.lower() in ("false", "f", "0", "off"):
                x = 0 
            elif v.lower() in ("true", "t", "1", "on"):
                x = 1
            else:
                x = ""
            values.append(int(x))
        trch.Parameter_Boolean_List_setValue(self.param, values)

    def Boolean_List_getValue(self):
        token = trch.Parameter_Boolean_List_getValue(self.param)
        values = []
        for tok in token:
            if tok:
                values.append("True")
            else:
                values.append("False")
        return '[' + ', '.join(values) + ']'

    def IPv4_List_setValue(self, value):
        arg = self._tokenize_list(value)
        trch.Parameter_IPv4_List_setValue(self.param, arg)

    def IPv4_List_getValue(self):
        tokens = trch.Parameter_IPv4_List_getValue(self.param)
        twrapped = ["'" + x + "'" for x in tokens]
        return '[' + ', '.join(twrapped) + ']'

    def IPv6_List_setValue(self, value):
        arg = self._tokenize_list(value)
        trch.Parameter_IPv6_List_setValue(self.param, arg)

    def IPv6_List_getValue(self):
        tokens = trch.Parameter_IPv6_List_getValue(self.param)
        twrapped = ["'" + x + "'" for x in tokens]
        return '[' + ', '.join(twrapped) + ']'

    def LocalFile_List_setValue(self, value):
        arg = self._tokenize_list(value)
        trch.Parameter_LocalFile_List_setValue(self.param, arg)

    def LocalFile_List_getValue(self):
        tokens = trch.Parameter_LocalFile_List_getValue(self.param)
        twrapped = ["'" + x + "'" for x in tokens]
        return '[' + ', '.join(twrapped) + ']'

    def TcpPort_List_setValue(self, value):
        tokens = [int(x) for x in self._tokenize_barelist(value)]
        trch.Parameter_Port_List_setValue(self.param, tokens)

    def TcpPort_List_getValue(self):
        tokens = trch.Parameter_Port_List_getValue(self.param)
        return '[' + ', '.join(str(x) for x in tokens) + ']'

    def UdpPort_List_setValue(self, value):
        self.TcpPort_List_setValue(value)

    def UdpPort_List_getValue(self):
        return self.TcpPort_List_getValue()

    def S16_List_setValue(self, value):
        tokens = [int(x) for x in self._tokenize_barelist(value)]
        trch.Parameter_S16_List_setValue(self.param, tokens)

    def S16_List_getValue(self):
        tokens = trch.Parameter_S16_List_getValue(self.param)
        return '[' + ', '.join(str(x) for x in tokens) + ']'

    def S32_List_setValue(self, value):
        tokens = [int(x) for x in self._tokenize_barelist(value)]
        trch.Parameter_S32_List_setValue(self.param, tokens)

    def S32_List_getValue(self):
        tokens = trch.Parameter_S32_List_getValue(self.param)
        return '[' + ', '.join(str(x) for x in tokens) + ']'

    def S64_List_setValue(self, value):
        tokens = [long(x) for x in self._tokenize_barelist(value)]
        trch.Parameter_S64_List_setValue(self.param, tokens)

    def S64_List_getValue(self):
        tokens = trch.Parameter_S64_List_getValue(self.param)
        return '[' + ', '.join(str(x) for x in tokens) + ']'

    def S8_List_setValue(self, value):
        tokens = [int(x) for x in self._tokenize_barelist(value)]
        trch.Parameter_S8_List_setValue(self.param, tokens)

    def S8_List_getValue(self):
        tokens = trch.Parameter_S8_List_getValue(self.param)
        return '[' + ', '.join(str(x) for x in tokens) + ']'

    def Socket_List_setValue(self, value):
        tokens = [int(x) for x in self._tokenize_barelist(value)]
        trch.Parameter_Socket_List_setValue(self.param, tokens)

    def Socket_List_getValue(self):
        tokens = trch.Parameter_Socket_List_getValue(self.param)
        return '[' + ', '.join(str(x) for x in tokens) + ']'

    def String_List_setValue(self, value):
        arg = self._tokenize_list(value)
        trch.Parameter_String_List_setValue(self.param, arg)

    def String_List_getValue(self):
        tokens = trch.Parameter_String_List_getValue(self.param)
        twrapped = ["'" + x + "'" for x in tokens]
        return '[' + ', '.join(twrapped) + ']'

    def U16_List_setValue(self, value):
        tokens = [int(x) for x in self._tokenize_barelist(value)]
        trch.Parameter_U16_List_setValue(self.param, tokens)

    def U16_List_getValue(self):
        tokens = trch.Parameter_U16_List_getValue(self.param)
        return '[' + ', '.join(str(x) for x in tokens) + ']'

    def U32_List_setValue(self, value):
        tokens = [int(x) for x in self._tokenize_barelist(value)]
        trch.Parameter_U32_List_setValue(self.param, tokens)

    def U32_List_getValue(self):
        tokens = trch.Parameter_U32_List_getValue(self.param)
        return '[' + ', '.join(str(x) for x in tokens) + ']'

    def U64_List_setValue(self, value):
        tokens = [long(x) for x in self._tokenize_barelist(value)]
        trch.Parameter_U64_List_setValue(self.param, tokens)

    def U64_List_getValue(self):
        tokens = trch.Parameter_U64_List_getValue(self.param)
        return '[' + ', '.join(str(x) for x in tokens) + ']'

    def U8_List_setValue(self, value):
        tokens = [int(x) for x in self._tokenize_barelist(value)]
        trch.Parameter_U8_List_setValue(self.param, tokens)

    def U8_List_getValue(self):
        tokens = trch.Parameter_U8_List_getValue(self.param)
        return '[' + ', '.join(str(x) for x in tokens) + ']'
    
    def UString_List_setValue(self, value):
        tokens = self._tokenize_list(value)
        values = []
        for tok in tokens:
            if tok.startswith("\\x"):
                decoded_val = tok.decode('string-escape')
            else:
                decoded_val = binascii.unhexlify(tok)
            values.append(decoded_val)
        trch.Parameter_UString_List_setValue(self.param, values)

    def UString_List_getValue(self):
        tokens = trch.Parameter_UString_List_getValue(self.param)
        strlist = ("'" + binascii.hexlify(l) + "'" for l in tokens)
        return '[' + ', '.join(strlist) + ']'

    def Buffer_List_setValue(self, value):
        tokens = self._tokenize_list(value)
        values = []
        for tok in tokens:
            if tok.startswith("\\x"):
                decoded_val = tok.decode('string-escape')
            else:
                decoded_val = binascii.unhexlify(tok)
            values.append(decoded_val)
        trch.Parameter_Buffer_List_setValue(self.param, values)

    def Buffer_List_getValue(self):
        tokens = trch.Parameter_Buffer_List_getValue(self.param)
        strlist = ("'" + binascii.hexlify(l) + "'" for l in tokens)
        return '[' + ', '.join(strlist) + ']'


class Paramgroup:
    def __init__(self, paramGroup):
        self.group       = paramGroup
        self.choiceList  = {}
        self.paramList   = {}

        for i in xrange(0, self.getNumParameters()):
            param = trch.Paramgroup_getParameter(paramGroup, i)
            name = trch.Parameter_getName(param)
            self.paramList[name.lower()] = Parameter(param)

        for i in xrange(0, self.getNumParamchoices()):
            paramChoice = trch.Paramgroup_getParamchoice(paramGroup, i)
            name = trch.Paramchoice_getName(paramChoice)
            self.choiceList[name.lower()] = Paramchoice(paramChoice)

    def __repr__(self):
        items = []
        for param in self.paramList:
            items.append(repr(self.paramList[param]))

        for choice in self.choiceList:
            items.append(repr(self.choiceList[choice]))

        return "".join(items)

    def getDescription(self):
        return trch.Paramgroup_getDescription(self.group)

    def getName(self):
        return trch.Paramgroup_getName(self.group)

    def getNumParamchoices(self):
        return trch.Paramgroup_getNumParamchoices(self.group)

    def getNumParameters(self):
        return trch.Paramgroup_getNumParameters(self.group)

    def getParameter(self, name):
        return self.paramList[name.lower()]
        
    def getParamchoice(self, name):
        return self.choiceList[name.lower()]

    def getAttributeList(self):
        return []

    def getAttributeValueList(self):
        alist = [Param(self.getName(), self.getDescription())]
        return alist

    def getParameterList(self):
        plist = []
        for key in self.paramList:
            plist.extend(self.paramList[key].getParameterList())
        for key in self.choiceList:
            plist.extend(self.choiceList[key].getParameterList())
        return plist

    def getParameterListExt(self):
        plist = []
        for key in self.paramList:
            plist.extend(self.paramList[key].getParameterListExt())
        for key in self.choiceList:
            plist.extend(self.choiceList[key].getParameterListExt())
        return plist
        
    def hasValidValue(self):
        return self.isValid()

    def isValid(self):
        return trch.Paramgroup_isValid(self.group)

    def matchName(self, name):
        return trch.Paramgroup_matchName(self.group, str(name))

    def hasValue(self):
        return 1


class Paramchoice:
    def __init__(self, paramChoice):
        self.choice     = paramChoice
        self.groupList  = {}
        
        self.groupNames = []
        for i in xrange(0, self.getNumParamgroups()):
            paramGroup = trch.Paramchoice_getParamgroup(paramChoice, i)
            name = trch.Paramgroup_getName(paramGroup)
            self.groupNames.append(name.lower())
            self.groupList[name.lower()] = Paramgroup(paramGroup)
    
    def __repr__(self):
        items = []
        if self.hasValidValue():
            items.append("%s : %s\n" % (self.getName(), self.getValue()))
            items.append(repr(self.groupList[self.getValue().lower()]))
        else:
            items.append("%s : %s\n" % (self.getName(), ""))

        return "".join(items)

    def getDefaultValue(self):
        return trch.Paramchoice_getDefaultValue(self.choice)

    def getDescription(self):
        return trch.Paramchoice_getDescription(self.choice)

    def getName(self):
        return trch.Paramchoice_getName(self.choice)

    def getNumParamgroups(self):
        return trch.Paramchoice_getNumParamgroups(self.choice)

    def getParamgroup(self, name):
        return self.groupList[name.lower()]

    def getValue(self):
        if self.hasValue():
            return trch.Paramchoice_getValue(self.choice)
        else:
            return ""

    def getAttributeList(self):
        alist = [("Name",        self.getName()),
                 ("Description", self.getDescription()),
                 ("Value",       self.getValue()),
                 ("Is Valid",    attribute_convert(self.hasValidValue())),
                 ("Required",    "YES")]
        return alist

    def getAttributeValueList(self):
        alist = []
        for group in self.groupNames:
            alist.extend(self.groupList[group].getAttributeValueList())
        return alist

    def getParameterList(self):
        item = Param(self.getName(), self.getValue())
        plist = [item]
        if self.hasValidValue():
            plist.extend(self.groupList[self.getValue().lower()].getParameterList())

        return plist

    def getParameterListExt(self):
        item = oParam(self.getName(), self.getValue(), self.getType(), 'Scalar')
        plist = [item]
        if self.hasValidValue():
            plist.extend(self.groupList[self.getValue().lower()].getParameterListExt())

        return plist

    def hasValidValue(self):
        return trch.Paramchoice_hasValidValue(self.choice)

    def isValid(self):
        return trch.Paramchoice_isValid(self.choice)

    def matchName(self, name):
        return trch.Paramchoice_matchName(self.choice, str(name))

    def setValue(self, value):
        trch.Paramchoice_setValue(self.choice, str(value))

    def resetValue(self):
        v = self.getDefaultValue()
        if not v:
            v = ''
        self.setValue(v)

    def hasValue(self):
        return trch.Paramchoice_hasValue(self.choice)

    def getType(self):
        return 'choice'

    def getFormat(self):
        return 'Scalar'

class Config:
    """
    Representation of a parsed XML file.

    Contains inputs, outputs constants.
    Does not contain logic, redirection.
    """
    def __init__(self, files):
        self.xmlInConfig  = files[0]
        if len(files) > 1:
            self.executable = files[1]
        else:
            self.executable = ""
        self.init_config()

    def init_config(self):
        self.configXML     = exma.readParamsFromEM(ctypes.c_char_p(self.xmlInConfig))
        # Config_unmarshal can fail and return None, which 
        # raises TrchError when passed to Config_getID
        try:
            self.config        = trch.Config_unmarshal(self.configXML)
            if self.config is None:
                raise TrchError("Parse error in the output configuration")
            self.id            = trch.Config_getID(self.config)
            self.name          = trch.Config_getName(self.config)
            self.version       = trch.Config_getVersion(self.config)
            self.configVersion = trch.Config_getConfigVersion(self.config)
            self.namespaceUri  = trch.Config_getNamespaceUri(self.config)
            self.schemaVersion = trch.Config_getSchemaVersion(self.config)
        except TrchError:
            raise

        self._inputParams   = Params(trch.Config_getInputParams(self.config), 
                                     self.namespaceUri, self.schemaVersion)
        self._outputParams  = Params(trch.Config_getOutputParams(self.config),
                                     self.namespaceUri, self.schemaVersion)
        #self._constants     = Params(trch.Config_getConstants(self.config),
        #                             self.namespaceUri, self.schemaVersion)
        self._constants = None


    def __repr__(self):
        items = []
        items.append("Name : %s\n" % self.name)
        items.append("ID : %s\n" % self.id)
        items.append("Version : %s\n" % self.version)
        items.append("Config Version : %s\n" % self.configVersion)
        return "".join(items)

    def getMarshalledInConfig(self):
        c = trch.Config_marshal(self.config, "t", None)
        return c

    def putMarshalledConfig(self, filename):
        c = trch.Config_marshal(self.config, "t", None)
        if isinstance(filename, str):
            with open(filename, "wb") as fh:
                fh.write(c)
        elif isinstance(filename, file):
            filename.write(c)

    def getName(self):
        return self.name

    def getVersion(self):
        return self.version

    def getConfigVersion(self):
        return self.configVersion

    def getBinaryHash(self):
        return "%s %s %s" % (hashlib.sha1(open(self.executable, 'rb').read()).hexdigest(),
                             os.lstat(self.executable).st_size,
                             os.path.basename(self.executable))

    def getConfigHash(self):
        return "%s %s %s" % (hashlib.sha1(open(self.xmlInConfig, 'rb').read()).hexdigest(),
                                      os.lstat(self.xmlInConfig).st_size,
                                      os.path.basename(self.xmlInConfig))


class Params:
    def __init__(self, params, ns, ver):
        self.choiceList = {}
        self.paramList  = {}
        self.parameters = params
        self.namespaceUri = ns
        self.schemaVersion = ver
        
        for i in xrange(0, self.getNumParameters()):
            param = trch.Params_getParameter(self.parameters, i)
            name = trch.Parameter_getName(param)
            self.paramList[name.lower()] = Parameter(param)

        for i in xrange(0, self.getNumParamchoices()):
            paramChoice = trch.Params_getParamchoice(self.parameters, i)
            name = trch.Paramchoice_getName(paramChoice)
            self.choiceList[name.lower()] = Paramchoice(paramChoice)

    def __repr__(self):
        items = []
        for param in self.paramList:
            items.append(repr(self.paramList[param]))

        for choice in self.choiceList:
            items.append(repr(self.choiceList[choice]))

        return "".join(items)
        
    def findParamchoice(self, name):
        param = trch.Params_findParamchoice(self.parameters, str(name))
        if param:
            return Paramchoice(param)
        else:
            return None

    def findParameter(self, name):
        param = trch.Params_findParameter(self.parameters, str(name))
        if param:
            return Parameter(param)
        else:
            return None

    def getNumParamchoices(self):
        return trch.Params_getNumParamchoices(self.parameters)

    def getNumParameters(self):
        return trch.Params_getNumParameters(self.parameters)

    def hasValidValue(self, name=None):
        return self.findOption(name).hasValidValue()

    def isValid(self, name=None):
        if name == None:
            return trch.Params_isValid(self.parameters)
        else:
            return self.findOption(name).isValid()

    def hasValue(self, name):
        param = self.findOption(name)
        return param.hasValue()

    def isParamchoice(self, name):
        if self.findParamchoice(name):
            return True
        else:
            return False

    def isParameter(self, name):
        if self.findParameter(name):
            return True
        else:
            return False

    def findOption(self, name):
        param = self.findParameter(name)
        if param is None:
            param = self.findParamchoice(name)
        return param

    def getDescription(self, name):
        return self.findOption(name).getDescription()

    def getType(self, name):
        return self.findOption(name).getType()

    def getFormat(self, name):
        return self.findOption(name).getFormat()

    def set(self, name, value):
        return self.findOption(name).setValue(value)

    def reset(self, name):
        self.findOption(name).resetValue()

    def get(self, name):
        if self.hasValue(name):
            return self.findOption(name).getValue()
        else:
            return ""

    def getAttributeList(self, name):
        return self.findOption(name).getAttributeList()

    def getRootParameterList(self):
        plist = []
        for key in self.paramList:
            plist.extend(self.paramList[key].getParameterList())
        return plist

    def getParameterList(self):
        plist = []
        for key in self.paramList:
            plist.extend(self.paramList[key].getParameterList())
        for key in self.choiceList:
            plist.extend(self.choiceList[key].getParameterList())
        return plist

    def getParameterListExt(self):
        plist = []
        for key in self.paramList:
            plist.extend(self.paramList[key].getParameterListExt())
        for key in self.choiceList:
            plist.extend(self.choiceList[key].getParameterListExt())
        return plist

    #def add(self, type, value):

    def addRendezvousParam(self, value):
        if not self.findOption("Rendezvous"):
            param = trch.Parameter_U16_create("Rendezvous", 
                                              "Rendezvous location", 
                                              1, 
                                              value,
                                              self.namespaceUri,
                                              self.schemaVersion)
            a = trch.Params_addParameter(self.parameters, param)
            del a
            self.paramList["rendezvous"] = self.findParameter("rendezvous")

        self.set("Rendezvous", value)
        


