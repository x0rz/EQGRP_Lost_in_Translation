<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Deletion"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Deletion">

 <xsl:element name="Storage">
  <xsl:attribute name="type">string</xsl:attribute>
  <xsl:attribute name="name">file_name</xsl:attribute>
  <xsl:attribute name="value"><xsl:value-of select="@file"/></xsl:attribute>
 </xsl:element>
 <xsl:element name="Storage">
  <xsl:attribute name="type">bool</xsl:attribute>
  <xsl:attribute name="name">is_file_deleted</xsl:attribute>
  <xsl:choose>
   <xsl:when test="@error = 0">
    <xsl:attribute name="value">true</xsl:attribute>
   </xsl:when>
   <xsl:otherwise>
    <xsl:attribute name="value">false</xsl:attribute>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:element>
 </xsl:template>

</xsl:transform>