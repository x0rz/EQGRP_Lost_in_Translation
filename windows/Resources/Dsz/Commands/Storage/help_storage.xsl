<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Commands">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Commands</xsl:attribute>
			<xsl:apply-templates select="Cmd"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Prefixes">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Prefixes</xsl:attribute>
			<xsl:apply-templates select="Prefix"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Prefix">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Prefix</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Cmd">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Command</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Loaded</xsl:attribute>
				<xsl:value-of select="@loaded"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Builtin</xsl:attribute>
				<xsl:value-of select="@builtin"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>