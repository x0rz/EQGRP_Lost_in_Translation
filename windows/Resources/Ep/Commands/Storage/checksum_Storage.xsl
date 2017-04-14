<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Directory"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Directory">
	<xsl:apply-templates select="File"/>
  </xsl:template>

  <xsl:template match="File">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">file_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@file"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">file_path</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="../@path"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">checksum_value</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@checksum"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>