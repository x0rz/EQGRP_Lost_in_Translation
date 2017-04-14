<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Loaded">
		<xsl:text>Library </xsl:text>
		<xsl:value-of select="."/>
		<xsl:text> loaded (location=</xsl:text>
		<xsl:value-of select="@location"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Location">
		<xsl:text>Library </xsl:text>
		<xsl:value-of select="."/>
		<xsl:text> found (location=</xsl:text>
		<xsl:value-of select="@location"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Freed">
		<xsl:text>Library </xsl:text>
		<xsl:value-of select="."/>
		<xsl:text> (location=</xsl:text>
		<xsl:value-of select="@location"/>
		<xsl:text>) freed</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
 
	<xsl:template match="Success"/>
	
</xsl:transform>