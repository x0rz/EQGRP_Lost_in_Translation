
from __future__ import print_function
from __future__ import division
ALIGN_LEFT = '<'
ALIGN_CENTER = '_'
ALIGN_RIGHT = '>'

def pprint(data, header=None, dictorder=None, align=None, output_file=None):
    if ((dict is type(data[0])) and (dictorder is None)):
        dictorder = data[0].keys()
    if ((dict is type(data[0])) and (header is None)):
        header = data[0].keys()
    (sdata, align) = makeStrings(data, dictorder, align)
    (widths, percents) = calcSize(sdata, header)
    output = ''
    if header:
        for i in range(len(header)):
            output += ((('|' + (' ' * (((widths[i] - len(header[i])) // 2) + 1))) + header[i]) + (' ' * (((widths[i] - len(header[i])) // 2) + 1)))
            if ((widths[i] - len(header[i])) % 2):
                output += ' '
            if percents[i]:
                output += (' ' * (percents[i] - header[i].count('%')))
        output += '|'
        output += '\n'
    for i in range(len(widths)):
        output += ('+-' + ('-' * ((widths[i] + 1) + percents[i])))
    output += '+'
    output += '\n'
    for j in range(len(sdata)):
        d = sdata[j]
        a = align[j]
        for i in range(len(d)):
            if (a[i] == ALIGN_RIGHT):
                output += ((('|' + (' ' * ((widths[i] - len(d[i])) + 1))) + d[i]) + ' ')
            elif (a[i] == ALIGN_CENTER):
                output += ((('|' + (' ' * (((widths[i] - len(d[i])) // 2) + 1))) + d[i]) + (' ' * (((widths[i] - len(d[i])) // 2) + 1)))
                if ((widths[i] - len(d[i])) % 2):
                    output += ' '
            else:
                output += (('| ' + d[i]) + (' ' * ((widths[i] - len(d[i])) + 1)))
                if percents[i]:
                    output += (' ' * (percents[i] - d[i].count('%')))
        output += '|'
        output += '\n'
    if output_file:
        with open(output_file, 'wb') as output_handle:
            output_handle.write(output)
    else:
        print(output, end='')

def makeStrings(data, dictOrder, align):
    r = []
    a = ([] if (align is None) else None)
    for i in data:
        c = []
        ac = []
        if dictOrder:
            for k in dictOrder:
                c += ([i[k]] if (unicode is type(i[k])) else [(str(i[k]) if (i[k] is not None) else '')])
                if (a is not None):
                    ac += ([ALIGN_RIGHT] if ((int is type(i[k])) or (float is type(i[k])) or (long is type(i[k]))) else [ALIGN_LEFT])
        else:
            for k in i:
                c += ([k] if (unicode is type(k)) else [(str(k) if (k is not None) else '')])
                if (a is not None):
                    ac += ([ALIGN_RIGHT] if ((int is type(k)) or (float is type(k)) or (long is type(k))) else [ALIGN_LEFT])
        r += [c]
        if (a is not None):
            a += [ac]
    return (r, (a if (a is not None) else align))

def calcSize(data, header):
    widths = range(len(data[0]))
    percents = range(len(data[0]))
    for i in widths:
        widths[i] = 0
        percents[i] = 0
    if header:
        for i in range(len(header)):
            r = len(header[i])
            if (r > widths[i]):
                widths[i] = r
            r = header[i].count('%')
            if (r > percents[i]):
                percents[i] = r
    for d in data:
        for i in range(len(d)):
            r = len(d[i])
            if (r > widths[i]):
                widths[i] = r
            r = d[i].count('%')
            if (r > percents[i]):
                percents[i] = r
    return (widths, percents)