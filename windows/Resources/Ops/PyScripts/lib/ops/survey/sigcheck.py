
import dsz
import ops, ops.survey
import ops.cmd

def main():
    sig_cmd = ops.cmd.getDszCommand('python ifthen.py -project TeDi')
    sig_result = sig_cmd.execute()
    if (not sig_cmd.success):
        ops.error('Failed to execute script.')
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()