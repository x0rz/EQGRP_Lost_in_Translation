
import dsz
MENU_TEXT = 'Run UserQuery'

def main():
    dsz.ui.Echo('Running user query script...', dsz.GOOD)
    dsz.control.echo.Off()
    dsz.cmd.Run('background log userquery -all', dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
if (__name__ == '__main__'):
    main()