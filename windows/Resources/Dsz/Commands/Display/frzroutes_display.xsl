<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="FrzRoutesActionCompleted">
		<xsl:text>Action completed</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="FrzRoutes">
		<xsl:text> Found </xsl:text>
		<xsl:value-of select="@numRoutes"/>
		<xsl:text> Routes : </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>      ADDRESS           PRECENDENCE   LINK_ID</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>-------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Route"/>
	</xsl:template>

	<xsl:template match="Route">
		<xsl:text>  </xsl:text>
		<xsl:value-of select="@address"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="@cidrBits"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="25-string-length(@address)-string-length(@cidrBits)"/>
		</xsl:call-template>
		<xsl:value-of select="@precedence"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="12-string-length(@precedence)"/>
		</xsl:call-template>
		<xsl:value-of select="@linkId"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
 
</xsl:transform>