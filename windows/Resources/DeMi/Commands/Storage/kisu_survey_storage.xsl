<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="KiSuSurveyPersistence"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="KiSuSurveyPersistence">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Persistence</xsl:attribute>

			<xsl:for-each select="Method">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Method</xsl:attribute>

					<xsl:element name="StringValue">
						<xsl:attribute name="name">Type</xsl:attribute>
						<xsl:value-of select="Type"/>
					</xsl:element>
					<xsl:element name="BoolValue">
						<xsl:attribute name="name">Compatible</xsl:attribute>
						<xsl:value-of select="Compatible"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Reason</xsl:attribute>
						<xsl:value-of select="Reason"/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>

		</xsl:element>
	</xsl:template>

</xsl:transform>