
import dsz
import ops

def main():
    ops.preload('language')
    flags = dsz.control.Method()
    dsz.control.echo.On()
    ops.info('Querying language')
    dsz.cmd.Run('language')
if (__name__ == '__main__'):
    main()