"""

XML Parsing routines outside of what TRCH handles.

This is primarily meant to deal with the .fb files


NOTE: Values pulled from XML are 'unicode' by default. The rest of FB prefers
'str' types.

"""
from xml.etree import ElementTree
import xml.dom.minidom
import util
import xml.parsers.expat as expat
import exception
import re


__all__ = ['parse_consolemode',
           'parse_touchlist',
           'parse_redirection',
           'parse_iparamorder',
           'get_elements']


def get_elements(xmlDoc, tag):
    try:
        elements = xmlDoc.getElementsByTagName(tag)
        if len(elements) == 0:
            elements = xmlDoc.getElementsByTagName("t:"+tag)
        return elements
    except:
        return []

def parse_consolemode(xmlFile):
    """
    Console mode

    INPUT
    -----

    The consolemode is in a plugin's meta file. The consolemode is optional and
    only used to override the default.

        <t:consolemode value="desired_mode" />

    Valid consolemodes are found in the plugin manager.

    OUTPUT
    ------

    A Python string.  The value of the 'value' attribute is returned as a
    string.

    """
    
    try:
        xmlDocument = xml.dom.minidom.parse(xmlFile)
        elem = get_elements(xmlDocument, "consolemode")[0]          # Fix to Bug #574
        #elem = xmlDocument.getElementsByTagName("t:consolemode")[0]
        return str(elem.getAttribute("value"))
    except IndexError:
        return ""
    return ""
    
def parse_touchlist(xmlFile):
    """
    Touch lists


    INPUT
    -----

    Touch lists are in a plugin's meta file.  Touch lists are optional.

        <t:touchlist>
            <t:plugin name="TouchPluginName"
                      displayname="How to display in fb"
                      description="Descr for fb">

                <t:iparam name="Param1" value="val" />
                <t:oparam name="Param1" value="ParamFoo" />
            </t:plugin>
        </t:touchlist>


    plugin - any number of plugin sections. One for each touch.
    iparam - Parameters that should be autoset when running the touch
    ivparam - Parameters that should be autoset based on parent plugins vars 
    oparam - Parameter map of touch output to host plugin


    OUTPUT
    ------

    Python list of dictionaries

        touchlist = [touch1, touch2, ..., touchN]

        Each touch is a dictionary composed of the plugin attributes.  A parameters
        key has a dictionary of autoset parameters.

        Example:

        touch1 = {
                  'name'        : 'SSLTouch',
                  'displayname' : 'Check for SSL',
                  'description' : 'Checks the target for SSL',
                  'parameters'  : {'TargetPort' : 443}
                 }
    """
    try:
        xmlDocument = xml.dom.minidom.parse(xmlFile)
        tlist = get_elements(xmlDocument, "touchlist")[0]       # Fix to bug #574
    except expat.ExpatError:
        # The XML failed to parse correctly
        import os.path
        (p, f) = os.path.split(xmlFile)
        raise exception.PluginMetaErr("Error parsing '%s' XML.  Touches not configured" % (f))
        return []
    except IndexError:
        # We didn't successfully get anything from "t:touchlist" Don't print here because some
        # things actually don't specify touches
        #return []
        raise

    touchlist = []

    for plugin in get_elements(tlist, "plugin"):        # Fix for bug #574 
        touch = {"name"        : str(plugin.getAttribute("name")),
                 "displayname" : str(plugin.getAttribute("displayname")),
                 "description" : str(plugin.getAttribute("description")),
                 "postmsg"     : str(plugin.getAttribute("postmessage")),
                 "iparams"     : util.iDict(), 
                 "ivparams"    : util.iDict(),
                 "oparams"     : util.iDict()}
        for p in get_elements(plugin, "iparam"):   # Fix for bug #574    #plugin.getElementsByTagName("t:iparam"):
            touch["iparams"][str(p.getAttribute("name"))] = str(p.getAttribute("value"))
        for p in get_elements(plugin, "ivparam"):  # Fix for bug #574    #plugin.getElementsByTagName("t:ivparam"):
            touch["ivparams"][str(p.getAttribute("name"))] = str(p.getAttribute("value"))
        for p in get_elements(plugin, "oparam"):   # Fix for bug #574    #plugin.getElementsByTagName("t:oparam"):
            touch["oparams"][str(p.getAttribute("name"))] = str(p.getAttribute("value"))

        touchlist.append(touch)
    return touchlist


