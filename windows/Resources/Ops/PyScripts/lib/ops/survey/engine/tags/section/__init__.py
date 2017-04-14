
from ops.survey.engine.xmlhandler import enforce
from ops.survey.engine.etreehandler import EtreeTagHandler
import ops.menu
SURVEY_SECTIONS = 'OPS_SURVEY_SECTIONS'

class SectionTagHandler(EtreeTagHandler, ):

    def marker_check(self):
        name = self.element.get('name')
        if ((SURVEY_SECTIONS not in self.flags) or (name not in self.flags[SURVEY_SECTIONS])):
            return False
        elif (self.element.get('marker') is not None):
            return EtreeTagHandler.marker_check(self)
        else:
            return True

    def validate(self):
        return self.__handle(validate=True)

    def process(self):
        return self.__handle()

    def __handle(self, validate=False):
        name = self.element.get('name')
        menu = (self.getbool('menu', default=False) or self.forcemenu)
        enforce((name is not None), '<section> tag requires a name attribute.')
        if ((menu or self.forcemenu) and (not validate)):
            if (not self.__menu()):
                return None
        return self.continue_processing(ignore=['preps'])

    def __menu(self):
        menu = ops.menu.Menu()
        menu.set_heading('Select Tasking')
        tasks = {}
        menu.add_option('Use this configuration')
        for e in self.element:
            display = e.get('name')
            if (display is None):
                display = e.get('marker')
            if (display is None):
                display = ('"%s": {"attribs": %s, "text": %s}' % (e.tag, e.attrib, repr(e.text)))
            menudisplay = display
            count = 0
            while (menudisplay in tasks):
                count += 1
                menudisplay = (display + (' #%d' % count))
            tasks[menudisplay] = e
            menu.add_toggle_option(menudisplay, section='Tasks', state='Enabled')
        result = menu.execute(exiton=[1], exit='Exit and SKIP ALL tasks')
        if (result['selection'] == 0):
            return False
        for i in result['all_states']['Tasks']:
            if (result['all_states']['Tasks'][i] == '<DISABLED>'):
                self.element.remove(tasks[i])
        return True