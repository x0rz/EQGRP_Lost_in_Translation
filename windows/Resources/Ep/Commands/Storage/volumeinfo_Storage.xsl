<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="VolumeInfo"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="VolumeInfo">

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">VolumeName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="VolumeName"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">VolumeSerialNumber</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="SerialNumber/@value"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">MaxComponentLength</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@maximumComponentLength"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">FileSystemName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="FileSystemName"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">FileSystemFlags</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Flags/@value"/></xsl:attribute>
    </xsl:element>

  </xsl:template>
</xsl:transform>