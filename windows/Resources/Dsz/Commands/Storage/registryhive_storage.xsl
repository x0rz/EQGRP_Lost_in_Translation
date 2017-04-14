<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Hive"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Hive">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Hive</xsl:attribute>
      <xsl:element name="StringValue">
        <xsl:attribute name="name">key</xsl:attribute>
        <xsl:value-of select="@key"/>
      </xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">hive</xsl:attribute>
				<xsl:value-of select="@hive"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">srcFile</xsl:attribute>
				<xsl:value-of select="@file"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">permanent</xsl:attribute>
				<xsl:value-of select="@permanent"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
  
</xsl:transform>