
from ops.survey.engine.etreehandler import EtreeTagHandler, enforce
from ops.survey.engine.launcher import plugin_launcher
import ops.survey.engine.launcher

class TaskTagHandler(EtreeTagHandler, ):

    def validate(self):
        return self.__process(validate=True)

    def process(self):
        return self.__process()

    def __process(self, validate=False):
        background = self.getbool('bg', default=False)
        module = self.element.get('module')
        enforce((module is not None), 'module attribute is required for <task>')
        prompt = self.getbool('prompt', default=False)
        resource = self.element.get('resource')
        pyscripts = self.getbool('pyscripts')
        run_name = self.element.get('run_name', default=ops.survey.PLUGIN)
        argselement = self.element.find('args')
        args = (argselement.text if (argselement is not None) else None)
        name = self.element.get('name')
        marker = self.element.get('marker')
        if (marker == 'None'):
            marker = None
        if (not validate):
            ret = plugin_launcher(module=module, bg=background, prompt=prompt, resource=resource, pyscripts=pyscripts, run_name=run_name, args=args, marker=marker, name=name)[0]
            if (not background):
                return ret
            else:
                return None
        else:
            return True