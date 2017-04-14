import sys,textwrap

rlmain = sys.modules[u"pyreadline.rlmain"]
rl = rlmain.rl

def get_doc(rl):
    methods = [(x, getattr(rl, x)) for x in dir(rl) if callable(getattr(rl, x))]
    return [ (x, m.__doc__ )for x, m in methods if m.__doc__]
    
    
def get_rest(rl):
    q = get_doc(rl)
    out = []
    for funcname, doc in q:
        out.append(funcname)
        out.append(u"\n".join(textwrap.wrap(doc, 80, initial_indent=u"   ")))
        out.append(u"")
    return out     