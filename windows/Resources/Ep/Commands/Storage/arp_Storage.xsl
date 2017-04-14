<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Arp"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Arp">
   <xsl:apply-templates select="Entry" />
  </xsl:template>

  <xsl:template match="Entry">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">interface_ip_addr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="InterfaceIp"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">interface</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@index"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ip_addr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Ip"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">phys_addr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="PhysicalAddress"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Type"/></xsl:attribute>
    </xsl:element>
  </xsl:template>


</xsl:transform>