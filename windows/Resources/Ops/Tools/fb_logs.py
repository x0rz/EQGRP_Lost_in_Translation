
import os
import shutil
import sys
import re
import traceback
sys.path.append('D:\\dszopsdisk\\resources\\ops\\pyscripts\\lib')
import sendfile

def fb_logs_get(OpsdiskPath='d:\\dszopsdisk', LogDir='d:\\logs'):
    full_list = []
    tool_names_dirs = ['exploits', 'touches', 'implants', 'listeningposts', 'payloads']
    for tool_name in tool_names_dirs:
        tool_dir_list = os.listdir(os.path.join(OpsdiskPath, tool_name))
        for name in tool_dir_list:
            temp = name.split('-', 1)[0]
            if (temp not in full_list):
                full_list.append(temp)
    full_list.append('fuzzbunch')
    full_list.append('Rpc')
    log_list_dirs = os.listdir(LogDir)
    base_exp_log_dir = os.path.join(OpsdiskPath, 'tmp', 'exploits')
    if (not os.path.isdir(base_exp_log_dir)):
        os.makedirs(base_exp_log_dir, 744)
    for ldir in log_list_dirs:
        if ((ldir in ('.', '..', 'exploits')) or (not os.path.isdir(os.path.join(LogDir, ldir)))):
            continue
        exp_log_dir = os.path.join(base_exp_log_dir, ldir)
        if (not os.path.isdir(exp_log_dir)):
            os.makedirs(os.path.join(base_exp_log_dir, ldir), 744)
        os.chdir(os.path.join(LogDir, ldir))
        for (curr_path, dir_list, file_list) in os.walk('.', topdown=True):
            if ('GuiRequestLog' in dir_list):
                dir_list.remove('GuiRequestLog')
            if ('GuiSystemLog' in dir_list):
                dir_list.remove('GuiSystemLog')
            if ('Payloads' in dir_list):
                dir_list.remove('Payloads')
            if ('payload' in dir_list):
                dir_list.remove('payload')
            if ('ScreenShots' in dir_list):
                dir_list.remove('ScreenShots')
            if ('GetFiles' in dir_list):
                dir_list.remove('GetFiles')
            if ('Tasking' in dir_list):
                dir_list.remove('Tasking')
            if ('UsedTools' in dir_list):
                dir_list.remove('UsedTools')
            for file_name in file_list:
                for exploit_name in full_list:
                    if (exploit_name in file_name):
                        cpfile = os.path.join(curr_path, file_name)
                        dstfile = os.path.join(exp_log_dir, file_name)
                        try:
                            src = open(cpfile, 'r')
                            dst = open(dstfile, 'w')
                            srctxt = src.readlines()
                            for line in srctxt:
                                dst.write(re.subn('[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}', 'X.X.X.X', line)[0])
                        except:
                            traceback.print_exc(sys.exc_info())
                            print ('Error clearing out data in %s' % cpfile)
                        finally:
                            src.close()
                            dst.close()
                        shutil.copystat(cpfile, dstfile)
    for ldir in os.listdir(base_exp_log_dir):
        try:
            sendfile.main(os.path.join(base_exp_log_dir, ldir), outfilebasename=(ldir + '_fb_logs'), destfolder='fast')
            pass
        except:
            print ('Could not send %s' % ldir)
            traceback.print_exc(sys.exc_info())
    print '\n\nFinished successfully'
    return 0
if (__name__ == '__main__'):
    fb_logs_get(os.sys.argv[1], os.sys.argv[2])
    exit()