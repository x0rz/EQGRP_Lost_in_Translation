<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="LdapEntries">
		<xsl:apply-templates select="LdapEntry"/>
  	</xsl:template>

	<xsl:template match="LdapEntry">
		<xsl:text>----------------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Attribute"/>
  	</xsl:template>
	
	<xsl:template match="Attribute">
		<xsl:value-of select="Type"/>
		<xsl:text>: </xsl:text>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="30 - string-length(Type)"/>
		</xsl:call-template>
		<xsl:value-of select="Value"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>