
import codecs
import os
import sys
KEYMAP = {u'[end]': '1', u'\u2193': '2', u'[pg dn]': '3', u'\u2190': '4', u'[clear]': '5', u'\u2192': '6', u'[home]': '7', u'\u2191': '8', u'[pg up]': '9', u'[insert]': '0', u'[del]': '.'}

def main(args):
    while (len(args) < 2):
        input_path = raw_input('\nEnter the path to a YAK2 scancodes file: ')
        if (not os.path.exists(input_path)):
            print 'File not found. Try again.'
        elif (not ('scancodes' in input_path)):
            print "You passed a bad file name, it must have 'scancodes' in the name!"
        else:
            args.append(input_path)
    shave(args[1])

def shave(input_file):
    input_handle = codecs.open(input_file, encoding='utf-16')
    data = input_handle.read()
    input_handle.close()
    for key in KEYMAP:
        data = data.replace(key, KEYMAP[key])
    new_file = ('%s.shaved.txt' % os.path.splitext(input_file)[0])
    while (not _safe_write(data, new_file)):
        new_file = raw_input('\nWhere would you like to save the output: ')

def _safe_write(data, file_path):
    try:
        output_handle = file(file_path, 'wb')
        output_handle.write(data)
        output_handle.close()
        print ('Wrote output file: %s' % file_path)
    except:
        print "Couldn't write output file."
        return False
    return True
if (__name__ == '__main__'):
    main(sys.argv)