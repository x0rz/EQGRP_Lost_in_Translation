<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="PidGuesser"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="PidGuesser">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">counter</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@counter"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">index</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@index"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">procId</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@procId"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">threadId</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@threadId"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>