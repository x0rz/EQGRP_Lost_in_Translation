<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="KiSuModuleLoad">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LoadModule</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Handle</xsl:attribute>
				<xsl:value-of select="@moduleHandle"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="@moduleId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Instance</xsl:attribute>
				<xsl:value-of select="@instance"/>
			</xsl:element>
		</xsl:element>

	</xsl:template>

</xsl:transform>