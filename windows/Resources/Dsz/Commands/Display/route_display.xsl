<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="include/StandardTransforms.xsl" />
	
	<xsl:template match="RouteAdded">
		<xsl:text>Route added</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="RouteDeleted">
		<xsl:text>Route deleted</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="Routes">
		<xsl:text>======================================================================================================</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Active Routes:</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text> Network Destination            Netmask          Gateway           Interface       Metric    Origin</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:apply-templates select="Route" />
		<xsl:text>======================================================================================================</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="Route">

		<xsl:choose>
			<xsl:when test="Destination/IPv4Address">
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="21 - string-length(Destination/IPv4Address)" />
				</xsl:call-template>
				<xsl:value-of select="Destination/IPv4Address" />

				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="21 - string-length(Netmask)" />
				</xsl:call-template>
				<xsl:value-of select="Netmask" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="41 - string-length(Destination/IPv6Address) - string-length(Netmask)" />
				</xsl:call-template>
				<xsl:value-of select="Destination/IPv6Address" />
				<xsl:text>/</xsl:text>
				<xsl:value-of select="Netmask" />
			</xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="Gateway/IPv4Address">
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="17 - string-length(Gateway/IPv4Address)" />
				</xsl:call-template>
				<xsl:value-of select="Gateway/IPv4Address" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="17 - string-length(Gateway/IPv6Address)" />
				</xsl:call-template>
				<xsl:value-of select="Gateway/IPv6Address" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="20-string-length(Interface)" />
		</xsl:call-template>
		<xsl:value-of select="Interface" />
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="10 - string-length(@metric)" />
		</xsl:call-template>
		<xsl:value-of select="@metric" />

		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="3" />
		</xsl:call-template>
		<xsl:value-of select="@origin" />
		
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

</xsl:transform>