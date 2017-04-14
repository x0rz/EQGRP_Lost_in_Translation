<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Version"/>
	    <xsl:apply-templates select="Status"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Version">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">major</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@major"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">minor</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@minor"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">build</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@build"/></xsl:attribute>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="Status">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">mailslot</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="RegisteredProcess/@mailslot"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">pid</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="RegisteredProcess/@pid"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">lastTrigger</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="LastTriggerTime"/></xsl:attribute>
    </xsl:element>
  </xsl:template>
</xsl:transform>