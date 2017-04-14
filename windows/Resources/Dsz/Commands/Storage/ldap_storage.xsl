<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="LdapEntries"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>

		</xsl:element>
	</xsl:template>

	<xsl:template match="LdapEntries">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LdapEntries</xsl:attribute>
			<xsl:apply-templates select="LdapEntry"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="LdapEntry">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LdapEntry</xsl:attribute>
			<xsl:apply-templates select="Attribute"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Attribute">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Attribute</xsl:attribute>
			<!-- data type: 1=boolean;2=string;3=integer;4=time;5=hex;6=largeint -->
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dataType</xsl:attribute>
				<xsl:value-of select="@dataType"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="Type"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="Value"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>