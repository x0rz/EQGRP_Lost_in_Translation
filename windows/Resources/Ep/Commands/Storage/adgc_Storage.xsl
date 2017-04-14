<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Entry"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Entry">
    <xsl:variable name="type" select="substring-before(substring-after(Category, 'CN='), ',')" />
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">type</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:choose>
        <xsl:when test="$type = 'Computer'">
         <xsl:text>COMPUTERS</xsl:text>
        </xsl:when>
        <xsl:when test="$type = 'Group'">
         <xsl:text>GROUPS</xsl:text>
        </xsl:when>
        <xsl:when test="$type = 'Person'">
         <xsl:text>USERS</xsl:text>
        </xsl:when>
       </xsl:choose>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Name" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">attributes</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="DistinguishedName" /></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>