def parse_redirection(xmlFile):
    """
    Redirection


    INPUT
    -----

    Redirection sections are in a plugin's standard XML file.  See the truantchild
    schema for details.


    OUTPUT
    ------

    Python dictionary of lists of dictionaries

        There are 2 types of redirection, remote and local.  Each section can have
        multiple channels. Each channel is represented as a dictionary.
        
        redir = {
                 'local' : 
                    [ { ..local params..}, ... ],
                 'remote' :
                    [ { ..remote params..}, ... ]
                }
    """
    def nsstrip(tag):
        for x in ('{tc0}', '{urn:trch}', 't:'):
            if tag.startswith(x):
                return tag.split(x)[1]
        else:
            return tag

    def get_redirection(config):
        for child in config:
            tag = nsstrip(child.tag)
            if tag == 'redirection':
                return child
        return None

    def get_remote_redir(node):
        if not node:
            return []
        return [child for child in node
                      if nsstrip(child.tag) == 'remote']

    def get_local_redir(node):
        if not node:
            return []
        return [child for child in node
                      if nsstrip(child.tag) == 'local']

    xmldoc = ElementTree.parse(xmlFile)
    config = xmldoc.getroot()
    redir = get_redirection(config)         # Redirection section of the plug-in XML

    remote = get_remote_redir(redir)        # remote tags in the plug-in redirection section
    local = get_local_redir(redir)          # local tags in the plug-in redirection section

    redirection = { 'remote' : [x.attrib for x in remote],
                    'local'  : [x.attrib for x in local] }
    
    # Insert a fix for XPath identifiers in redirection sections.
    # These shouldn't be here, but this fixes everything for now...
    for tunnel in redirection['remote'] + redirection['local']:
        for k,v in tunnel.items():
            if v.lower() == '//identifier':
                tunnel[k] = 'TargetIp'
            elif re.match(r'//service\[name=.*\]/port', v.lower()):
                tunnel[k] = 'TargetPort'

    return redirection


def parse_iparamorder(xmlFile):
    """
    Input Parameter Order

    INPUT
    -----

    Plugin's standard XML file.

    OUTPUT
    ------

    List of parameter names in display order
    """

    xmlDocument = xml.dom.minidom.parse(xmlFile)

    try:
        #iparams = xmlDocument.getElementsByTagName("t:inputparameters")[0]
        iparams = get_elements(xmlDocument, "inputparameters")[0]       # Fix to bug #574
    except IndexError:
        return []

    order = []
    #for param in (iparams.getElementsByTagName("t:parameter") + 
    #              iparams.getElementsByTagName("t:paramchoice")):
    # Fix for bug #574
    for param in (get_elements(iparams, "parameter") +
                  get_elements(iparams, "paramchoice")):
        order.append(str(param.getAttribute("name")))

    return order

def parse_forward(xmlFile):
    """
    Forward-deployment (i.e., DARINGVETERAN/DARINGNEOPHYTE) DLL Configuration
    
    INPUT
    -----
    Path to plugin's standard FB file.
    
    OUTPUT
    ------
    Dictionary mapping archOs tag (e.g., "x86-Windows") to a tuple containing
    plugin proxy and core DLLs.  Note that either element may be None!
    """
    xmldoc = ElementTree.parse(xmlFile)
    arches = {}
    for arch in xmldoc.findall("package/arch"):
        proxy = getattr(arch.find('base'), 'text', None)
        core = getattr(arch.find('core'), 'text', None)
        arches[arch.get('name')] = (proxy, core)
    return arches
