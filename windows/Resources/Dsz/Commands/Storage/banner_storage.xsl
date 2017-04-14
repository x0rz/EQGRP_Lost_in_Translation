<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Transfer" />
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Transfer">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Transfer</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">address</xsl:attribute>
				<xsl:value-of select="@address" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">port</xsl:attribute>
				<xsl:value-of select="@port" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">data_size</xsl:attribute>
				<xsl:value-of select="Data/@size" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Data</xsl:attribute>
				<xsl:value-of select="Data" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Text</xsl:attribute>
				<xsl:value-of select="Text" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:transform>