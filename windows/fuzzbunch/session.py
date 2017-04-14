"""Fuzzbunch Session handling

General class relationships.  Currently Fuzzbunch only uses one session
with the session history being composed of session items.

    Session
    |
    |-- SessionItem (Plugin - Evadefred)
        |
        |-- SessionInfo (label=History)
        \-- SessionInfo (label=Contract)

For each SessionItem, Fuzzbunch maintains two lists of parameters:
* History   - Input parameters
* Contract  - Output parameters
"""
import uuid
import exception
import util
import os

__all__ = ['Session']

try:
    DEFAULT_TMP = os.environ['TMP']
except KeyError:
    DEFAULT_TMP = "/tmp"

HISTORY_STR = "History"
CONTRACT_STR = "Contract"

class SessionInfo:
    """Session info class.  Contains a single set of parameters, either input
    (History) or output (Contract) as a label.

    label  - label for this info item (Contract|History)
    params - var,val parameter tuples
    item   - parent item reference 

    """
    def __init__(self, label, params, item):
        self.item   = item
        self.label  = label
        self.params = util.iDict()
        for p in params:
            self.set(p[0], p)

    """
    Printing

    """
    def get_item_info(self):
        return "%s - %d" % (self.item.name,self.item.id)

    def __str__(self):
        return "%s - %d" % (self.item.name,self.item.id)

    def __repr__(self):
        string  = ">>> %d :: %s\n" % (self.item.id, self.item.name)
        for v in self.params.itervalues():
            string += "    %s\n" % (str(v))
        return string

    """
    Marking

    """
    def mark_used(self):
        """Mark the parent item as used"""
        self.set_mark("USED")

    def set_mark(self, value):
        """Mark the parent item"""
        self.item.set_status(value)

    """
    Labels

    """
    def get_label(self):
        """Get the label for this info"""
        return self.label

    """
    Parameter access

    """
    def set(self, var, val):
        """Add a parameter with value"""
        self.params[var] = val

    def get(self, var):
        """Get a parameter value"""
        try:
            return self.params[var]
        except KeyError:
            raise exception.CmdErr, "%s does not exist" % var

    def get_paramlist(self):
        """Get a list of all parameter var,vals"""
        return self.params.items()


class SessionItem(object):
    """Session item class. Contains info items which have the actual parameters
    of the session.  Items correspond to one execution of a given plugin and
    maintain the state of the plugin execution.  Possible states are 
        RUNNING - Plugin is still executing
        FAIL    - Plugin has failed
        READY   - Plugin is done executing and has generated a contract
        USED    - Item contract has been used by another plugin
    """
    def __init__(self, name, id, description, sess):
        self.sess = sess
        self.name = name
        self.id   = id
        self.description = description
        self.status = "RUNNING"
        self._contract = None
        self._history  = None       # Ends up containing the running history of sessions with this name

    def __str__(self):
        """The short view of what's going on"""
        return "%s (%s)" % (self.name, self.status)

    def __repr__(self):
        """All information about the SessionItem"""
        string  = "[%d] %s (%s)\n" % (self.id, self.name, self.status)
        string += "    Description : %s\n" % (self.description)
        string += "    Contract    : %s\n" % (str(self.contract))
        string += "    History     : %s\n" % (str(self.history))
        return string

    """
    Session Item Attributes

    """
    def get_name(self):
        """Get the item name"""
        return self.name

    def get_description(self):
        return self.description

    def get_longname(self):
        return self.name + "  " + self.description

    def history():
        doc = "Session item history params"
        def fget(self):
            return self._history
        def fset(self, value):
            self._history = SessionInfo(HISTORY_STR, value, self)
        return locals()
    history = property(**history())

    def contract():
        doc = "Session item contract params"
        def fget(self):
            return self._contract
        def fset(self, value):
            self._contract = SessionInfo(CONTRACT_STR, value, self)
        return locals()
    contract = property(**contract())

    def get_info(self):
        return (util.Param(HISTORY_STR, self.history), 
                util.Param(CONTRACT_STR, self.contract))

    """
    Directories

    """
    def get_dirs(self):
        """Return session directories"""
        return self.sess.get_dirs()

    """
    Item status

    """
    def is_ready(self):
        if self.status == "READY":
            return True
        else:
            return False

    def is_failed(self):
        if self.status == "FAIL":
            return True
        else:
            return False

    def get_status(self):
        """Get the item status"""
        reason = ''
        if self.is_failed():
            try:
                # This shouldn't happen, but weirder things have
                for p in self.contract.get_paramlist():
                    if p.name.lower() == 'returncode':
                        reason = ' : ' + p.value.value
                        break
            except:
                # Still say we failed, but don't say why
                pass
        return self.status + reason

    def set_status(self, status):
        """Set the status of the item"""
        if status.upper() in ("RUNNING", "FAIL", "READY", "USED"):
            self.status = status.upper()
        else:
            raise exception.CmdErr, "%s invalid status" % status

    def mark_running(self):
        self.set_status("RUNNING")

    def mark_fail(self):
        self.set_status("FAIL")

    def mark_ready(self):
        self.set_status("READY")

    def mark_used(self):
        self.set_status("USED")

    """
    Contract Handling

    """
    def has_opencontract(self):
        if self.status in ("USED", "FAIL"):
            return False
        if self.status == "RUNNING":
            return True

        for p in self.contract.get_paramlist():
            if p.name.lower() in ("connectedtcp", "rendezvous"):
                return True
        return False

    def has_contract(self):
        if self.contract:
            return True
        else:
            return False


class Session:
    """Session class.  Contains complete history (items) for a session."""
    def __init__(self, name):
        self.name  = name
        self.items = []
        self.session_id = str(uuid.uuid4())
        self.set_dirs(DEFAULT_TMP, DEFAULT_TMP)

    def get_name(self):
        """Get the name of the session"""
        return self.name

    """
    Directories

    """
    def set_dirs(self, base_dir, log_dir):
        """Set session directories"""
        self.base_dir = os.path.normpath(base_dir)
        self.log_dir  = os.path.normpath(log_dir)

    def get_dirs(self):
        """Return session directories"""
        return (self.base_dir, self.log_dir)

    """
    Single Item Access

    """
    def add_item(self, name, description):
        """Add a new item to the session"""
        id = len(self.items)
        self.items.append(SessionItem(name, id, description, self))
        return self.items[-1]

    def get_item(self, index):
        """Get an item by index from the session"""
        try:
            return self.items[index]
        except IndexError:
            raise exception.CmdErr, "Bad index %d" % index

    """
    Bulk access

    """
    def get_itemlist(self):
        """Get all of the items in the session"""
        return [util.Param(item.get_name(), item) for item in self.items]

    """
    Contract Interface

    """
    def get_contractlist(self):
        return [item.contract
                for item in self.items
                if item.contract and item.is_ready()]

    def get_contract(self, index):
        """Get a contract by index from the session"""
        item = self.get_item(index)
        if item.contract:
            return item.contract
        else:
            raise exception.CmdErr, "Contract not available"

