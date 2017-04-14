<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Activity"/>
			<xsl:apply-templates select="NewActivity"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Activity">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LastActivity</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">days</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(Last, 'P'), 'D')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">hours</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(Last, 'T'), 'H')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">minutes</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(Last, 'H'), 'M')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">seconds</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(Last, 'M'), '.')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="NewActivity">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">NewActivity</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="Last/@type"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">typeValue</xsl:attribute>
				<xsl:value-of select="Last/@typeValue"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">days</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(Last, 'P'), 'D')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">hours</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(Last, 'T'), 'H')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">minutes</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(Last, 'H'), 'M')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">seconds</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(Last, 'M'), '.')"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">nanos</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(Last, '.'), 'S')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>