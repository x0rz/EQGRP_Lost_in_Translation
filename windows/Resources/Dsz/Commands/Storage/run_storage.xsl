<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="ProcessOutput"/>
			<xsl:apply-templates select="ProcessStarted"/>
			<xsl:apply-templates select="ProcessStatus"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ProcessOutput">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessOutput</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Output</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="ProcessStarted">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessStarted</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ProcessStatus">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessStatus</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Status</xsl:attribute>
				<xsl:value-of select="@status"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>