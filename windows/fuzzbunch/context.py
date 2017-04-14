"""
Base command context class used to extend the cmd class.  A context provides
it's own set of do_cmds but is largely managed by the cmd class.

The CmdCtx class by itself is largely useless.  It should be used as base class
to derive any desired context from.

Contexts can be standalone or can be plugin managers.  
"""

__all__ = ["CmdCtx"]

class CmdCtx:
    """Cmd context class that can be used to dynamically extend the Cmd
    class to handle additional commands.  This defines the interface
    for derived classes.
    """
    def __init__(self, name, type):
        # Metadata abou the Command Context, including name and type
        self.set_name(name)
        self.set_type(type)

    def get_name(self):
        """Get the name of the context"""
        return self.name

    def get_type(self):
        """Get the type of the context"""
        return self.type

    def set_name(self, name):
        """Set the name of the context"""
        self.name = name

    def set_type(self, type):
        """Set the type of the context"""
        self.type = type

    def print_info(self):
        """Print context info"""
        return

    def lookup_function(self, name):
        return getattr(self, 'do_' + name.lower())

    def lookup_compfunction(self, name):
        return getattr(self, 'complete_' + name.lower())

    def lookup_helpfunction(self, name):
        return getattr(self, 'help_' + name.lower())

    def get_names(self):
        names = []
        classes = [self.__class__]
        while classes:
            aclass = classes.pop(0)
            if aclass.__bases__:
                classes = classes + list(aclass.__bases__)
            names = names + dir(aclass)
        return names

    def set_active_plugin(self, unused):
        """Set the active plugin"""
        pass

    def get_active_name(self):
        """Get the name of the active plugin"""
        return self.get_name()

    def get_plugins(self):
        """Return a list of all plugins"""
        return []



