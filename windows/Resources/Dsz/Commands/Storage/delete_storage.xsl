<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Deletions">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="FileDelete">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DeletionItem</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">File</xsl:attribute>
				<xsl:value-of select="@file"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Delay</xsl:attribute>
				<xsl:value-of select="@delay"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">StatusValue</xsl:attribute>
				<xsl:value-of select="@statusValue"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">StatusString</xsl:attribute>
				<xsl:value-of select="StatusString"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>