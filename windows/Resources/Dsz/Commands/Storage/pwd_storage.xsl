<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="DirectoryInfo"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="DirectoryInfo"> 
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">CurrentDirectory</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Path</xsl:attribute>
				<xsl:value-of select="CurrentDirectory"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Virtual</xsl:attribute>
				<xsl:value-of select="@virtual"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>
