<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
      <xsl:element name="StorageNodes">
          <xsl:apply-templates select="PortMap/Process"/>
      </xsl:element>
  </xsl:template>

  <xsl:template match="Process">
   <xsl:apply-templates select="Port" />
  </xsl:template>

  <xsl:template match="Port">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">procId</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="../@id"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ip</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@sourceAddr"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">port</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@sourcePort"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">pType</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@type"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">pState</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@state"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">procName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="../@name"/></xsl:attribute>
    </xsl:element>

  </xsl:template>

</xsl:transform>