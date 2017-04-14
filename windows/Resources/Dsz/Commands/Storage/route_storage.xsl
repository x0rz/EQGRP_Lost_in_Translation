<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Routes" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Routes">
		<xsl:apply-templates select="Route" />
	</xsl:template>
	
	<xsl:template match="Route">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Route</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Destination</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Destination/IPv4Address">
						<xsl:value-of select="Destination/IPv4Address"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="Destination/IPv6Address"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">NetworkMask</xsl:attribute>
				<xsl:value-of select="Netmask"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Gateway</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Gateway/IPv4Address">
						<xsl:value-of select="Gateway/IPv4Address"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="Gateway/IPv6Address"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Interface</xsl:attribute>
				<xsl:value-of select="Interface"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Metric</xsl:attribute>
				<xsl:value-of select="@metric"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Origin</xsl:attribute>
				<xsl:value-of select="@origin"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">RouteType</xsl:attribute>
				<xsl:value-of select="Destination/IPAddress/@type"/>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">FlagLoopback</xsl:attribute>
				<xsl:choose>
					<xsl:when test="FlagLoopback">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">FlagAutoConfigure</xsl:attribute>
				<xsl:choose>
					<xsl:when test="FlagAutoConfigure">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">FlagPermanent</xsl:attribute>
				<xsl:choose>
					<xsl:when test="FlagPermanent">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">FlagPublish</xsl:attribute>
				<xsl:choose>
					<xsl:when test="FlagPublish">
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