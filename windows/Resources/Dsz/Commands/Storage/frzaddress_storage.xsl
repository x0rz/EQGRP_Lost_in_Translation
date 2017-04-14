<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="TaskingInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">TaskingInfo</xsl:attribute>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">TaskType</xsl:attribute>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Value</xsl:attribute>
					<xsl:value-of select="TaskType"/>
				</xsl:element>
			</xsl:element>
			<xsl:if test="Address">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Address</xsl:attribute>
					<xsl:value-of select="Address"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="FrzAddresses">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Addresses</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumAddresses</xsl:attribute>
				<xsl:value-of select="@numAddresses"/>
			</xsl:element>
			<xsl:apply-templates select="Address"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Address">
		<xsl:element name="StringValue">
			<xsl:attribute name="name">Address</xsl:attribute>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>

