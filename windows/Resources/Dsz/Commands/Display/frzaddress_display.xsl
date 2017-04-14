<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="FrzAddressActionCompleted">
		<xsl:text>Action completed</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="FrzAddresses">
		<xsl:text>Found </xsl:text>
		<xsl:value-of select="@numAddresses"/>
		<xsl:text> Addresses : </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Address"/>
	</xsl:template>

	<xsl:template match="Address">
		<xsl:text>    </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
 
</xsl:transform>