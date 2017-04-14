<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Available"/>
			<xsl:apply-templates select="Status"/>
			<xsl:apply-templates select="String"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Available">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Available</xsl:attribute>
			
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Status">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Status</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Major</xsl:attribute>
				<xsl:value-of select="Major"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Minor</xsl:attribute>
				<xsl:value-of select="Minor"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Fix</xsl:attribute>
				<xsl:value-of select="Fix"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Build</xsl:attribute>
				<xsl:value-of select="Build"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Available</xsl:attribute>
				<xsl:value-of select="Available"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="String">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Output</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">String</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>