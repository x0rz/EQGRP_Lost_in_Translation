<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/">
    <xsl:apply-templates select="Storage"/>
  </xsl:template>

  <xsl:template match="Storage"> 
    <xsl:element name="Storage">
      <xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute>
      <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>