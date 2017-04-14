import pluginmanager
import sys
import os
import exception

mswindows = (sys.platform == "win32")

if mswindows:
    BINARY_EXT = (".exe",".py")
else:
    BINARY_EXT = ("", ".py")

FB_CONFIG_EXT = ".fb"
PLUGIN_CONFIG_EXT = ".xml"

class PluginfinderError(Exception):
    pass

def getextensionfiles(location, ext):
    return [file 
            for file in os.listdir(location) 
            if file.endswith(ext)]

def configlistsearch(configlist, item):
    for file in configlist:
        if file.startswith(item):
            return configlist.index(file)
    return None

def getpluginlist(location, bin):
    """@brief   Get a list of available plugins from a given directory
    
    @param  location        Directory to search for plugins
    @param  bin             Is what we're trying to load binary?
    """
    fblist     = getextensionfiles(location, FB_CONFIG_EXT)         # get list of .fb files
    configlist = getextensionfiles(location, PLUGIN_CONFIG_EXT)     # get list of .xml files
    dirlist    = os.listdir(location)
    pluginlist = []
    
    for config in configlist:
        base    = ".".join(config.split(".")[:-2])

        # Try to find a corresponding .fb file for each .xml file
        fbindex = configlistsearch(fblist, base)
        if fbindex is not None:
            if bin:
                for ext in BINARY_EXT:
                    if base + ext in dirlist:
                        # Add a tuple containing (config, executable, fbfile) to pluginlist
                        pluginlist.append((os.path.join(location, config),
                                           os.path.join(location, base + ext),
                                           os.path.join(location, fblist[fbindex])))
            else:
                # Cover the case in which we don't have an executable file 
                pluginlist.append((os.path.join(location, config),
                                   "noFile",
                                   os.path.join(location, fblist[fbindex])))
    return pluginlist


def addplugins(fb, type, location, constructor, manager=pluginmanager.PluginManager, bin=True):
    """
    @brief Enumerate available plugins and add them to the fuzzbunch pluginmanager

    @param fb           Fuzzbunch object
    @param type         String with the type of plugin to add (Exploit, Payload,  Touch, etc...)
    @param location     The disk location to look for that type of plugin
    @param constructor  Constructor to use to instantiate the plugin
    """
    # Get a list of tuples for the available plugins in 'location'
    # Each entry will be (config, executable, fbfile)
    
    #
    # XXX Should we ensure the directories exist and load nothing, or 
    # fail, in the event the directory doesn't exist already.
    #
    plugins = getpluginlist(location, bin)
    manager = fb.register_manager(type, manager)
    
    for plugin in plugins:
        try:
            manager.add_plugin(plugin, constructor)
        except exception.PluginXmlErr:
            # We encountered an error in the plugin's XML file.  We don't want
            # this to kill execution of Fuzzbunch
            import os.path
            (d,f) = os.path.split(plugin[0])
            n = f.split('-')[0]
            fb.io.pre_input(None)
            fb.io.print_warning("Failed to load %s - XML Error" % (str(n)))
            fb.io.post_input()

