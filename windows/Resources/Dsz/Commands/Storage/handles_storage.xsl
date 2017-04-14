<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Handles"/>
			<xsl:apply-templates select="DuplicatedHandle"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Handles">
		<xsl:apply-templates select="Process"/>
	</xsl:template>
	
	<xsl:template match="DuplicatedHandle">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DuplicatedHandle</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">OrigHandle</xsl:attribute>
				<xsl:value-of select="@origHandleId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">OrigProcessId</xsl:attribute>
				<xsl:value-of select="@origProcessId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NewHandle</xsl:attribute>
				<xsl:value-of select="@newHandleId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NewProcessId</xsl:attribute>
				<xsl:value-of select="@newProcessId"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
		
	<xsl:template match="Process">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Process</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
			
			<xsl:apply-templates select="Handle"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Handle">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Handle</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="@handleId"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Metadata</xsl:attribute>
				<xsl:value-of select="Metadata"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>