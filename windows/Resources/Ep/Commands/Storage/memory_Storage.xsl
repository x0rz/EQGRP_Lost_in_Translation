<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Memory"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Memory">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">memVirtAvail</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Virtual/@available div 1000000"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">memVirtTotal</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Virtual/@total div 1000000"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">memPageAvail</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Page/@available div 1000000"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">memPageTotal</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Page/@total div 1000000"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">memPhysAvail</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Physical/@available div 1000000"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">memPhysTotal</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Physical/@total div 1000000"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">memPhysLoad</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@memPhysLoad"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>