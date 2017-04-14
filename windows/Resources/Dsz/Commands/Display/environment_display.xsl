<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Environment">
		<xsl:apply-templates select="Value"/>
	</xsl:template>
	
	<xsl:template match="Value">
		<xsl:choose>
			<xsl:when test="../@action = 'DELETE'">
				<xsl:text>Deleted '</xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>'</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@name"/>
				<xsl:text>=</xsl:text>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>