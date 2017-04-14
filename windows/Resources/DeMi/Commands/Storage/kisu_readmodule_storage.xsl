<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="KiSuReadModuleSuccess"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="KiSuReadModuleSuccess">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Module</xsl:attribute>

			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>

			<xsl:element name="IntValue">
				<xsl:attribute name="name">Instance</xsl:attribute>
				<xsl:value-of select="@instance"/>
			</xsl:element>

			<xsl:element name="IntValue">
				<xsl:attribute name="name">Size</xsl:attribute>
				<xsl:value-of select="@bytes"/>
			</xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">Module</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>