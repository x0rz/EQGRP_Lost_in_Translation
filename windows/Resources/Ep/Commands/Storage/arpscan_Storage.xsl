<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Entry"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Entry">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ip_addr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@ip"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">phys_addr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@mac"/></xsl:attribute>
    </xsl:element>
  </xsl:template>


</xsl:transform>