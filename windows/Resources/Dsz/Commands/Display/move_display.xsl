<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>

	<xsl:template match="Results">
		<xsl:text>Src File : </xsl:text>
		<xsl:value-of select="Source"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Dst File : </xsl:text>
		<xsl:value-of select="Destination"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>