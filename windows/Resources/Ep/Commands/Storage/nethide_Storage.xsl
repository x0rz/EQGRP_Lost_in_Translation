<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Ports"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Ports">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="Port">

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">lport</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@lport"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">lipAddr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@lipAddr"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">fport</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@fport"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">fipAddr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@fipAddr"/></xsl:attribute>
    </xsl:element>

  </xsl:template>

  <xsl:template match="Mode">
    <xsl:element name="Storage">
	<xsl:attribute name="type">int</xsl:attribute>
	<xsl:attribute name="name">mode</xsl:attribute>
	<xsl:attribute name="value"><xsl:value-of select="@mode"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>


