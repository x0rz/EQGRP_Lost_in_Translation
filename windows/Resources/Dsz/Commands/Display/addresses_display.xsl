<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Established">
		<xsl:text>Connection established</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
  
	<xsl:template match="LocalAddress">
		<xsl:text>        Local Address : </xsl:text>
		<xsl:value-of select="@address"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>         Architecture : </xsl:text>
		<xsl:value-of select="OsVersion/@arch"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Compiled Architecture : </xsl:text>
		<xsl:value-of select="OsVersion/@compiledArch"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>             Platform : </xsl:text>
		<xsl:value-of select="OsVersion/@platform"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>              Version : </xsl:text>
		<xsl:value-of select="OsVersion/@major"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="OsVersion/@minor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="OsVersion/@other"/>
		<xsl:if test="OsVersion/@build != 0">
			<xsl:text> (build </xsl:text>
			<xsl:value-of select="OsVersion/@build"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    C Library Version : </xsl:text>
		<xsl:value-of select="OsVersion/@cLibMajor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="OsVersion/@cLibMinor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="OsVersion/@cLibRevision"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>           Process Id : </xsl:text>
		<xsl:value-of select="OsVersion/@pid"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>                 Type : </xsl:text>
		<xsl:value-of select="OsVersion/@type"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="RemoteAddress">
		<xsl:text>       Remote Address : </xsl:text>
		<xsl:value-of select="@address"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>         Architecture : </xsl:text>
		<xsl:value-of select="OsVersion/@arch"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Compiled Architecture : </xsl:text>
		<xsl:value-of select="OsVersion/@compiledArch"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>             Platform : </xsl:text>
		<xsl:value-of select="OsVersion/@platform"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>              Version : </xsl:text>
		<xsl:value-of select="OsVersion/@major"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="OsVersion/@minor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="OsVersion/@other"/>
		<xsl:if test="OsVersion/@build != 0">
			<xsl:text> (build </xsl:text>
			<xsl:value-of select="OsVersion/@build"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    C Library Version : </xsl:text>
		<xsl:value-of select="OsVersion/@cLibMajor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="OsVersion/@cLibMinor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="OsVersion/@cLibRevision"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>           Process Id : </xsl:text>
		<xsl:value-of select="OsVersion/@pid"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>                 Type : </xsl:text>
		<xsl:value-of select="OsVersion/@type"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>             Metadata : </xsl:text>
		<xsl:value-of select="Metadata"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="ConMgrInfo"/>
	<xsl:template match="FrzAddresses"/>
	<xsl:template match="FrzLinks"/>
	<xsl:template match="FrzRoutes"/>
	<xsl:template match="FrzSecAssociations"/>
	<xsl:template match="HwAddresses"/>
	<xsl:template match="IpAddresses"/>
	<xsl:template match="Modules"/>
	<xsl:template match="ToolVersions"/>
	
</xsl:transform>