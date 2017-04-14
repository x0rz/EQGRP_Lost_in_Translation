<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="Activity">
		<xsl:text>Time since last activity: </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    </xsl:text>
		<xsl:value-of select="substring-before(substring-after(Last, 'P'), 'D')"/>
		<xsl:text> day(s), </xsl:text>
		<xsl:value-of select="substring-before(substring-after(Last, 'T'), 'H')"/>
		<xsl:text> hour(s), </xsl:text>
		<xsl:value-of select="substring-before(substring-after(Last, 'H'), 'M')"/>
		<xsl:text> minute(s), </xsl:text>
		<xsl:value-of select="substring-before(substring-after(Last, 'M'), '.')"/>
		<xsl:text> second(s)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="NewActivity">
		<xsl:text>USER ACTIVITY!</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>