
import dsz
import dsz.ui
import dsz.script
SELF = int(dsz.script.Env['script_command_id'])

def get(env, cmdid=0, addr=dsz.script.Env['target_address']):
    if (not dsz.env.Check(env, cmdid, addr)):
        return None
    else:
        return unicode(dsz.env.Get(env, cmdid, addr), 'utf_8')

def set(env, value, cmdid=0, addr=dsz.script.Env['target_address']):
    if (bool is type(value)):
        translated_value = str(value).upper()
    elif (unicode is type(value)):
        translated_value = value.encode('utf8')
    else:
        translated_value = str(value)
    dsz.env.Set(env, translated_value, cmdid, addr)

def delete(env, cmdid=0, addr=dsz.script.Env['target_address']):
    dsz.env.Delete(env, cmdid, addr)

def upper(env, cmdid=0, addr=dsz.script.Env['target_address']):
    value = get(env, cmdid, addr)
    if value:
        return value.upper()
    else:
        return value

def lower(env, cmdid=0, addr=dsz.script.Env['target_address']):
    value = get(env, cmdid, addr)
    return (value.lower() if value else value)

def bool(env, cmdid=0, addr=dsz.script.Env['target_address']):
    value = upper(env, cmdid, addr)
    return ((value == 'TRUE') if value else value)

def numeric(env, base=10, cmdid=0, addr=dsz.script.Env['target_address']):
    value = get(env, cmdid, addr)
    return (int(value, base) if value else value)
if (__name__ == '__main__'):
    if (not dsz.script.IsLocal()):
        import sys
        dsz.ui.Echo('To run unit tests, you must be in a local context.', dsz.ERROR)
        sys.exit((-1))
    import unittest
    UNICODE = u'\u0100\u0101\u0102\u0103\u0104\u0105\u0106\u0107\u0108\u0109\u010a'
    ASCII = 'The quick brown fox jumped over the lazy dog.'
    LOWER = ASCII.lower()
    UPPER = ASCII.upper()
    TEST = 'OPS_ENV_TEST'

    class EnvTest(unittest.TestCase, ):

        def testASCII(self):
            set(TEST, ASCII)
            self.assertEqual(get(TEST), ASCII)

        def testAlwaysUnicode(self):
            set(TEST, ASCII)
            self.assertEqual(type(get(TEST)), unicode)

        def testUNICODE(self):
            set(TEST, UNICODE)
            self.assertEqual(get(TEST), UNICODE)

        def testNumericInt(self):
            set(TEST, 5)
            self.assertEqual(numeric(TEST), 5)

        def testNumericHex(self):
            set(TEST, '0xBEEF')
            self.assertEqual(numeric(TEST, base=16), 48879)

        def testBoolTrue(self):
            set(TEST, True)
            self.assertTrue(bool(TEST))

        def testBoolFalse(self):
            set(TEST, False)
            self.assertFalse(bool(TEST))

        def testLower(self):
            set(TEST, UPPER)
            self.assertEqual(lower(TEST), LOWER)

        def testUpper(self):
            set(TEST, LOWER)
            self.assertEqual(upper(TEST), UPPER)
    unittest.main()