<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Version"/>
	    <xsl:apply-templates select="Device"/>
	    <xsl:apply-templates select="StoredConfiguration" />
	</xsl:element>
  </xsl:template>


  <xsl:template match="Version">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">major</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@major"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">minor</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@minor"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">revision</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@revision"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Device">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">deviceName</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">listening</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@isListening"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="StoredConfiguration">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">maxSize</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@maxSize"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">logFile</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="LogFile"/></xsl:attribute>
    </xsl:element>
    <xsl:for-each select="Device">
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">device</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
		</xsl:element>
    </xsl:for-each>
  </xsl:template>
  
</xsl:transform>