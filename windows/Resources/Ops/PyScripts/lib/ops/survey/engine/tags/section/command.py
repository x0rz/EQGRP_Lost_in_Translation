
from ops.survey.engine.xmlhandler import enforce
from ops.survey.engine.etreehandler import EtreeTagHandler
import dsz
import ops.cmd
import ops.db
ALLOWED_WITHOUT_WARNING = ['language', 'systemversion']
ALLOWED_COMMANDS = (['passworddump'] + ALLOWED_WITHOUT_WARNING)

class CommandTagHandler(EtreeTagHandler, ):

    def validate(self):
        return self.__process(validate=True)

    def process(self):
        return self.__process()

    def __process(self, validate=False):
        background = self.getbool('bg', default=False)
        cachetag = self.element.get('cachetag', default=None)
        prompt = self.getbool('prompt', default=True)
        quiet = self.getbool('quiet', default=False)
        enforce((not (background and cachetag)), 'background and cachetag attributes of <command> are mutually exclusive.')
        command = self.element.text.strip()
        enforce((command in ALLOWED_COMMANDS), (lambda : ("'%s' is not a valid input for <command>." % command)))
        if (not validate):
            cmd = ops.cmd.getDszCommand(command)
            cmd.dszbackground = background
            cmd.dszquiet = quiet
            (issafe, msgs) = cmd.safetyCheck()
            if issafe:
                if (command not in ALLOWED_WITHOUT_WARNING):
                    ops.info(('%s has passed registered safety checks, but you should still make sure' % command))
                    for msg in msgs:
                        ops.info(msg)
            else:
                ops.warn(('"%s" has NOT passed registered safety checks' % command))
                for msg in msgs:
                    ops.error(msg)
                ops.warn(('"%s" will not be run at this time' % command))
                return True
            if prompt:
                if (not dsz.ui.Prompt(((("Do you want to run '%s'" + (' in the background' if background else '')) + '?') % command))):
                    return True
            result = cmd.execute()
            if ((cachetag is not None) and (result is not None)):
                voldb = ops.db.get_voldb()
                voldb.save_ops_object(result, tag=cachetag)
        return True