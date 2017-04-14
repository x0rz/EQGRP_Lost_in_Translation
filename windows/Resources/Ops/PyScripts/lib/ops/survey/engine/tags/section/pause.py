
from ops.survey.engine.etreehandler import EtreeTagHandler, enforce
import ops

class PauseTagHandler(EtreeTagHandler, ):

    def validate(self):
        return self.__handler(validate=True)

    def process(self):
        self.__handler()

    def __handler(self, validate=False):
        msg = self.element.text
        if (not validate):
            ops.pause(msg)
        return True