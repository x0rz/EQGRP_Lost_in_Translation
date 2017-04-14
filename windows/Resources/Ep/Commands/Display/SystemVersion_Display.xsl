<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

    <xsl:template match="TargetVersion">
	<xsl:text>     Version : </xsl:text>
	<xsl:value-of select="@major"/>
	<xsl:text>.</xsl:text>
	<xsl:value-of select="@minor"/>
	<xsl:text> (build </xsl:text>
	<xsl:value-of select="@build"/>
	<xsl:text>)&#x0D;&#x0A;</xsl:text>

    <xsl:text> Platform Id : </xsl:text>
    <xsl:value-of select="@platform"/>
    <xsl:text> (</xsl:text>
    <xsl:choose>
	<xsl:when test="(number(@platform) = 2) and (number(@major) = 4)"><xsl:text>Windows NT</xsl:text></xsl:when>
	<xsl:when test="(number(@platform) = 2) and (number(@major) = 5) and (number(@minor) = 0)"><xsl:text>Windows 2000</xsl:text></xsl:when>
	<xsl:when test="(number(@platform) = 2) and (number(@major) = 5) and (number(@minor) = 1)"><xsl:text>Windows XP</xsl:text></xsl:when>
	<xsl:when test="(number(@platform) = 2) and (number(@major) = 5) and (number(@minor) = 2)"><xsl:text>Windows 2003</xsl:text></xsl:when>
	<xsl:when test="(number(@platform) = 2) and (number(@major) = 6)"><xsl:text>Windows Vista</xsl:text></xsl:when>
	<xsl:when test="(number(@platform) = 1) and (number(@major) = 4) and (number(@minor) = 0)"><xsl:text>Windows 95</xsl:text></xsl:when>
	<xsl:when test="(number(@platform) = 1) and (number(@major) = 4) and (number(@minor) = 10)"><xsl:text>Windows 98</xsl:text></xsl:when>
	<xsl:when test="(number(@platform) = 1) and (number(@major) = 4) and (number(@minor) = 90)"><xsl:text>Windows ME</xsl:text></xsl:when>
	<xsl:otherwise><xsl:text>Unmatched OS</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text>)&#x0D;&#x0A;</xsl:text>
    
    <xsl:text>Service Pack : </xsl:text>
    <xsl:value-of select="ServicePack"/>
    <xsl:text>&#x0D;&#x0A;</xsl:text>

    <xsl:text>  SP Version : </xsl:text>
    <xsl:value-of select="ServicePack/@major"/>
    <xsl:text>.</xsl:text>
    <xsl:value-of select="ServicePack/@minor"/>
    <xsl:text>&#x0D;&#x0A;</xsl:text>

    <xsl:text>Product Type : </xsl:text>
    <xsl:choose>
	<xsl:when test="number(ProductType) = 1"><xsl:text>Workstation / Professional</xsl:text></xsl:when>
	<xsl:when test="number(ProductType) = 2"><xsl:text>Domain controller</xsl:text></xsl:when>
	<xsl:when test="number(ProductType) = 3"><xsl:text>Server</xsl:text></xsl:when>
	<xsl:otherwise></xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#x0D;&#x0A;</xsl:text>

    <xsl:if test="TerminalServer">
	<xsl:text>&#x0D;&#x0A;    *** NT 4 TERMINAL SERVER ***&#x0D;&#x0A;&#x0D;&#x0A;</xsl:text>
    </xsl:if>

    <xsl:text>Suites : &#x0D;&#x0A;</xsl:text>
    <xsl:if test="Suites/@verSuiteBackOffice = 'true'"><xsl:text>    Microsoft BackOffice components are installed&#x0D;&#x0A;</xsl:text></xsl:if>
    <xsl:if test="Suites/@verSuiteDataCenter = 'true'"><xsl:text>    DataCenter Server is installed&#x0D;&#x0A;</xsl:text></xsl:if>
    <xsl:if test="Suites/@verSuiteEnterprise = 'true'"><xsl:text>    Advanced Server / Enterprise Server is installed&#x0D;&#x0A;</xsl:text></xsl:if>
    <xsl:if test="Suites/@verSuiteSmallBusiness = 'true'"><xsl:text>    Microsoft Small Business Server is installed&#x0D;&#x0A;</xsl:text></xsl:if>
    <xsl:if test="Suites/@verSuiteSmallBusinessRestricted = 'true'"><xsl:text>    Microsoft Small Business Server is installed with the restrictive client license in force&#x0D;&#x0A;</xsl:text></xsl:if>
    <xsl:if test="Suites/@verSuiteTerminal = 'true'"><xsl:text>    Terminal Services is installed&#x0D;&#x0A;</xsl:text></xsl:if>
    <xsl:if test="Suites/@verSuiteCommunications = 'true'"><xsl:text>    Communications flag is set (undocumented type)&#x0D;&#x0A;</xsl:text></xsl:if>
    <xsl:if test="Suites/@verSuiteEmbeddedNt = 'true'"><xsl:text>    Embedded NT flag is set (undocumented type)&#x0D;&#x0A;</xsl:text></xsl:if>
    <xsl:if test="Suites/@verSuiteSingleUserTs = 'true'"><xsl:text>    Single user Terminal Server flag is set (undocumented type)&#x0D;&#x0A;</xsl:text></xsl:if>
    <xsl:if test="Suites/@verSuitePersonal = 'true'"><xsl:text>    Windows XP Home Edition is installed.&#x0D;&#x0A;</xsl:text></xsl:if>
    <xsl:if test="Suites/@verSuiteBlade = 'true'"><xsl:text>    Windows .NET Web Server is installed.&#x0D;&#x0A;</xsl:text></xsl:if>

  </xsl:template>

</xsl:transform>