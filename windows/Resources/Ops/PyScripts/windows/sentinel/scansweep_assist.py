
import subprocess

def main(alert_bat_file, output_dir):
    subprocess.Popen(('cmd /K %s' % alert_bat_file), creationflags=subprocess.CREATE_NEW_CONSOLE)
    return True