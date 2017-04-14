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
			<xsl:if test="LinkId">
				<xsl:element name="IntValue">
					<xsl:attribute name="name">LinkId</xsl:attribute>
					<xsl:value-of select="LinkId"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="LinkProvider">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">LinkProvider</xsl:attribute>
					<xsl:value-of select="LinkProvider"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="Data">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Data</xsl:attribute>
					<xsl:value-of select="Data"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="FrzLinks">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Links</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumLinks</xsl:attribute>
				<xsl:value-of select="@numLinks"/>
			</xsl:element>
			<xsl:apply-templates select="Link"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Link">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Link</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="FrzLinkState">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">State</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">StateValue</xsl:attribute>
				<xsl:value-of select="@state"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">State</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="FrzLinkConfiguration">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Configuration</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LinkProvider</xsl:attribute>
				<xsl:value-of select="@provider"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LinkProviderName</xsl:attribute>
				<xsl:value-of select="@providerName"/>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Crypto</xsl:attribute>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Provider</xsl:attribute>
					<xsl:value-of select="Crypto/@provider"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">ProviderName</xsl:attribute>
					<xsl:value-of select="Crypto/@providerName"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Key</xsl:attribute>
					<xsl:value-of select="Crypto/Key"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">ConnectionManager</xsl:attribute>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Provider</xsl:attribute>
					<xsl:value-of select="ConnectionMgr/@provider"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">ProviderName</xsl:attribute>
					<xsl:value-of select="ConnectionMgr/@providerName"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Parameters</xsl:attribute>
				<xsl:value-of select="Parameters"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>

