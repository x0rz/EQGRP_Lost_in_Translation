<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
			<xsl:apply-templates select="Hosts"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Hosts">
		<xsl:apply-templates select="HostInfo"/>
	</xsl:template>
	
	<xsl:template match="HostInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">HostInfo</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Info</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>
