<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Error"/>
			<xsl:apply-templates select="Storage"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Error">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Error</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">error</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Storage">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="BoolStorageItem">
		<xsl:element name="BoolValue">
			<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="IntStorageItem">
		<xsl:element name="IntValue">
			<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="StringStorageItem">
		<xsl:element name="StringValue">
			<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>