<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="StandardTransforms.xsl" />
	<xsl:output method="xml" omit-xml-declaration="no" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="SRNetstat/Connection" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Connection">
		<xsl:element name="Storage">
			<xsl:attribute name="type">int</xsl:attribute>
			<xsl:attribute name="name">id</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@id"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">type</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@type"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">int</xsl:attribute>
			<xsl:attribute name="name">localPort</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@localPort"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">int</xsl:attribute>
			<xsl:attribute name="name">remotePort</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@remotePort"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute>
			<xsl:attribute name="name">state</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@state"/></xsl:attribute>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>