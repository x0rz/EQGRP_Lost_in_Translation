
import os
import re

def listdir(path, mask=None, includeFiles=True, includeDirs=True, maskFlags=re.IGNORECASE):
    path = os.path.normpath(path)
    files = os.listdir(path)
    if (not includeFiles):
        for f in files:
            if os.path.isfile(os.path.join(path, f)):
                files.remove(f)
    if (not includeDirs):
        for f in files:
            if os.path.isdir(os.path.join(path, f)):
                files.remove(f)
    if mask:
        regex = re.compile(mask, maskFlags)
        rm = []
        for f in files:
            if (not regex.search(f)):
                rm += [f]
        for f in rm:
            files.remove(f)
    return files

def shell_lex(string):
    build = []
    partition = re.compile('^(.*?)(?<![^\\\\]\\\\)(".*)')
    unescape = re.compile('(?<!\\\\)(\\\\)(?=")')
    while string:
        match = partition.match(string)
        if match:
            match = match.groups()
            if (match[0] != ''):
                for i in match[0].split(' '):
                    if i:
                        build.append(i)
            rematch = partition.match(match[1][1:])
            if (rematch is None):
                raise RuntimeError, 'Could not find end of quote.'
            rematch = rematch.groups()
            build.append(unescape.sub('', rematch[0]))
            string = rematch[1][1:]
        else:
            for i in string.split(' '):
                if i:
                    build.append(i)
            break
    return build

def make_sys_argv(prog, string):
    build = ([prog] + shell_lex(string))
    return build