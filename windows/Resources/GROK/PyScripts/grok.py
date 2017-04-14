
import dsz.version.checks
import grok_x86
import grok_x64
if dsz.version.checks.IsOs64Bit():
    grok_x64.main()
else:
    grok_x86.main()