
import dsz
MENU_TEXT = 'Pull DNS cache'

def main():
    dsz.ui.Echo('Running dns -cache -display...', dsz.GOOD)
    dsz.control.echo.Off()
    dsz.cmd.Run('background log dns -cache -display', dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
if (__name__ == '__main__'):
    main()