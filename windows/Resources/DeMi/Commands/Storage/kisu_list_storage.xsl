<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="KiSuEnumeration"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="KiSuEnumeration">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Enumeration</xsl:attribute>

			<xsl:for-each select="KiSu">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Item</xsl:attribute>

					<xsl:element name="IntValue">
						<xsl:attribute name="name">Id</xsl:attribute>
						<xsl:value-of select="@id"/>
					</xsl:element>

					<xsl:element name="StringValue">
						<xsl:attribute name="name">Name</xsl:attribute>
						<xsl:value-of select="@name"/>
					</xsl:element>

					<xsl:element name="IntValue">
						<xsl:attribute name="name">VersionMajor</xsl:attribute>
						<xsl:value-of select="@versionMajor"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">VersionMinor</xsl:attribute>
						<xsl:value-of select="@versionMinor"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">VersionFix</xsl:attribute>
						<xsl:value-of select="@versionFix"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">VersionBuild</xsl:attribute>
						<xsl:value-of select="@versionBuild"/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>

		</xsl:element>
	</xsl:template>

</xsl:transform>