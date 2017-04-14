<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Child">
	<xsl:text>Stopping child </xsl:text>
	<xsl:value-of select="@childRequest"/>
	<xsl:text> for command </xsl:text>
	<xsl:value-of select="@request"/>
	<xsl:call-template name="PrintReturn"/>
  </xsl:template>

  <xsl:template match="Stop">
	<xsl:text>Attempting to stop command </xsl:text>
	<xsl:value-of select="@request"/>
	<xsl:text> (</xsl:text>
	<xsl:value-of select="@type"/>
	<xsl:text>)</xsl:text>
	<xsl:call-template name="PrintReturn"/>
  </xsl:template>

  <xsl:template match="Stopped">
	<xsl:text>    Stopped</xsl:text>
	<xsl:call-template name="PrintReturn"/>
  </xsl:template>

</xsl:transform>