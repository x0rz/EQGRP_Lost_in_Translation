<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="LpModule" />
			<xsl:apply-templates select="LocalDependencies" />
			<xsl:apply-templates select="RemoteDependencies" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="LpModule">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LpModule</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="Id"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="LocalDependencies">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LocalDependencies</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Address</xsl:attribute>
				<xsl:value-of select="@address"/>
			</xsl:element>
			<xsl:apply-templates select="ModuleInfo" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="RemoteDependencies">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">RemoteDependencies</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Address</xsl:attribute>
				<xsl:value-of select="@address"/>
			</xsl:element>
			<xsl:apply-templates select="ModuleInfo" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ModuleInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ModuleInfo</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="Id"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>