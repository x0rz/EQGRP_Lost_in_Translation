<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Hidden"/>
			<xsl:apply-templates select="Unhidden"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Hidden">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">HideObject</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="@value"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">data</xsl:attribute>
				<xsl:value-of select="MetaData"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Unhidden">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">UnhideObject</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="@value"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">data</xsl:attribute>
				<xsl:value-of select="MetaData"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>