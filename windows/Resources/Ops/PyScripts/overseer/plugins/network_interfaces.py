
import dsz
MENU_TEXT = 'List all network interfaces'

def main():
    dsz.ui.Echo('Running network interface commands...', dsz.GOOD)
    dsz.control.echo.Off()
    dsz.cmd.Run('background log devicequery -deviceclass net', dsz.RUN_FLAG_RECORD)
    dsz.cmd.Run('background log performance -data NetworkInterface', dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
if (__name__ == '__main__'):
    main()