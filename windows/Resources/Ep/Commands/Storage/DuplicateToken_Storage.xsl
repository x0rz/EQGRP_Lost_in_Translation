<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="StandardTransforms.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="no"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageNodes">	
			<xsl:apply-templates select="Logon"/>
			<xsl:apply-templates select="ProcessList"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ProcessList">
		<xsl:apply-templates select="Process"/>
	</xsl:template>
	
	<xsl:template match="Process">
		<xsl:element name="Storage">
			<xsl:attribute name="type">int</xsl:attribute>
			<xsl:attribute name="name">id</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">name</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@name"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">user</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@user"/></xsl:attribute>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Logon">
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">handle</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@handle"/></xsl:attribute>
		</xsl:element>
    
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">alias</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@alias"/></xsl:attribute>
		</xsl:element>
	</xsl:template>

</xsl:transform>