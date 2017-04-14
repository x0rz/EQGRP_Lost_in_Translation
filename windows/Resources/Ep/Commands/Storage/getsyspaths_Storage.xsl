<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="SystemDir"/>
	    <xsl:apply-templates select="TempDir"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="SystemDir">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">systemDirectoryPath</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
    </xsl:element>
  </xsl:template>
  <xsl:template match="TempDir">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">temporaryPath</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>