<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StandardTransforms.xsl" />
	<xsl:import href="systemversion_windows.xsl" />
	<xsl:import href="systemversion_linux.xsl" />
	<xsl:import href="systemversion_solaris.xsl" />	

	<xsl:output method="text" />
	
	<xsl:template match="SystemVersion">
		<xsl:text>Architecture : </xsl:text>
		<xsl:value-of select="@architecture" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   OS Family : </xsl:text>
		<xsl:value-of select="@platform" />
		<xsl:call-template name="PrintReturn" />
		
		<xsl:choose>
			<xsl:when test="@platform = 'winnt'">
				<xsl:call-template name="PrintWindowsVersion"/>	
			</xsl:when>
			<xsl:when test="@platform = 'win9x'">
				<xsl:call-template name="PrintWindowsVersion"/>
			</xsl:when>
			<xsl:when test="@platform = 'linux'">
				<xsl:call-template name="PrintLinuxVersion"/>
			</xsl:when>
			<xsl:when test="@platform = 'linux_se'">
				<xsl:call-template name="PrintLinuxVersion"/>
			</xsl:when>
			<xsl:when test="@platform = 'solaris'">
				<xsl:call-template name="PrintSolarisVersion"/>
			</xsl:when>
			<xsl:otherwise>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:transform>
