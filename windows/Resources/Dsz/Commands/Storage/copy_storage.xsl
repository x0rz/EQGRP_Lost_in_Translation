<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Results">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">CopyResults</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">source</xsl:attribute>
				<xsl:value-of select="Source"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">destination</xsl:attribute>
				<xsl:value-of select="Destination"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>