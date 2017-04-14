<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">	
	    <xsl:apply-templates select="Channels"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Channels">
	<xsl:apply-templates select="Channel"/>
  </xsl:template>

  <xsl:template match="Channel">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">channel_id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="number(@request)"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">command_id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="number(@commandRequest)"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">address</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Function"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">sent</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="number(Sent/@total)"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">received</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="number(Received/@total)"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">flags</xsl:attribute>
      <xsl:attribute name="value"><xsl:if test="Released">R</xsl:if><xsl:if test="Local">L</xsl:if></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>