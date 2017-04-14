<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Hop"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Hop">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">traceHop</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@hop"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">traceIP</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Destination"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">traceTTL</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@ttl"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">traceCode</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Code/@code"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">traceTime</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@time"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">traceName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="HostName"/></xsl:attribute>
    </xsl:element>
  </xsl:template>
</xsl:transform>