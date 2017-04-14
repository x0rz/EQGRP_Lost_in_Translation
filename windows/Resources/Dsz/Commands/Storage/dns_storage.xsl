<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	
	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="DnsCacheEntries/CacheEntry"/>
			<xsl:apply-templates select="Dns/AnswerData"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="DnsCacheEntries">
		<xsl:apply-templates select="CacheEntry"/>
	</xsl:template>
	
	<xsl:template match="CacheEntry">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">CacheEntry</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">EntryName</xsl:attribute>
				<xsl:value-of select="EntryName"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">DataType</xsl:attribute>
				<xsl:value-of select="Data/@type"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">DataTypeStr</xsl:attribute>
				<xsl:value-of select="Data/@typeStr"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Data</xsl:attribute>
				<xsl:value-of select="Data"/>
			</xsl:element>
			<xsl:call-template name="TimeStorage">
				<xsl:with-param name="time" select="Ttl"/>
				<xsl:with-param name="name" select="'Ttl'"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template match="AnswerData">
		<xsl:apply-templates select="Answer"/>
	</xsl:template>

	<xsl:template match="Answer">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DnsAnswer</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Ttl</xsl:attribute>
				<xsl:value-of select="@ttl"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="TypeStr"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Query</xsl:attribute>
				<xsl:call-template name="HandleDnsString">
					<xsl:with-param name="node" select="String"/>
				</xsl:call-template>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">DataType</xsl:attribute>
				<xsl:value-of select="DnsData/@type"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Data</xsl:attribute>
				<xsl:choose>
					<xsl:when test="DnsData/@type = 'domain'">
						<xsl:call-template name="HandleDnsString">
							<xsl:with-param name="node" select="DnsData"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="DnsData/@type = 'hostAddress'">
						<xsl:value-of select="DnsData"/>
					</xsl:when>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template name="HandleDnsString">
		<xsl:param name="node"/>

		<xsl:for-each select="$node/String">
			<xsl:if test="string-length(.) &gt; 0">
				<xsl:if test="position() &gt; 1">
					<xsl:text>.</xsl:text>
				</xsl:if>
				<xsl:value-of select="."/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
</xsl:transform>