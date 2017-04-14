<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Languages"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Languages">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Languages</xsl:attribute>
			<xsl:apply-templates select="LocaleLanguage"/>
			<xsl:apply-templates select="UILanguage"/>
			<xsl:apply-templates select="InstalledLanguage"/>
			<xsl:apply-templates select="OSLanguages"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="LocaleLanguage">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LocaleLanguage</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">English</xsl:attribute>
				<xsl:value-of select="English"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Native</xsl:attribute>
				<xsl:value-of select="Native"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="@value"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="UILanguage">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">UiLanguage</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">English</xsl:attribute>
				<xsl:value-of select="English"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Native</xsl:attribute>
				<xsl:value-of select="Native"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="@value"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="InstalledLanguage">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">InstalledLanguage</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">English</xsl:attribute>
				<xsl:value-of select="English"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Native</xsl:attribute>
				<xsl:value-of select="Native"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="@value"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="OSLanguages">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">OSLanguages</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">availableLanguages</xsl:attribute>
				<xsl:value-of select="@availableLanguages"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">osFile</xsl:attribute>
				<xsl:value-of select="@osFile"/>
			</xsl:element>

			<xsl:apply-templates select="OSLanguage"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="OSLanguage">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">OSLanguage</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">English</xsl:attribute>
				<xsl:value-of select="English"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Native</xsl:attribute>
				<xsl:value-of select="Native"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="@value"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
			
</xsl:transform>