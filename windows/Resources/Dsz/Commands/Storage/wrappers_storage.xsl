<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="CommandWrappers">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Wrappers</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">WrapperType</xsl:attribute>
				<xsl:value-of select="@wrapperType"/>
			</xsl:element>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="CommandWrapper">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Wrapper</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Command</xsl:attribute>
				<xsl:value-of select="@command"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Location</xsl:attribute>
				<xsl:value-of select="@location"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Project</xsl:attribute>
				<xsl:value-of select="@project"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Script</xsl:attribute>
				<xsl:value-of select="@script"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ScriptArg</xsl:attribute>
				<xsl:value-of select="@scriptArg"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>

