<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Interfaces"/>
	    <xsl:apply-templates select="Routes"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Interfaces">
   <xsl:apply-templates select="Interface" />
  </xsl:template>

  <xsl:template match="Routes">
   <xsl:apply-templates select="Route" />
  </xsl:template>

  <xsl:template match="Interface">
   <xsl:element name="Storage">
    <xsl:attribute name="type">string</xsl:attribute>
    <xsl:attribute name="name">interface_index</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="@index" /></xsl:attribute>
   </xsl:element>
   <xsl:element name="Storage">
    <xsl:attribute name="type">string</xsl:attribute>
    <xsl:attribute name="name">interface_ip</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="@ip" /></xsl:attribute>
   </xsl:element>
   <xsl:element name="Storage">
    <xsl:attribute name="type">string</xsl:attribute>
    <xsl:attribute name="name">phys_addr</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="PhysAddr" /></xsl:attribute>
   </xsl:element>
   <xsl:element name="Storage">
    <xsl:attribute name="type">string</xsl:attribute>
    <xsl:attribute name="name">desc</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="Description" /></xsl:attribute>
   </xsl:element>
  </xsl:template>

  <xsl:template match="Route">
   <xsl:element name="Storage">
    <xsl:attribute name="type">string</xsl:attribute>
    <xsl:attribute name="name">network_dest</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="@destination" /></xsl:attribute>
   </xsl:element>

   <xsl:element name="Storage">
    <xsl:attribute name="type">string</xsl:attribute>
    <xsl:attribute name="name">network_mask</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="@mask" /></xsl:attribute>
   </xsl:element>

   <xsl:element name="Storage">
    <xsl:attribute name="type">string</xsl:attribute>
    <xsl:attribute name="name">gateway_ip</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="@gateway" /></xsl:attribute>
   </xsl:element>

   <xsl:element name="Storage">
    <xsl:attribute name="type">string</xsl:attribute>
    <xsl:attribute name="name">interface</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="@interfaceIndex" /></xsl:attribute>
   </xsl:element>

   <xsl:element name="Storage">
    <xsl:attribute name="type">int</xsl:attribute>
    <xsl:attribute name="name">metric</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="@metric1" /></xsl:attribute>
   </xsl:element>

   <xsl:element name="Storage">
    <xsl:attribute name="type">int</xsl:attribute>
    <xsl:attribute name="name">metric_2</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="@metric2" /></xsl:attribute>
   </xsl:element>

   <xsl:element name="Storage">
    <xsl:attribute name="type">int</xsl:attribute>
    <xsl:attribute name="name">metric_3</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="@metric3" /></xsl:attribute>
   </xsl:element>

   <xsl:element name="Storage">
    <xsl:attribute name="type">int</xsl:attribute>
    <xsl:attribute name="name">metric_4</xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="@metric4" /></xsl:attribute>
   </xsl:element>
  </xsl:template>

</xsl:transform>