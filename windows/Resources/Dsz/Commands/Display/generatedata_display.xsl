<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="GenerateData_OrigCmdInfo">
		<xsl:text>          Command : </xsl:text>
		<xsl:value-of select="CommandName"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Storage Transform : </xsl:text>
		<xsl:value-of select="StorageTransform"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>     Resource Dir : </xsl:text>
		<xsl:value-of select="ResourceDir"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="GenerateData_OpenedFile">
		<xsl:text>Parsing log file : </xsl:text>
		<xsl:value-of select="substring-after(., '/')"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>