
import dsz
import ops

def main():
    flags = dsz.control.Method()
    ops.preload('registryquery')
    ops.info('Registry checks')
    dsz.control.echo.On()
    dsz.cmd.Run('registryquery -hive L -key "SYSTEM\\currentcontrolset\\services\\tcpip\\parameters\\winsock" -value HelperDLLName')
    dsz.cmd.Run('registryquery -hive L -key "software\\microsoft\\windows nt\\currentversion\\\\windows" -value AppInit_Dlls')
    dsz.cmd.Run('registryquery -hive L -key "software\\microsoft\\windows\\currentversion\\run"')
    dsz.cmd.Run('registryquery -hive L -key "software\\microsoft\\windows\\currentversion\\runonce"')
    dsz.cmd.Run('registryquery -hive L -key "software\\microsoft\\windows\\currentversion\\runonceex"')
    dsz.control.echo.Off()
    ops.info('Querying winlogon and processor keys in the background.')
    dsz.cmd.Run('background registryquery -hive L -key "software\\microsoft\\windows nt\\currentversion\\winlogon"')
    dsz.cmd.Run('background registryquery -hive L -key "HARDWARE\\DESCRIPTION\\System\\CentralProcessor" -recursive')
if (__name__ == '__main__'):
    main()