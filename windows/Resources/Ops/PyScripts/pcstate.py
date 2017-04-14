
import ops.cmd
import ops.env
import ops.parseargs
from argparse import ArgumentTypeError
PCFIX_VAR = 'OPS_PCFIX'

def main():

    def validate(x):
        try:
            x = int(x)
        except ValueError as e:
            raise ArgumentTypeError(e)
        except:
            raise 
        if ((x < 0) or (x > 5)):
            raise ArgumentTypeError, 'Value must be on interval [0,5]'
        return x
    parser = ops.parseargs.ArgumentParser()
    parser.add_argument('pcfix', type=validate, help='Number on interval [0,5]')
    options = parser.parse_args()
    ops.env.set(PCFIX_VAR, options.pcfix)
    prob_cmd = ops.cmd.getDszCommand(('problem PCFIX %s' % options.pcfix))
    prob_cmd.execute()
if (__name__ == '__main__'):
    main()