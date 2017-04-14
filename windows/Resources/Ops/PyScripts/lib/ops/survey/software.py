
import dsz, dsz.version
import ops
import ops.survey
from datetime import datetime, timedelta
import ops.system.software
import ops.pprint
from optparse import OptionParser
PACKAGES_FILTER_KEYWORDS = ['hotfix', 'update']

def _commonsorter(keys):
    if (len(keys) < 1):
        return keys
    if ('updatedate' in keys[0]):
        datefield = 'updatedate'
    elif ('modified' in keys[0]):
        datefield = 'modified'
    else:
        raise RuntimeError, 'Unsupported data structure'
    keys.sort((lambda x, y: cmp(x['name'].lower(), y['name'].lower())))
    for i in range((len(keys) - 1)):
        if (keys[i]['name'] == keys[(i + 1)]['name']):
            if (keys[i][datefield] != keys[(i + 1)][datefield]):
                keys[i][datefield] = ('%s (%s), %s (%s)' % (keys[i][datefield], keys[i]['arch'], keys[(i + 1)][datefield], keys[(i + 1)]['arch']))
            keys[(i + 1)]['arch'] = None
            keys[i]['arch'] = '32 & 64-bit'
    keys = filter((lambda x: (x['arch'] is not None)), keys)
    return keys

def _displaySoftwareKeys(options):
    ops.survey.print_sub_header('Software key(s)')
    softkey = ops.system.software.get_software_keys(maxage=timedelta(seconds=options.maxage))
    ops.survey.print_agestring(softkey[0].dszobjage)
    keys = []
    for rootkey in softkey:
        if ('-wow64' in rootkey.commandmetadata.fullcommand):
            arch = '64-bit'
        else:
            arch = '32-bit'
        for key in rootkey.key[0].subkey:
            keys.append({'arch': arch, 'name': key.name, 'updatedate': key.updatedate})
    keys = _commonsorter(keys)
    ops.pprint.pprint(keys, dictorder=['arch', 'name', 'updatedate'], header=['Architecture', 'Name', 'Last update'])

def _displayProgramFiles(options):
    ops.survey.print_sub_header('Program files dir(s)')
    progfiles = ops.system.software.get_programfiles_dirs(maxage=timedelta(seconds=options.maxage))
    ops.survey.print_agestring(progfiles[0].dszobjage)
    progs = []
    for dirlist in progfiles:
        arch = ('32-bit' if ((not dsz.version.checks.IsOs64Bit()) or ('(x86)' in dirlist.commandmetadata.fullcommand)) else '64-bit')
        for dir in dirlist.diritem[0].fileitem:
            if ((dir.name == '.') or (dir.name == '..')):
                continue
            progs.append({'arch': arch, 'name': dir.name, 'modified': dir.filetimes.modified.time})
    progs = _commonsorter(progs)
    ops.pprint.pprint(progs, dictorder=['arch', 'name', 'modified'], header=['Architecture', 'Folder Name', 'Modified'])

def _displayInstallerPackages(options):
    ops.survey.print_sub_header('Installer Packages')
    packages = ops.system.software.get_packagelist(maxage=timedelta(seconds=options.maxage))
    ops.survey.print_agestring(packages.dszobjage)
    packs = []
    for p in packages.package:
        for i in PACKAGES_FILTER_KEYWORDS:
            if (i in p.name.lower()):
                break
        else:
            packs.append({'name': p.name, 'description': p.description, 'version': p.version, 'installdate': p.installdate, 'arch': p.revision})

    def _packsorter(x, y):
        ret = cmp(x['name'], y['name'])
        if (ret != 0):
            return ret
        ret = cmp(x['version'], y['version'])
        if (ret != 0):
            return ret
        return cmp(x['arch'], y['arch'])
    packs.sort(_packsorter)
    for i in range((len(packs) - 1)):
        if ((packs[i]['name'] == packs[(i + 1)]['name']) and (packs[i]['version'] == packs[(i + 1)]['version']) and (packs[i]['arch'] != packs[(i + 1)]['arch'])):
            packs[(i + 1)]['arch'] = None
            packs[i]['arch'] = '32 & 64-bit'
    packs = filter((lambda x: (x['arch'] is not None)), packs)
    ops.pprint.pprint(packs, dictorder=['arch', 'name', 'description', 'version', 'installdate'], header=['Arcitecture', 'Name', 'Description', 'Installed version', 'Date installed'])

def main():
    parser = OptionParser()
    parser.add_option('--maxage', dest='maxage', default='3600', help='Maximum age of information to use before re-running queries', type='int')
    (options, args) = parser.parse_args()
    ops.survey.print_header('Installed software')
    _displayInstallerPackages(options)
    _displaySoftwareKeys(options)
    _displayProgramFiles(options)
if ((__name__ == '__main__') or (__name__ == ops.survey.PLUGIN)):
    main()