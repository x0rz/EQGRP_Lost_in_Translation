<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
 
	<xsl:template match="Hops">
		<xsl:apply-templates select="HopInfo"/>
	</xsl:template>
	
	<xsl:template match="HopInfo">
		<xsl:value-of select="HopNumber"/>
		<xsl:text>  </xsl:text>
		<xsl:value-of select="Host"/>
		<xsl:text>  </xsl:text>
			<xsl:variable name="min_to_ms" select="number(substring-before(substring-after(TripTime, 'H'), 'M'))*(60000)"/>
			<xsl:variable name="s_to_ms" select="number(substring-before(substring-after(TripTime, 'M'), '.'))*(1000)"/>
			<xsl:variable name="ns_to_ms" select="number(substring(substring-after(TripTime, '.'), 1, 3))"/>
			<xsl:variable name="ms" select="number($min_to_ms + $s_to_ms + $ns_to_ms)"/>
		<xsl:value-of select="$ms"/>
		<xsl:text>ms</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>
