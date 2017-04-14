<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
			<xsl:apply-templates select="Hops"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Hops">
		<xsl:apply-templates select="HopInfo"/>
	</xsl:template>
	
	<xsl:template match="HopInfo">
		<xsl:element name="ObjectValue">
		<xsl:attribute name="name">HopInfo</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Hop</xsl:attribute>
				<xsl:value-of select="HopNumber"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Time</xsl:attribute>
				<xsl:variable name="min_to_ms" select="number(substring-before(substring-after(TripTime, 'H'), 'M'))*(60000)"/>
				<xsl:variable name="s_to_ms" select="number(substring-before(substring-after(TripTime, 'M'), '.'))*(1000)"/>
				<xsl:variable name="ns_to_ms" select="number(substring(substring-after(TripTime, '.'), 1, 3))"/>
				<xsl:variable name="ms" select="number($min_to_ms + $s_to_ms + $ns_to_ms)"/>
				<xsl:value-of select="$ms"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Host</xsl:attribute>
				<xsl:value-of select="Host"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>
