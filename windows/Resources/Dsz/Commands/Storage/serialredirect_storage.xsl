<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:message>In top</xsl:message>
		
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="SerialDataWrite"/>
			<xsl:apply-templates select="SerialDataRead"/>
		</xsl:element>
		
	</xsl:template>
	
	<xsl:template match="SerialDataWrite">
		<xsl:message>In write</xsl:message>
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SerialDataWrite</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Input</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="SerialDataRead">
		<xsl:message>In read</xsl:message>
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SerialDataRead</xsl:attribute>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">Output</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>

		</xsl:element>
	</xsl:template>

</xsl:transform>