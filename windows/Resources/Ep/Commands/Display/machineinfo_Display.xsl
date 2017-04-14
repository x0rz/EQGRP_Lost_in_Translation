<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="MachineInfo">
    <xsl:text> Server Name : </xsl:text>
    <xsl:value-of select="Name" />
    <xsl:call-template name="PrintReturn" />
    <xsl:text>     Comment : </xsl:text>
    <xsl:value-of select="Comment" />
    <xsl:call-template name="PrintReturn" />
    <xsl:text>Runs version : </xsl:text>
    <xsl:value-of select="@major" />
    <xsl:text>.</xsl:text>
    <xsl:call-template name="CharFill">
     <xsl:with-param name="i" select="3 - string-length(@minor)" />
     <xsl:with-param name="char" select="0" />
    </xsl:call-template>
    <xsl:value-of select="@minor" />
    <xsl:call-template name="PrintReturn" />
    <xsl:text> Server Type : </xsl:text>
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
    <xsl:call-template name="PrintReturn" />
    <xsl:text>     Browser : </xsl:text>
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
    <xsl:call-template name="PrintReturn" />
    <xsl:text> Other Types : </xsl:text>
    <xsl:if test="Type/FlagsList/SvTypeServerMfpn">
     <xsl:text>+NetWare server</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypeSqlServer">
     <xsl:text>+SQL</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypeTimeSource">
     <xsl:text>+TimeSource</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypeAfp">
     <xsl:text>+AppleTalk</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypeNovell">
     <xsl:text>+Novell</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypePrintQServer">
     <xsl:text>+LM printQ server</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypeDialinServer">
     <xsl:text>+LM dialin server</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypeDomainMember">
     <xsl:text>+LM domain member</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypeServerUnix">
     <xsl:text>+Unix services</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypeDfs">
     <xsl:text>+DFSRoot</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypeClusterNT">
     <xsl:text>+Cluster</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypeTerminalServer">
     <xsl:text>+TerminalServer</xsl:text>
    </xsl:if>
    <xsl:if test="Type/FlagsList/SvTypeDCE">
     <xsl:text>+DCE</xsl:text>
    </xsl:if>
    <xsl:call-template name="PrintReturn" />
    <xsl:text>   Remaining : </xsl:text>
    <xsl:value-of select="Type/@unknown" />
    <xsl:call-template name="PrintReturn" />
  </xsl:template>

</xsl:transform>