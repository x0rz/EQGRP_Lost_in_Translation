<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Memory"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Memory">
	    <xsl:element name="ObjectValue">
	        <xsl:attribute name="name">MemoryItem</xsl:attribute>
	        
	        <xsl:element name="IntValue">
				<xsl:attribute name="name">physicalLoad</xsl:attribute>
				<xsl:value-of select="@physicalLoad"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">physicalAvail</xsl:attribute>
				<xsl:value-of select="Physical/@available"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">physicalTotal</xsl:attribute>
				<xsl:value-of select="Physical/@total"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">virtualAvail</xsl:attribute>
				<xsl:value-of select="Virtual/@available"/>
			</xsl:element>
	    	<xsl:element name="IntValue">
				<xsl:attribute name="name">virtualTotal</xsl:attribute>
				<xsl:value-of select="Virtual/@total"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">pageAvail</xsl:attribute>
				<xsl:value-of select="Page/@available"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">pageTotal</xsl:attribute>
				<xsl:value-of select="Page/@total"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
	
</xsl:transform>