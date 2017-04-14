<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Alias"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Alias">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">alias</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@original"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">replace</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@replace"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>