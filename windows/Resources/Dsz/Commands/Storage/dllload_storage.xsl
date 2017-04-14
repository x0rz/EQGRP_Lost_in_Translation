<?xml version='1.1' ?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="DllLoad"/>
			<xsl:apply-templates select="DllUnload"/>
			<xsl:apply-templates select="DllInjected"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="DllLoad">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DllLoad</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">LoadAddress</xsl:attribute>
				<xsl:value-of select="@loadAddress"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="DllUnload">
		<xsl:element name="ObjectValue">
		<xsl:attribute name="name">DllUnload</xsl:attribute>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Unloaded</xsl:attribute>
				<xsl:value-of select="@unloaded"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="DllInjected">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DllLoad</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">LoadAddress</xsl:attribute>
				<xsl:value-of select="@loadAddress"/>
			</xsl:element>
		</xsl:element>
		<xsl:element name="ObjectValue">
		<xsl:attribute name="name">DllUnload</xsl:attribute>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Unloaded</xsl:attribute>
				<xsl:value-of select="@unloaded"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>