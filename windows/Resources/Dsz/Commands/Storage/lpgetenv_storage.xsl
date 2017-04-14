<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Environment" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Environment">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">EnvItem</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">address</xsl:attribute>
				<xsl:value-of select="@address"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">option</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="Value"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">system</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Static">
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