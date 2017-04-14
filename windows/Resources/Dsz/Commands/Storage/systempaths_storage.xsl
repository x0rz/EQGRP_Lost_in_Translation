<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Dirs"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Dirs">
		<xsl:apply-templates select="WindowsDir"/>
		<xsl:apply-templates select="SystemDir"/>
		<xsl:apply-templates select="TempDir"/>
	</xsl:template>
	
	<xsl:template match="WindowsDir">
		<xsl:element name="ObjectValue">
				<xsl:attribute name="name">WindowsDir</xsl:attribute>
				
			<xsl:element name="StringValue">
				<xsl:attribute name="name">location</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="SystemDir">
		<xsl:element name="ObjectValue">
				<xsl:attribute name="name">SystemDir</xsl:attribute>
				
			<xsl:element name="StringValue">
				<xsl:attribute name="name">location</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="TempDir">
		<xsl:element name="ObjectValue">
				<xsl:attribute name="name">TempDir</xsl:attribute>
				
			<xsl:element name="StringValue">
				<xsl:attribute name="name">location</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>