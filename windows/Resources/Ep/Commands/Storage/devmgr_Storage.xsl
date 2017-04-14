<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Device"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Device">

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">DeviceDesc</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="DeviceDesc"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">Driver</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Driver"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">FriendlyName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="FriendlyName"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">HwdID</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="HardwareID"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">LocationInfo</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="LocationInfo"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">Mfg</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Mfg"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">PhysDevObjName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="PhysDevObjName"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ServPth</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="ServicePath"/></xsl:attribute>
    </xsl:element>


  </xsl:template>
</xsl:transform>