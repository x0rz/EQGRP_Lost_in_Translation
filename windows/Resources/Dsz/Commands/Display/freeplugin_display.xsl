<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Freed">
		<xsl:choose>
			<xsl:when test="@loadCount != 0">
				<xsl:text>    Load count reduced to </xsl:text>
				<xsl:value-of select="@loadCount"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>    Plugin freed</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="ModuleFree">
		<xsl:text>Freeing plugin </xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text> (target=</xsl:text>
		<xsl:value-of select="@target"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
 
	<xsl:template match="Success"/>
	
</xsl:transform>