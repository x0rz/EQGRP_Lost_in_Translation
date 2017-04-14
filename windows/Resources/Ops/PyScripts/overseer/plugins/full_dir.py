
import dsz
MENU_TEXT = 'Run recursive dir listing'

def main():
    dsz.ui.Echo('Running recursive directory listing...', dsz.GOOD)
    age = dsz.ui.GetString('Please enter an age parameter for the dir (enter 0 for no age)', '7d')
    command_string = 'background log dir -mask * -path * -max 0 -recursive'
    if (age != '0'):
        command_string += (' -age %s' % age)
    dsz.control.echo.Off()
    dsz.cmd.Run(command_string, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
if (__name__ == '__main__'):
    main()