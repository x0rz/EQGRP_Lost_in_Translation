<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Strings"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Strings">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Strings</xsl:attribute>
			<xsl:apply-templates select="String"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="String">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">String</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">string</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">offset</xsl:attribute>
				<xsl:value-of select="@offset"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>

</xsl:transform>