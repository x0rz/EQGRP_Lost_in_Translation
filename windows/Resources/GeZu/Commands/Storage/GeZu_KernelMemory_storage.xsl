<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
		<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="GeZu_KernelMemoryResponse"/>
		</xsl:element>
	</xsl:template>
	
		
	<xsl:template match="GeZu_KernelMemoryResponse">
		<xsl:element name="StringValue">
			<xsl:attribute name="name">MemDump</xsl:attribute>
			<xsl:value-of select="MemDump" />
		</xsl:element>	
	</xsl:template>
	
	
	
</xsl:transform>