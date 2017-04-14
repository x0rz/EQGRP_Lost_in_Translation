<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Connection"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Connection">

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">protocol</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@type"/></xsl:attribute>
    </xsl:element>
   
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">valid</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@valid"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">local_addr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@localIp" />:<xsl:value-of select="@localPort" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">remote_addr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@remoteIp" />:<xsl:value-of select="@remotePort" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">state</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@state" /></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>