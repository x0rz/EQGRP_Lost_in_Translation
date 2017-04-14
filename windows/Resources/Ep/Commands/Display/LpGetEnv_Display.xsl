<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Environment"/>
    <xsl:apply-templates select="Error"/>
  </xsl:template>

    <xsl:template match="Environment">
	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="5" /> 
        </xsl:call-template>

	<xsl:value-of select="Name"/> = <xsl:value-of select="Value"/><xsl:text> </xsl:text><xsl:apply-templates select="Static"/><xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="Static">(system)</xsl:template>

</xsl:transform>