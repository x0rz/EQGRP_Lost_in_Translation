
import dsz
import ops, ops.survey
import ops.cmd
import ops.env
import ops.files.dirs
import ops.system.registry
import ops.system.environment
import ops.project
from optparse import OptionParser
import datetime
import os.path
import traceback
ONE_DAY = 86400
ONE_MONTH = (ONE_DAY * 30)
ONE_YEAR = (ONE_DAY * 365)

def main():
    keylist = [('system\\currentcontrolset\\control\\timezoneinformation', 'OPS_EXTRA_TIMEZONE_KEY', ONE_DAY, True), ('SYSTEM\\CurrentControlSet\\Enum\\USB', 'OPS_USB_USB_KEY', ONE_DAY, True), ('SYSTEM\\CurrentControlSet\\Enum\\USBSTOR', 'OPS_USB_USBSTOR_KEY', ONE_DAY, True), ('Software\\Policies\\Microsoft\\Windows\\WindowsUpdate', 'OPS_EXTRA_WUPOLICY_KEY', ONE_DAY, True), ('Software\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate', 'OPS_EXTRA_WU_KEY', ONE_DAY, True), ('SYSTEM\\CurrentControlSet\\Services\\Dhcp\\Parameters', 'OPS_EXTRA_DHCP_KEY', ONE_DAY, True), ('SYSTEM\\CurrentControlSet\\Services\\wuauserv', 'OPS_EXTRA_WUSERV_KEY', ONE_DAY, True), ('Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Connection\\WinHttpSettings', 'OPS_EXTRA_WINHTTP_KEY', ONE_DAY, True), ('HARDWARE\\DESCRIPTION\\System\\CentralProcessor', 'OPS_EXTRA_CPU_KEY', ONE_DAY, True), ('SYSTEM\\CurrentControlSet\\Control\\LSA\\Data', 'OPS_SLRO_LSADATA', ONE_YEAR, False), ('SYSTEM\\CurrentControlSet\\Control\\LSA\\GBG', 'OPS_SLRO_LSAGBG', ONE_YEAR, False), ('SYSTEM\\CurrentControlSet\\Control\\LSA\\JD', 'OPS_SLRO_LSAJD', ONE_YEAR, False), ('SYSTEM\\CurrentControlSet\\Control\\LSA\\Skew1', 'OPS_SLRO_LSASKEWL', ONE_YEAR, False), ('SECURITY\\Policy\\Secrets\\DPAPI_SYSTEM\\CurrVal', 'OPS_SLRO_DPAPICURRVAL', ONE_YEAR, False), ('SECURITY\\Policy\\PolSecretEncryptionKey', 'OPS_SLRO_POLSECRET', ONE_YEAR, False), ('SECURITY\\Policy\\L$HYDRAENCKEY_28ada6da-d622-11d1-9cb9-00c04fb16e75\\CurrVal', 'OPS_SLRO_HYDRAKEY', ONE_YEAR, False), ('SYSTEM\\CurrentControlSet\\Control\\Terminal Server\\RCM\\Secrets\\L$HYDRAENCKEY_28ada6da-d622-11d1-9cb9-00c04fb16e75\\CurrVal', 'OPS_SLRO_RCMSECRETS', ONE_YEAR, False), ('SECURITY\\Policy\\PolEKList', 'OPS_SLRO_POLEKLIST', ONE_YEAR, False), ('system\\RAdmin\\v2.0\\Server\\Parameters', 'OPS_SLRO_RADMIN2', ONE_MONTH, False), ('SOFTWARE\\RAdmin\\v3.0\\Server\\Parameters\\Radmin Security', 'OPS_SLRO_RADMIN3', ONE_MONTH, False), ('SECURITY\\Policy\\Secrets', 'OPS_SLRO_POLICYSECRETS', ONE_MONTH, True), ('software\\pgp corporation\\pgp', 'OPS_SLRO_PGP', ONE_MONTH, True), ('software\\network associates\\pgp60', 'OPS_SLRO_NAPGP60', ONE_MONTH, True), ('software\\network associates\\pgp55', 'OPS_SLRO_NAPGP55', ONE_MONTH, True), ('software\\network associates\\pgp', 'OPS_SLRO_NAPGP', ONE_MONTH, True), ('Software\\TeamViewer', 'OPS_SLRO_TEAMVIEWER', ONE_DAY, True)]
    winroot = ops.env.get('OPS_WINDOWSDIR')
    sysroot = ops.env.get('OPS_SYSTEMDIR')
    programdata = ops.system.environment.get_environment_var('ALLUSERSPROFILE', maxage=datetime.timedelta(seconds=14400)).value
    progfiles = ops.system.environment.get_environment_var('PROGRAMFILES', maxage=datetime.timedelta(seconds=14400)).value
    dirwalklist = [(os.path.join(sysroot, 'Microsoft\\Protect\\S-1-5-18'), 'OPS_SLRO_PROTECT18', ONE_DAY, True), (os.path.join(sysroot, 'Microsoft\\Protect\\S-1-5-20'), 'OPS_SLRO_PROTECT20', ONE_DAY, True), (os.path.join(programdata, 'Microsoft\\Crypto\\RSA'), 'OPS_SLRO_RSAKEYS', ONE_DAY, True), (os.path.join(progfiles, 'InfoTeCS\\ViPNet Client'), 'OPS_SLRO_VIPNET', ONE_DAY, False), (os.path.join(winroot, 'Fonts'), 'OPS_WINDOWS_FONTS', ONE_DAY, False)]
    results = []
    for pair in keylist:
        try:
            results.append(ops.system.registry.get_registrykey('L', pair[0], cache_tag=pair[1], cache_size=1, maxage=datetime.timedelta(pair[2]), dszquiet=False, dszlog=True, recursive=pair[3]))
        except:
            pass
    for pair in dirwalklist:
        try:
            results.append(ops.files.dirs.get_dirlisting(pair[0], cache_tag=pair[1], cache_size=1, maxage=datetime.timedelta(pair[2]), dszquiet=False, dszlog=True, recursive=pair[3]))
        except:
            pass
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()