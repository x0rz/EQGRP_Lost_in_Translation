<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Deletion">

  <xsl:value-of select="@file" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>&#x09;</xsl:text>
  <xsl:value-of select="." />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

 </xsl:template>

</xsl:transform>