<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Loaded">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Library</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Location</xsl:attribute>
				<xsl:value-of select="@location"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Location">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Library</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Location</xsl:attribute>
				<xsl:value-of select="@location"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Freed">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Library</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Location</xsl:attribute>
				<xsl:value-of select="@location"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>

