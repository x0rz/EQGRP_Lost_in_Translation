
import dsz
MENU_TEXT = 'Retrieve credentials ( Putty, SecureCRT, etc )'

def main():
    dsz.ui.Echo('Checking for credentials in known locations...', dsz.GOOD)
    dsz.control.echo.Off()
    dsz.cmd.Run('background log python windows/autologon.py', dsz.RUN_FLAG_RECORD)
    dsz.cmd.Run('background log python windows/simontatham.py -args "-f"', dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
if (__name__ == '__main__'):
    main()