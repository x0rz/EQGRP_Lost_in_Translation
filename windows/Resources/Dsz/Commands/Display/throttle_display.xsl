<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Throttle">
		<xsl:text>Throttling for </xsl:text>
		<xsl:value-of select="@addr"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    </xsl:text>
		<xsl:choose>
			<xsl:when test="number(.) = 0">
				<xsl:text>DISABLED</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
				<xsl:text> bytes per second</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>