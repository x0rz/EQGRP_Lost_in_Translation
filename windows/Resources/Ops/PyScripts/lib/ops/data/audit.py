
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz

class AuditingEventData(DszObject, ):

    def __init__(self, dszpath='', cmdid=None, opsclass=None, parent=None, debug=False):
        DszObject.__init__(self, dszpath, cmdid, dszauditevent, parent, debug)

    def __getAuditingSuccess(self):
        return (self.audit_event_success == 1)
    auditing_success = property(__getAuditingSuccess)

    def __getAuditingFailure(self):
        return (self.audit_event_failure == 1)
    auditing_failure = property(__getAuditingFailure)
if ('audit' not in cmd_definitions):
    dszauditevent = OpsClass('event', {'audit_event_success': OpsField('audit_event_success', dsz.TYPE_BOOL), 'audit_event_failure': OpsField('audit_event_failure', dsz.TYPE_BOOL), 'category': OpsField('category', dsz.TYPE_STRING), 'categorynative': OpsField('categorynative', dsz.TYPE_STRING), 'subcategory': OpsField('subcategory', dsz.TYPE_STRING), 'subcategorynative': OpsField('subcategorynative', dsz.TYPE_STRING), 'categoryguid': OpsField('categoryguid', dsz.TYPE_STRING), 'subcategoryguid': OpsField('subcategoryguid', dsz.TYPE_STRING)}, AuditingEventData, single=False)
    audit = OpsClass('status', {'event': dszauditevent, 'audit_mode': OpsField('audit_mode', dsz.TYPE_BOOL), 'audit_status_avail': OpsField('audit_status_avail', dsz.TYPE_BOOL)}, DszObject)
    auditcommand = OpsClass('audit', {'status': audit}, DszCommandObject)
    cmd_definitions['audit'] = auditcommand