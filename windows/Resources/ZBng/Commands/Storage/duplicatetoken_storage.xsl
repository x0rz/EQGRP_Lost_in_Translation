<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
			<xsl:element name="StorageObjects">
				<xsl:apply-templates select="Logon"/>
				<xsl:apply-templates select="ProcessList"/>
			</xsl:element>
	</xsl:template>
	
	<xsl:template match="ProcessList">
		<xsl:apply-templates select="Process"/>
	</xsl:template>

	<xsl:template match="Process">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Process</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">user</xsl:attribute>
				<xsl:value-of select="@user"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Logon">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Token</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="@handle"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">alias</xsl:attribute>
				<xsl:value-of select="@alias"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>