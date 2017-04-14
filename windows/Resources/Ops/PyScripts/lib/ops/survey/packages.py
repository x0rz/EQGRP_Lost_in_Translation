
from __future__ import print_function
import codecs
import dsz
import ops, ops.db, ops.dszcmd
from ops.pprint import pprint

def get():
    flags = dsz.control.Method()
    dsz.control.echo.Off()
    if (not dsz.cmd.Run('packages', dsz.RUN_FLAG_RECORD)):
        return None
    apps = []
    for i in ops.dszcmd.get('package', dsz.TYPE_OBJECT):
        data = {}
        data['name'] = ops.dszcmd.objget(i, 'name', s=True)
        data['version'] = ops.dszcmd.objget(i, 'version', s=True)
        data['description'] = ops.dszcmd.objget(i, 'description', s=True)
        data['install_date'] = ops.dszcmd.objget(i, 'installdate', s=True)
        apps += [data]
    return apps

def update_db():
    apps = get()
    with ops.db.Database() as db:
        c = db.cursor()
        c.execute('DELETE FROM applications')
        for i in apps:
            c.execute('INSERT OR IGNORE INTO applications (name, version, description, install_date) VALUES (?, ?, ?, ?)', (i['name'], i['version'], i['description'], i['install_date']))
    return apps

def packages(update=False, filterUpdates=False):
    if update:
        update_db()
    else:
        needupdate = False
        with ops.db.Database() as db:
            c = db.cursor()
            c.execute('SELECT name FROM applications')
            if (c.rowcount < 1):
                needupdate = True
        if needupdate:
            update_db()
    apps = []
    with ops.db.Database() as db:
        c = db.cursor()
        if filterUpdates:
            c.execute('SELECT name, version, description, install_date FROM applications WHERE name NOT LIKE "%update%" AND name NOT LIKE "%hotfix%" ORDER BY name ASC')
        else:
            c.execute('SELECT name, version, description, install_date FROM applications ORDER BY name ASC')
        for i in c:
            apps += [{'name': i[0], 'version': i[1], 'description': i[2], 'install_date': i[3]}]
    return apps

def main():
    ops.info('Fetching installed applications')
    apps = packages(filterUpdates=True)
    if (not apps):
        ops.error('Error pulling installed applications.')
    else:
        pprint(apps, header=['Name', 'Version', 'Description', 'Install Date'], dictorder=['name', 'version', 'description', 'install_date'])
        print()
if (__name__ == '__main__'):
    main()