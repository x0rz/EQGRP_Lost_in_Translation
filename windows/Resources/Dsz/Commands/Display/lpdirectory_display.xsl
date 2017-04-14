<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="include/StandardTransforms.xsl"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Directory"/>
    <xsl:apply-templates select="Error"/>
  </xsl:template>

    <xsl:template match="Directory">Directory : 
	<xsl:value-of select="."/><xsl:text>
</xsl:text></xsl:template>

</xsl:transform>