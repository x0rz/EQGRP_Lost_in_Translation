<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="VideoSummary"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="VideoSummary">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">jpegFileName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@jpegFileName"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">jpegSize</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@jpegSize"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>
