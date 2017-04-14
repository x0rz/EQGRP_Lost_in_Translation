<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Results">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">MatchFileTimesResults</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SourceFile</xsl:attribute>
				<xsl:value-of select="Src"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">DestFile</xsl:attribute>
				<xsl:value-of select="Dst"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>