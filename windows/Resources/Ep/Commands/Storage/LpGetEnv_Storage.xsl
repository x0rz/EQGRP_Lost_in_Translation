<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Environment"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Environment">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">option</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Name"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">value</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Value"/></xsl:attribute>
    </xsl:element>
    <xsl:choose>
	<xsl:when test="Static">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">system</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">system</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>