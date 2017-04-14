<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="peddlecheap_common.xsl"/>
  
	<xsl:template match="AttemptConnection">
		<xsl:text>Connecting to [</xsl:text>
		<xsl:value-of select="Target/Address"/>
		<xsl:text>]:</xsl:text>
		<xsl:value-of select="Target/Port"/>
		<xsl:text> from [</xsl:text>
		<xsl:value-of select="Local/Address"/>
		<xsl:text>]:</xsl:text>
		<xsl:value-of select="Local/Port"/>
		<xsl:text>...</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Connected">
		<xsl:text>    CONNECTED</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>