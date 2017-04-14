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
      <xsl:attribute name="name">name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@name"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">path</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="../@path"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">size</xsl:attribute>
      <xsl:choose>
	<xsl:when test="number(@size) &gt;= 4294967296">
	  <!-- greater than 4 gigs -->
	  <xsl:attribute name="value">4294967296</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="value"><xsl:value-of select="@size"/></xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">isdir</xsl:attribute>
      <xsl:choose>
	<xsl:when test="FileAttributeDirectory">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

</xsl:transform>