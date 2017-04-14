<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Filter"/>
	    <xsl:apply-templates select="Status"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Filter">

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">AdapterFilter</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="AdapterFilter/@value"/></xsl:attribute>
    </xsl:element>
 
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">filter</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="BpfFilter"/></xsl:attribute>
    </xsl:element>

  </xsl:template>

  <xsl:template match="Status">

	<xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">VersionMajor</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Version/@major"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">VersionMinor</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Version/@minor"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">VersionRevision</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Version/@revision"/></xsl:attribute>
    </xsl:element>
    
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FilterActive</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@filterActive"/></xsl:attribute>
    </xsl:element>
 
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">ThreadRunning</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@threadRunning"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">MaxFileSize</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@maxCaptureSize"/></xsl:attribute>
    </xsl:element>
 
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">MaxPacketSize</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@maxPacketSize"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">CaptureFile</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@captureFile"/></xsl:attribute>
    </xsl:element>

  </xsl:template>

</xsl:transform>