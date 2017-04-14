<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="UserModified"/>
		</xsl:element>
	</xsl:template>
		

	<xsl:template match="UserModified">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Authentication</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">password</xsl:attribute>
				<xsl:text>ZAQ!nji(</xsl:text>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">username</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>	

</xsl:transform>
