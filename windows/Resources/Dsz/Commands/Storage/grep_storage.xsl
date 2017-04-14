<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="File"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="File">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">File</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Location</xsl:attribute>
				<xsl:value-of select="@location"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumLines</xsl:attribute>
				<xsl:value-of select="count(Line)"/>
			</xsl:element>
			
			<xsl:if test="@error">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Error</xsl:attribute>
					<xsl:value-of select="@error"/>
				</xsl:element>
			</xsl:if>
			
			<xsl:apply-templates select="Line"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Line">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Line</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Position</xsl:attribute>
				<xsl:value-of select="@position"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:transform>