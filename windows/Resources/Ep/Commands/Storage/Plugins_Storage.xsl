<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Plugins"/>
	    <xsl:apply-templates select="RemotePlugins"/>	
	</xsl:element>
  </xsl:template>

  <xsl:template match="Plugins">
	<xsl:apply-templates select="Plugin"/>
  </xsl:template>

  <xsl:template match="RemotePlugins">
	<xsl:apply-templates select="RemotePlugin"/>
  </xsl:template>

  <xsl:template match="Plugin">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="number(Id)"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">loadcount</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="number(LoadCount)"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">file</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="File"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="RemotePlugin">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">remote_id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="number(Id)"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">remote_loadcount</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="number(LoadCount)"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">remote_file</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="File"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>