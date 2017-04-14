<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Drivers"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Drivers">
   <xsl:apply-templates select="Driver" />
  </xsl:template>

  <xsl:template match="Driver">

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
    </xsl:element>
   
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">base</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@base"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">size</xsl:attribute>
      <xsl:attribute name="value"><xsl:text>0x</xsl:text><xsl:value-of select="@size"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">flags</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@flags"/></xsl:attribute>
    </xsl:element>
   
  </xsl:template>
</xsl:transform>