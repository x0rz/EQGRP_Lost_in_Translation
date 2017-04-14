<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ImplantInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ImplantInfo</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Version</xsl:attribute>
				<xsl:value-of select="Version" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="Id" />
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="RemoteAddress">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">RemoteAddress</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>