<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Drive">

  <xsl:variable name="Buffer"    select="21" />

  <xsl:variable name="Free"      select="format-number(@free,      '###,###,###,### Bytes')" />
  <xsl:variable name="Available" select="format-number(@available, '###,###,###,### Bytes')" />
  <xsl:variable name="Total"     select="format-number(@total,     '###,###,###,### Bytes')" />

  <xsl:value-of select="@letter" />
  <xsl:text>:\&#x0D;&#x0A;</xsl:text>

  <xsl:text>Free      :</xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="$Buffer - string-length($Free)" /> 
   </xsl:call-template>
  <xsl:value-of select="$Free" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Available :</xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="$Buffer - string-length($Available)" /> 
   </xsl:call-template>
  <xsl:value-of select="$Available" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Total     :</xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="$Buffer - string-length($Total)" /> 
   </xsl:call-template>
  <xsl:value-of select="$Total" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:if test="@free &lt; (40 * 1024 * 1024)">
   <xsl:text>Diskspace is low on this drive</xsl:text>
   <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>

 </xsl:template>

</xsl:transform>