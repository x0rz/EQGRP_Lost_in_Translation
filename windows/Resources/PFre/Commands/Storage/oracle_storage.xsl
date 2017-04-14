<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="PassFreelyMemCheck"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="PassFreelyMemCheck">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">MemCheck</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">filename</xsl:attribute>
				<xsl:call-template name="last-filename">
					<xsl:with-param name="input" select="." />
				</xsl:call-template>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template name="last-filename">
		<xsl:param name="input" />

		<xsl:choose>
			<xsl:when test="contains($input, 'Filename = ')">
				<xsl:call-template name="last-filename">
					<xsl:with-param name="input" select="substring-after($input, 'Filename = ')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before($input, '&#x0A;')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:transform>