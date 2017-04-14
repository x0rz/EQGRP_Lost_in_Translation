<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="Status">
		<xsl:text>  Version : </xsl:text>
		<xsl:value-of select="Major"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="Minor"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="Fix"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="Build"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>Available : </xsl:text>
		<xsl:value-of select="Available"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Available">
		<xsl:text>Available : </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="String">
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Uninstalled">
		<xsl:text>Uninstalled</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>