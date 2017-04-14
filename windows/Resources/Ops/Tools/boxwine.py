
username = raw_input('username:')
password = raw_input('password:')
tmp = ''
for i in username:
    x = hex(ord(i))[2:]
    if (len(x) < 4):
        y = ('%s%s' % (('0' * (4 - len(x))), x))
    else:
        y = x
    tmp += ('%s%s' % (y[2:], y[:2]))
tmp += '0000'
print ('USERNAME: %s' % tmp)
tmp = ''
for i in password:
    x = hex(ord(i))[2:]
    if (len(x) < 4):
        y = ('%s%s' % (('0' * (4 - len(x))), x))
    else:
        y = x
    tmp += ('%s%s' % (y[2:], y[:2]))
tmp += '0000'
print ('PASSWORD: %s' % tmp)
raw_input('Press Enter to continue')