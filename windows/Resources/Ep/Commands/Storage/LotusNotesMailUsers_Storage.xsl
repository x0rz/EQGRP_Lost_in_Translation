<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="LotusNotesMailUsers"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="LotusNotesMailUsers">
    <xsl:apply-templates select="User"/>
  </xsl:template>

    <xsl:template match="User">
	<xsl:apply-templates select="FirstName"/>
	<xsl:apply-templates select="LastName"/>
	<xsl:apply-templates select="MailFile"/>
	<xsl:apply-templates select="InternetAddress"/>
    </xsl:template>

    <xsl:template match="FirstName">
      <xsl:element name="Storage">
        <xsl:attribute name="type">string</xsl:attribute>
        <xsl:attribute name="name">firstName</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
      </xsl:element>
    </xsl:template>

    <xsl:template match="LastName">
      <xsl:element name="Storage">
        <xsl:attribute name="type">string</xsl:attribute>
        <xsl:attribute name="name">lastName</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
      </xsl:element>
    </xsl:template>

    <xsl:template match="MailFile">
      <xsl:element name="Storage">
        <xsl:attribute name="type">string</xsl:attribute>
        <xsl:attribute name="name">mailFile</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
      </xsl:element>
    </xsl:template>

    <xsl:template match="InternetAddress">
      <xsl:element name="Storage">
        <xsl:attribute name="type">string</xsl:attribute>
        <xsl:attribute name="name">internetAddress</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
      </xsl:element>
    </xsl:template>

</xsl:transform>



