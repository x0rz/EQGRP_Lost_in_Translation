<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="SystemDir">
  <xsl:text>&#x09;The system directory path is:</xsl:text>
  <xsl:value-of select="." />
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="TempDir">
  <xsl:text>&#x09;The Temp directory path is:</xsl:text>
  <xsl:value-of select="." />
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

</xsl:transform>