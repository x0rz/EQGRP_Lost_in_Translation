<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="UserAlias" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="UserAlias">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">AliasItem</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">alias</xsl:attribute>
				<xsl:value-of select="@original"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">replace</xsl:attribute>
				<xsl:value-of select="@replace"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">location</xsl:attribute>
				<xsl:value-of select="@location"/>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Options</xsl:attribute>
				<xsl:for-each select="Option">
					<xsl:element name="StringValue">
						<xsl:attribute name="name">option</xsl:attribute>
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>