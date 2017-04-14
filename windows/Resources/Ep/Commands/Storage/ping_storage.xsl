<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="PingResponses"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="PingResponses">
   <xsl:apply-templates select="Response" />
  </xsl:template>

  <xsl:template match="Response">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">srcAddr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Ip/@source"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">dstAddr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Ip/@destination"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">ttl</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Ip/@ttl"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Ip/Icmp/@type"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">code</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Ip/Icmp/@code"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>