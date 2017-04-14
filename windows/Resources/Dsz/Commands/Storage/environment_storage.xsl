<?xml version='1.0' ?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Environment"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Environment">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Environment</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">action</xsl:attribute>
		        <xsl:value-of select="@action"/>
			</xsl:element>
			
			<xsl:apply-templates select="Value"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Value">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Value</xsl:attribute>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
		        <xsl:value-of select="@name"/>
			</xsl:element>
		
			<xsl:element name="StringValue">
				<xsl:attribute name="name">value</xsl:attribute>
		        <xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>

