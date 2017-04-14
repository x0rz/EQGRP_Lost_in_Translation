
import dsz
MENU_TEXT = 'Queue periodic screenshots'

def main():
    dsz.ui.Echo('Starting periodic screenshots...', dsz.GOOD)
    interval = dsz.ui.GetString('Please select a screenshot interval', '4-6m')
    dsz.control.echo.Off()
    command = ('periodic -p %s screenshot -res high -format jpeg' % interval)
    dsz.cmd.Run(command, dsz.RUN_FLAG_RECORD)
    dsz.control.echo.On()
if (__name__ == '__main__'):
    main()