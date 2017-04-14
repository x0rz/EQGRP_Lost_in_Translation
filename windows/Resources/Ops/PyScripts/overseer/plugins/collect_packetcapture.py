
import os
import dsz
MENU_TEXT = 'Try to retrieve packet capture data'

def main():
    dsz.ui.Echo('Checking for DARKSKYLINE collection...', dsz.GOOD)
    win_dir = dsz.path.windows.GetSystemPaths()[0]
    font_dir = os.path.join(win_dir, 'Fonts')
    if dsz.file.Exists('vga_ds.tff', font_dir):
        dsz.ui.Echo('\tDS capture file exists...', dsz.GOOD)
        dsz.cmd.Run('darkskyline', dsz.RUN_FLAG_RECORD)
    else:
        dsz.ui.Echo('\tDS capture file not found.', dsz.WARNING)
if (__name__ == '__main__'):
    main()