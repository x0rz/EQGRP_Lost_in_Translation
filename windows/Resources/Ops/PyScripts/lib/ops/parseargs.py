
import argparse
import sys

def int10or16(x):
    if ((type(x) is str) or (type(x) is unicode)):
        if x.startswith('0x'):
            return int(x[2:], 16)
        else:
            return int(x)
    else:
        raise TypeError, 'dszint conversion must be performed on a string or unicode string'

class ArgumentParser(argparse.ArgumentParser, ):

    def __init__(self, **kwargs):
        argparse.ArgumentParser.__init__(self, **kwargs)

    def parse_known_args(self, args=None, namespace=None, **kwargs):
        if (args is None):
            args = sys.argv[1:]
        expected_args = []
        for action in self._optionals._actions:
            for string in action.option_strings:
                if string.startswith('--'):
                    expected_args.append(string[1:])
        for i in range(0, len(args)):
            if ((args[i] in expected_args) or (args[i] == '-')):
                args[i] = ('-' + args[i])
        return argparse.ArgumentParser.parse_known_args(self, args=args, namespace=namespace, **kwargs)

    def format_help(self):
        return argparse.ArgumentParser.format_help(self).replace('--', '-')
if (__name__ == '__main__'):
    parser = ArgumentParser(add_help=False)
    parser.add_argument('pos')
    parser.add_argument('--test', '-t', type=int10or16)
    parser.add_argument('--foo', nargs='?')
    parser.add_argument('--bar', nargs='+')
    parser.add_argument('--bool', action='store_true')
    parser.add_argument_group('Rand').add_argument('--rand')
    subparsers = parser.add_subparsers()
    subparsers.add_parser('invoke').add_argument('--action')
    options = parser.parse_args()
    print options