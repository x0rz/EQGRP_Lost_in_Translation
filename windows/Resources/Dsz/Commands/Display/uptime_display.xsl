<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Uptime">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Uptime: </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    </xsl:text>
		<xsl:value-of select="substring-before(substring-after(Duration, 'P'), 'D')"/>
		<xsl:text> day(s), </xsl:text>
		<xsl:value-of select="substring-before(substring-after(Duration, 'T'), 'H')"/>
		<xsl:text> hour(s), </xsl:text>
		<xsl:value-of select="substring-before(substring-after(Duration, 'H'), 'M')"/>
		<xsl:text> minute(s), </xsl:text>
		<xsl:value-of select="substring-before(substring-after(Duration, 'M'), '.')"/>
		<xsl:text> second(s)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:if test="IdleTime">
			<xsl:call-template name="PrintReturn"/>
			<xsl:text>Idle Time: </xsl:text>
			<xsl:call-template name="PrintReturn"/>
			<xsl:text>    </xsl:text>
			<xsl:value-of select="substring-before(substring-after(IdleTime, 'P'), 'D')"/>
			<xsl:text> day(s), </xsl:text>
			<xsl:value-of select="substring-before(substring-after(IdleTime, 'T'), 'H')"/>
			<xsl:text> hour(s), </xsl:text>
			<xsl:value-of select="substring-before(substring-after(IdleTime, 'H'), 'M')"/>
			<xsl:text> minute(s), </xsl:text>
			<xsl:value-of select="substring-before(substring-after(IdleTime, 'M'), '.')"/>
			<xsl:text> second(s)</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>

</xsl:transform>
