<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="ListeningPost"/>
	    <xsl:apply-templates select="Implant"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="ListeningPost">
	<xsl:apply-templates select="Compiled"/>
	<xsl:apply-templates select="Base"/>
	<xsl:apply-templates select="Plugins"/>
  </xsl:template>
	
  <xsl:template match="Compiled">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">lp</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@major"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">lp</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@minor"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">lp</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@build"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Base">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">LpBaseMajor</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@major"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">LpBaseMinor</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@minor"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">LpBaseBuild</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@build"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Plugins">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">LpPluginsMajor</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@major"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">LpPluginsMinor</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@minor"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">LpPluginsBuild</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@build"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Implant">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">implant</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@major"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">implant</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@minor"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">implant</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@build"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>

