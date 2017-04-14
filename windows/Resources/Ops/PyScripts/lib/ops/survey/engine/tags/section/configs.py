
from ops.survey.engine.bugcatcher import bugcatcher
from ops.survey.engine.etreehandler import EtreeTagHandler
from ops.survey.engine.xmlhandler import enforce
import dsz
import ops.survey
import ops.survey.engines

class ConfigsTagHandler(EtreeTagHandler, ):

    def validate(self):
        self.__process(validate=True)

    def process(self):
        self.__process()

    def __process(self, validate=False):
        file = self.element.get('file')
        section = self.element.get('section')
        enforce((file is not None), '<config> requires a file attribute.')
        enforce((section is not None), '<config> requires a section attribute.')
        if validate:
            return True
        for (resdir, fullpath) in ops.survey.locate_files(file, 'Data'):
            if dsz.ui.Prompt(('Execute configuration %s :: %s?' % (resdir, fullpath))):
                bugcatcher((lambda : ops.survey.engines.run(fullpath, sections=[section], forcemenu=True)), bug_critical=False)
        return True