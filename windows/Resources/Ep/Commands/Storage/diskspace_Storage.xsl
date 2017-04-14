<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Drive"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Drive">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">free</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@free"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">available</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@available"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">total</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@total"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">letter</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@letter"/></xsl:attribute>
    </xsl:element>
    <xsl:choose>
	<xsl:when test="@free &lt; (40 * 1024 * 1024)">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">low_diskspace</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">low_diskspace</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:transform>