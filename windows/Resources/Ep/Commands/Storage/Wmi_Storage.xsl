<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:apply-templates select="WMI"/>
  </xsl:template>

  <xsl:template match="WMI">
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="TouchResults"/>
	    <xsl:apply-templates select="ProcessList"/>
	    <xsl:apply-templates select="RunCmd"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="TouchResults">
  	<xsl:element name="Storage">
		<xsl:attribute name="type">string</xsl:attribute>
		<xsl:attribute name="name">Sysroot</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="Name"/></xsl:attribute>
	</xsl:element>
  	<xsl:element name="Storage">
		<xsl:attribute name="type">string</xsl:attribute>
		<xsl:attribute name="name">OS</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="OS"/></xsl:attribute>
	</xsl:element>
  	<xsl:element name="Storage">
		<xsl:attribute name="type">string</xsl:attribute>
		<xsl:attribute name="name">Version</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="Version"/></xsl:attribute>
	</xsl:element>
  	<xsl:element name="Storage">
		<xsl:attribute name="type">string</xsl:attribute>
		<xsl:attribute name="name">ServicePack</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="ServicePack"/></xsl:attribute>
	</xsl:element>
  	<xsl:element name="Storage">
		<xsl:attribute name="type">string</xsl:attribute>
		<xsl:attribute name="name">Language</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="Language"/></xsl:attribute>
	</xsl:element>
   </xsl:template>

   <xsl:template match="RemoteProcess">
	<xsl:element name="Storage">
		<xsl:attribute name="type">int</xsl:attribute>
		<xsl:attribute name="name">PID</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="@PID"/></xsl:attribute>
	</xsl:element>
	<xsl:element name="Storage">
		<xsl:attribute name="type">string</xsl:attribute>
		<xsl:attribute name="name">Path</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="@Path"/></xsl:attribute>
	</xsl:element>
	<xsl:element name="Storage">
		<xsl:attribute name="type">string</xsl:attribute>
		<xsl:attribute name="name">Process</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="@Process"/></xsl:attribute>
	</xsl:element>
   </xsl:template>

   <xsl:template match="RunCmd">
	<xsl:element name="Storage">
		<xsl:attribute name="type">string</xsl:attribute>
		<xsl:attribute name="name">Command</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="Command"/></xsl:attribute>
	</xsl:element>
	<xsl:element name="Storage">
		<xsl:attribute name="type">int</xsl:attribute>
		<xsl:attribute name="name">ReturnValue</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="ReturnValue"/></xsl:attribute>
	</xsl:element>
	<xsl:element name="Storage">
		<xsl:attribute name="type">int</xsl:attribute>
		<xsl:attribute name="name">RemotePID</xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="RemotePID"/></xsl:attribute>
	</xsl:element>
   </xsl:template>


</xsl:transform>