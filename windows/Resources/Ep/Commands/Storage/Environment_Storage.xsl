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
    <xsl:if test="@envValue">
      <xsl:element name="Storage">
        <xsl:attribute name="type">string</xsl:attribute>
        <xsl:attribute name="name">varValue</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="@envValue"/></xsl:attribute>
      </xsl:element>
    </xsl:if>
 
  </xsl:template>

</xsl:transform>