
from ops.data import OpsClass, OpsField, DszObject, DszCommandObject, cmd_definitions
import dsz
if ('trafficcapture' not in cmd_definitions):
    dzsfilter = OpsClass('filter', {'adapterfilter': OpsField('adapterfilter', dsz.TYPE_INT), 'bpffilter': OpsField('bpffilter', dsz.TYPE_STRING)}, DszObject, single=True)
    dsztcstatus = OpsClass('status', {'versionmajor': OpsField('versionmajor', dsz.TYPE_INT), 'versionminor': OpsField('versionminor', dsz.TYPE_INT), 'versionrevision': OpsField('versionrevision', dsz.TYPE_INT), 'filteractive': OpsField('filteractive', dsz.TYPE_BOOL), 'threadrunning': OpsField('threadrunning', dsz.TYPE_BOOL), 'maxfilesize': OpsField('maxfilesize', dsz.TYPE_INT), 'maxpacketsize': OpsField('maxpacketsize', dsz.TYPE_INT), 'capturefile': OpsField('capturefile', dsz.TYPE_STRING), 'capturefilesize': OpsField('capturefilesize', dsz.TYPE_INT)}, DszObject, single=True)
    trafficcapturecommand = OpsClass('trafficcapture', {'filter': dzsfilter, 'status': dsztcstatus}, DszCommandObject)
    cmd_definitions['trafficcapture'] = trafficcapturecommand