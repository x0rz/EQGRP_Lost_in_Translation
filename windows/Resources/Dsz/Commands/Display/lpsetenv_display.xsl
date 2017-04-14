<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="include/StandardTransforms.xsl"/>

  <xsl:template match="Set">
	<xsl:text>Environment variable set</xsl:text>
	<xsl:call-template name="PrintReturn"/>
  </xsl:template>

  <xsl:template match="Removed">
	<xsl:text>Environment variable removed</xsl:text>
	<xsl:call-template name="PrintReturn"/>
  </xsl:template>

</xsl:transform>