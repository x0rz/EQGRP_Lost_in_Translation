<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="RemoteProcess">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">RemoteExecution</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">returnValue</xsl:attribute>
				<xsl:value-of select="RetVal"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">processId</xsl:attribute>
				<xsl:value-of select="Id"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>