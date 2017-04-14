<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="no"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageNodes">	
			<xsl:apply-templates select="Logon"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Logon">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Logon</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Alias</xsl:attribute>
				<xsl:value-of select="@alias"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Handle</xsl:attribute>
				<xsl:value-of select="@handle"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>