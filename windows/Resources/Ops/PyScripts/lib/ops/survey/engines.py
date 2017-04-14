
import os
import dsz.lp
import ops
import ops.survey
import ops.survey.engine.xmlhandler
import ops.survey.engine.etreehandler
import ops.survey.engine.tags.section
ops.survey.engine.xmlhandler.register_handler('2', ops.survey.engine.etreehandler.ElementTreeProcessor, namespace='ops.survey.engine.tags')

def execute(file, flags={}, **kwargs):
    config = ops.survey.engine.xmlhandler.Config(file=file, flags=flags, **kwargs)
    return config.process()

def validate(file, flags={}, **kwargs):
    config = ops.survey.engine.xmlhandler.Config(file=file, flags=flags, **kwargs)
    return config.validate()

def makepath(file=None, resource='Ops', subdirs=['Data'], fullpath=None):
    if (bool(file) and bool(fullpath)):
        raise RuntimeError, 'file and fullpath are mutually exclusive'
    if fullpath:
        return fullpath
    else:
        path = os.path.join(ops.RESDIR, resource)
        for i in subdirs:
            path = os.path.join(path, i)
        return os.path.join(path, file)

def run(file=None, resource='Ops', subdirs=['Data'], fullpath=None, **kwargs):
    config = makepath(file, resource, subdirs, fullpath)
    version = ops.survey.engine.xmlhandler.version(config)
    if (version == '2'):
        run2(config, **kwargs)
    else:
        execute(config)

def run2(config, sections=None, forcemenu=False):
    default_sections = ops.survey.DEFAULT_SECTIONS
    override = ops.env.get(ops.survey.OVERRIDE, addr='')
    if override:
        if (override.find(':') > (-1)):
            (config, useless, default_sections) = override.partition(':')
            config = os.path.join(ops.RESDIR, config)
        else:
            config = os.path.join(ops.RESDIR, override)
    if (sections is None):
        sections = default_sections
    return execute(config, flags={ops.survey.engine.tags.section.SURVEY_SECTIONS: sections}, forcemenu=forcemenu)
if (__name__ == '__main__'):
    print ('Validation: %s' % validate(makepath('survey.xml')))
    print '---------------------'
    run(file='survey.xml')