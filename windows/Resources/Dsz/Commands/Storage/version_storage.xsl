<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="/Version"> 
		<xsl:element name="ObjectValue">
		<xsl:attribute name="name">VersionItem</xsl:attribute>
			<xsl:apply-templates select="ListeningPost"/>
			<xsl:apply-templates select="Implant"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ListeningPost">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ListeningPost</xsl:attribute>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Compiled</xsl:attribute>
				<xsl:call-template name="StoreVersion">
					<xsl:with-param name="element" select="Compiled"/>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Base</xsl:attribute>
				<xsl:call-template name="StoreVersion">
					<xsl:with-param name="element" select="Base"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Implant">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Implant</xsl:attribute>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Compiled</xsl:attribute>
				<xsl:call-template name="StoreVersion">
					<xsl:with-param name="element" select="Compiled"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="StoreVersion">
		<xsl:param name="element"/>
		<xsl:element name="IntValue">
			<xsl:attribute name="name">major</xsl:attribute>
			<xsl:value-of select="$element/@major"/>
		</xsl:element>
		<xsl:element name="IntValue">
			<xsl:attribute name="name">minor</xsl:attribute>
			<xsl:value-of select="$element/@minor"/>
		</xsl:element>
		<xsl:element name="IntValue">
			<xsl:attribute name="name">fix</xsl:attribute>
			<xsl:value-of select="$element/@fix"/>
		</xsl:element>
		<xsl:if test="$element/@build">
			<xsl:element name="IntValue">
				<xsl:attribute name="name">build</xsl:attribute>
				<xsl:value-of select="$element/@build"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length($element/.) != 0">
			<xsl:element name="StringValue">
				<xsl:attribute name="name">description</xsl:attribute>
				<xsl:value-of select="$element/."/>
			</xsl:element>
		</xsl:if>
	</xsl:template>

</xsl:transform>

