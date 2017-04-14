<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Objects"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Objects">
		<xsl:apply-templates select="ObjectDirectory"/>
	</xsl:template>
	
	<xsl:template match="ObjectDirectory">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DirectoryItem</xsl:attribute>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">Path</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">QueryFailure</xsl:attribute>
				<xsl:choose>
					<xsl:when test="QueryFailure">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:choose>
				<xsl:when test="QueryFailure">
					<xsl:element name="StringValue">
						<xsl:attribute name="name">ErrorString</xsl:attribute>
						<xsl:value-of select="QueryFailure"/>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates select="Object"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Object">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ObjectItem</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>