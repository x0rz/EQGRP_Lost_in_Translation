<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Set"/>
    <xsl:apply-templates select="Removed"/>
    <xsl:apply-templates select="Error"/>
  </xsl:template>

    <xsl:template match="Set">Environment variable set
</xsl:template>

    <xsl:template match="Removed">Environment variable removed
</xsl:template>

</xsl:transform>