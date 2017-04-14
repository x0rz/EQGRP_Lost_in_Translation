<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="TargetDir"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="TargetDir"> 
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">TargetDirectory</xsl:attribute>
				
			<xsl:element name="StringValue">
				<xsl:attribute name="name">path</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>