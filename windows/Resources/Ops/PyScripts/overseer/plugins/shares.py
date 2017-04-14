
import dsz
MENU_TEXT = 'Run shares commands'

def main():
    dsz.ui.Echo('Running shares -list and shares -query...', dsz.GOOD)
    dsz.control.echo.Off()
    dsz.cmd.Run('background log shares -list', dsz.RUN_FLAG_RECORD)
    dsz.cmd.Run('background log shares -query', dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
if (__name__ == '__main__'):
    main()