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
      <xsl:attribute name="name">type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Type"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="RemoteName"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">local</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="LocalName"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ipaddr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="IPAddr"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">comment</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Comment"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">provider</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Provider"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>