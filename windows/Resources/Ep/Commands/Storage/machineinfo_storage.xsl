<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="MachineInfo"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="MachineInfo">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Name"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">comment</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Comment"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">os_version</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@major"/>.<xsl:value-of select='@minor' /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">os_type</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:choose>
        <xsl:when test="Type/FlagsList/SvTypeWindows">
         <xsl:text>Windows</xsl:text>
        </xsl:when>
        <xsl:when test="Type/FlagsList/SvTypeServerVms">
         <xsl:text>VMS</xsl:text>
        </xsl:when>
        <xsl:when test="Type/FlagsList/SvTypeServerOsf">
         <xsl:text>OSF</xsl:text>
        </xsl:when>
        <xsl:otherwise>
         <xsl:text> </xsl:text>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">os_modifier</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:if test="Type/FlagsList/SvTypeNT">
        <xsl:text> NT</xsl:text>
       </xsl:if>
       <xsl:if test="Type/FlagsList/SvTypeWfw">
        <xsl:text> for Workgroups</xsl:text>
       </xsl:if>
       <xsl:if test="Type/FlagsList/SvTypeServer">
        <xsl:text> Server</xsl:text>
       </xsl:if>
       <xsl:if test="Type/FlagsList/SvTypeWorkstation and not(Type/FlagsList/SvTypeServer)">
        <xsl:text> Workstation</xsl:text>
       </xsl:if>
       <xsl:if test="Type/FlagsList/SvTypeDomainCtrl">
        <xsl:text> PDC</xsl:text>
       </xsl:if>
       <xsl:if test="Type/FlagsList/SvTypeDomainBakCtrl">
        <xsl:text> BDC</xsl:text>
       </xsl:if>
       <xsl:if test="Type/FlagsList/SvTypeServerNT">
        <xsl:text> non-DC</xsl:text>
       </xsl:if>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">browser</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:choose>
        <xsl:when test="Type/FlagsList/SvTypeDomainMaster">
         <xsl:text>+Domain master browser</xsl:text>
        </xsl:when>
        <xsl:when test="Type/FlagsList/SvTypeMasterBrowser">
         <xsl:text>+Workgroup master browser</xsl:text>
        </xsl:when>
        <xsl:when test="Type/FlagsList/SvTypeBackupBrowser">
         <xsl:text>+backup workgroup browser</xsl:text>
        </xsl:when>
        <xsl:when test="Type/FlagsList/SvTypePotentialBrowser">
         <xsl:text>+potential master browser</xsl:text>
        </xsl:when>
        <xsl:otherwise>
         <xsl:text> </xsl:text>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">netware_server</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeServerMfpn">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">sql_server</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeSqlServer">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">time_source</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeTimeSource">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">appletalk</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeAfp">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">novell</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeNovell">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">printq_server</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypePrintQServer">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">dialin_server</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeDialinServer">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">domain_member</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeDomainMember">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">unix_services</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeServerUnix">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">dfs_root</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeDFS">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">cluster</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeClusterNT">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">terminal_server</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeTerminalServer">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">dce</xsl:attribute>
      <xsl:choose>
       <xsl:when test="Type/FlagsList/SvTypeDCE">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

</xsl:transform>