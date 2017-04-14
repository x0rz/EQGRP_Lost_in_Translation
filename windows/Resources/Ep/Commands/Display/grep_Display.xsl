<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="File">
  <xsl:text>--------------------------------------------&#x0D;&#x0A;</xsl:text>
  <xsl:value-of select="@location" />
  <xsl:text>&#x0D;&#x0A;--------------------------------------------&#x0D;&#x0A;</xsl:text>

  <xsl:if test="@denied">
     <xsl:text>    ACCESS_DENIED&#x0D;&#x0A;</xsl:text>
  </xsl:if>

  <!-- print any lines -->
  <xsl:apply-templates select="Line"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="Line">
  <xsl:variable name="location" select="format-number(@position, '00000000')" />
  <xsl:value-of select="$location" />
  <xsl:text> - </xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

</xsl:transform>