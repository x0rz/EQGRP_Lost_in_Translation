<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="Storage">
	    <xsl:apply-templates select="Plugins"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Plugin">
	<xsl:apply-templates select="Plugin"/>
  </xsl:template>

  <xsl:template match="Plugin">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">file</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
    </xsl:element>
    <xsl:choose>
	<xsl:when test="(@remotechecksum = @localchecksum) and (@remotesize = @localsize)">
	   <xsl:element name="Storage">
		<xsl:attribute name="type">bool</xsl:attribute>
		<xsl:attribute name="name">good</xsl:attribute>
		<xsl:attribute name="value">true</xsl:attribute>
	   </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	   <xsl:element name="Storage">
		<xsl:attribute name="type">bool</xsl:attribute>
		<xsl:attribute name="name">good</xsl:attribute>
		<xsl:attribute name="value">false</xsl:attribute>
	   </xsl:element>
	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>