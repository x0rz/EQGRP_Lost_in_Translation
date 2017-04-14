<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="PingResponse"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="PingResponse">
		<xsl:apply-templates select="Response" />
	</xsl:template>
	
	<xsl:template match="Response">
		<xsl:variable name="min_to_ms" select="number(substring-before(substring-after(Elapsed, 'H'), 'M'))*(60000)"/>
		<xsl:variable name="s_to_ms" select="number(substring-before(substring-after(Elapsed, 'M'), '.'))*(1000)"/>
		<xsl:variable name="ns_to_ms" select="number(substring(substring-after(Elapsed, '.'), 1, 3))"/>
		<xsl:variable name="ms" select="number($min_to_ms + $s_to_ms + $ns_to_ms)"/>
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Response</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">length</xsl:attribute>
				<xsl:value-of select="@length" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">elapsed</xsl:attribute>
		 	    <xsl:value-of select="$ms"/>
			</xsl:element>
			<xsl:if test="@ttl">
				<xsl:element name="IntValue">
					<xsl:attribute name="name">ttl</xsl:attribute>
					<xsl:value-of select="@ttl"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="@type" />
			</xsl:element>
			<xsl:apply-templates select="Data" />
			<xsl:apply-templates select="FromAddr" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Data">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Data</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Data</xsl:attribute>
				<xsl:value-of select="." />
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="FromAddr">
		<xsl:element name="ObjectValue">
			<xsl:choose>
				<xsl:when test="FromAddr/IPv6Address">
					<xsl:attribute name="name">FromAddr</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Addr</xsl:attribute>
						<xsl:value-of select="IPv6Address" />
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Type</xsl:attribute>
						<xsl:text>ipv6</xsl:text>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="name">FromAddr</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Addr</xsl:attribute>
						<xsl:value-of select="IPv4Address" />
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Type</xsl:attribute>
						<xsl:text>ipv4</xsl:text>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>