<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Drives/Drive"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Drive">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Drive</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">free</xsl:attribute>
				<xsl:value-of select="@free"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">available</xsl:attribute>
				<xsl:value-of select="@available"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">total</xsl:attribute>
				<xsl:value-of select="@total"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">path</xsl:attribute>
				<xsl:value-of select="@path"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">low_diskspace</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@free &lt; (40 * 1024 * 1024)">
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