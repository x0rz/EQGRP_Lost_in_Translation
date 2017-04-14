<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Throttle"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Throttle">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ThrottleItem</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Address</xsl:attribute>
				<xsl:value-of select="@addr"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">BytesPerSecond</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Enabled</xsl:attribute>
				<xsl:choose>
					<xsl:when test="number(.) = 0">
						<xsl:text>false</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>true</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>

