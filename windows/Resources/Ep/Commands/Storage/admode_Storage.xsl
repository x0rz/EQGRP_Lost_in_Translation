<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="AdMode"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="AdMode">
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">mixed</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:choose>
        <xsl:when test="contains(@mixed, 'true')">
         <xsl:text>true</xsl:text>
        </xsl:when>
        <xsl:otherwise>
         <xsl:text>false</xsl:text>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>