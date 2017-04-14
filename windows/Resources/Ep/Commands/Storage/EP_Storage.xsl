<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="CommandLog"/>
	    <xsl:apply-templates select="CommandStart"/>
	    <xsl:apply-templates select="CommandXml"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="CommandLog"> 
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">OutputFile</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="CommandStart">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">LastCommandId</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@request"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="CommandXml"> 
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">XmlFile</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>