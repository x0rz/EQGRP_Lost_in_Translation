<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Process"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="Process">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Process</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>