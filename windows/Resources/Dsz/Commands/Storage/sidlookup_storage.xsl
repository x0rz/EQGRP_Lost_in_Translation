<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Sid"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Sid">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Sid</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="Id"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>