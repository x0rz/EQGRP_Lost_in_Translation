<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Ports">
		<xsl:text>              LocalAddr           LocalPort Type     State     Process</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>-----------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:apply-templates select="Process" />
	</xsl:template>
	
	<xsl:template match="Process">
		<xsl:apply-templates select="Port" />

		<xsl:text>------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

	<xsl:template match="Port">
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="32 - string-length(@sourceAddr)" />
		</xsl:call-template>
		<xsl:value-of select="@sourceAddr" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="8 - string-length(@sourcePort)" />
		</xsl:call-template>
		<xsl:value-of select="@sourcePort" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="8 - string-length(@type)" />
		</xsl:call-template>
		<xsl:value-of select="@type" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="12 - string-length(@state)" />
		</xsl:call-template>
		<xsl:value-of select="@state" />
		<xsl:text>  </xsl:text>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="4 - string-length(../@id)" />
		</xsl:call-template>
		<xsl:value-of select="../@id" />
		<xsl:text> - </xsl:text>
		<xsl:value-of select="../@name" />
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
</xsl:transform>