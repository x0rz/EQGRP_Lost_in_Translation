<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
			<xsl:element name="StorageNodes">
				<xsl:apply-templates select="Element"/>
				
			</xsl:element>
	</xsl:template>
	<xsl:template match="Element">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Element</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			
			<xsl:apply-templates select="Attribute"/>
			<xsl:apply-templates select="Text"/>
			<xsl:apply-templates select="Element"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Attribute">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Attribute</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="@value"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Text">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Text</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Text</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>