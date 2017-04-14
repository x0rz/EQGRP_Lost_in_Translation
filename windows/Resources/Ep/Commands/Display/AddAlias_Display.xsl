<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Alias"/>
    <xsl:apply-templates select="Error"/>
  </xsl:template>

    <xsl:template match="Alias">Alias '<xsl:value-of select="@original"/>' to '<xsl:value-of select="@replace"/>' added.<xsl:text>
</xsl:text></xsl:template>

</xsl:transform>