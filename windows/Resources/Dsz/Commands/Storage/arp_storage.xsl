<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="ArpEntries" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ArpEntries">
		<xsl:apply-templates select="ArpEntry" />
	</xsl:template>
	
	<xsl:template match="ArpEntry">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Entry</xsl:attribute>
			<xsl:choose>
				<xsl:when test="IP/IPv6Address">
					<xsl:element name="StringValue">
						<xsl:attribute name="name">IP</xsl:attribute>
						<xsl:value-of select="IP/IPv6Address" />
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">IpType</xsl:attribute>
						<xsl:text>ipv6</xsl:text>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">IP</xsl:attribute>
						<xsl:value-of select="IP/IPv4Address" />
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">IpType</xsl:attribute>
						<xsl:text>ipv4</xsl:text>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">MAC</xsl:attribute>
				<xsl:value-of select="Physical/MacAddress" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="@type" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">State</xsl:attribute>
				<xsl:value-of select="@state" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Adapter</xsl:attribute>
				<xsl:value-of select="@adapter" />
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">IsRouter</xsl:attribute>
				<xsl:choose>
					<xsl:when test="FlagIsRouter">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">IsUnreachable</xsl:attribute>
				<xsl:choose>
					<xsl:when test="FlagIsUnreachable">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>
