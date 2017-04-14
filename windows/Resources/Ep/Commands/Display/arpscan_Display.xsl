<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="StandardTransforms.xsl"/>
	<xsl:output method="text"/>

	<xsl:template match="Entry">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="17 - string-length(@ip)"/>
		</xsl:call-template>
		<xsl:value-of select="@ip"/>
		<xsl:text> -&gt; </xsl:text>
		<xsl:value-of select="@mac"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>