
import dsz
import sqlite3
import sys
if (__name__ == '__main__'):
    save_flags = dsz.control.Method()
    dsz.control.echo.Off()
    if (dsz.script.Env['script_parent_echo_disabled'].lower() != 'false'):
        dsz.control.quiet.On()
    if (len(sys.argv) != 3):
        dsz.ui.Echo(('Invalid number of arguments supplied. Expected 3 (including program name), received %d.' % len(sys.argv)))
        print ('For debugging purposes:\n%s' % sys.argv)
        sys.exit((-1))
    database_file = sys.argv[1]
    sql_statement = sys.argv[2]
    dsz.script.data.Start('sqlstatementinfo')
    dsz.script.data.Add('database_file', database_file, dsz.TYPE_STRING)
    dsz.script.data.Add('sql_statement', sql_statement, dsz.TYPE_STRING)
    dsz.script.data.Store()
    db = sqlite3.connect(database_file)
    c = db.cursor()
    rows = c.execute(sql_statement).fetchall()
    if (len(rows) > 0):
        for r in rows:
            dsz.script.data.Start('row')
            d = 0
            for c in r:
                dsz.script.data.Add(('column%d' % d), str(c), dsz.TYPE_STRING)
                d += 1
            dsz.script.data.Store()